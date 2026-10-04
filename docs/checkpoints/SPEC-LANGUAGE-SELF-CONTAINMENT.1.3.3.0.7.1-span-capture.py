"""Capture before/current public source-bound native/fresh records, stdout only."""
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
if mode not in ("before", "after"):
    raise ValueError("before/after required")
rows = []
for case in json.loads((ROOT / (PREFIX + "span-cases.json")).read_bytes()):
    for seed in ("0", "1", "2"):
        command = ["perl", "-Iperl", PREFIX + "span-probe.pl", case["id"]]
        run = subprocess.run(command, cwd=ROOT, capture_output=True,
                             env=dict(os.environ, PERL5LIB="", PERL_HASH_SEED=seed,
                                      PERL_PERTURB_KEYS="2", LINKEDSPEC_RAW_BASELINE="1" if mode == "before" else ""))
        if run.returncode or run.stderr:
            raise ValueError((case["id"], seed, run.returncode, run.stderr.decode()))
        rows.append({"command": command, "exit": run.returncode, "stdout": run.stdout.decode(),
                     "stderr": run.stderr.decode(), "observation": json.loads(run.stdout)})
    print("captured " + mode + " " + case["id"], file=sys.stderr)
print(json.dumps({"owner": OWNER, "mode": mode, "seeds": ["0", "1", "2"], "perturbation": "2",
                  "baseline_owners": {name: hashlib.sha256((ROOT / (PREFIX + "before-" + name + ".pm")).read_bytes()).hexdigest()
                                      for name in ("EmitContext", "Diagnostics")}, "rows": rows}, indent=2))
