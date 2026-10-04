"""Execute the exact24 previously failing Phase0 subtests and original helper."""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"
mode = sys.argv[1]
if mode not in ("before", "after"):
    raise ValueError("before/after required")
path = PREFIX + "before-span-phase0.t" if mode == "before" else "t/phase0_regression.t"
source_bytes = (ROOT / path).read_bytes()
source = source_bytes.decode()
cases = json.loads((ROOT / (PREFIX + "compatibility-cases.json")).read_bytes())[:24]
blocks = []
for case in cases:
    match = re.search(r"^subtest '" + re.escape(case["id"]) + r"' => sub \{\n(.*?)(?=^subtest |\Z)", source, re.M | re.S)
    if not match:
        raise ValueError("exact Phase0 subtest missing: " + case["id"])
    blocks.append(match.group(0))
helper = re.search(r"^sub normalize_error \{.*?(?=^sub |\Z)", source, re.M | re.S)
if not helper:
    raise ValueError("original helper missing")
loader = ("BEGIN { require './" + PREFIX + "before-compat-RawDependencies.pm'; "
          "$INC{'LinkedSpec/ActionIR/RawDependencies.pm'} = '" + PREFIX + "before-compat-RawDependencies.pm'; }\n") if mode == "before" else ""
program = ("use strict; use warnings; use Test::More; use LinkedSpec ();\n" + loader +
           helper.group(0) + "\n" + "\n".join(blocks) + "\ndone_testing();\n")
command = ["perl", "-Iperl", "-"]
run = subprocess.run(command, cwd=ROOT, input=program, text=True, capture_output=True,
                     env=dict(os.environ, PERL5LIB="", PERL_HASH_SEED="0", PERL_PERTURB_KEYS="2"))
print(json.dumps({"owner": OWNER, "mode": mode, "source": path,
                  "source_sha256": hashlib.sha256(source_bytes).hexdigest(),
                  "command": command, "program": program, "exit": run.returncode,
                  "stdout": run.stdout, "stderr": run.stderr,
                  "limits": "Exact24 previously failed test bodies and original normalize_error helper. No extracted claim of a complete1034-test run."}, indent=2))
