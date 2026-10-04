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
unit = "t/actionir_nested_block_source_spans.t"
if mode == "before":
    loader = "BEGIN { local @INC = @INC; require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-span-Parser.pm'; $INC{'LinkedSpec/ActionIR/AST/Parser.pm'} = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-span-Parser.pm'; require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-span-RawDependencies.pm'; $INC{'LinkedSpec/ActionIR/RawDependencies.pm'} = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-span-RawDependencies.pm'; require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-span-RuleIR.pm'; $INC{'LinkedSpec/RuleIR.pm'} = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-span-RuleIR.pm'; require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-span-EmitContext.pm'; $INC{'LinkedSpec/RuleIR/EmitContext.pm'} = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-span-EmitContext.pm'; require './docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-span-Diagnostics.pm'; $INC{'LinkedSpec/ActionIR/Diagnostics.pm'} = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-before-span-Diagnostics.pm';  } my $file = shift; my $result = do './'.$file; die $@ if $@; die $! unless defined $result;"
    commands = [["perl", "-Iperl", "-e", loader, unit]]
else:
    commands = [["prove", "-v", "-Iperl", unit]]
rows = []
for command in commands:
    run = subprocess.run(command, cwd=ROOT, capture_output=True,
                         env=dict(os.environ, PERL5LIB="", PERL_HASH_SEED="0", PERL_PERTURB_KEYS="2"))
    rows.append({"command": command, "exit": run.returncode, "stdout": run.stdout.decode(), "stderr": run.stderr.decode()})
print(json.dumps({"owner": OWNER, "mode": mode, "rows": rows}, indent=2))
