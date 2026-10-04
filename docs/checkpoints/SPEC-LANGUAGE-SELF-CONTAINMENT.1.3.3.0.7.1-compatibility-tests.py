"""Retain actual27-test RED/GREEN commands, loader and complete output channels."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
OWNER = "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1"
PREFIX = "docs/checkpoints/" + OWNER + "-"
TEST = "t/actionir_raw_dependency_compatibility.t"
mode = sys.argv[1]
if mode == "before":
    loader = "BEGIN { require './" + PREFIX + "before-compat-RawDependencies.pm'; $INC{'LinkedSpec/ActionIR/RawDependencies.pm'} = '" + PREFIX + "before-compat-RawDependencies.pm'; } my $result = do './" + TEST + "'; die $@ if $@; die $! unless defined $result;"
    command = ["perl", "-Iperl", "-e", loader]
elif mode == "after":
    command = ["prove", "-v", "-Iperl", TEST]
else:
    raise ValueError("before/after required")
run = subprocess.run(command, cwd=ROOT, text=True, capture_output=True,
                     env=dict(os.environ, PERL5LIB="", PERL_HASH_SEED="0", PERL_PERTURB_KEYS="2"))
print(json.dumps({"owner": OWNER, "mode": mode, "command": command, "exit": run.returncode,
                  "stdout": run.stdout, "stderr": run.stderr,
                  "source_sha256": hashlib.sha256((ROOT / TEST).read_bytes()).hexdigest(),
                  "limits": "Complete27-test source; before loads the exact frozen collector only, after executes current owners. Fixed seed0/perturbation2. Child versus prove wrapper exit identities remain distinct."}, indent=2))
