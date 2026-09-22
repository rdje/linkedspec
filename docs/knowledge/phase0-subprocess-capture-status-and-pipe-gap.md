---
id: phase0-subprocess-capture-status-and-pipe-gap
title: Phase0 subprocess capture loses signal failures and can block on stderr
answers:
  - can Phase0 subprocess helpers report a signalled child as successful
  - can Phase0 subprocess capture deadlock on large stderr
  - which tasks own Phase0 subprocess status and pipe draining
  - were controlled pipe timeout children reaped during the Phase0 diagnosis
  - does the repeated-action CLI test helper lose signals or block on stderr
  - does the rule-local cursor CLI consumer share the subprocess status and pipe defects
  - do Perl trace test subprocess helpers lose signals and block on stderr
date: 2026-09-22
status: confirmed harness defects; .2.16.1 and .2.16.2 repairs retain prerequisites
tags: [perl, phase0, subprocess, signals, pipes, conformance]
evidence: "CONFORMANCE-SOURCE-READING.1.82 at dc88fc1397b01a6dadb7b2d8a8cbf91b2169e1e0. Forty-eight source-extracted controls cover four helpers, six child outcomes and original/guard variants. Original SIGTERM becomes status zero; stderr-first and interleaved large output time out. All eight timed-out owned children are terminated and reaped. In-memory status/multiplex guards distinguish the outcomes; no tracked implementation is changed."
reverify: "Run PHASE0_PROCESS_CAPTURE below. Exact helper hash fails closed after source changes; use completed repair evidence rather than expecting the old defects forever."
evidence_group84: "At 4480cc52, the repeated-action run_primary_command helper reproduces the same two defects in 12 controlled outcomes. Original SIGTERM reports 0, stderr-first/interleaved output time out, both owned children are reaped, and in-memory guards preserve exit7 and output while reporting 143 for SIGTERM. Existing .2.16 children own this fifth helper; no source repair or historical false-green run is claimed."
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

## September 22 repeated-action consumer extension

The fully read `t/repeated_action_result_perl_contract.t` uses the same pattern in
`run_primary_command`. Its ordinary ten roles pass 122 nested assertions, including
exact CLI JSON and empty stderr, but those small-output successes do not cover
process failure or pipe saturation. Twelve original/guard controls reproduce the
same results as above for this fifth helper, with both timeout children reaped.
Repairs `.2.16.1` and `.2.16.2` now include it; required reading still gates repair.

This replay reuses the unchanged six owned programs, cleanup and output assertions
from PHASE0_PROCESS_CAPTURE, substituting the exact source-pinned fifth helper and
its variable names. It executes no parser/CI child and changes no tracked source.

```bash
bash tools/project_data_run.sh python3 - <<'REPEATED_PROCESS_CAPTURE'
from pathlib import Path
import re

card = Path('docs/knowledge/phase0-subprocess-capture-status-and-pipe-gap.md').read_text()
recipe = card.split("<<'PHASE0_PROCESS_CAPTURE'\n", 1)[1].split('\nPHASE0_PROCESS_CAPTURE', 1)[0]
start = recipe.index('source = Path(')
end = recipe.index("prefix = r'''")
recipe = recipe[:start] + '''source = Path('t/repeated_action_result_perl_contract.t').read_text()
names = ['run_primary_command']
original = re.search(r'^sub run_primary_command \\{\\n.*?(?=^sub role_neutral_contract)', source, re.M | re.S)[0]
assert hashlib.sha256(original.encode()).hexdigest() == '12cf5ab78452ca09866b313e17be72e0c50b7fa7ca9e919a3261d2183cee51c9'
old_drain = " my $stdout = do { local $/; <$stdout_fh> } // '';\\n my $stderr = do { local $/; <$stderr_fh> } // '';"
assert original.count(old_drain) == 1
assert original.count('return ($? >> 8, $stdout, $stderr)') == 1
''' + recipe[end:]
recipe = recipe.replace('phase0-process-capture-reverify', 'repeated-process-capture-reverify')
start = recipe.index('my @helpers = (')
end = recipe.index('\nfor my $helper', start)
recipe = recipe[:start] + "my @helpers = (['run_primary_command', sub { run_primary_command('owned-probe') }]);" + recipe[end:]
start = recipe.index("new_drain = r'''")
end = recipe.index('\nresults = {}', start)
drain = recipe[start:end].replace('$out_fh', '$stdout_fh').replace('$err_fh', '$stderr_fh')
drain = drain.replace('$out .=', '$stdout .=').replace('$err .=', '$stderr .=')
drain = drain.replace("new_drain = r'''", "new_drain = r''' my ($stdout, $stderr) = ('', '');\n")
recipe = recipe[:start] + drain + recipe[end:]
old = "body.replace('my $exit_code = $? >> 8;',\n                            'my $exit_code = ($? & 127) ? 128 + ($? & 127) : ($? >> 8);')"
new = "body.replace('return ($? >> 8, $stdout, $stderr)',\n                            'return (($? & 127) ? 128 + ($? & 127) : ($? >> 8), $stdout, $stderr)')"
assert recipe.count(old) == 1
recipe = recipe.replace(old, new)
for old, new in [('len(rows) == 24', 'len(rows) == 6'),
                 ('PASS 24 expected outcome controls', 'PASS 6 expected outcome controls'),
                 ('controls=48, timeout_children_reaped=8', 'controls=12, timeout_children_reaped=2')]:
    assert recipe.count(old) == 1
    recipe = recipe.replace(old, new)
exec(compile(recipe, 'repeated-process-capture-reverify', 'exec'))
REPEATED_PROCESS_CAPTURE
```

