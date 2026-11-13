"""One-shot old/current selected-error observations with before-use custody."""
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
ACTIVATION = 'e0a1bb47571b75b800546c3d4522e0d2ca5f778c'
OLD = 'fff959ef7e8896b5b97f311a276cabc4f5034551'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
OUT = BASE / 'epochs'
OUT.mkdir()
PRIVATE = Path('.linkedspec-data/raw-error-audit')
PRIVATE.mkdir()


def digest(body, mode):
    return dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=mode)


def freeze(paths, destination):
    rows = {}
    with tarfile.open(destination, 'x:gz') as archive:
        for path in sorted(set(paths)):
            assert not path.is_absolute() and '..' not in path.parts
            metadata = path.lstat()
            assert stat.S_ISREG(metadata.st_mode) and metadata.st_dev == ROOT.stat().st_dev
            body = path.read_bytes()
            rows[str(path)] = digest(body, stat.S_IMODE(metadata.st_mode))
            member = tarfile.TarInfo(str(path))
            member.size, member.mode = len(body), rows[str(path)]['mode']
            archive.addfile(member, io.BytesIO(body))
    with tarfile.open(destination) as archive:
        assert set(archive.getnames()) == rows.keys()
        for member in archive:
            assert member.isfile() and digest(archive.extractfile(member).read(), member.mode) == rows[member.name]
    return rows


def verify(rows):
    for name, row in rows.items():
        path = Path(name)
        assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        assert digest(path.read_bytes(), stat.S_IMODE(path.stat().st_mode)) == row


