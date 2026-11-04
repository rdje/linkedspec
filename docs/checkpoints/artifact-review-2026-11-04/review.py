"""Bounded, dated artifact metadata review; this program never removes artifacts."""
import argparse
import base64
import copy
from datetime import datetime, timezone
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import stat
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OUTPUT = HERE / 'observation.json.gz'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.6'
HELPER = 'docs/checkpoints/REPO-HYGIENE.19/census.py'
SCOPES = ('.', 'rust/target/release', 'rust/target/debug/incremental',
          'rust/target/debug/deps', 'target/release', 'target/debug/incremental',
          'target/debug/deps', '.linkedspec-data/logs')
CONVENTIONS = ('dart/.dart_tool', '.linkedspec-data/cache/dart-pub',
               '.linkedspec-data/cache/dart-home',
               '.linkedspec-data/cache/julia-depot/compiled',
               '.linkedspec-data/cache/julia-depot/packages',
               '.linkedspec-data/cache/julia-depot/registries')
PRODUCERS = (HELPER, 'docs/checkpoints/REPO-HYGIENE.18-census.py',
             'docs/checkpoints/REPO-HYGIENE.22/census.py',
             'tools/run_lua_project_data.sh', 'tools/project_data_env.sh',
             'tools/project_data_run.sh', 'tools/run_python_project_data.sh')


def packet(raw):
    return {'sha256': hashlib.sha256(raw).hexdigest(),
            'base64': base64.b64encode(raw).decode()}


def independent(root, name, excluded, submodules):
    """Use scandir/lstat, separately from the canonical os.walk scanner."""
    start = root if name == '.' else root / name
    device = root.lstat().st_dev
    cursor = root
    for component in start.relative_to(root).parts:
        cursor /= component
        relative = cursor.relative_to(root).as_posix()
        if relative in excluded or relative in submodules:
            return []
        try:
            info = cursor.lstat()
        except FileNotFoundError:
            return []
        if not stat.S_ISDIR(info.st_mode) or info.st_dev != device or (cursor / '.git').exists():
            return []
    rows, pending = [], [start]
    while pending:
        directory = pending.pop()
        with os.scandir(directory) as entries:
            for entry in entries:
                path = Path(entry.path)
                relative = path.relative_to(root).as_posix()
                info = entry.stat(follow_symlinks=False)
                if stat.S_ISLNK(info.st_mode) or info.st_dev != device:
                    continue
                if stat.S_ISDIR(info.st_mode):
                    if relative not in excluded and relative not in submodules and not (path / '.git').exists():
                        pending.append(path)
                elif stat.S_ISREG(info.st_mode):
                    suffix = next((s for s in ('.log', '.bin', '.DS_Store') if entry.name.endswith(s)), None)
                    if suffix:
                        rows.append({'path': relative, 'suffix': suffix, 'bytes': info.st_size})
    return sorted(rows, key=lambda row: row['path'])


def validate(report):
    assert report['owner'] == OWNER and report['removed'] == []
    assert tuple(report['scopes']) == SCOPES
    for name, row in report['scopes'].items():
        assert row['primary'] == row['independent'], 'independent metadata mismatch: ' + name
        paths = [item['path'] for item in row['primary']]
        assert paths == sorted(set(paths)), 'duplicate/unsorted path'
        for item in row['primary']:
            path = Path(item['path'])
            assert not path.is_absolute() and '..' not in path.parts
            assert type(item['bytes']) is int and item['bytes'] >= 0
    for image in (*report['producers'].values(), *report['messages'].values(), report['git_index']):
        assert packet(base64.b64decode(image['base64'])) == image, 'retained packet identity'


