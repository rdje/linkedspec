"""Capture focused recurring tests and a reason-sensitive legacy RED/raw GREEN."""
import gzip
import hashlib
import io
import json
import os
from pathlib import Path
import stat
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'normal'
OUT.mkdir()
ORACLES = BASE / 'oracles'
ORACLES.mkdir()


def identity(path):
    assert not path.is_absolute() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    return dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))


def freeze(paths, destination):
    rows = {}
    with tarfile.open(destination, 'x:gz') as archive:
        for path in sorted(set(paths)):
            rows[str(path)] = identity(path)
            member = tarfile.TarInfo(str(path))
            member.size, member.mode = rows[str(path)]['bytes'], rows[str(path)]['mode']
            archive.addfile(member, io.BytesIO(path.read_bytes()))
    with tarfile.open(destination) as archive:
        assert set(archive.getnames()) == rows.keys()
        for member in archive:
            body = archive.extractfile(member).read()
            assert dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=member.mode) == rows[member.name]
    return rows


def verify(rows):
    for name, row in rows.items():
        assert identity(Path(name)) == row, 'actual before-use input changed: ' + name


def execute(folder, tag, command, environment):
    selected = {key: environment[key] for key in ('LUA_PATH', 'LUA_CPATH', 'LINKEDSPEC_LUA_TEST_RUNTIME')}
    if 'LINKEDSPEC_RAW_ERROR_CAPTURE' in environment:
        selected['LINKEDSPEC_RAW_ERROR_CAPTURE'] = environment['LINKEDSPEC_RAW_ERROR_CAPTURE']
    (folder / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.', environment=selected), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, env=environment, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (folder / (tag + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (folder / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    return result


paths = [Path(name.decode()) for name in subprocess.check_output(['git', 'ls-files', '-z', '--', 'lua']).split(b'\0') if name]
paths += [Path('lua/test') / name for name in ('raw_error_observation.lua', 'raw_error_observation_test.lua')]
paths += [Path('tests/fixtures') / name for name in ('lua_raw_error_observation_cases.json', 'lua_raw_error_observation_profiles.json')]
paths += [BASE / name for name in ('run_normal.py', 'field_oracle.lua', 'prepare_normal.py', 'prepare-normal-before-use.py.gz', 'normal-preparation-inputs.json', 'cases.json', 'analysis/old-profiles.json', 'analysis/result.json')]
paths += [Path('tools') / name for name in ('project_data_run.sh', 'project_data_env.sh')]
paths += [Path('specs') / name for name in ('spec.spec', 'pplugin.spec', 'user_function_definition.spec')]
for host in ('puc', 'luajit'):
    path = BASE / 'epochs' / (host + '-native-identities.json')
    paths.append(path)
    native = json.loads(path.read_bytes())
    verify(native)
    paths += [Path(name) for name in native]
inputs = freeze(paths, OUT / 'inputs-before-use.tar.gz')
(OUT / 'input-identities.json').write_text(json.dumps(inputs, indent=2, sort_keys=True) + '\n')
assert Path('tests/fixtures/lua_raw_error_observation_cases.json').read_bytes() == (BASE / 'cases.json').read_bytes()
assert Path('tests/fixtures/lua_raw_error_observation_profiles.json').read_bytes() == (BASE / 'analysis/old-profiles.json').read_bytes()
profiles = json.loads((BASE / 'analysis/old-profiles.json').read_bytes())
results = {}
for host in ('puc', 'luajit'):
    folder = OUT / host
    folder.mkdir()
    (ORACLES / host).mkdir()
    runtime = os.environ.get('LINKEDSPEC_LUA_CMD' if host == 'puc' else 'LINKEDSPEC_LUAJIT_CMD', 'lua' if host == 'puc' else 'luajit')
    environment = {key: value for key, value in os.environ.items() if not key.startswith(('LUA_INIT', 'LUA_PATH_', 'LUA_CPATH_'))}
    environment.update(LUA_PATH='lua/src/?.lua;lua/src/?/init.lua;;',
        LUA_CPATH='.linkedspec-data/raw-error-audit/native/' + host + '/?.so;;', LINKEDSPEC_LUA_TEST_RUNTIME=runtime)
    version = execute(folder, 'version', ['bash', 'tools/project_data_run.sh', runtime, '-v'], environment)
    assert version.returncode == 0
    environment['LINKEDSPEC_RAW_ERROR_CAPTURE'] = str(folder)
    verify(inputs)
    result = execute(folder, 'normal', ['bash', 'tools/project_data_run.sh', runtime, 'lua/test/raw_error_observation_test.lua'], environment)
    assert result.returncode == 0 and result.stderr == b'', 'Actual normal failure retained'
    rows = {}
    for line in result.stdout.decode().splitlines():
        if line.startswith('RAW_ERROR_NORMAL '):
            _, name, body = line.split(' ', 2)
            assert name not in rows
            rows[name] = json.loads(body)
    assert rows == profiles[host]
    assert b'RAW_ERROR_NORMAL_OWNER @lua/src/linkedspec/interpreter.lua\n' in result.stdout
    assert b'RAW_ERROR_NORMAL_SUMMARY 128 checks PASS\n' in result.stdout
    artifacts = list(folder.glob('*.parsed.json')) + list(folder.glob('*.emitted.lua'))
    assert len(artifacts) == 16
    identities = freeze(artifacts, folder / 'actual-parsed-emitted.tar.gz')
    (folder / 'artifact-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
    environment.pop('LINKEDSPEC_RAW_ERROR_CAPTURE')
    for mode in ('legacy', 'raw'):
        target = ORACLES / host / mode
        target.mkdir()
        verify(inputs)
        oracle = execute(target, 'oracle', ['bash', 'tools/project_data_run.sh', runtime,
            str(BASE / 'field_oracle.lua'), mode, str(target)], environment)
        if mode == 'legacy':
            assert oracle.returncode == 1 and b'raw-field oracle: projection misses expected_kind' in oracle.stderr
            assert b'RAW_FIELD_ORACLE legacy own_needed_source_take_receiver expected_kind false\n' in oracle.stdout
        else:
            assert oracle.returncode == 0 and oracle.stderr == b''
            assert b'RAW_FIELD_ORACLE raw own_needed_source_take_receiver expected_kind true\n' in oracle.stdout
            assert b'RAW_FIELD_ORACLE raw own_signature_fixed_missing_composed rule_label true\n' in oracle.stdout
        parsed = list(target.glob('*.parsed.json'))
        assert len(parsed) == (1 if mode == 'legacy' else 2)
        identities = freeze(parsed, target / 'actual-parsed.tar.gz')
        (target / 'artifact-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
    verify(inputs)
    results[host] = dict(normal_exit=0, normal_checks=128, cases=8, routes=4, legacy_oracle_exit=1, raw_oracle_exit=0)
    print(host + ': normal128PASS, specific legacyRED1 and rawGREEN0', flush=True)
(OUT / 'result.json').write_text(json.dumps(results, indent=2, sort_keys=True) + '\n')
