"""Retain the first semantic RED, restore exact legacy current sections."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
FIRST = BASE / 'first'
OUT = BASE / 'qualified'
SOURCE = Path('docs/tasks/LUA-BACKEND-PARITY.md')
MANIFEST = Path('docs/history/task-narrative-epochs/TYPE-REFERENCE-BOOK.1.2.23.4.16.json')


def recover(path):
    with tarfile.open(path) as source:
        return {m.name: source.extractfile(m).read() for m in source if m.isfile()}


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


original = recover(FIRST / 'inputs-before-first-migration.tar.gz')[str(SOURCE)]
first = recover(FIRST / 'actual-migrated-images.tar.gz')
assert SOURCE.read_bytes() == first[str(SOURCE)] and MANIFEST.read_bytes() == first[str(MANIFEST)]
assert original.count(b'## Current frontier\n') == 1
tail = original[original.index(b'## Current frontier\n'):]
assert b'## Current frontier\n' not in SOURCE.read_bytes(), 'retain the actual first loss'
assert not OUT.exists()
OUT.mkdir()
dependencies = [FIRST / name for name in ('input-identities.json', 'inputs-before-first-migration.tar.gz',
                                           'actual-migrated-images.tar.gz', 'migrated-identities.json')]
(OUT / 'dependency-identities.json').write_text(json.dumps(
    {str(p): identity(p.read_bytes()) for p in dependencies}, indent=2) + '\n')
paths = [Path(p) for p in json.loads((FIRST / 'input-identities.json').read_bytes())]
paths += [BASE / 'qualify_legacy_tail.py', MANIFEST]
identities = {}
with tarfile.open(OUT / 'inputs-before-first-restoration.tar.gz', 'x:gz') as output:
    for path in sorted(set(paths)):
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        identities[str(path)] = dict(identity(raw), mode=path.stat().st_mode & 0o777)
        output.add(path, arcname=str(path), recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
(OUT / 'boundary-before.json').write_text(json.dumps(dict(
    result='RED', expected='exact legacy current frontier and all trailing sections remain current',
    actual_tail_present=False, current=identity(SOURCE.read_bytes()), original_tail=identity(tail)), indent=2) + '\n')
SOURCE.write_bytes(first[str(SOURCE)] + tail)
assert SOURCE.read_bytes().endswith(tail)
with tarfile.open(OUT / 'actual-qualified-images.tar.gz', 'x:gz') as output:
    output.add(SOURCE, arcname=str(SOURCE), recursive=False)
    output.add(MANIFEST, arcname=str(MANIFEST), recursive=False)
(OUT / 'boundary-after.json').write_text(json.dumps(dict(
    result='GREEN', actual_tail_present=True, current=identity(SOURCE.read_bytes()),
    restored_tail=identity(tail), source_bytes_renewed=len(original)-SOURCE.stat().st_size), indent=2) + '\n')
commands = {}


def run(name, command):
    commands[name] = dict(argv=command, cwd='.', expected_exit=0)
    (OUT / 'commands.json').write_text(json.dumps(commands, indent=2) + '\n')
    actual = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for label, raw in (('stdout', actual.stdout), ('stderr', actual.stderr)):
        (OUT / (name + '-' + label + '.log.gz')).write_bytes(gzip.compress(raw, mtime=0))
    (OUT / (name + '-exit.txt')).write_text(str(actual.returncode) + '\n')
    print(name, 'actual exit', actual.returncode, flush=True)
    assert actual.returncode == 0 and not actual.stderr, 'retain unexpected qualification unchanged'
    return actual.stdout


reader = ['bash', 'tools/run_python_project_data.sh', 'tools/read_task_narrative.py',
          '--tree', 'LUA-BACKEND-PARITY', '--epoch', 'TYPE-REFERENCE-BOOK.1.2.23.4.16']
assert run('whole-query', reader + ['--all']) == original
assert run('node-query', reader + ['--id', 'LUA-BACKEND-PARITY.8.4']) == gzip.decompress((FIRST / 'node-query-stdout.log.gz').read_bytes())
run('narrative', ['bash', 'tools/run_python_project_data.sh', 'tools/check_task_narrative.py'])
run('unicode-owner', ['bash', 'tools/run_python_project_data.sh', 'tools/check_unicode_case_contract.py'])
run('capability-owners', ['bash', 'tools/project_data_run.sh', 'perl', 'tools/check_capability_conformance.pl'])
run('closure-owners', ['bash', 'tools/run_python_project_data.sh', 'tools/check_language_closure_contract.py'])
for name, expected in identities.items():
    if name != str(SOURCE):
        assert identity(Path(name).read_bytes()) == {k: expected[k] for k in ('bytes', 'sha256')}, name
        assert Path(name).stat().st_mode & 0o777 == expected['mode']
assert all(identity(p.read_bytes()) == json.loads((OUT / 'dependency-identities.json').read_bytes())[str(p)] for p in dependencies)
print('Exact legacy tail restored; first semantic RED and imprecise-node-query limit retained; generic repair4.17 remains open')
