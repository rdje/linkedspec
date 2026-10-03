"""Retain complete focused direct-dependent TAP streams on stdout."""
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
tests = ("t/actionir_ast_parser.t", "t/noncurrent_helper_metadata.t",
         "t/generated_source_contract.t", "t/trace_actionir_pipeline.t")
rows = []
for test in tests:
    command = ["prove", "-v", "-Iperl", test]
    run = subprocess.run(command, cwd=ROOT, env=dict(os.environ, PERL5LIB=""),
                         capture_output=True)
    rows.append({"command": command, "exit": run.returncode,
                 "stdout": run.stdout.decode(), "stderr": run.stderr.decode()})
print(json.dumps({"owner": "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0",
                  "rows": rows}, indent=2))
raise SystemExit(any(row["exit"] for row in rows))
