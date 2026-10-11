"""Retain actual missing-question and original-binding RED/restorations on supplied copies."""
import base64
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
FOLDER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2/'
REVIEW = FOLDER + 'review-consolidation.py'
REPORT = FOLDER + 'consolidation-review.json'
TARGET = ROOT / (FOLDER + 'consolidation-evidence.json')
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
serialize = lambda value: (json.dumps(value, indent=2) + '\n').encode()
review = json.loads((ROOT / REPORT).read_bytes())
assert review['result'] == 'PASS'
files = {path: (ROOT / path).read_bytes() for path in set(review['inputs']) | {REPORT}}
assert all(sha(files[path]) == digest for path, digest in review['inputs'].items())
population = {path: sha(raw) for path, raw in files.items()}


def missing_question():
    path = 'docs/knowledge/perl-array-receiver-required-capture.md'
    question = b'  - "can parser argument mutation change __source_expr"\n'
    assert files[path].count(question) == 1
    return {path: files[path].replace(question, b'', 1)}


def original_binding():
    path = FOLDER + 'original-claim.json'
    data = json.loads(files[path])
    data['claims'][0]['durability']['inputs'][0]['sha256'] = '0' * 64
    damaged = serialize(data)
    assert len(damaged) == len(files[path])
    record_path = FOLDER + 'preservation.json'
    record = json.loads(files[record_path])
    record['original_files']['original-claim.json']['sha256'] = sha(damaged)
    return {path: damaged, record_path: serialize(record)}


controls = [('missing-receiver-question', missing_question, 'combined receiver card identity'),
            ('forged-original-binding', original_binding, 'preserved original input')]
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot consolidation evidence already retained'
    git_dir = subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=ROOT, text=True).strip()
    with tempfile.TemporaryDirectory(prefix='receiver-consolidation-controls-', dir=os.environ['TMPDIR']) as directory:
        directory = Path(directory)
        assert directory.stat().st_dev == ROOT.stat().st_dev
        for path, raw in files.items():
            target = directory / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
            target.chmod((ROOT / path).stat().st_mode & 0o777)
        environment = dict(os.environ, GIT_DIR=git_dir, GIT_WORK_TREE=str(directory),
                           GIT_OPTIONAL_LOCKS='0', PYTHONDONTWRITEBYTECODE='1')

        def run(expected):
            command = ['python3', REVIEW]
            result = subprocess.run(command, cwd=directory, env=environment,
                                    stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
            observed = {p.relative_to(directory).as_posix(): sha(p.read_bytes())
                        for p in directory.rglob('*') if p.is_file()}
            assert observed == expected, 'consolidation control input preservation'
            return {'command': command, 'returncode': result.returncode,
                    'stdout_base64': base64.b64encode(result.stdout).decode(),
                    'stderr_base64': base64.b64encode(result.stderr).decode(),
                    'inputs': expected, 'unchanged': True}

        healthy = run(population)
        reached = ROOT / (FOLDER + 'consolidation-evidence-reached.json')
        assert not reached.exists()
        rows = []
        reached.write_bytes(serialize({'healthy': healthy, 'rows': rows}))
        assert healthy['returncode'] == 0 and not base64.b64decode(healthy['stderr_base64'])
        for label, operation, reason in controls:
            changed = operation()
            for path, raw in changed.items():
                (directory / path).write_bytes(raw)
            damaged = dict(population, **{path: sha(raw) for path, raw in changed.items()})
            red = run(damaged)
            row = {'label': label, 'reason': reason,
                   'changed': {path: {'sha256': sha(raw), 'bytes_base64': base64.b64encode(raw).decode()}
                               for path, raw in changed.items()}, 'red': red}
            reached.write_bytes(serialize({'healthy': healthy, 'rows': rows + [row]}))
            assert red['returncode'] != 0 and reason.encode() in base64.b64decode(red['stderr_base64']), 'reason-sensitive metadata RED'
            for path in changed:
                (directory / path).write_bytes(files[path])
            restored = run(population)
            row['restored'] = restored
            reached.write_bytes(serialize({'healthy': healthy, 'rows': rows + [row]}))
            assert restored['returncode'] == 0 and not base64.b64decode(restored['stderr_base64'])
            rows.append(row)
    report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
              'review_sha256': sha(files[REVIEW]), 'report_sha256': sha(files[REPORT]),
              'inputs': population, 'healthy': healthy, 'controls': rows,
              'scope': 'Two actual metadata RED/restorations on exact repository-volume copies. Omitted receiver question fails full independent card reconstruction. Forged original native binding fails actual preserved-input identity beyond its updated immediate original-claim SHA binding. Full changed bytes, input populations and channels are retained before assertions. No runtime measurement or cap change.'}
    TARGET.write_bytes(serialize(report))
else:
    report = json.loads(TARGET.read_bytes())
    assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
    assert report['review_sha256'] == sha(files[REVIEW]) and report['report_sha256'] == sha(files[REPORT])
    assert report['inputs'] == population and report['healthy']['inputs'] == population and report['healthy']['returncode'] == 0
    assert len(report['controls']) == len(controls) == 2
    for row, (label, operation, reason) in zip(report['controls'], controls):
        changed = operation()
        assert row['label'] == label and row['reason'] == reason
        assert row['changed'] == {path: {'sha256': sha(raw), 'bytes_base64': base64.b64encode(raw).decode()}
                                  for path, raw in changed.items()}
        assert row['red']['inputs'] == dict(population, **{path: sha(raw) for path, raw in changed.items()})
        assert row['red']['returncode'] != 0 and reason.encode() in base64.b64decode(row['red']['stderr_base64']) and row['red']['unchanged']
        assert row['restored']['inputs'] == population and row['restored']['returncode'] == 0 and row['restored']['unchanged']
    assert json.loads((ROOT / (FOLDER + 'consolidation-evidence-reached.json')).read_bytes()) == {'healthy': report['healthy'], 'rows': report['controls']}
print('Consolidation evidence PASS: two actual named RED/restorations; unchanged runtime and limits')
