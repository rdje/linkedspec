"""Run reason-sensitive corruptions through the actual independent reviewer."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.2'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
COMMAND = ['bash', 'tools/run_python_project_data.sh', PREFIX + 'review.py']
target = ROOT / (PREFIX + 'evidence.json')
assert not target.exists(), 'one-shot capture'
digest = lambda raw: hashlib.sha256(raw).hexdigest()
successful = {p: p.read_bytes() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*.json')}
rows = []


def replace(name, change):
    path = ROOT / (PREFIX + name + '.json')
    value = json.loads(successful[path])
    change(value)
    path.write_text(json.dumps(value, indent=2) + '\n')


def control(name, corrupt, reason):
    try:
        corrupt()
        altered = {p.relative_to(ROOT).as_posix(): {'sha256': digest(p.read_bytes()),
                    'bytes_base64': base64.b64encode(p.read_bytes()).decode()}
                   for p, before in successful.items() if p.read_bytes() != before}
        assert altered, name
        completed = subprocess.run(COMMAND, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
        row = {'case': name, 'command': COMMAND, 'returncode': completed.returncode,
               'stdout_base64': base64.b64encode(completed.stdout).decode(),
               'stderr_base64': base64.b64encode(completed.stderr).decode(),
               'expected_reason': reason, 'mutated_inputs': altered}
        rows.append(row)
        assert completed.returncode != 0 and reason.encode() in completed.stderr, name
        row['observed'] = 'RED'
    finally:
        for path, before in successful.items():
            if path.read_bytes() != before:
                path.write_bytes(before)
        assert all(path.read_bytes() == before for path, before in successful.items())


control('failed-positive-fixture', lambda: replace('final-after', lambda row: row.update(returncode=1)),
        'failed positive fixture')


def missing_artifact(row):
    del row['inputs']['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0-cases.json']


control('missing-reader-artifact', lambda: replace('final-consumers', missing_artifact),
        'wrong supplied input population/content')
control('missing-inverse', lambda: replace('final-inverses', lambda row: row['rows'].pop()),
        'missing inverse population')


def forged_semantic_reason():
    name = 'final-inverse-opaque-ast-release'

    def change(row):
        out = base64.b64decode(row['stdout_base64'])
        old = b'joined opaque AST return preserves native immediate release'
        assert out.count(old) == 1
        row['stdout_base64'] = base64.b64encode(out.replace(old, b'irrelevant failure', 1)).decode()

    replace(name, change)
    path = PREFIX + name + '.json'
    changed_hash = digest((ROOT / path).read_bytes())

    def index_change(index):
        selected = [row for row in index['rows'] if row['path'] == path]
        assert len(selected) == 1
        selected[0]['sha256'] = changed_hash

    replace('final-inverses', index_change)


control('forged-semantic-reason', forged_semantic_reason, 'missing distinguishing semantic RED')
control('falsely-successful-lifetime-before', lambda: replace('lifetime-before', lambda row: row.update(returncode=0)),
        'non-semantic failure exit')

completed = subprocess.run(COMMAND, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
assert completed.returncode == 0 and all(path.read_bytes() == before for path, before in successful.items())
report = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
          'reviewer_sha256': digest((ROOT / (PREFIX + 'review.py')).read_bytes()), 'rows': rows,
          'restored_successful_artifacts': {p.relative_to(ROOT).as_posix(): digest(raw) for p, raw in successful.items()},
          'restored_command': {'command': COMMAND, 'returncode': completed.returncode,
                               'stdout_base64': base64.b64encode(completed.stdout).decode(),
                               'stderr_base64': base64.b64encode(completed.stderr).decode()},
          'scope': 'Five actual reviewer subprocess RED controls with full channels and exact mutant JSON bytes. Only mutable proof JSON changes temporarily; all original successful outputs restore byte-identically. No runtime/history/checker changes.'}
target.write_text(json.dumps(report, indent=2) + '\n')
print('Actual evidence reviewer controls PASS5; all successful artifacts restore exactly')
