"""Capture exact descriptor/source units for controls and tracked shipped specs."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"
mode = sys.argv[1]
if mode not in ("original", "before", "after"):
    raise ValueError("original/before/after required")
cases = json.loads((ROOT / (PREFIX + "compatibility-cases.json")).read_bytes())
requests = [{"id": "control:" + case["id"], "source": case["source"]} for case in cases]
rows = []
for request in requests:
    command = ["perl", "-Iperl", PREFIX + "compatibility-probe.pl"]
    run = subprocess.run(command, cwd=ROOT, input=json.dumps(request).encode(), capture_output=True,
                         env=dict(os.environ, PERL5LIB="", PERL_HASH_SEED="0", PERL_PERTURB_KEYS="2",
                                  LINKEDSPEC_COMPAT_ORIGINAL="1" if mode == "original" else "",
                                  LINKEDSPEC_COMPAT_BEFORE="1" if mode == "before" else ""))
    if run.returncode or run.stderr:
        raise ValueError((request["id"], run.returncode, run.stderr.decode()))
    rows.append({"request": request, "source_sha256": hashlib.sha256(request["source"].encode()).hexdigest(),
                 "command": command, "exit": run.returncode, "stdout": run.stdout.decode(),
                 "stderr": run.stderr.decode(), "observation": json.loads(run.stdout)})
    print("captured census " + request["id"], file=sys.stderr)
print(json.dumps({"owner": OWNER, "mode": mode, "seed": "0", "perturbation": "2", "rows": rows,
                  "limits": "Compatibility descriptor and source-unit AST/events only; no native/fresh runtime admission."}, indent=2))
