---
id: phase0-subprocess-capture-status-and-pipe-gap
title: Phase0 subprocess capture loses signal failures and can block on stderr
answers:
  - can Phase0 subprocess helpers report a signalled child as successful
  - can Phase0 subprocess capture deadlock on large stderr
  - which tasks own Phase0 subprocess status and pipe draining
  - were controlled pipe timeout children reaped during the Phase0 diagnosis
date: 2026-09-21
status: confirmed harness defects; .2.16.1 and .2.16.2 repairs retain prerequisites
tags: [perl, phase0, subprocess, signals, pipes, conformance]
evidence: "CONFORMANCE-SOURCE-READING.1.82 at dc88fc1397b01a6dadb7b2d8a8cbf91b2169e1e0. Forty-eight source-extracted controls cover four helpers, six child outcomes and original/guard variants. Original SIGTERM becomes status zero; stderr-first and interleaved large output time out. All eight timed-out owned children are terminated and reaped. In-memory status/multiplex guards distinguish the outcomes; no tracked implementation is changed."
reverify: "Run PHASE0_PROCESS_CAPTURE below. Exact helper hash fails closed after source changes; use completed repair evidence rather than expecting the old defects forever."
---

## Mechanism and bounded evidence

Four helpers in `t/phase0_regression.t` use the same capture/status pattern:
`run_get_parser_in_subprocess`, `run_parser_invocation_in_subprocess`,
`run_perl_snippet_in_subprocess`, and `run_perl_test_file_in_subprocess`.
They drain stdout to EOF before reading stderr, then return only `$? >> 8`.

The exact helper bodies are extracted unchanged. Only their open3 child command
is replaced with owned test programs. Ordinary success and exit 7 retain output
and status, but SIGTERM produces reported status zero because its signal bits
are discarded. Large stderr before stdout and interleaved writes block: the child
waits for its stderr pipe to drain while the parent waits for stdout EOF.
A two-second owned-child alarm terminates and reaps each blocked child.

| Controlled child | Original helpers | In-memory guard controls |
| --- | --- | --- |
| Exit 0 / exit 7 | Correct status and small output | Preserved |
| SIGTERM | Incorrect status 0 | Status 143 |
| 262,144 stderr bytes before stdout | Timeout, child reaped | Completes; expected byte counts |
| 262,144 stdout bytes before stderr | Completes | Completes |
| Interleaved 4,096-byte writes | Timeout, child reaped | Completes; expected byte counts |

All 48 expected-outcome controls pass. The eight timeout children are reaped;
no real parser, verifier or CI child is signalled. Small output text is checked
exactly; large-output controls check stream byte counts. No actual historical
false-green CI run is established. The guard is diagnostic scratch code, not a
landed repair or a tested wait-failure policy.

`.2.16.1` owns valid wait/normal-exit and signal handling; `.2.16.2` owns concurrent
drainage, exact large-output regression and bounded cleanup. Both require the
remaining source/book/policy reading. Startup `.79` owns the separate routing
verifier's established signal-status defect; source access does not combine their
implementation scopes. Existing parser markers and staged-AST consumer plans
must remain checked alongside improved process status.

## Source-pinned reproduction

