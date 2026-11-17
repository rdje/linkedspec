"""Retain and migrate one qualified closed tree through the existing epoch API."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import stat
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = '08c39a2dfb4be628af24a445a7fdbb98a82e962f'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.35'
TREE = 'PERL-ACTIONIR-AST-MIGRATION'
TARGET = 'docs/tasks/' + TREE + '.md'
MANIFEST = 'docs/history/task-narrative-epochs/' + OWNER + '.json'
PRESSURE = Path('docs/checkpoints/rust-loader-qualification-2026-11-16')


def native(tag, argv, accepted=0):
    folder = BASE / 'commands'
    folder.mkdir(exist_ok=True)
    with (folder / (tag + '-command.json')).open('x') as stream:
        json.dump(dict(argv=argv, cwd='.'), stream, indent=2)
        stream.write('\n')
    result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (folder / (tag + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (folder / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == accepted, 'actual command failure retained:' + tag
    assert not result.stderr, 'actual stderr retained:' + tag
    return result.stdout


def freeze(label, paths):
    identities = {}
    with tarfile.open(BASE / (label + '.tar.gz'), 'x:gz') as archive:
        for name in sorted(set(paths)):
            path = Path(name)
            assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
            assert path.is_file() and path.stat().st_dev == ROOT.stat().st_dev
            body = path.read_bytes()
            identities[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
            archive.add(path, arcname=name, recursive=False)
    (BASE / (label + '-identities.json')).write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')


def main():
    assert not (BASE / 'before.tar.gz').exists(), 'one-shot migration capture'
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    plan = json.loads((BASE / 'scan.json').read_bytes())
    chosen, = [row for row in plan['sources'] if row['tree'] == TREE]
    assert chosen['compatible'] and not chosen['selected_scope_loss'] and not chosen['duplicate_core']
    assert chosen['ids'] == 28 and len(chosen['selected']) == 23 and chosen['proposed_saved_bytes'] == 13074
    before = Path(TARGET).read_bytes()
    assert hashlib.sha256(before).hexdigest() == chosen['sha256'] and not Path(MANIFEST).exists()
    epochs = sorted(Path('docs/history/task-narrative-epochs').glob('*.json'))
    paths = [TARGET, 'tools/migrate_task_narrative.py', 'tools/task_narrative.py', 'tools/read_task_narrative.py',
        'tools/run_python_project_data.sh', 'tools/project_data_run.sh', 'tools/project_data_env.sh']
    paths += [str(path) for path in epochs] + [json.loads(path.read_bytes())['source_path'] for path in epochs]
    paths += [str(path) for path in Path('docs/tasks').glob('*.md')]
    paths += [str(path) for path in BASE.glob('*.py')] + [str(BASE / 'scan.json')]
    paths += [str(PRESSURE / 'pressure_repair.py')] + [str(path) for path in (PRESSURE / 'pressure').iterdir() if path.is_file()]
    freeze('before', paths)
    log = Path('.linkedspec-data/rust-loader-commit.log')
    normal = log.read_bytes()
    assert b'doctrines: ALL 10 enforced doctrines PASS.' in normal and b'[main 08c39a2df]' in normal and b'[memory-pointer] ok: post-commit' in normal
    (BASE / 'prior-normal.log.gz').write_bytes(gzip.compress(normal, mtime=0))
    (BASE / 'prior-normal.json').write_text(json.dumps(dict(source=str(log), sha256=hashlib.sha256(normal).hexdigest(),
        mode=stat.S_IMODE(log.stat().st_mode), recording='after-use complete preceding normal and post-pointer PASS'), indent=2) + '\n')
    telemetry_source = Path('.linkedspec-data/push-monitor/20261117T000920.514071Z')
    (BASE / 'telemetry').mkdir()
    copies = {}
    for source in sorted(telemetry_source.iterdir()):
        if source.suffix in ('.pack', '.idx', '.log') or source.name.startswith(('objects-', 'object-metadata-')):
            continue
        target = BASE / 'telemetry' / source.name
        target.write_bytes(source.read_bytes())
        target.chmod(stat.S_IMODE(source.stat().st_mode))
        copies[str(target)] = dict(source=str(source), sha256=hashlib.sha256(target.read_bytes()).hexdigest(), mode=stat.S_IMODE(target.stat().st_mode))
    (BASE / 'telemetry-identities.json').write_text(json.dumps(copies, indent=2, sort_keys=True) + '\n')
    native('literal-consumer-search', ['rg', '-n', '-F', TARGET, 'tools', 'scripts', 'tests', '.githooks', 'doctrine'], accepted=1)
    old_pressure = native('prior-pressure-archive', ['bash', 'tools/run_python_project_data.sh', str(PRESSURE / 'pressure_repair.py'), '--review'])
    assert json.loads(old_pressure)['headroom_bytes'] == 227
    assert native('target-source', ['git', 'show', ACTIVATION + ':' + TARGET]) == before
    native('migration', ['bash', 'tools/run_python_project_data.sh', 'tools/migrate_task_narrative.py',
        '--apply', '--epoch', OWNER, '--tree', TREE, '--source-commit', ACTIVATION])
    manifest = json.loads(Path(MANIFEST).read_bytes())
    assert manifest['selected'] == sorted(row['id'] for row in chosen['selected'])
    after = Path(TARGET).read_bytes()
    assert len(before) - len(after) == chosen['proposed_saved_bytes']
    freeze('after', [TARGET, MANIFEST])
    assert native('query-all', ['bash', 'tools/run_python_project_data.sh', 'tools/read_task_narrative.py',
        '--tree', TREE, '--epoch', OWNER, '--all']) == before
    content = before.split(b'## Current Frontier\n', 1)[0]
    matches = list(re.finditer(rb'^- ID: `([^`\n]+)`\n', content, re.M))
    queries = []
    for index, match in enumerate(matches):
        identifier = match[1].decode()
        tag = 'query-' + str(index)
        expected = content[match.start():matches[index+1].start() if index+1<len(matches) else len(content)]
        value = native(tag, ['bash', 'tools/run_python_project_data.sh', 'tools/read_task_narrative.py',
            '--tree', TREE, '--epoch', OWNER, '--id', identifier])
        assert value == expected
        queries.append(dict(id=identifier, tag=tag, sha256=hashlib.sha256(value).hexdigest()))
    (BASE / 'queries.json').write_text(json.dumps(queries, indent=2) + '\n')
    result = native('review', ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review.py'), '--current'])
    print(result.decode(), end='')


if __name__ == '__main__':
    main()
