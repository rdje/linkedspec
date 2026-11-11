"""Retire only verified duplicates of these completed owned epochs."""
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
target = BASE / 'retired-live-copies.json'
assert not target.exists()
retired = []
for phase, tag in (('before', 'normal-parsed'), ('direct', 'normal-parsed'), ('trace', 'actual-traces')):
    packet = next(p for p in json.loads((BASE / phase / 'custody.json').read_bytes()) if p['tag'] == tag)
    verified = []
    with tarfile.open(ROOT / packet['archive']) as archive:
        assert set(archive.getnames()) == packet['files'].keys()
        for member in archive:
            path = ROOT / member.name
            assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
            body = archive.extractfile(member).read(); row = packet['files'][member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == path.stat().st_mode & 0o777 == row['mode']
            assert path.read_bytes() == body
            verified.append(path)
    for path in verified:
        path.unlink()
        retired.append(dict(path=path.relative_to(ROOT).as_posix(), phase=phase, tag=tag,
            archive=packet['archive'], identity=packet['files'][path.relative_to(ROOT).as_posix()]))
assert len(retired) == 642
assert all(not (ROOT / row['path']).exists() for row in retired)
target.write_text(json.dumps(retired, indent=2, sort_keys=True) + '\n')
print('Retired642 exact live duplicates after archived byte/full-mode verification; all proof bytes retained')