```bash
bash tools/project_data_run.sh python3 - <<'PHASE0_PROCESS_CAPTURE'
from pathlib import Path
import hashlib, json, re, subprocess

work = Path('.linkedspec-data/scratch/phase0-process-capture-reverify')
work.mkdir(parents=True, exist_ok=True)
source = Path('t/phase0_regression.t').read_text()
names = ['run_get_parser_in_subprocess', 'run_parser_invocation_in_subprocess',
         'run_perl_snippet_in_subprocess', 'run_perl_test_file_in_subprocess']
bodies = []
for name in names:
    match = re.search(r'^sub ' + name + r' \{\n.*?(?=^sub |\Z)', source, re.M | re.S)
    assert match, name
    bodies.append(match[0])
original = ''.join(bodies)
assert hashlib.sha256(original.encode()).hexdigest() == 'a638c9a84a940b64e62df60fe070e7cf3029e35f8506702329ff70fabe19de86'
old_drain = '    $out .= $_ while <$out_fh>;\n    $err .= $_ while <$err_fh>;'
assert original.count(old_drain) == 4
assert original.count('my $exit_code = $? >> 8;') == 4
prefix = r'''
use strict;
use warnings;
use IPC::Open3 ();
use IO::Select ();
use Symbol qw(gensym);
use JSON::PP ();
use Cwd qw(abs_path);
my $Bin = abs_path('t');
our ($MODE, $CHILD_PID);
sub open3 {
    my %program = (
        success => '$|=1; print STDOUT "out\n"; print STDERR "err\n"; exit 0',
        exit7 => '$|=1; print STDOUT "out\n"; print STDERR "err\n"; exit 7',
        signal15 => '$|=1; print STDOUT "out\n"; print STDERR "err\n"; kill 15, $$; exit 99',
        large_stderr => 'print STDERR "E" x 262144; print STDOUT "OUT\n";',
        large_stdout => 'print STDOUT "O" x 262144; print STDERR "ERR\n";',
        interleaved => '$|=1; for (1..64) { print STDERR "E" x 4096; print STDOUT "O" x 4096 }',
    );
    $CHILD_PID = IPC::Open3::open3($_[0], $_[1], $_[2], $^X, '-e', $program{$MODE});
    return $CHILD_PID;
}
'''
suffix = r'''
my @helpers = (
    ['run_get_parser_in_subprocess', sub { run_get_parser_in_subprocess('owned-probe') }],
    ['run_parser_invocation_in_subprocess', sub { run_parser_invocation_in_subprocess('owned-probe', 'x') }],
    ['run_perl_snippet_in_subprocess', sub { run_perl_snippet_in_subprocess('owned-probe') }],
    ['run_perl_test_file_in_subprocess', sub { run_perl_test_file_in_subprocess('owned-probe') }],
);
for my $helper (@helpers) {
    for my $mode (qw(success exit7 signal15 large_stderr large_stdout interleaved)) {
        $MODE = $mode;
        $CHILD_PID = undef;
        my ($reaped, @result) = (0);
        my $ok = eval {
            local $SIG{ALRM} = sub {
                die "no owned child\n" unless defined $CHILD_PID;
                kill 'TERM', $CHILD_PID;
                $reaped = waitpid($CHILD_PID, 0) == $CHILD_PID ? 1 : 0;
                $CHILD_PID = undef;
                die "OWNED_PIPE_TIMEOUT\n";
            };
            alarm 2;
            @result = $helper->[1]->();
            alarm 0;
            $CHILD_PID = undef;
            1;
        };
        alarm 0;
        my $error = $@;
        die $error if !$ok && $error ne "OWNED_PIPE_TIMEOUT\n";
        print JSON::PP->new->canonical->encode({
            helper => $helper->[0], mode => $mode, timed_out => $ok ? 0 : 1,
            timeout_child_reaped => $reaped,
            status => $ok ? $result[0] : undef,
            stdout_bytes => $ok ? length($result[1]) : undef,
            stderr_bytes => $ok ? length($result[2]) : undef,
            stdout => $ok && $mode =~ /^(?:success|exit7|signal15)$/ ? $result[1] : undef,
            stderr => $ok && $mode =~ /^(?:success|exit7|signal15)$/ ? $result[2] : undef,
        }), "\n";
    }
}
'''
new_drain = r'''    my $ready = IO::Select->new($out_fh, $err_fh);
    my $out_fd = fileno($out_fh);
    while ($ready->count) {
        for my $fh ($ready->can_read) {
            my $bytes = sysread($fh, my $buffer, 65536);
            die "read: $!" unless defined $bytes;
            if (!$bytes) { $ready->remove($fh); next; }
            if (fileno($fh) == $out_fd) { $out .= $buffer; }
            else { $err .= $buffer; }
        }
    }'''
results = {}
for variant in ['original', 'guard_control']:
    body = original
    if variant == 'guard_control':
        body = body.replace(old_drain, new_drain)
        body = body.replace('my $exit_code = $? >> 8;',
                            'my $exit_code = ($? & 127) ? 128 + ($? & 127) : ($? >> 8);')
    path = work / (variant + '.pl')
    path.write_text(prefix + body + suffix)
    result = subprocess.run(['perl', str(path)], capture_output=True, text=True, timeout=45)
    (work / (variant + '.log')).write_text(result.stdout + result.stderr)
    assert result.returncode == 0 and result.stderr == '', (variant, result.returncode, result.stderr)
    rows = [json.loads(line) for line in result.stdout.splitlines()]
    assert len(rows) == 24
    for row in rows:
        mode = row['mode']
        timeout = variant == 'original' and mode in ['large_stderr', 'interleaved']
        assert row['timed_out'] == int(timeout), (variant, row)
        if timeout:
            assert row['timeout_child_reaped'] == 1, row
        else:
            expected_status = 7 if mode == 'exit7' else (143 if mode == 'signal15' and variant == 'guard_control' else 0)
            assert row['status'] == expected_status, (variant, row)
            if mode in ['success', 'exit7', 'signal15']:
                assert (row['stdout'], row['stderr']) == ('out\n', 'err\n'), row
            else:
                expected_sizes = {'large_stderr': (4, 262144), 'large_stdout': (262144, 4), 'interleaved': (262144, 262144)}
                assert (row['stdout_bytes'], row['stderr_bytes']) == expected_sizes[mode], row
    results[variant] = rows
    print(variant, 'PASS 24 expected outcome controls', flush=True)
proof = dict(status='PASS', helper_sha256=hashlib.sha256(original.encode()).hexdigest(),
             controls=48, timeout_children_reaped=8, source_helpers=names, results=results)
(work / 'proof.json').write_text(json.dumps(proof, indent=2) + '\n')
print(json.dumps({k:v for k,v in proof.items() if k != 'results'}, indent=2))
PHASE0_PROCESS_CAPTURE
```

Related: [[routing-verifier-child-signal-status-gap]],
[[conformance-perl-consumer-reading]].
