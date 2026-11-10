"""Repository-local finite I/O; retain real complete channels and source bodies."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path('docs/checkpoints/array-transform-result-guard-julia-2026-11-10')
OWNER = Path('julia/src/runtime/Interpreter.jl')
NORMAL = Path('julia/test/array_transform_result_guard_composition_test.jl')
FIXTURE = Path('tests/fixtures/array_transform_result_guard_julia_cases.json')
PROFILE = Path('tests/fixtures/array_transform_result_guard_julia_profiles.json')
GRAMMAR = Path('specs/user_function_definition.spec')


def freeze(out, paths, stem='input', name='inputs-before-first-run.tar.gz'):
    records = {}
    with tarfile.open(out / name, 'w:gz') as archive:
        for path in sorted(set(paths)):
            assert not path.is_absolute() and '..' not in path.parts
            assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
            body = path.read_bytes()
            records[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(),
                                      mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=path, recursive=False)
    with tarfile.open(out / name) as archive:
        assert set(archive.getnames()) == records.keys()
        for member in archive:
            expected = records[member.name]
            body = archive.extractfile(member).read()
            assert hashlib.sha256(body).hexdigest() == expected['sha256'] and len(body) == expected['bytes']
            assert member.mode & 0o777 == expected['mode']
    (out / (stem + '-identities.json')).write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
    return records


def verify(records):
    for name, expected in records.items():
        path = Path(name)
        assert path.is_file() and not path.is_symlink()
        assert hashlib.sha256(path.read_bytes()).hexdigest() == expected['sha256']
        assert path.stat().st_mode & 0o777 == expected['mode']


def execute(out, tag, command, environment):
    keys = ('JULIA_NUM_THREADS', 'OPENBLAS_NUM_THREADS', 'JULIA_PKG_PRECOMPILE_AUTO',
            'LINKEDSPEC_ARRAY_TRANSFORM_CAPTURE')
    packet = dict(argv=command, cwd='.', environment={k: environment[k] for k in keys if k in environment})
    (out / (tag + '-command.json')).write_text(json.dumps(packet, indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, env=environment, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (out / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (out / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    return result


def artifacts(out):
    files = sorted((out / 'emitted').glob('*.jl')) + sorted((out / 'parsed').glob('*.json'))
    records = freeze(out, files, 'artifact', 'actual-emitted-parsed.tar.gz')
    verify(records)
    for path in files:
        path.unlink()  # Verified owned duplicates; complete original bytes remain archived.
    for name in ('emitted', 'parsed'):
        (out / name).rmdir()


def frames(body, tag='ARRAY_TRANSFORM_JULIA_NORMAL'):
    rows = {}
    for line in body.decode().splitlines():
        if line.startswith(tag + ' '):
            _, key, value = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(value)
    return rows