def execute(folder, tag, command, environment):
    selected = {key: environment[key] for key in ('LUA_PATH', 'LUA_CPATH', 'LINKEDSPEC_LUA_TEST_RUNTIME')}
    (folder / (tag + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.', environment=selected), indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, env=environment, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (folder / (tag + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (folder / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    return result


paths = [Path(name.decode()) for name in subprocess.check_output(['git', 'ls-files', '-z', '--', 'lua']).split(b'\0') if name]
paths += [Path('lua/test/raw_error_observation.lua')]
paths += [BASE / name for name in ('capture.py', 'probe.lua', 'cases.json', 'prepare.py', 'prepare-before-use.py.gz', 'preparation.json')]
paths += [BASE / 'intake' / name for name in ('inputs-before-use.tar.gz', 'input-identities.json', 'old-sdk-sources.tar.gz', 'old-sdk-identities.json', 'result.json')]
paths += [Path('specs') / name for name in ('spec.spec', 'pplugin.spec', 'user_function_definition.spec')]
paths += [Path('tools') / name for name in ('project_data_run.sh', 'project_data_env.sh')]
inputs = freeze(paths, OUT / 'inputs-before-use.tar.gz')
(OUT / 'input-identities.json').write_text(json.dumps(inputs, indent=2, sort_keys=True) + '\n')

old_root = PRIVATE / 'old'
old_identities = json.loads((BASE / 'intake/old-sdk-identities.json').read_bytes())
old_paths = []
with tarfile.open(BASE / 'intake/old-sdk-sources.tar.gz') as archive:
    assert set(archive.getnames()) == old_identities.keys()
    for member in archive:
        assert member.isfile() and member.name.startswith('lua/src/') and '..' not in Path(member.name).parts
        body = archive.extractfile(member).read()
        expected = {key: value for key, value in old_identities[member.name].items() if key != 'git_oid'}
        assert digest(body, member.mode) == expected
        target = old_root / member.name
        target.parent.mkdir(parents=True, exist_ok=True)
        assert not target.exists()
        target.write_bytes(body)
        target.chmod(member.mode)
        old_paths.append(target)
for name in ('spec.spec', 'pplugin.spec', 'user_function_definition.spec'):
    path = Path('specs') / name
    body = subprocess.check_output(['git', 'show', OLD + ':' + str(path)])
    assert body == path.read_bytes(), 'grammar inputs must agree across these source epochs'
    target = old_root / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(body)
    target.chmod(0o644)
    old_paths.append(target)
old_inputs = freeze(old_paths, OUT / 'old-materialized-before-use.tar.gz')
(OUT / 'old-materialized-identities.json').write_text(json.dumps(old_inputs, indent=2, sort_keys=True) + '\n')

native_products = {}
previous = 'docs/checkpoints/array-transform-callable-lua-2026-11-12/intake/'
with tarfile.open(BASE / 'intake/inputs-before-use.tar.gz') as retained:
    for host in ('puc', 'luajit'):
        native_root = PRIVATE / 'native' / host
        native_root.mkdir(parents=True)
        source = previous + host + '/native-before-first-run.tar.gz'
        raw_archive = retained.extractfile(source).read()
        original_rows = json.loads(retained.extractfile(previous + host + '/native-identities.json').read())
        files = []
        with tarfile.open(fileobj=io.BytesIO(raw_archive)) as archive:
            assert set(archive.getnames()) == original_rows.keys()
            for member in archive:
                assert member.isfile()
                body = archive.extractfile(member).read()
                assert digest(body, member.mode) == original_rows[member.name]
                target = native_root / Path(member.name).name
                assert target.name in ('linkedspec_regex_pcre2.so', 'linkedspec_filesystem_native.so', 'linkedspec_mcp_system.so')
                target.write_bytes(body)
                target.chmod(member.mode)
                files.append(target)
        native_products[host] = freeze(files, OUT / (host + '-native-before-use.tar.gz'))
        (OUT / (host + '-native-identities.json')).write_text(json.dumps(native_products[host], indent=2, sort_keys=True) + '\n')

expected_ids = {row['id'] for row in json.loads((BASE / 'cases.json').read_bytes())}
observations = {}
for epoch, input_root in (('old', str(old_root) + '/'), ('current', '')):
    (OUT / epoch).mkdir()
    for host in ('puc', 'luajit'):
        folder = OUT / epoch / host
        folder.mkdir()
        runtime = os.environ.get('LINKEDSPEC_LUA_CMD' if host == 'puc' else 'LINKEDSPEC_LUAJIT_CMD', 'lua' if host == 'puc' else 'luajit')
        environment = {key: value for key, value in os.environ.items() if not key.startswith(('LUA_INIT', 'LUA_PATH_', 'LUA_CPATH_'))}
        environment.update(LUA_PATH=input_root + 'lua/src/?.lua;' + input_root + 'lua/src/?/init.lua;;',
            LUA_CPATH=str(PRIVATE / 'native' / host / '?.so') + ';;', LINKEDSPEC_LUA_TEST_RUNTIME=runtime)
        verify(inputs)
        verify(old_inputs)
        verify(native_products[host])
        version = execute(folder, 'version', ['bash', 'tools/project_data_run.sh', runtime, '-v'], environment)
        assert version.returncode == 0
        result = execute(folder, 'probe', ['bash', 'tools/project_data_run.sh', runtime,
            str(BASE / 'probe.lua'), str(BASE / 'cases.json'), str(folder), input_root], environment)
        assert result.returncode == 0 and result.stderr == b'', 'Actual SDK probe failure retained at ' + str(folder)
        rows = {}
        for line in result.stdout.decode().splitlines():
            if line.startswith('RAW_ERROR_CASE '):
                _, identifier, value = line.split(' ', 2)
                assert identifier not in rows
                rows[identifier] = json.loads(value)
        assert rows.keys() == expected_ids
        assert ('RAW_ERROR_OWNER @' + input_root + 'lua/src/linkedspec/interpreter.lua\n').encode() in result.stdout
        artifacts = list(folder.glob('*.parsed.json')) + list(folder.glob('*.emitted.lua'))
        assert len(artifacts) == 2 * len(expected_ids)
        artifact_rows = freeze(artifacts, folder / 'actual-parsed-emitted.tar.gz')
        (folder / 'artifact-identities.json').write_text(json.dumps(artifact_rows, indent=2, sort_keys=True) + '\n')
        verify(inputs)
        verify(old_inputs)
        verify(native_products[host])
        observations[(epoch, host)] = rows
        print(epoch + '/' + host + ': selected errors and actual artifact inputs captured', flush=True)
for host in ('puc', 'luajit'):
    assert observations[('old', host)] == observations[('current', host)], 'Old/current selected raw and published observations differ'
report = dict(activation=ACTIVATION, old_sdk=OLD, cases=len(expected_ids), routes=['native', 'restored', 'plan', 'fresh'],
    hosts=['puc', 'luajit'], old_current_equal=True,
    scope='Complete observed acyclic field names/finite values, not Lua identity/metatable/all-error completeness. Reused retained opaque native products; native/cache/toolchain/OS and wider module-source closure remain4.2/SESSION5.')
(OUT / 'result.json').write_text(json.dumps(report, indent=2, sort_keys=True) + '\n')
print(json.dumps(report, sort_keys=True))
