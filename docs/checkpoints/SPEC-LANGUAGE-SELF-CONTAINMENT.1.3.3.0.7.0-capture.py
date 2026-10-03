"""Capture current public source-bound native and independent fresh observations."""
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0"
PREFIX = "docs/checkpoints/" + OWNER + "-"
rows = []
for case in json.loads((ROOT / (PREFIX + "cases.json")).read_bytes()):
    for seed in ("0", "1", "2"):
        command = ["perl", "-Iperl", PREFIX + "probe.pl", case["id"]]
        run = subprocess.run(command, cwd=ROOT,
                             env=dict(os.environ, PERL5LIB="", PERL_HASH_SEED=seed,
                                      PERL_PERTURB_KEYS="2"), capture_output=True)
        if run.returncode != 0 or run.stderr:
            raise ValueError((case["id"], seed, run.returncode, run.stderr))
        rows.append({"command": command, "exit": run.returncode,
                     "stdout": run.stdout.decode(), "stderr": run.stderr.decode(),
                     "observation": json.loads(run.stdout)})
print(json.dumps({"owner": OWNER, "seeds": ["0", "1", "2"],
                  "perturbation": "2", "rows": rows}, indent=2))
