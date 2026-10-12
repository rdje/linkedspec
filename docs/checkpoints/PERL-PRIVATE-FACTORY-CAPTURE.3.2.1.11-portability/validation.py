"""Capture separate actual channels for focused portability and composed public gates."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-portability/'
target = ROOT / (PREFIX + 'validation.json')
assert not target.exists(), 'one-shot focused validation'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
rows = []
for command in (['bash', 'scripts/check_repo_root_path_portability.sh'],
                ['python3', 'tools/check_public_aggregate_selector_surface.py']):
    process = subprocess.run(command, cwd=ROOT, capture_output=True)
    rows.append({'command': command, 'returncode': process.returncode,
        'stdout_base64': base64.b64encode(process.stdout).decode(), 'stderr_base64': base64.b64encode(process.stderr).decode()})
    assert process.returncode == 0 and process.stdout and not process.stderr, rows[-1]
paths = ('scripts/check_repo_root_path_portability.sh', 'tools/check_public_aggregate_selector_surface.py',
    'tools/check_executable_aggregate_selector_sources.py', 'tools/project_data_env.sh',
    'tools/project_data_run.sh', 'tools/run_python_project_data.sh', PREFIX + 'validation.py')
target.write_text(json.dumps({'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'sources': {p: sha((ROOT / p).read_bytes()) for p in paths}, 'rows': rows,
    'scope': 'Actual separate focused command channels. Exact portability serializer byte controls and complete public70-file population are independently retained by current review and original177-input supplied replay. Full composed-project dependencies require the separate exact staged canonical receipt; this is no new backend admission.'}, indent=2) + '\n')
print('Focused actual portability/public validation PASS; separate command channels retained')
