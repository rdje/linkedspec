"""Remove only the archived, freshly reproduced exact generated output tree."""
import datetime
import gzip
import json
import os
from pathlib import Path
import common as c

first_raw = (c.ROOT / (c.HOME + 'render-recovery.json.gz')).read_bytes()
fresh_raw = (c.ROOT / (c.HOME + 'render-outputs.json.gz')).read_bytes()
first, fresh = json.loads(gzip.decompress(first_raw)), json.loads(gzip.decompress(fresh_raw))
assert json.loads(gzip.decompress((c.ROOT / (c.HOME + 'render-final.json.gz')).read_bytes()))['result'] == 'PASS'
assert set(first['files']) == set(fresh['files']) and len(first['files']) == 39
for path, item in first['files'].items():
    assert c.decode(item['base64']) == c.decode(fresh['files'][path]['base64'])
    assert c.sha(c.decode(item['base64'])) == item['sha256'] == fresh['files'][path]['sha256']
    assert item['mode'] == fresh['files'][path]['mode']
assert {path: item['mode'] for path, item in first['directories'].items()} == fresh['directories']
ledger_path = 'docs/ARTIFACT_CLEANUP.md'
live_intersections = []
for source in sorted((c.ROOT / 'docs/claims').glob('*.json')):
    for claim in json.loads(source.read_bytes()).get('claims', []):
        durability = claim.get('durability', {})
        if durability.get('mode') == 'live' and any(item['path'] == ledger_path or item['path'].startswith('output/') for item in durability.get('inputs', [])):
            live_intersections.append(source.relative_to(c.ROOT).as_posix())
assert not live_intersections, ('preservation required before touching cleanup ledger', live_intersections)
ledger = c.read(ledger_path)
root = c.ROOT / 'output'
assert root.is_dir() and not root.is_symlink() and root.stat().st_dev == c.ROOT.stat().st_dev
observed_files, observed_dirs = {}, {}
for directory, names, filenames in os.walk(root, followlinks=False):
    parent = Path(directory)
    assert not parent.is_symlink() and not (parent / '.git').exists()
    observed_dirs[parent.relative_to(root).as_posix()] = parent.stat().st_mode & 0o7777
    assert all(not (parent / name).is_symlink() for name in names)
    for name in filenames:
        source = parent / name
        assert source.is_file() and not source.is_symlink() and source.stat().st_dev == c.ROOT.stat().st_dev
        observed_files[source.relative_to(root).as_posix()] = dict(sha256=c.sha(source.read_bytes()), mode=source.stat().st_mode & 0o7777)
assert observed_dirs == fresh['directories']
assert observed_files == {path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in fresh['files'].items()}
preparation = dict(result='prepared', original_archive_sha256=c.sha(first_raw), fresh_archive_sha256=c.sha(fresh_raw),
    files=observed_files, directories=observed_dirs, old_cleanup_ledger=ledger,
    live_intersections=live_intersections, producer_base64=c.encode(Path(__file__).read_bytes()),
    scope='Complete archive and fresh actual output names/bytes/modes agree with the exact current '
          '39-file tree before deletion. No unknown data, symlink, nested repository, other volume '
          'or live claimed ledger input is admitted. Only these known generated paths are removed.')
c.write_new(c.HOME + 'output-cleanup-preparation.json', preparation)
removed = []
for path, item in sorted(observed_files.items()):
    target = root / path
    assert not target.is_symlink() and c.sha(target.read_bytes()) == item['sha256']
    assert target.stat().st_mode & 0o7777 == item['mode']
    target.unlink()
    removed.append(path)
    (c.ROOT / (c.HOME + 'output-cleanup-reached.json')).write_text(json.dumps(dict(removed=removed), indent=1) + '\n')
for path in sorted(observed_dirs, key=lambda value: (len(Path(value).parts), value), reverse=True):
    target = root if path == '.' else root / path
    assert not target.is_symlink()
    target.rmdir()  # Refuse unknown concurrent entries instead of deleting them.
assert not root.exists() and not root.is_symlink(), 'exact named residue census'
assert c.read(ledger_path) == ledger
count, size = len(removed), sum(len(c.decode(item['base64'])) for item in first['files'].values())
now = datetime.datetime.now(datetime.timezone.utc).isoformat()
summary = (f'{now} — {c.OWNER}: removed exact failed-render output/ ({count} files/{size} bytes) '
           'after complete archival and fresh whole-output name/byte/mode equivalence; exact residue '
           'absent. All proof data and reusable caches retained. This is scoped instrument-output '
           'recovery, not a broad metadata census or lifecycle/recovery/purge admission. Evidence: '
           'docs/checkpoints/knowledge-fields/output-cleanup.json.\n')
(c.ROOT / ledger_path).write_text('# Latest artifact cleanup\n\n' + summary)
report = dict(result='PASS', removed_files=count, removed_bytes=size, removed_paths=removed,
              residue=dict(path='output', exists=False, symlink=False),
              cleanup_utc=now, cleanup_ledger_sha256=c.sha((c.ROOT / ledger_path).read_bytes()),
              preparation_sha256=c.sha((c.ROOT / (c.HOME + 'output-cleanup-preparation.json')).read_bytes()),
              producer_sha256=c.sha(Path(__file__).read_bytes()),
              scope='Only the exact39 known generated files were removed after complete recoverable '
                    'archival, fresh actual reproduction and per-file identity/mode checks. Known '
                    'empty directories are removed with rmdir; unknown data would refuse cleanup. '
                    'The exact target is absent. Latest-entry cleanup ledger records this scope; '
                    'the prior full hygiene review remains in Git and its own immutable artifacts.')
c.write_new(c.HOME + 'output-cleanup.json', report)
print('Exact render-output recovery PASS:', count, 'files;', size, 'bytes;fresh full equivalence;residue absent')
