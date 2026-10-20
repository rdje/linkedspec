"""Remove only the two verified duplicate byte streams after actual partition use."""
import datetime
import hashlib
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c
import partition_storage as storage

P = storage.P
copy = storage.load('partition-copy.json')
assert copy['result'] == 'PASS'
assert storage.load('partition-use-context.json')['result'] == 'PASS'
context = storage.load('partition-context.json')
assert context['run']['returncode'] == 0 and context['restored']
assert storage.load('partition-controls-review.json')['result'] == 'PASS'
before = []
for row in copy['originals']:
    source = storage.checked_target(row['path'])
    raw = source.read_bytes()
    assert len(raw) == row['size'] and hashlib.sha256(raw).hexdigest() == row['sha256']
    assert source.stat().st_mode & 0o7777 == row['mode']
    rebuilt, mode, _ = storage.read_partition(row['index'])
    assert rebuilt == raw and mode == row['mode']
    before.append(dict(path=row['path'], size=len(raw), sha256=row['sha256'], mode=mode))
for row in before:
    storage.checked_target(row['path']).unlink()
for row in before:
    assert not (ROOT / row['path']).exists()
    raw, mode = storage.read_bytes(row['path'])
    assert c.sha(raw) == row['sha256'] and len(raw) == row['size'] and mode == row['mode']
c.write_new(P + 'partition-removal.json', dict(result='PASS', removed=before,
    removed_bytes=sum(row['size'] for row in before), residue_count=0,
    cleanup_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    producer=c.read(P + 'retire_originals.py'), reader=c.read(P + 'partition_storage.py'),
    scope='Copy, byte/mode verification, actual retained-reader use and distinguishing '
          'controls all precede removal. Only the two exact duplicate originals are '
          'removed; chunks, original whole hashes/modes and all observations remain.'))
print('Verified duplicate originals removed; residue0; exact logical bytes remain readable')
