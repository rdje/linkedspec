"""Replay only the catalogue-driven source-seeding helper and exact file oracle."""
import base64
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import types

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
TEST = 'tools/test_task_narrative.py'
HELPER = 'tools/task_narrative.py'


def decode(item):
    raw = base64.b64decode(item['base64'], validate=True)
    assert hashlib.sha256(raw).hexdigest() == item['sha256']
    return raw


def packet(epoch):
    value = json.loads(gzip.decompress((HERE / ('epoch-fixture-qualified-' + epoch + '.json.gz')).read_bytes()))
    for item in (*value['inputs'].values(), value['stdout'], value['stderr']):
        decode(item)
    return value


def files_match(target, expected):
    actual = {path.relative_to(target).as_posix(): path.read_bytes()
              for path in (target / 'docs/tasks').glob('*.md')}
    assert actual == expected, 'copied epoch source population or bytes'


def review():
    before, after = packet('before'), packet('after')
    assert before['returncode'] == 1 and after['returncode'] == 0
    assert b'FileNotFoundError' in decode(before['stderr'])
    assert b'docs/tasks/LUA-BACKEND-PARITY.md' in decode(before['stderr'])
    assert decode(after['stderr']) == b''
    assert b'task-narrative-epoch-controls:' in decode(after['stdout'])
    assert set(before['inputs']) == set(after['inputs'])
    for name in after['inputs']:
        if name != TEST:
            assert before['inputs'][name] == after['inputs'][name], 'nonproducer scoped input changed'
    inputs = {name: decode(image) for name, image in after['inputs'].items()}
    expected = {}
    for name, raw in inputs.items():
        if name.startswith('docs/history/task-narrative-epochs/'):
            source = json.loads(raw)['source_path']
            expected[source] = inputs[source]
    assert 'docs/tasks/LUA-BACKEND-PARITY.md' in expected
    original_module = sys.modules.get('task_narrative')
    rejected = []
    try:
        subject = types.ModuleType('task_narrative')
        subject.__file__ = str(ROOT / HELPER)
        exec(compile(inputs[HELPER], subject.__file__, 'exec'), subject.__dict__)
        sys.modules['task_narrative'] = subject
        producer = types.ModuleType('frozen_epoch_fixture')
        producer.__file__ = str(ROOT / TEST)
        exec(compile(inputs[TEST], producer.__file__, 'exec'), producer.__dict__)
        with tempfile.TemporaryDirectory(prefix='epoch-seeding-', dir=os.environ['LINKEDSPEC_RUN_DIR']) as name:
            fixture = Path(name)
            source_root, target = fixture / 'input', fixture / 'output'
            for path, raw in inputs.items():
                destination = source_root / path
                destination.parent.mkdir(parents=True, exist_ok=True)
                destination.write_bytes(raw)
            producer.ROOT = subject.ROOT = source_root
            # Retained immutable Git objects stay in the owning repository;
            # all current manifest/source files come from the frozen fixture.
            subject.git = lambda *args: subprocess.check_output(['git', '-C', str(ROOT), *args])
            producer.copy_epoch_current_sources(target)
            files_match(target, expected)
            selected = target / 'docs/tasks/LUA-BACKEND-PARITY.md'
            raw = selected.read_bytes()
            for label in ('missing-source', 'changed-source'):
                if label == 'missing-source':
                    selected.unlink()
                else:
                    selected.write_bytes(raw + b'corrupted source\n')
                try:
                    files_match(target, expected)
                except AssertionError:
                    rejected.append(label)
                else:
                    raise AssertionError('ineffective fixture control: ' + label)
                selected.write_bytes(raw)
            files_match(target, expected)
    finally:
        if original_module is None:
            sys.modules.pop('task_narrative', None)
        else:
            sys.modules['task_narrative'] = original_module
    return {'result': 'PASS', 'scoped_source_population': 'all retained manifest source paths copied byte-exact',
            'original_consumer': 'missing Lua fixture source', 'candidate_consumer': 'exit0/empty stderr',
            'rejected_controls': rejected,
            'limits': 'Frozen helper/current-source population and actual dated consumer channels; no full control-program/native/archive-input closure credit or lowercase boundary repair.'}


if __name__ == '__main__':
    print(json.dumps(review(), sort_keys=True))
