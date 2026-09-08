---
id: routing-verifier-child-signal-status-gap
title: Routing enforcement discards child signal status and can accept a terminated verifier
answers:
  - "does routing pressure enforcement reject a signal-terminated child"
  - "can the README routing checker accept a killed verifier"
  - "which task owns routing verifier child status handling"
  - "does the routing Git helper preserve signal termination"
  - "are document history child status helpers affected by the routing defect"
date: 2026-09-08
status: confirmed defect; repair pending under SESSION-STARTUP-READING.79
tags: [verification, doctrine, readme, process-status, diagnostics, startup-reading]
evidence: "Checkpoint .3.3.62 reverified the frozen .3.3.61 controls, which extracted the unchanged git_capture and run_fixed_verifier helpers from scripts/check_readme_routing_pressure.pl. Twelve child controls compare the original source with an in-memory guard: success and exit 7 behave correctly, but SIGTERM becomes zero and the original fixed verifier returns success. The guard rejects the signal and maps the Git result to 143. Nine separate document-history controls reject ordinary and signal failures correctly. No actual Git or doctrine child was signalled, and no particular CI run is shown to have suffered this failure."
reverify: "Run the source-pinned managed reproduction below; SESSION-STARTUP-READING.79 owns production repair and recurrence."
---

# A shifted exit byte is insufficient evidence of child success

At the inspected source boundary, both `git_capture` and `run_fixed_verifier`
wait for their child but interpret only `$? >> 8`. That discards the low signal
bits. A child terminated by SIGTERM therefore appears to have ordinary exit code zero.

| Child outcome | Current fixed verifier | Current Git helper status | In-memory guard control |
| --- | --- | --- | --- |
| Normal exit 0 | Accepts | 0 | Accepts; Git status 0 |
| Normal exit 7 | Rejects; one error | 7 | Rejects; Git status 7 |
| SIGTERM | **Accepts** | **0** | Rejects; Git status 143 |

The reproduction extracts the exact helper bodies and substitutes only their
`open3` command target with an owned, self-contained Perl child. It runs both
original and guarded versions against all three outcomes, reaps every child and
removes its managed scratch workspace. These controls demonstrate the helper
defect, not an actual interrupted Git command or a false receipt from a particular
canonical run. The guard is a counterfactual control, not a landed repair.

A direct `$? >> 8` spelling census of Perl/shell sources in `scripts/`,
`tools/` and `knowledge-map/` found only these two sites. That census does
not cover variable-mediated shifts or every subprocess implementation. Separately,
the three source-extracted document-history helpers check pipe close success:
nine success/exit 7/SIGTERM controls retain successful stdout, preserve child stderr,
and reject failures (the optional Git helper returns undef). Their exact executable
control and source hashes are retained in the .3.3.61 commit evidence (64d82792).

Repair .79 must require a valid wait result and successful normal termination,
retain useful stdout/stderr and ordinary failure diagnostics, audit analogous
captured-process helpers, and prove real verifier integration plus canonical CI.
Its implementation remains gated by startup .3/.4/.5.

## Source-pinned reproduction

The whole-source and helper hashes deliberately fail closed after an owner change;
update this dated fact with the completed repair rather than silently treating its
old defect expectations as current.

```sh
bash tools/project_data_run.sh python3 -W error - <<'PY'
from pathlib import Path
import hashlib, json, os, re, subprocess, tempfile

owner = Path("scripts/check_readme_routing_pressure.pl")
source = owner.read_text()
source_hash = hashlib.sha256(owner.read_bytes()).hexdigest()
assert source_hash == "c764d2f626bfb14db1919dc4af85827c61deec0c5fa98bb9e5aae354b7dfc083"
git_body = source[source.index("sub git_capture {"):source.index("sub git_ok {")]
verifier_body = source[source.index("sub run_fixed_verifier {"):source.index("sub canonical_object {")]
assert hashlib.sha256(git_body.encode()).hexdigest() == "ccbc00bd1aabb09e83bdb55d8b341cd8080f320c8af991b053def449adb6d42d"
assert hashlib.sha256(verifier_body.encode()).hexdigest() == "52981fa1ce9952e5ff160ed7a4181854cfea113d111efd35ff256c96af311acf"
prefix = r'''
use strict;
use warnings;
use IPC::Open3 ();
use Symbol qw(gensym);
use JSON::PP ();
our $MODE;
my @errors;
sub problem { push @errors, $_[0]; }
sub open3 {
    my $program = $MODE eq 'success' ? 'exit 0'
        : $MODE eq 'exit7' ? 'exit 7'
        : 'kill 15, $$; exit 99';
    return IPC::Open3::open3($_[0], $_[1], $_[2], $^X, '-e', $program);
}
'''
suffix = r'''
for my $mode (qw(success exit7 signal15)) {
    $MODE = $mode;
    @errors = ();
    my $accepted = run_fixed_verifier({ id => 'probe', verifier => 'knowledge_map' });
    my ($status, $stdout, $stderr) = git_capture('status');
    print JSON::PP->new->canonical->encode({
        mode => $mode, verifier_accepted => 0 + $accepted,
        diagnostic_count => scalar(@errors), git_status => $status,
        git_stdout => $stdout, git_stderr => $stderr,
    }), "\n";
}
'''
assert "if (($? >> 8) != 0)" in verifier_body
assert "return ($? >> 8, $stdout, $stderr);" in git_body
with tempfile.TemporaryDirectory(prefix="routing-child-status-") as temporary:
    scratch = Path(temporary)
    assert scratch.stat().st_dev == Path.cwd().stat().st_dev
    for variant in ("original", "guard_control"):
        v = verifier_body
        g = git_body
        if variant == "guard_control":
            v = v.replace("if (($? >> 8) != 0)", "if ($? != 0)")
            g = g.replace("return ($? >> 8, $stdout, $stderr);",
                          "return (($? & 127) ? 128 + ($? & 127) : ($? >> 8), $stdout, $stderr);")
        script = scratch / (variant + ".pl")
        script.write_text(prefix + g + v + suffix)
        result = subprocess.run(["perl", str(script)], capture_output=True, text=True, check=True)
        assert result.stderr == ""
        rows = [json.loads(line) for line in result.stdout.splitlines()]
        expected = [(1, 0, 0), (0, 1, 7), (1, 0, 0)] if variant == "original" else [(1, 0, 0), (0, 1, 7), (0, 1, 143)]
        assert [(r["verifier_accepted"], r["diagnostic_count"], r["git_status"]) for r in rows] == expected
        assert all(r["git_stdout"] == r["git_stderr"] == "" for r in rows)
        print(json.dumps({"variant": variant, "rows": rows}, sort_keys=True))
print(json.dumps({"owner": owner.as_posix(), "owner_sha256": source_hash,
                  "git_capture_sha256": hashlib.sha256(git_body.encode()).hexdigest(),
                  "run_fixed_verifier_sha256": hashlib.sha256(verifier_body.encode()).hexdigest(),
                  "temporary_removed": not scratch.exists(), "real_doctrine_children_run": 0}, sort_keys=True))
PY
```
