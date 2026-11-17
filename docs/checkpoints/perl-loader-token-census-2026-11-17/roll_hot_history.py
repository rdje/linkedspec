"""Apply the existing required hot-shard rollover with exact source preservation."""
import gzip
import hashlib
import json
from pathlib import Path
import stat
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
FOLDER = BASE / 'history-rollover'
CURRENT = 'CHANGES.md'
MANIFEST = 'docs/history/changes/manifest.jsonl'


def sha(body):
    return hashlib.sha256(body).hexdigest()


def run(label, argv):
    stem = FOLDER / label
    with stem.with_suffix('.json').open('x') as stream:
        json.dump(dict(argv=argv, cwd='.'), stream, indent=2)
        stream.write('\n')
    result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (FOLDER / (label + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (FOLDER / (label + '-exit.txt')).write_text(str(result.returncode) + '\n')
    return result


def archive(label, names):
    identities = {}
    with tarfile.open(FOLDER / (label + '.tar.gz'), 'x:gz') as packed:
        for name in sorted(names):
            path = Path(name)
            assert path.is_file() and not path.is_symlink() and path.stat().st_dev == Path('.').stat().st_dev
            body = path.read_bytes()
            identities[name] = dict(bytes=len(body), sha256=sha(body), mode=stat.S_IMODE(path.stat().st_mode))
            packed.add(path, arcname=name, recursive=False)
    (FOLDER / (label + '-identities.json')).write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')


def main():
    assert not FOLDER.exists(), 'one-shot rollover observation'
    FOLDER.mkdir()
    plan = json.loads((BASE / 'plan.json').read_bytes())
    assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == plan['activation']
    assert subprocess.check_output(['git', 'status', '--porcelain', '--', 'docs/history/changes']) == b'', 'history store initially clean'
    bindings = []
    for path in sorted(Path('docs/claims').glob('*.json')):
        for claim in json.loads(path.read_bytes())['claims']:
            leg = claim['durability']
            for row in leg.get('inputs', []):
                if row['path'] in (CURRENT, MANIFEST):
                    assert leg['mode'] == 'historical', 'history live binding requires qualification'
                    bindings.append(dict(record=str(path), claim=claim['name'], input=row, mode=leg['mode'], revision=leg['revision']))
    (FOLDER / 'prior-bindings.json').write_text(json.dumps(bindings, indent=2, sort_keys=True) + '\n')
    old_files = {}
    for path in sorted(Path('docs/history/changes').rglob('*')):
        if path.is_file() and str(path) != MANIFEST:
            assert not path.is_symlink()
            body = path.read_bytes()
            old_files[str(path)] = dict(bytes=len(body), sha256=sha(body), mode=stat.S_IMODE(path.stat().st_mode))
    (FOLDER / 'old-store-identities.json').write_text(json.dumps(old_files, indent=2, sort_keys=True) + '\n')
    tools = {'tools/roll_document_history.pl', 'tools/read_document_history.pl', 'tools/lib/LinkedSpec/DocumentHistoryCatalog.pm',
        'tools/project_data_run.sh', 'tools/project_data_env.sh', str(BASE / 'roll_hot_history.py'), str(BASE / 'review_hot_history.py')}
    archive('before', tools | {CURRENT, MANIFEST})
    prefix = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'PERL5OPT=', 'perl']
    check = [*prefix, 'tools/roll_document_history.pl', '--surface', 'change_history', '--check']
    before_check = run('required-check', check)
    assert before_check.returncode != 0 and b'rollover required' in before_check.stderr
    before_read = run('archive-before', [*prefix, 'tools/read_document_history.pl', '--surface', 'change_history', '--all'])
    assert before_read.returncode == 0 and not before_read.stderr
    applied = run('apply', [*prefix, 'tools/roll_document_history.pl', '--surface', 'change_history', '--apply'])
    assert applied.returncode == 0 and not applied.stderr
    after_old_files = {}
    for name, row in old_files.items():
        path = Path(name)
        body = path.read_bytes()
        assert len(body) == row['bytes'] and sha(body) == row['sha256'] and stat.S_IMODE(path.stat().st_mode) == row['mode'], 'old immutable store unchanged'
        after_old_files[name] = dict(bytes=len(body), sha256=sha(body), mode=stat.S_IMODE(path.stat().st_mode))
    (FOLDER / 'after-old-store-identities.json').write_text(json.dumps(after_old_files, indent=2, sort_keys=True) + '\n')
    now_files = {str(path) for path in Path('docs/history/changes').rglob('*') if path.is_file()}
    new_files = now_files - set(old_files) - {MANIFEST}
    assert new_files
    archive('after', new_files | {CURRENT, MANIFEST})
    after_read = run('archive-after', [*prefix, 'tools/read_document_history.pl', '--surface', 'change_history', '--all'])
    assert after_read.returncode == 0 and not after_read.stderr
    assert before_read.stdout and after_read.stdout.endswith(before_read.stdout), 'old archive stream remains an exact suffix'
    appended = after_read.stdout[:-len(before_read.stdout)]
    with tarfile.open(FOLDER / 'before.tar.gz') as packed:
        before_current = packed.extractfile(CURRENT).read()
    after_current = Path(CURRENT).read_bytes()
    assert appended and before_current.endswith(appended), 'new archive is the current source suffix'
    retained = before_current[:-len(appended)]
    assert after_current == retained.rstrip(b'\n') + b'\n', 'only permitted hot EOF normalization'
    separator = retained[len(after_current):]
    assert all(byte == 10 for byte in separator)
    assert before_current + before_read.stdout == after_current + separator + after_read.stdout, 'exact combined history reconstruction'
    final_check = run('final-check', check)
    assert final_check.returncode == 0 and not final_check.stderr
    record = dict(result='PASS', activation=plan['activation'], before_bytes=len(before_current), after_bytes=len(after_current),
        archived_bytes=len(appended), omitted_hot_separator_hex=separator.hex(), combined_bytes=len(before_current + before_read.stdout),
        combined_sha256=sha(before_current + before_read.stdout), new_files=sorted(new_files), old_files_unchanged=len(old_files),
        limits='Existing public data rollover only. Archive --all excludes the hot root; exact combined reconstruction reinstates only recorded source LF separator bytes permitted by the existing EOF contract. No source/tool/schema/limit/runtime or old claim/hash change. Full native/outer-first-use/per-read/physical custody remains4.2/SESSION5.')
    (FOLDER / 'result.json').write_text(json.dumps(record, indent=2, sort_keys=True) + '\n')
    print(json.dumps(record, sort_keys=True))


if __name__ == '__main__':
    main()
