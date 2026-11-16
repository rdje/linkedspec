"""One qualified unpartitioned epoch, with sources retained before each child."""
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
ACTIVATION = 'e476d208dcee58f67ca4d0d7a950d5aa8bdcab00'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.34'
TREE = 'NONCURRENT-HELPER-CODE-PURGE'
TARGET = 'docs/tasks/' + TREE + '.md'
MANIFEST = 'docs/history/task-narrative-epochs/' + OWNER + '.json'
PRESSURE = Path('docs/checkpoints/perl-consumer-roles-2026-11-16')


def native(tag, argv, accepted=0):
    folder = BASE / 'commands'
    folder.mkdir(exist_ok=True)
    with (folder / (tag + '-command.json')).open('x') as stream:
        json.dump(dict(argv=argv, cwd='.'), stream, indent=2)
        stream.write('\n')
    result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for name in ('stdout', 'stderr'):
        (folder / (tag + '-' + name + '.gz')).write_bytes(gzip.compress(getattr(result, name), mtime=0))
    (folder / (tag + '-exit.txt')).write_text(str(result.returncode) + '\n')
    assert result.returncode == accepted, 'actual command channels retained:' + tag
    if accepted == 0:
        assert not result.stderr, 'unexpected stderr:' + tag
    return result.stdout, result.stderr


def freeze(stem, paths):
    identities = {}
    with tarfile.open(BASE / (stem + '.tar.gz'), 'x:gz') as archive:
        for name in sorted(set(paths)):
            path = Path(name)
            assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
            assert path.is_file() and path.stat().st_dev == ROOT.stat().st_dev
            body = path.read_bytes()
            identities[name] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body), mode=stat.S_IMODE(path.stat().st_mode))
            archive.add(path, arcname=name, recursive=False)
    with tarfile.open(BASE / (stem + '.tar.gz')) as archive:
        assert set(archive.getnames()) == identities.keys()
        for member in archive:
            row = identities[member.name]
            body = archive.extractfile(member).read()
            assert member.isfile() and len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode == row['mode']
    (BASE / (stem + '-identities.json')).write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')


