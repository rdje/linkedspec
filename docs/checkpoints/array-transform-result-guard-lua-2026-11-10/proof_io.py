"""Finite Lua inputs/native products/artifacts and complete physical channels."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path('docs/checkpoints/array-transform-result-guard-lua-2026-11-10')
OWNER = Path('lua/src/linkedspec/interpreter.lua')
NORMAL = Path('lua/test/array_transform_result_guard_composition_test.lua')
FIXTURE = Path('tests/fixtures/array_transform_result_guard_lua_cases.json')
PROFILE = Path('tests/fixtures/array_transform_result_guard_lua_profiles.json')
GRAMMAR = Path('specs/user_function_definition.spec')
HOSTS = ('puc', 'luajit')


def freeze(out, paths, stem='input', name='inputs-before-first-run.tar.gz'):
    rows = {}
    with tarfile.open(out / name, 'x:gz') as archive:
        for path in sorted(set(paths)):
            assert not path.is_absolute() and '..' not in path.parts
            assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
            body = path.read_bytes()
            rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=path, recursive=False)
    with tarfile.open(out / name) as archive:
        assert set(archive.getnames()) == rows.keys()
        for member in archive:
            row = rows[member.name]
            body = archive.extractfile(member).read()
            assert hashlib.sha256(body).hexdigest() == row['sha256'] and len(body) == row['bytes']
            assert member.mode & 0o777 == row['mode']
    (out / (stem + '-identities.json')).write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
    return rows


def verify(rows):
    for name, row in rows.items():
        path = Path(name)
        assert path.is_file() and not path.is_symlink()
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256']
        assert path.stat().st_mode & 0o777 == row['mode']


def execute(out, tag, command, environment):
    keys = ('LUA_PATH', 'LUA_CPATH', 'LINKEDSPEC_LUA_TEST_RUNTIME',
            'LINKEDSPEC_ARRAY_TRANSFORM_CAPTURE', 'LINKEDSPEC_ARRAY_TRANSFORM_INPUT_ROOT')
    (out / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.',
        environment={key: environment[key] for key in keys if key in environment}), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, env=environment, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (out / (tag + '-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (out / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    return result


def build_native(out, host, environment):
    native = out / 'native'
    assert execute(out, 'build', ['bash', 'tools/build_lua_native.sh', host, str(native)], environment).returncode == 0
    files = [native / name for name in ('linkedspec_regex_pcre2.so', 'linkedspec_filesystem_native.so', 'linkedspec_mcp_system.so')]
    assert set(native.iterdir()) == set(files)
    rows = freeze(out, files, 'native', 'native-before-first-run.tar.gz')
    return native, rows


def artifacts(out):
    files = sorted((out / 'emitted').glob('*.lua')) + sorted((out / 'parsed').glob('*.json'))
    rows = freeze(out, files, 'artifact', 'actual-emitted-parsed.tar.gz')
    verify(rows)
    for path in files:
        path.unlink()
    (out / 'emitted').rmdir()
    (out / 'parsed').rmdir()


def frames(body, tag='ARRAY_TRANSFORM_LUA_NORMAL'):
    rows = {}
    for line in body.decode().splitlines():
        if line.startswith(tag + ' '):
            _, key, value = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(value)
    return rows
