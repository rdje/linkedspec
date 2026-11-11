"""One existing epoch migration; preserve actual inputs before each consumer."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile
import traceback

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.23'
TREE = 'JULIA-BACKEND-PARITY'
SOURCE = 'docs/tasks/' + TREE + '.md'
ACTIVATION = 'd34acedac2583bd7ef7ab805880710cd806afbdd'
MANIFEST = 'docs/history/task-narrative-epochs/' + OWNER + '.json'


def digest(body):
    return hashlib.sha256(body).hexdigest()


def freeze(stem, paths):
    identities = {}
    target = BASE / (stem + '.tar.gz')
    assert not target.exists()
    with tarfile.open(target, 'x:gz') as archive:
        for name in sorted(set(paths)):
            path = ROOT / name
            assert not path.is_symlink() and path.is_file() and path.stat().st_dev == ROOT.stat().st_dev
            assert not Path(name).is_absolute() and '..' not in Path(name).parts
            body = path.read_bytes()
            identities[name] = dict(bytes=len(body), sha256=digest(body), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=name, recursive=False)
    with tarfile.open(target) as archive:
        assert set(archive.getnames()) == set(identities)
        for member in archive:
            body = archive.extractfile(member).read(); row = identities[member.name]
            assert member.isfile() and len(body) == row['bytes'] and digest(body) == row['sha256']
            assert member.mode & 0o777 == row['mode']
    (BASE / (stem + '-identities.json')).write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
    return identities


def execute(name, argv):
    folder = BASE / 'commands' / name
    folder.mkdir(parents=True)
    packet = dict(argv=argv, cwd='.')
    (folder / 'command.json').write_text(json.dumps(packet, indent=2) + '\n')
    result = subprocess.run(argv, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (folder / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (folder / 'exit.txt').write_text(str(result.returncode) + '\n')
    assert result.returncode == 0, name + ': actual failure retained'
    return result


def main():
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == ACTIVATION
    assert not (ROOT / MANIFEST).exists()
    original = (ROOT / SOURCE).read_bytes()
    assert original == subprocess.check_output(['git', 'show', ACTIVATION + ':' + SOURCE], cwd=ROOT)
    assert original.count(b'\n## Current Frontier\n') == 1
    assert b'\n## Current frontier\n' not in original and b'  Scope:' not in original
    assert b'  Narrative epoch:' not in original
    # verify_epochs reads every existing manifest and its complete committed body.
    manifests = sorted((ROOT / 'docs/history/task-narrative-epochs').glob('*.json'))
    sources = {SOURCE}
    git_rows = []
    source_folder = BASE / 'git-inputs'; source_folder.mkdir()
    for number, manifest in enumerate(manifests):
        row = json.loads(manifest.read_bytes())
        assert re.fullmatch(r'[0-9a-f]{40}', row['source_commit'])
        assert row['source_path'] == 'docs/tasks/' + row['tree'] + '.md'
        body = subprocess.check_output(['git', 'cat-file', 'blob', row['source_blob']], cwd=ROOT)
        assert digest(body) == row['sha256'] and len(body) == row['bytes']
        target = source_folder / ('source-' + str(number) + '.log.gz')
        target.write_bytes(gzip.compress(body, mtime=0))
        git_rows.append(dict(manifest=str(manifest.relative_to(ROOT)), source_commit=row['source_commit'],
            source_path=row['source_path'], source_blob=row['source_blob'], sha256=digest(body),
            bytes=len(body), retained_body=str(target.relative_to(ROOT))))
        sources.add(row['source_path'])
    (BASE / 'git-input-identities.json').write_text(json.dumps(git_rows, indent=2) + '\n')
    paths = subprocess.check_output(['git', 'ls-files', 'docs/tasks'], cwd=ROOT, text=True).splitlines()
    paths += [str(path.relative_to(ROOT)) for path in manifests]
    paths += [str(path.relative_to(ROOT)) for path in BASE.glob('*.py')]
    paths += [str(path.relative_to(ROOT)) for path in source_folder.iterdir()]
    paths += [str(REL / 'git-input-identities.json')]
    paths += ['tools/' + name for name in ('migrate_task_narrative.py', 'task_narrative.py',
        'read_task_narrative.py', 'project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
    paths += list(sources)
    inputs = freeze('inputs-before-migration', paths)
    result = execute('migration', ['bash', 'tools/run_python_project_data.sh', 'tools/migrate_task_narrative.py',
        '--apply', '--epoch', OWNER, '--tree', TREE, '--source-commit', ACTIVATION])
    assert result.stderr == b''
    output = freeze('outputs-before-reader', [SOURCE, MANIFEST])
    actual_manifest = json.loads((ROOT / MANIFEST).read_bytes())
    assert actual_manifest['source_commit'] == ACTIVATION and actual_manifest['tree'] == TREE
    raw = execute('reader-all', ['bash', 'tools/run_python_project_data.sh', 'tools/read_task_narrative.py',
        '--tree', TREE, '--epoch', OWNER, '--all'])
    assert raw.stdout == original and raw.stderr == b''
    before_frontier = original.split(b'## Current Frontier\n')[0]
    matches = list(re.finditer(rb'^- ID: `([^`\n]+)`\n', before_frontier, re.M))
    for number, match in enumerate(matches):
        key = match[1].decode()
        end = matches[number + 1].start() if number + 1 < len(matches) else len(before_frontier)
        expected = before_frontier[match.start():end]
        queried = execute('reader-' + key, ['bash', 'tools/run_python_project_data.sh', 'tools/read_task_narrative.py',
            '--tree', TREE, '--epoch', OWNER, '--id', key])
        assert queried.stdout == expected and queried.stderr == b''
    for name, row in inputs.items():
        if name == SOURCE:
            continue
        path = ROOT / name
        assert digest(path.read_bytes()) == row['sha256'] and path.stat().st_mode & 0o777 == row['mode'], name
    for name, row in output.items():
        path = ROOT / name
        assert digest(path.read_bytes()) == row['sha256'] and path.stat().st_mode & 0o777 == row['mode'], name
    (BASE / 'complete.txt').write_text('Actual migration and every declared public query complete; inputs/outputs unchanged.\n')
    print(result.stdout.decode(), end='')
    print('Public whole-source and all stable-ID queries match exact original bytes; actual channels retained')


if __name__ == '__main__':
    try:
        main()
    except BaseException:
        (BASE / 'wrapper-failure.log.gz').write_bytes(gzip.compress(traceback.format_exc().encode(), mtime=0))
        raise