def controls(report):
    selected = next(name for name, row in report['scopes'].items() if row['primary'])
    rejected = []
    for name in ('missing-row', 'wrong-size', 'duplicate-row', 'outside-path', 'producer-byte'):
        changed = copy.deepcopy(report)
        rows = changed['scopes'][selected]['primary']
        if name == 'missing-row':
            rows.pop()
        elif name == 'wrong-size':
            rows[0]['bytes'] += 1
        elif name == 'duplicate-row':
            rows.append(copy.deepcopy(rows[0]))
        elif name == 'outside-path':
            rows[0]['path'] = '../outside.log'
        else:
            image = next(iter(changed['producers'].values()))
            image['sha256'] = '0' * 64
        try:
            validate(changed)
        except AssertionError as error:
            assert str(error).startswith(('independent metadata mismatch:', 'retained packet identity'))
            rejected.append(name)
        else:
            raise AssertionError('ineffective corruption control: ' + name)
    return rejected


def capture():
    assert not OUTPUT.exists(), 'capture is one-shot'
    assert not ROOT.is_symlink()
    spec = importlib.util.spec_from_file_location('artifact_census', ROOT / HELPER)
    helper = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(helper)
    index = subprocess.check_output(['git', 'ls-files', '--stage', '-z'], cwd=ROOT)
    submodules = {row.split(b'\t', 1)[1].decode() for row in index.split(b'\0') if row.startswith(b'160000 ')}
    # The parent observation is deliberately one level, not a project-wide walk.
    with os.scandir(ROOT) as entries:
        root_directories = {entry.name for entry in entries if entry.is_dir(follow_symlinks=False)}
    scopes = {}
    for name in SCOPES:
        excluded = root_directories | helper.namespace['EXCLUDED'] if name == '.' else set()
        primary, nested, links, volumes = helper.scan(ROOT, ROOT / name, excluded, submodules)
        scopes[name] = {'primary': primary, 'independent': independent(ROOT, name, excluded, submodules),
                        'nested_repositories_excluded': nested, 'symlinks_excluded': links,
                        'other_volumes_excluded': volumes}
    conventions = {}
    for name in CONVENTIONS:
        cursor = ROOT
        present = True
        for component in Path(name).parts:
            cursor /= component
            try:
                info = cursor.lstat()
            except FileNotFoundError:
                present = False
                break
            assert stat.S_ISDIR(info.st_mode) and info.st_dev == ROOT.lstat().st_dev
        conventions[name] = {'present_directory': present, 'retained': True}
    sources = (*PRODUCERS, Path(__file__).relative_to(ROOT).as_posix())
    report = {'owner': OWNER, 'at_utc': datetime.now(timezone.utc).isoformat(),
              'activation_commit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
              'scopes': scopes, 'retained_conventions': conventions, 'removed': [],
              'git_index': packet(index),
              'producers': {name: packet((ROOT / name).read_bytes()) for name in sources},
              'messages': {name: packet((ROOT / name).read_bytes()) for name in (
                  '.linkedspec-data/logs/backlog-publication.log',
                  '.linkedspec-data/logs/push-batch-10-01.txt')},
              'limits': 'Dated named-scope path/byte metadata, not a whole-project population, '
                        'content ownership, liveness, disposability, reclamation or concurrent-adversarial guarantee. '
                        'All artifacts/caches/proof are retained. Lua managed-run outputs are not traversed; '
                        'the published wrapper is retained as the convention reference. Publication messages '
                        'are preserved observations; transport/Git-object custody remains23.4.7.'}
    validate(report)
    report['rejected_controls'] = controls(report)
    raw = json.dumps(report, separators=(',', ':')).encode()
    OUTPUT.write_bytes(gzip.compress(raw, mtime=0))
    assert gzip.decompress(OUTPUT.read_bytes()) == raw
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', action='store_true')
    args = parser.parse_args()
    report = capture() if args.capture else json.loads(gzip.decompress(OUTPUT.read_bytes()))
    validate(report)
    assert controls(report) == report['rejected_controls']
    current = packet(Path(__file__).read_bytes())
    assert current == report['producers'][Path(__file__).relative_to(ROOT).as_posix()]
    print(json.dumps({'date': report['at_utc'], 'scoped_rows': sum(len(row['primary']) for row in report['scopes'].values()),
                      'removed': 0, 'rejected_controls': report['rejected_controls'], 'result': 'PASS'}))


if __name__ == '__main__':
    main()
