"""Copy two oversized exact byte streams into bounded chunks; verify before any removal."""
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c
import partition_storage as storage

P = storage.P
baseline = json.loads((ROOT / (P + 'baseline.json')).read_bytes())
assert baseline['run']['returncode'] == 0 and baseline['inputs_bytes_modes_unchanged']
measured = json.loads((ROOT / (P + 'scanner-inputs.json')).read_bytes())['inputs']
assert json.loads((ROOT / (P + 'scanner-review.json')).read_bytes())['result'] == 'PASS'
limit = 16 * 1024 * 1024
rows = []
for logical, index_path in storage.INDEXES.items():
    source = storage.checked_target(logical)
    mode = source.stat().st_mode & 0o7777
    digest = hashlib.sha256()
    parts, total = [], 0
    with source.open('rb') as stream:
        while payload := stream.read(limit):
            number = len(parts)
            path = str(Path(index_path).parent / f'part-{number:03d}.json.gz')
            target = storage.checked_target(path)
            target.parent.mkdir(parents=True, exist_ok=True)
            c.write_new(path, dict(version=1, payload_base64=c.encode(payload)), packed=True)
            target.chmod(0o644)
            packed = target.read_bytes()
            assert len(packed) < 50 * 1024 * 1024
            parts.append(dict(path=path, file_sha256=c.sha(packed), payload_sha256=c.sha(payload),
                              size=len(payload), mode=0o644, offset=total, number=number))
            digest.update(payload)
            total += len(payload)
    assert dict(sha256=digest.hexdigest(), mode=mode) == measured[logical]
    index = dict(version=1, logical_path=logical, sha256=digest.hexdigest(),
                 size=total, mode=mode, parts=parts)
    c.write_new(index_path, index)
    rebuilt, rebuilt_mode, actual = storage.read_partition(index_path)
    assert rebuilt_mode == mode and actual == index
    assert rebuilt == source.read_bytes()
    rows.append(dict(path=logical, sha256=digest.hexdigest(), mode=mode, size=total,
                     index=index_path, parts=len(parts)))
c.write_new(P + 'partition-copy.json', dict(result='PASS', originals=rows,
    chunk_payload_limit=limit, parts=sum(row['parts'] for row in rows),
    producer=c.read(P + 'partition.py'), reader=c.read(P + 'partition_storage.py'),
    scope='Exact raw gzip streams are copied, not recompressed or regenerated. Each '
          'payload, physical chunk, whole stream, byte count and original mode verifies '
          'against the original measured identity. Both original files remain until the '
          'actual retained reader uses partitions and corruption controls pass.'))
print('Partition copy PASS:', len(rows), 'streams;', sum(row['parts'] for row in rows), 'bounded chunks')
