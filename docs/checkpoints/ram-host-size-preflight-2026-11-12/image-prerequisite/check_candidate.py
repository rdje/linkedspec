"""Check the repaired current direct-source candidate before final staging."""
import hashlib
import json
from pathlib import Path
import subprocess

ROOT=Path.cwd().resolve()
BASE=Path(__file__).resolve().parent.relative_to(ROOT)
rows=json.loads((BASE/'isolated-recovery/input-identities.json').read_bytes())
names=['tools/historical_objective_images.py','tools/test_historical_objective_images.py',
       'tests/language-readiness/verify_objectives.py','tools/run_ci_local.sh',
       'tools/host_ram_usage.sh','tools/ram_guard.sh','tools/test_ram_guard.py',
       'doctrine/project_data_storage/python_entrypoints.json','doctrine/project_data_storage/python_temporary_owners.json',
       'tests/language-readiness/current-source-images.json.gz','tests/language-readiness/current-source-successors.json.gz',
       'tests/language-readiness/additional-source-images.json.gz',
       'tests/language-readiness/current-source-successors-2026-11-12.json.gz',
       'tests/language-readiness/ram-preflight-ci-evolution.json.gz']
for name in names:
    path=Path(name)
    assert hashlib.sha256(path.read_bytes()).hexdigest()==rows[name]['sha256'] and path.stat().st_mode&0o777==rows[name]['mode'],name
documents=json.loads((BASE/'publication/outputs-after-use.json').read_bytes())
for name,row in documents.items():
    path=Path(name)
    assert hashlib.sha256(path.read_bytes()).hexdigest()==row['sha256'] and path.stat().st_mode&0o777==row['mode'],name
changed=subprocess.check_output(['git','diff','HEAD','--name-only','--','perl','rust','dart','julia','lua','specs'])
assert changed==b'','runtime source change outside this infrastructure repair'
print('Repaired current producer/table/document identities: PASS (pre-staging only)')
