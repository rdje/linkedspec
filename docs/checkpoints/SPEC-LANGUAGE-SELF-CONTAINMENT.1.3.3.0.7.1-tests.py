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
unit = sys.argv[2] if len(sys.argv) > 2 else "t/actionir_raw_dependency_metadata.t"
if mode == "before":
    loader = "BEGIN { require './" + PREFIX + "before-EmitContext.pm'; $INC{'LinkedSpec/RuleIR/EmitContext.pm'} = '" + PREFIX + "before-EmitContext.pm'; require './" + PREFIX + "before-Diagnostics.pm'; $INC{'LinkedSpec/ActionIR/Diagnostics.pm'} = '" + PREFIX + "before-Diagnostics.pm'; } my $file = shift; my $result = do './'.$file; die $@ if $@; die $! unless defined $result;"
    commands = [["perl", "-Iperl", "-e", loader, unit]]
else:
    commands = [["prove", "-v", "-Iperl", unit], ["prove", "-v", "-Iperl", "t/actionir_raw_dependency_provenance.t"]]
    commands += [["prove", "-v", "-Iperl", name] for name in ['t/canonical_event_occurrence_order.t', 't/trace_actionir_pipeline.t', 't/noncurrent_helper_metadata.t', 't/actionir_ast_parser.t', 't/trace_actionir_method_lowering.t', 't/generated_source_contract.t', 't/codeblock_while_perl.t', 't/recursive_observation_perl_contract.t', 't/recognition_transaction_perl_contract.t', 't/progressive_span_dispatch_perl_contract.t', 't/staged_ast_enrichment_perl_contract.t']]
rows = []
for command in commands:
    run = subprocess.run(command, cwd=ROOT, capture_output=True,
                         env=dict(os.environ, PERL5LIB="", PERL_HASH_SEED="0", PERL_PERTURB_KEYS="2"))
    rows.append({"command": command, "exit": run.returncode, "stdout": run.stdout.decode(), "stderr": run.stderr.decode()})
print(json.dumps({"owner": OWNER, "mode": mode, "rows": rows}, indent=2))

if mode == "after" and any(row["exit"] for row in rows):
    raise SystemExit(1)
