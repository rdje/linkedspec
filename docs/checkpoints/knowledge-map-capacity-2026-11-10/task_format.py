"""Retain actual staged checklist checks around a documented format correction."""
import argparse
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
GATE = 'scripts/check_diagnosis_evidence.sh'
PART = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
TASKS = ('docs/tasks/TYPE-REFERENCE-BOOK.md', PART)
OLD = ('  - [x] **LOCKSTEP** — book/helper spine/Knowledge, task/future78/index/frontier, '
       'change/engineering/live/MEMORY distinguish observed defects/reader qualifications '
       'from pending independent implementation and full admission.\n')
NEW = (OLD.replace(' from pending independent implementation and full admission.', '.')
       + '  Open scope: pending independent implementation and full admission remain separately owned.\n')


def image(raw):
    return {'sha256': hashlib.sha256(raw).hexdigest(), 'base64': base64.b64encode(raw).decode()}


def capture(epoch):
    path = HERE / ('task-format-' + epoch + '.json.gz')
    assert not path.exists(), 'one-shot capture already exists'
    inputs = {name: image(subprocess.check_output(['git', 'show', ':' + name], cwd=ROOT)) for name in TASKS}
    inputs[GATE] = image((ROOT / GATE).read_bytes())
    inputs[Path(__file__).relative_to(ROOT).as_posix()] = image(Path(__file__).read_bytes())
    names = subprocess.check_output(['git', 'diff', '--cached', '--name-only', '-z'], cwd=ROOT)
    result = subprocess.run(['bash', GATE], cwd=ROOT, capture_output=True)
    assert result.returncode == (1 if epoch == 'before' else 0)
    report = {'epoch': epoch, 'inputs': inputs, 'staged_paths': image(names),
              'returncode': result.returncode, 'stdout': image(result.stdout), 'stderr': image(result.stderr)}
    path.write_bytes(gzip.compress(json.dumps(report, sort_keys=True).encode(), mtime=0))
    return {'epoch': epoch, 'returncode': result.returncode}


def unpack(item):
    raw = base64.b64decode(item['base64'], validate=True)
    assert image(raw) == item
    return raw


def review():
    before, after = [json.loads(gzip.decompress((HERE / ('task-format-' + epoch + '.json.gz')).read_bytes()))
                     for epoch in ('before', 'after')]
    for report in (before, after):
        for item in (*report['inputs'].values(), report['staged_paths'], report['stdout'], report['stderr']):
            unpack(item)
    assert before['returncode'] == 1 and after['returncode'] == 0
    for name in before['inputs']:
        left, right = [unpack(report['inputs'][name]) for report in (before, after)]
        if name == PART:
            assert left.count(OLD.encode()) == 1
            assert right == left.replace(OLD.encode(), NEW.encode())
        else:
            assert right == left
    assert b'governed staged changes need' in unpack(before['stderr'])
    assert b'carries a complete tool-evidence checklist' in unpack(after['stdout'])
    return {'result': 'PASS', 'scope': 'exact staged checklist-format correction; gate and statuses unchanged',
            'before': 1, 'after': 0}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', choices=('before', 'after'))
    args = parser.parse_args()
    print(json.dumps(capture(args.capture) if args.capture else review(), sort_keys=True))
