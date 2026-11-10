"""Replay the exact logical objective epoch without inventing a Git capture."""
import base64
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
BUNDLE = HERE / 'objective-frozen-epoch.json.gz'


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert hashlib.sha256(raw).hexdigest() == row['sha256']
    return raw


def review():
    data = json.loads(gzip.decompress(BUNDLE.read_bytes()))
    record = json.loads(decode(data['original_record']))
    claim = record['claims'][data['claim_index']]
    assert data['owner'] == record['owner'] == 'TYPE-REFERENCE-BOOK.1.2.23.4.18.1'
    assert claim['name'] == 'bounded-committed-current-image-admission'
    assert claim['durability']['inputs'] == data['declared_inputs']
    rows = {row['path']: row for row in data['declared_inputs']}
    assert len(rows) == len(data['declared_inputs']) == 231
    assert set(rows) == set(data['sources'])
    decode(data['instrument'])
    for name, row in data['sources'].items():
        relative = Path(name)
        assert not relative.is_absolute() and '..' not in relative.parts
        assert rows[name]['sha256'] == row['sha256']
        assert rows[name]['role'] == row['role']
        assert row['mode'] in (0o644, 0o755)
        decode(row)
    # This retained physical input already contains the exact unit-test source
    # as a logical packet; it was not a separate inline durability row.
    snapshot_name = str(HERE.relative_to(ROOT) / 'objective-current-inputs.json.gz')
    nested = json.loads(gzip.decompress(decode(data['sources'][snapshot_name])))
    sources = dict(data['sources'])
    for name, row in nested.items():
        relative = Path(name)
        assert not relative.is_absolute() and '..' not in relative.parts
        decode(row)
        if name in sources:
            assert sources[name]['sha256'] == row['sha256']
        else:
            assert name == 'tools/test_historical_objective_images.py'
            sources[name] = dict(row, mode=0o644)
    assert len(sources) == 232
    scratch = ROOT / '.linkedspec-data/normal-hook-restoration'
    scratch.mkdir(parents=True, exist_ok=True)
    commands = []
    with tempfile.TemporaryDirectory(prefix='objective-frozen-', dir=scratch) as directory:
        provided = Path(directory)
        assert provided.stat().st_dev == ROOT.stat().st_dev
        for name, row in sources.items():
            path = provided / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(decode(row))
            path.chmod(row['mode'])
        env = os.environ.copy()
        # The real read-only object database supplies already declared committed
        # stages. The provided tree itself is the retained uncommitted epoch.
        env.update(GIT_DIR=str(ROOT / '.git'), GIT_WORK_TREE=str(provided),
                   GIT_OPTIONAL_LOCKS='0', PYTHONDONTWRITEBYTECODE='1')
        for script in ('objective_current_review.py', 'objective_recovery_review.py'):
            command = ['bash', 'tools/run_python_project_data.sh',
                       str(HERE.relative_to(ROOT) / script)]
            result = subprocess.run(command, cwd=provided, env=env, capture_output=True)
            assert result.returncode == 0 and result.stderr == b'', (script, result.returncode, result.stderr.decode(errors='replace'))
            value = json.loads(result.stdout)
            assert value['result'] == 'PASS'
            commands.append(dict(argv=command, cwd='provided retained epoch', exit=0,
                                 stdout_sha256=hashlib.sha256(result.stdout).hexdigest(), result=value))
        for name, row in sources.items():
            path = provided / name
            assert path.read_bytes() == decode(row), 'replay altered retained input: ' + name
            assert path.stat().st_mode & 0o777 == row['mode']
    return dict(result='PASS', exact_inline_inputs=len(rows), logical_sources=len(sources), commands=commands,
                boundary='Retained logical artifact epoch; no historical Git capture or new native observation.')


if __name__ == '__main__':
    print(json.dumps(review(), sort_keys=True))
