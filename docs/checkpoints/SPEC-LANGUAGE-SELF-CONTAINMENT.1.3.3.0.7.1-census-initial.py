"""Capture exact descriptor/source units for controls and tracked shipped specs."""
import hashlib
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"
cases = json.loads((ROOT / "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0-cases.json").read_bytes())
requests = [{"id": "control:" + case["id"], "source": case["source"]} for case in cases]
paths = subprocess.check_output(["git", "ls-files", "specs"], cwd=ROOT, text=True).splitlines()
for path in paths:
    if path.endswith(".spec"):
        requests.append({"id": "shipped:" + path, "path": path, "source": (ROOT / path).read_text()})
rows = []
for request in requests:
    command = ["perl", "-Iperl", PREFIX + "census.pl"]
    run = subprocess.run(command, cwd=ROOT, input=json.dumps(request).encode(), capture_output=True,
                         env=dict(os.environ, PERL5LIB="", PERL_HASH_SEED="0", PERL_PERTURB_KEYS="2"))
    if run.returncode or run.stderr:
        raise ValueError((request["id"], run.returncode, run.stderr.decode()))
    rows.append({"request": request, "source_sha256": hashlib.sha256(request["source"].encode()).hexdigest(),
                 "command": command, "exit": run.returncode, "stdout": run.stdout.decode(),
                 "stderr": run.stderr.decode(), "observation": json.loads(run.stdout)})
print(json.dumps({"owner": OWNER, "seed": "0", "perturbation": "2", "rows": rows,
                  "limits": "Activation/current descriptor and original rewrite-source units; no runtime or full language admission."}, indent=2))