## September 22 cursor CLI consumer extension

`t/rule_local_cursor_perl_contract.t::run_primary_command` is the byte-identical
sixth helper: SHA-256 12cf5ab78452ca09866b313e17be72e0c50b7fa7ca9e919a3261d2183cee51c9.
Twelve fresh controls reproduce the same defects and guard outcomes; both timeout
children are reaped. Existing `.2.16.1/.2.16.2` now include this consumer, retaining
its complete 14-role admission and all required reading prerequisites.

```bash
bash tools/project_data_run.sh python3 - <<'CURSOR_PROCESS_CAPTURE'
from pathlib import Path
card = Path('docs/knowledge/phase0-subprocess-capture-status-and-pipe-gap.md').read_text()
code = card.split("<<'REPEATED_PROCESS_CAPTURE'\n", 1)[1].split('\nREPEATED_PROCESS_CAPTURE', 1)[0]
assert code.count('t/repeated_action_result_perl_contract.t') == 1
assert code.count('^sub role_neutral_contract') == 1
code = code.replace('t/repeated_action_result_perl_contract.t', 't/rule_local_cursor_perl_contract.t')
code = code.replace('^sub role_neutral_contract', '^sub parsed_rule_ir')
code = code.replace('repeated-process-capture-reverify', 'cursor-process-capture-reverify')
exec(compile(code, 'cursor-process-capture-reverify', 'exec'))
CURSOR_PROCESS_CAPTURE
```

## September 22 trace-consumer extension

Reading .1.88 completes the three ActionIR trace consumers and the CLI prefix
through its complete _run_cmd helper. Their four helpers reproduce the same
status and pipe defects in 48 controlled outcomes; all eight timeout children
are reaped. The three _run_perl_snippet bodies are byte-identical; the recipe
pins their hash and the separate CLI helper hash. Existing .2.16.1/.2.16.2 now
own ten helpers. Preserve cold-process marker/status/stderr assertions, retain
all prerequisites, and read the CLI test suffix before implementing repairs.
No original parser or CI child is signalled and no historical false-green run
is inferred. The initial scratch recipe extraction targeted the wrapper rather
than the base recipe and failed before launching children; the corrected replay
extracts the base PHASE0_PROCESS_CAPTURE scaffold and passes all controls.

