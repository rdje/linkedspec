"""Retain actual census/review producers, exits and both full channels."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/REPO-HYGIENE.15-'

def digest(raw):
    return hashlib.sha256(raw).hexdigest()

def channel(raw):
    return {'bytes': len(raw), 'sha256': digest(raw),
            'gzip_base64': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}

assert not any((ROOT / (PREFIX + name)).exists() for name in ('actual.json', 'artifact-review.json', 'verification.json')), 'one-shot actual capture already exists'
revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
producers = [PREFIX + name for name in ('census.py', 'review.py', 'capture.py')]
producers += ['tools/run_python_project_data.sh', 'tools/project_data_env.sh', 'tools/project_data_run.sh']
identities = {path: digest((ROOT / path).read_bytes()) for path in producers}
report = {'owner': 'REPO-HYGIENE.15', 'revision': revision, 'complete': False, 'inputs': identities, 'runs': []}
for name, args, output in (('census.py', [], 'artifact-review.json'), ('review.py', ['--live'], 'verification.json')):
    command = ['bash', 'tools/run_python_project_data.sh', PREFIX + name] + args
    before = {path: digest((ROOT / path).read_bytes()) for path in producers}
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    report['runs'].append({'command': command, 'exit': result.returncode,
                           'stdout': channel(result.stdout), 'stderr': channel(result.stderr),
                           'inputs_before': before,
                           'inputs_after': {path: digest((ROOT / path).read_bytes()) for path in producers}})
    (ROOT / (PREFIX + 'actual.json')).write_text(json.dumps(report, indent=2) + '\n')
    assert result.returncode == 0 and not result.stderr, name
    assert before == identities == report['runs'][-1]['inputs_after']
    parsed = json.loads(result.stdout)
    (ROOT / (PREFIX + output)).write_bytes(result.stdout)
    print(name + ' exit0; full stdout/stderr retained', flush=True)
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == revision
report['complete'] = True
(ROOT / (PREFIX + 'actual.json')).write_text(json.dumps(report, indent=2) + '\n')
