"""Retire only the eighteen independently archived completed trace duplicates."""
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
target = BASE / 'retired-live-copies.json'
assert not target.exists()
packet = next(row for row in json.loads((BASE / 'trace/custody.json').read_bytes()) if row['tag'] == 'artifacts')
rows = []
with tarfile.open(ROOT / packet['archive']) as archive:
    assert set(archive.getnames()) == packet['files'].keys() and len(packet['files']) == 18
    for member in archive:
        path = ROOT / member.name
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        body = archive.extractfile(member).read(); row = packet['files'][member.name]
        assert body == path.read_bytes() and len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert member.mode & 0o777 == path.stat().st_mode & 0o777 == row['mode']
        rows.append(dict(path=member.name, archive=packet['archive'], identity=row))
for row in rows:
    (ROOT / row['path']).unlink()
assert all(not (ROOT / row['path']).exists() for row in rows)
target.write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
print('Retired18 exact plain trace/input duplicates after byte/full-mode archive verification; all proof retained')
