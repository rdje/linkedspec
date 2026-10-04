"""Reproduce the initial character-mode JSON printer failure on its exact source."""
import hashlib
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = "docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1-"
request = {"id": "shipped:specs/spec.spec", "path": "specs/spec.spec",
           "source": (ROOT / "specs/spec.spec").read_text()}
command = ["perl", "-Iperl", PREFIX + "census-initial.pl"]
run = subprocess.run(command, cwd=ROOT, input=json.dumps(request).encode(), capture_output=True,
                     env=dict(os.environ, PERL5LIB="", PERL_HASH_SEED="0", PERL_PERTURB_KEYS="2"))
if run.returncode != 0 or b"Wide character in print" not in run.stderr:
    raise ValueError("initial printer failure not reproduced")
observation = json.loads(run.stdout)
print(json.dumps({"command": command, "request": request, "exit": run.returncode,
                  "stdout": run.stdout.decode(), "stderr": run.stderr.decode(), "observation": observation,
                  "source_sha256": hashlib.sha256(request["source"].encode()).hexdigest(),
                  "producer_sha256": hashlib.sha256((ROOT / (PREFIX + "census-initial.pl")).read_bytes()).hexdigest(),
                  "result": "REPRODUCED", "limits": "One source replays the instrument warning; aborted initial aggregate is not claimed."}, indent=2))
