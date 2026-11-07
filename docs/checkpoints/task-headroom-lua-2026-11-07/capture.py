"""One-shot existing-protocol migration; retain actual inputs and full channels."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'first'
SOURCE = Path('docs/tasks/LUA-BACKEND-PARITY.md')
EPOCH = 'TYPE-REFERENCE-BOOK.1.2.23.4.16'
MANIFEST = Path('docs/history/task-narrative-epochs') / (EPOCH + '.json')
ACTIVATION = '2286c6606a9fb86290801e1c8a0053e59d342a1f'


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def archive(target, paths):
    records = {}
    with tarfile.open(target, 'x:gz') as output:
        for path in sorted(set(paths)):
            assert not path.is_absolute() and '..' not in path.parts
            cursor = ROOT
            for part in path.parts:
                cursor /= part
                assert not cursor.is_symlink() and cursor.stat().st_dev == ROOT.stat().st_dev
            assert path.is_file()
            raw = path.read_bytes()
            records[str(path)] = dict(identity(raw), mode=path.stat().st_mode & 0o777)
            output.add(path, arcname=str(path), recursive=False)
    return records


assert git('rev-parse', 'HEAD').decode().strip() == ACTIVATION
assert not MANIFEST.exists() and not OUT.exists()
assert SOURCE.read_bytes() == git('show', ACTIVATION + ':' + str(SOURCE))
OUT.mkdir()
paths = list(Path('docs/tasks').glob('*.md')) + list(Path('docs/tasks').glob('*.index.jsonl'))
for directory in ('docs/history/task-narrative', 'docs/history/task-narrative-epochs'):
    paths += [p for p in Path(directory).rglob('*') if p.is_file()]
paths += [Path('tools') / p for p in (
    'task_narrative.py', 'migrate_task_narrative.py', 'read_task_narrative.py',
    'check_task_narrative.py', 'test_task_narrative.py', 'check_memory_handoff_state.py',
    'check_unicode_case_contract.py', 'check_capability_conformance.pl',
    'check_language_closure_contract.py', 'project_data_env.sh',
    'project_data_run.sh', 'run_python_project_data.sh')]
paths += [BASE / 'capture.py', Path('doctrine/readme_stability/routes.jsonl')]
paths += [Path('capability_conformance') / p for p in (
    'unicode_case_contract.json', 'language_closure_contract.json', 'manifest.json')]
before = archive(OUT / 'inputs-before-first-migration.tar.gz', paths)
(OUT / 'input-identities.json').write_text(json.dumps(before, indent=2, sort_keys=True) + '\n')
(OUT / 'tracked-before.patch.gz').write_bytes(gzip.compress(git('diff', '--binary', 'HEAD'), mtime=0))
(OUT / 'activation.txt').write_text(ACTIVATION + '\n')
(OUT / 'host.json').write_text(json.dumps(dict(python=sys.version), indent=2) + '\n')
commands = {}


def run(name, command, expected):
    assert name not in commands
    commands[name] = dict(argv=command, cwd='.', expected_exit=expected)
    (OUT / 'commands.json').write_text(json.dumps(commands, indent=2) + '\n')
    result = subprocess.run(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel, raw in (('stdout', result.stdout), ('stderr', result.stderr)):
        (OUT / (name + '-' + channel + '.log.gz')).write_bytes(gzip.compress(raw, mtime=0))
    (OUT / (name + '-exit.txt')).write_text(str(result.returncode) + '\n')
    print(name, 'actual exit', result.returncode, flush=True)
    assert result.returncode == expected, 'retain unexpected epoch; qualify separately'
    return result


reader = ['bash', 'tools/run_python_project_data.sh', 'tools/read_task_narrative.py',
          '--tree', 'LUA-BACKEND-PARITY', '--epoch', EPOCH]
old = run('before-query', reader + ['--id', 'LUA-BACKEND-PARITY.8.4'], 1)
assert b'epoch input is missing' in old.stderr
run('migration', ['bash', 'tools/run_python_project_data.sh', 'tools/migrate_task_narrative.py',
                 '--apply', '--epoch', EPOCH, '--tree', 'LUA-BACKEND-PARITY',
                 '--source-commit', ACTIVATION], 0)
after = archive(OUT / 'actual-migrated-images.tar.gz', [SOURCE, MANIFEST])
(OUT / 'migrated-identities.json').write_text(json.dumps(after, indent=2, sort_keys=True) + '\n')
run('node-query', reader + ['--id', 'LUA-BACKEND-PARITY.8.4'], 0)
whole = run('whole-query', reader + ['--all'], 0)
assert whole.stdout == git('show', ACTIVATION + ':' + str(SOURCE))
run('narrative', ['bash', 'tools/run_python_project_data.sh', 'tools/check_task_narrative.py'], 0)
run('unicode-owner', ['bash', 'tools/run_python_project_data.sh', 'tools/check_unicode_case_contract.py'], 0)
run('capability-owners', ['bash', 'tools/project_data_run.sh', 'perl', 'tools/check_capability_conformance.pl'], 0)
run('closure-owners', ['bash', 'tools/run_python_project_data.sh', 'tools/check_language_closure_contract.py'], 0)
for name, expected in before.items():
    if name != str(SOURCE):
        assert identity(Path(name).read_bytes()) == {k: expected[k] for k in ('bytes', 'sha256')}, name
        assert Path(name).stat().st_mode & 0o777 == expected['mode']
(OUT / 'tracked-after.patch.gz').write_bytes(gzip.compress(git('diff', '--binary', 'HEAD'), mtime=0))
(OUT / 'result.json').write_text(json.dumps(dict(
    owner=EPOCH, activation=ACTIVATION, source=str(SOURCE), manifest=str(MANIFEST),
    tracked_input_boundary='Retained activation Git plus exact before patch; direct migration/query inputs archived before use.',
    limits='No runtime or Lua5.4 admission; OS/toolchain/transitive custody and general isolation remain separate4.2/SESSION5.'
), indent=2) + '\n')
print('Actual source-bound migration, complete public queries and direct owner consumers retained')
