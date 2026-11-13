"""Freeze the bounded error audit's sources before any SDK/probe consumption."""
import hashlib
import json
from pathlib import Path
import stat
import subprocess
import tarfile
import io

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = 'e0a1bb47571b75b800546c3d4522e0d2ca5f778c'
OLD = 'fff959ef7e8896b5b97f311a276cabc4f5034551'
PACK = Path('.linkedspec-data/push-monitor/20261113T004910.681476Z')
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
OUT = BASE / 'intake'
OUT.mkdir()
assert OUT.stat().st_dev == ROOT.stat().st_dev


def identity(body, mode):
    return dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=mode)


def freeze(paths, destination):
    identities = {}
    with tarfile.open(destination, 'x:gz') as archive:
        for path in sorted(set(paths)):
            assert not path.is_absolute() and '..' not in path.parts
            metadata = path.lstat()
            assert stat.S_ISREG(metadata.st_mode) and metadata.st_dev == ROOT.stat().st_dev
            body = path.read_bytes()
            row = identity(body, stat.S_IMODE(metadata.st_mode))
            member = tarfile.TarInfo(path.as_posix())
            member.size, member.mode = len(body), row['mode']
            archive.addfile(member, io.BytesIO(body))
            identities[path.as_posix()] = row
    with tarfile.open(destination) as archive:
        assert set(archive.getnames()) == identities.keys()
        for member in archive:
            assert member.isfile()
            assert identity(archive.extractfile(member).read(), member.mode) == identities[member.name]
    return identities


paths = [Path(name.decode()) for name in subprocess.check_output(['git', 'ls-files', '-z', '--', 'lua']).split(b'\0') if name]
paths += [Path('specs') / name for name in ('spec.spec', 'pplugin.spec', 'user_function_definition.spec')]
paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh', 'run_lua_project_data.sh', 'build_lua_native.sh')]
paths += [BASE / 'intake.py', Path('MEMORY.md'), Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md'), Path('docs/tasks/TYPE-REFERENCE-BOOK.md')]
paths += [Path('docs/knowledge') / (name + '.md') for name in ('lua-runtime-structured-diagnostics', 'lua-callable-pipeline-result-guards', 'lua-callable-array-transform-result-guards')]
paths += [Path('docs/linkedspec-book/src') / name for name in ('appendix/runtime-semantics.md', 'appendix/backend-handoff.md', 'dsl/value-container-flow-helper-reference.md')]
previous = Path('docs/checkpoints/array-transform-callable-lua-2026-11-12')
paths += [previous / name for name in ('REVIEW.md', 'proof_io.py', 'field_probe.lua', 'capture_field_probe.py', 'observer.lua', 'cases.json')]
for host in ('puc', 'luajit'):
    paths += [previous / 'intake' / host / name for name in ('native-identities.json', 'native-before-first-run.tar.gz')]
    paths += [path for path in (previous / 'fieldprobe' / host).iterdir() if path.is_file()]
paths += [previous / 'fieldprobe' / name for name in ('cases.json', 'complete.txt', 'input-identities.json', 'inputs-before-first-run.tar.gz')]
for name in ('array-pipeline-callable-lua-2026-11-11', 'array-concat-open-arity-lua-2026-11-12'):
    paths.append(Path('docs/checkpoints') / name / 'REVIEW.md')
paths += [path for path in PACK.iterdir() if path.is_file() and path.suffix in ('.json', '.gz', '.txt', '.log')]
paths.append(Path('.linkedspec-data/ram-host-size-commit.log'))
current = freeze(paths, OUT / 'inputs-before-use.tar.gz')
(OUT / 'input-identities.json').write_text(json.dumps(current, indent=2, sort_keys=True) + '\n')

old = {}
tree = subprocess.check_output(['git', 'ls-tree', '-rz', OLD, '--', 'lua/src'])
with tarfile.open(OUT / 'old-sdk-sources.tar.gz', 'x:gz') as archive:
    for entry in tree.split(b'\0'):
        if not entry:
            continue
        metadata, encoded_name = entry.split(b'\t', 1)
        mode, kind, oid = metadata.decode().split()
        name = encoded_name.decode()
        assert kind == 'blob' and mode in ('100644', '100755')
        body = subprocess.check_output(['git', 'show', OLD + ':' + name])
        row = identity(body, int(mode, 8) & 0o777)
        row['git_oid'] = oid
        member = tarfile.TarInfo(name)
        member.size, member.mode = len(body), row['mode']
        archive.addfile(member, io.BytesIO(body))
        old[name] = row
with tarfile.open(OUT / 'old-sdk-sources.tar.gz') as archive:
    assert set(archive.getnames()) == old.keys()
    for member in archive:
        expected = {key: value for key, value in old[member.name].items() if key != 'git_oid'}
        assert identity(archive.extractfile(member).read(), member.mode) == expected
(OUT / 'old-sdk-identities.json').write_text(json.dumps(old, indent=2, sort_keys=True) + '\n')

for name, row in current.items():
    path = Path(name)
    assert identity(path.read_bytes(), stat.S_IMODE(path.stat().st_mode)) == row
result = dict(activation=ACTIVATION, old_sdk=OLD, current_inputs=len(current), old_sdk_inputs=len(old),
    scope='Complete selected source/consumer bodies and actual prior probe/monitor channels; no SDK run or native build. Native/cache/toolchain/OS closure remains4.2/SESSION5.')
(OUT / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(result, sort_keys=True))
