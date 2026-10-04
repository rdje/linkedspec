"""Capture the real public metadata regression against before/current owners."""
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"
mode = sys.argv[1]
if mode not in ("before", "after"):
    raise ValueError("before/after required")
unit = "t/actionir_raw_dependency_metadata.t"
if mode == "before":
    loader = "BEGIN { require './" + PREFIX + "before-EmitContext.pm'; $INC{'LinkedSpec/RuleIR/EmitContext.pm'} = '" + PREFIX + "before-EmitContext.pm'; require './" + PREFIX + "before-Diagnostics.pm'; $INC{'LinkedSpec/ActionIR/Diagnostics.pm'} = '" + PREFIX + "before-Diagnostics.pm'; } my $file = shift; my $result = do './'.$file; die $@ if $@; die $! unless defined $result;"
    commands = [["perl", "-Iperl", "-e", loader, unit]]
else:
    commands = [["prove", "-v", "-Iperl", unit]]
rows = []
for command in commands:
    run = subprocess.run(command, cwd=ROOT, capture_output=True,
                         env=dict(os.environ, PERL5LIB="", PERL_HASH_SEED="0", PERL_PERTURB_KEYS="2"))
    rows.append({"command": command, "exit": run.returncode, "stdout": run.stdout.decode(), "stderr": run.stderr.decode()})
print(json.dumps({"owner": OWNER, "mode": mode, "rows": rows}, indent=2))
