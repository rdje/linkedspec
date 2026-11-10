"""Retain the exact uncommitted objective claim's logical inputs before evolution."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import stat

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OUTPUT = HERE / 'objective-frozen-epoch.json.gz'
CLAIM = ROOT / 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.18.1.json'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


assert not OUTPUT.exists(), 'one-shot exact logical input retention'
raw_record = CLAIM.read_bytes()
record = json.loads(raw_record)
claim = record['claims'][4]
assert claim['name'] == 'bounded-committed-current-image-admission'
assert claim['durability']['mode'] == 'live'
rows = claim['durability']['inputs']
assert len(rows) == len({row['path'] for row in rows}) == 231
sources = {}
for row in rows:
    name = row['path']; relative = Path(name)
    assert not relative.is_absolute() and '..' not in relative.parts
    assert not name.startswith('rgx/'), 'dependency sources are not an intake surface'
    path = ROOT / relative
    info = path.lstat()
    assert stat.S_ISREG(info.st_mode) and info.st_dev == ROOT.stat().st_dev
    raw = path.read_bytes()
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], 'capture already-stale input: ' + name
    sources[name] = dict(**packet(raw), role=row['role'], mode=stat.S_IMODE(info.st_mode))
instrument_name = Path(__file__).relative_to(ROOT).as_posix()
payload = dict(owner=record['owner'], original_record=packet(raw_record), claim_index=4,
               declared_inputs=rows, sources=sources,
               instrument=dict(path=instrument_name, **packet(Path(__file__).read_bytes())),
               scope='Exact currently declared logical input epoch, including uncommitted producer/table bodies. This is not a Git capture or a new runtime observation. Original statements/results/hashes stay recoverable; no retroactive original first-use/native closure credit.')
OUTPUT.write_bytes(gzip.compress(json.dumps(payload, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
assert json.loads(gzip.decompress(OUTPUT.read_bytes())) == payload
for name, row in sources.items():
    path = ROOT / name
    assert path.read_bytes() == base64.b64decode(row['base64'])
    assert stat.S_IMODE(path.stat().st_mode) == row['mode']
assert CLAIM.read_bytes() == raw_record
print(json.dumps(dict(result='retained', declared_inputs=len(sources), input_bytes=sum(len(base64.b64decode(row['base64'])) for row in sources.values()), record_sha256=hashlib.sha256(raw_record).hexdigest()), sort_keys=True))