def main():
    assert not (BASE / 'before.tar.gz').exists(), 'capture/migration is one-shot'
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
    proposal = json.loads((BASE / 'scan.json').read_bytes())
    chosen, = [row for row in proposal['sources'] if row['tree'] == TREE]
    assert chosen['compatible'] and not chosen['selected_scope_loss'] and chosen['proposed_saved_bytes'] > 15000
    assert all(re.fullmatch(re.escape(TREE) + r'(?:\.[0-9]+)*', row['id']) for row in chosen['selected'])
    before = Path(TARGET).read_bytes()
    assert hashlib.sha256(before).hexdigest() == chosen['sha256'] and not Path(MANIFEST).exists()
    # Existing epochs make the migrator/reader consume every retained manifest
    # and its current task source, not just the newly selected tree.
    epochs = sorted(Path('docs/history/task-narrative-epochs').glob('*.json'))
    prior_sources = [json.loads(path.read_bytes())['source_path'] for path in epochs]
    paths = [TARGET, 'tools/migrate_task_narrative.py', 'tools/task_narrative.py', 'tools/read_task_narrative.py',
             'tools/run_python_project_data.sh', 'tools/project_data_run.sh', 'tools/project_data_env.sh']
    paths += [str(path) for path in epochs] + prior_sources
    paths += [str(path) for path in Path('docs/tasks').glob('*.md')]
    paths += [str(path) for path in BASE.glob('*.py')] + [str(BASE / 'scan.json')]
    paths += [str(PRESSURE / name) for name in ('review_pressure.py', 'pressure.json', 'task-activation.gz',
             'task-before.gz', 'task-after.gz', 'first-normal.gz', 'pressure-review-stdout.json')]
    freeze('before', paths)
    # Retain the complete successful preceding normal log; no replay or deletion.
    log = Path('.linkedspec-data/perl-roles-normal-retry-20261116.log')
    body = log.read_bytes()
    assert b'doctrines: ALL 10 enforced doctrines PASS.' in body
    assert b'post-commit activation_commit 3f619e9c2aa74d0f3f8d9d64c2c90e82d11d81e0 resolves to first parent' in body
    assert b'[main e476d208d]' in body
    (BASE / 'prior-normal.log.gz').write_bytes(gzip.compress(body, mtime=0))
    (BASE / 'prior-normal.json').write_text(json.dumps(dict(source=str(log), sha256=hashlib.sha256(body).hexdigest(),
        mode=stat.S_IMODE(log.stat().st_mode), channel='original combined stdout/stderr', result='complete normal and post-pointer PASS'), indent=2) + '\n')
    telemetry_source = Path('.linkedspec-data/push-monitor/20261116T171858.448209Z')
    telemetry = BASE / 'telemetry'
    telemetry.mkdir()
    copies = {}
    for source in sorted(telemetry_source.iterdir()):
        if source.is_file() and not source.is_symlink() and source.suffix in ('.json', '.gz', '.txt'):
            destination = telemetry / source.name
            data = source.read_bytes()
            mode = stat.S_IMODE(source.stat().st_mode)
            destination.write_bytes(data)
            destination.chmod(mode)
            copies[str(destination)] = dict(source=str(source), sha256=hashlib.sha256(data).hexdigest(), mode=mode)
    (BASE / 'telemetry-identities.json').write_text(json.dumps(copies, indent=2, sort_keys=True) + '\n')
    # This dated strict reader legitimately refuses the changed current task.
    _, errors = native('prior-pressure-current', ['bash', 'tools/run_python_project_data.sh', str(PRESSURE / 'review_pressure.py')], accepted=1)
    assert b'ValueError: current task identity' in errors
    old, _ = native('target-source', ['git', 'show', ACTIVATION + ':' + TARGET])
    assert old == before
    native('migration', ['bash', 'tools/run_python_project_data.sh', 'tools/migrate_task_narrative.py',
        '--apply', '--epoch', OWNER, '--tree', TREE, '--source-commit', ACTIVATION])
    manifest = json.loads(Path(MANIFEST).read_bytes())
    assert manifest['selected'] == sorted(row['id'] for row in chosen['selected'])
    after = Path(TARGET).read_bytes()
    assert len(before) - len(after) == chosen['proposed_saved_bytes']
    freeze('after', [TARGET, MANIFEST])
    # Publish output images before any reader consumes them.
    expected, _ = native('query-all', ['bash', 'tools/run_python_project_data.sh', 'tools/read_task_narrative.py',
        '--tree', TREE, '--epoch', OWNER, '--all'])
    assert expected == before
    content = before.split(b'## Current Frontier\n', 1)[0]
    matches = list(re.finditer(rb'^- ID: `([^`\n]+)`\n', content, re.M))
    query_rows = []
    for index, match in enumerate(matches):
        identifier = match[1].decode()
        node = content[match.start():matches[index + 1].start() if index + 1 < len(matches) else len(content)]
        value, _ = native('query-' + str(index), ['bash', 'tools/run_python_project_data.sh', 'tools/read_task_narrative.py',
            '--tree', TREE, '--epoch', OWNER, '--id', identifier])
        assert value == node
        query_rows.append(dict(id=identifier, tag='query-' + str(index), sha256=hashlib.sha256(node).hexdigest()))
    (BASE / 'queries.json').write_text(json.dumps(query_rows, indent=2) + '\n')
    (BASE / 'result.json').write_text(json.dumps(dict(owner=OWNER, activation=ACTIVATION, tree=TREE,
        before_bytes=len(before), after_bytes=len(after), selected=manifest['selected'], saved_bytes=len(before) - len(after),
        queries=len(query_rows) + 1,
        limits='Finite source/contract preservation, not fresh helper semantics/SDK/reading/physical reclamation. Complete native/outer-launcher first-use/source-origin/physical custody remains4.2/SESSION5.'), indent=2) + '\n')
    print('Qualified epoch and every public query retained; independent recovery remains.')


if __name__ == '__main__':
    main()