```bash
bash tools/project_data_run.sh python3 - <<'TRACE_PROCESS_CAPTURE'
from pathlib import Path
import hashlib, json, re, subprocess

card = Path('docs/knowledge/phase0-subprocess-capture-status-and-pipe-gap.md').read_text()
recipe = card.split("<<'PHASE0_PROCESS_CAPTURE'\n", 1)[1].split('\nPHASE0_PROCESS_CAPTURE', 1)[0]
prefix = recipe.split("prefix = r'''", 1)[1].split("'''", 1)[0]
prefix += '\nuse File::Spec;\nuse File::Basename qw(dirname);\n'
suffix_template = recipe.split("suffix = r'''", 1)[1].split("'''", 1)[0]
sources = [
 ('t/trace_actionir_compact_lowerers.t', '_run_perl_snippet', 'fced4162bfd99d0d567ae7b83d8acf3a3a0e313c1b4e355e33c838ae3afedccd'),
 ('t/trace_actionir_method_lowering.t', '_run_perl_snippet', 'fced4162bfd99d0d567ae7b83d8acf3a3a0e313c1b4e355e33c838ae3afedccd'),
 ('t/trace_actionir_pipeline.t', '_run_perl_snippet', 'fced4162bfd99d0d567ae7b83d8acf3a3a0e313c1b4e355e33c838ae3afedccd'),
 ('t/trace_cli.t', '_run_cmd', '3ff15df3fd15e2cb6f101a67a73ff79a70dda22877f36a8b23e40929f4be8454'),
]
work = Path('.linkedspec-data/scratch/trace-process-capture-reverify')
work.mkdir(parents=True, exist_ok=True)
all_results = []
for source_path, helper, digest in sources:
 original = re.search(r'^sub '+helper+r' \{\n.*?^}\n', Path(source_path).read_text(), re.M | re.S)[0]
 assert hashlib.sha256(original.encode()).hexdigest() == digest
 out_var, out_handle = ('out', 'out_fh') if helper == '_run_perl_snippet' else ('stdout', 'out')
 old_drain = ' my ($'+out_var+', $stderr);\n {\n  local $/;\n  $'+out_var+' = <$'+out_handle+'>;\n }\n {\n  local $/;\n  $stderr = <$err>;\n }'
 assert original.count(old_drain) == 1
 new_drain = ''' my ($OUTPUT, $stderr) = ('', '');
 my $ready = IO::Select->new($HANDLE, $err);
 my $out_fd = fileno($HANDLE);
 while ($ready->count) {
  for my $fh ($ready->can_read) {
   my $bytes = sysread($fh, my $buffer, 65536);
   die "read: $!" unless defined $bytes;
   if (!$bytes) { $ready->remove($fh); next; }
   if (fileno($fh) == $out_fd) { $OUTPUT .= $buffer; }
   else { $stderr .= $buffer; }
  }
 }'''.replace('$OUTPUT', '$'+out_var).replace('$HANDLE', '$'+out_handle)
 helper_start = suffix_template.index('my @helpers = (')
 helper_end = suffix_template.index('\nfor my $helper', helper_start)
 suffix = suffix_template[:helper_start]+"my @helpers = (['"+helper+"', sub { "+helper+"('owned-probe') }]);"+suffix_template[helper_end:]
 for variant in ['original', 'guard_control']:
  body = original
  if variant == 'guard_control':
   body = body.replace(old_drain, new_drain)
   assert body.count('$? >> 8') == 1
   body = body.replace('$? >> 8', '(($? & 127) ? 128 + ($? & 127) : ($? >> 8))')
  name = Path(source_path).stem+'-'+variant
  probe = work/(name+'.pl');probe.write_text(prefix+body+suffix)
  result = subprocess.run(['perl',str(probe)],capture_output=True,text=True,timeout=45)
  (work/(name+'.log')).write_text(result.stdout+result.stderr)
  assert result.returncode == 0 and result.stderr == '', (name,result.returncode,result.stderr)
  rows = [json.loads(line) for line in result.stdout.splitlines()];assert len(rows)==6
  for row in rows:
   mode=row['mode'];timeout=variant=='original' and mode in ['large_stderr','interleaved']
   assert row['timed_out']==int(timeout),(name,row)
   if timeout:
    assert row['timeout_child_reaped']==1,row
   else:
    status=7 if mode=='exit7' else (143 if mode=='signal15' and variant=='guard_control' else 0)
    assert row['status']==status,(name,row)
    if mode in ['success','exit7','signal15']:
     assert (row['stdout'],row['stderr'])==('out\n','err\n'),row
    else:
     sizes={'large_stderr':(4,262144),'large_stdout':(262144,4),'interleaved':(262144,262144)}
     assert (row['stdout_bytes'],row['stderr_bytes'])==sizes[mode],row
  all_results.append(dict(source=source_path,helper=helper,sha256=digest,variant=variant,results=rows))
  print(name,'PASS 6 controls',flush=True)
proof=dict(controls=48,timeout_children_reaped=8,source_helpers=4,results=all_results)
(work/'proof.json').write_text(json.dumps(proof,indent=2)+'\n')
print('PASS 48 trace-helper outcome controls; all 8 timed-out owned children reaped.')
TRACE_PROCESS_CAPTURE
```
