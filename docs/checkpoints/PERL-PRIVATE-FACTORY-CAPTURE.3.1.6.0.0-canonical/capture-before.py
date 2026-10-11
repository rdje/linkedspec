"""One-shot reproduce the actual failed CI registration against the old auditor."""
import base64
import hashlib
import json
from pathlib import Path
import subprocess
import types

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
TARGET = HERE / 'before.json'
assert not TARGET.exists(), 'original observation already retained'
packet = json.loads((HERE / 'attempt-02.json').read_bytes())
auditor_path = 'tests/language-readiness/verify_objectives.py'
runner_path = 'tools/run_ci_local.sh'
original = base64.b64decode(packet['inputs'][auditor_path])
audit = types.ModuleType('original_objective_audit')
audit.__file__ = str(ROOT / auditor_path)
exec(compile(original, audit.__file__, 'exec'), audit.__dict__)
milestone_path = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.5-verification.json'
milestone = json.loads((ROOT / milestone_path).read_bytes())
hashes = []

def find_hashes(value):
    if isinstance(value, dict):
        if runner_path in value:
            hashes.append(value[runner_path])
        for child in value.values():
            find_hashes(child)
    elif isinstance(value, list):
        for child in value:
            find_hashes(child)

find_hashes(milestone)
assert len(hashes) == 1 and isinstance(hashes[0], str)
baseline = subprocess.check_output(['git', 'show', packet['base_head'] + ':' + runner_path], cwd=ROOT)
control = audit.verify_governance_evolution(runner_path, baseline, hashes[0])
try:
    audit.verify_governance_evolution(runner_path, base64.b64decode(packet['inputs'][runner_path]), hashes[0])
except ValueError as error:
    rejection = str(error)
else:
    raise AssertionError('original failed candidate unexpectedly accepted')
assert rejection == 'governance registration mismatch: tools/run_ci_local.sh'
TARGET.write_text(json.dumps({'baseline': control, 'native_rejection': rejection,
    'historical_hash': hashes[0], 'milestone': milestone_path,
    'producer_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    'scope': 'Original retained auditor accepts clean activation CI and rejects the actual failed staged runner. No original historical observation is refreshed.'}, indent=2) + '\n')
print('Original governance registration RED reproduced; activation control PASS')
