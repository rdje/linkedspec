"""Remove only owned live intake copies after exact archived-byte verification."""
import gzip
import hashlib
import json
from pathlib import Path
import shutil
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
retained = {}
packets = []
for phase in ('intake', 'trace'):
    packets += json.loads((BASE / phase / 'custody.json').read_bytes())
for packet in packets:
    with tarfile.open(packet['archive']) as archive:
        assert set(archive.getnames()) == set(packet['files'])
        for member in archive:
            body = archive.extractfile(member).read()
            row = packet['files'][member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
            retained[member.name] = row
paths = [BASE / 'intake' / name for name in ('native', 'fresh', 'native-exec', 'fresh-exec')]
paths += [BASE / 'trace' / name for name in ('runner', 'trace-exec')]
paths += list((BASE / 'trace').glob('*.trace.log'))
removed = {}
for path in paths:
    assert path.exists() and not path.is_symlink()
    for file in ([path] if path.is_file() else path.rglob('*')):
        if file.is_dir():
            continue
        assert file.is_file() and not file.is_symlink() and file.stat().st_dev == ROOT.stat().st_dev
        body = file.read_bytes()
        row = retained[str(file)]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and file.stat().st_mode & 0o777 == row['mode']
        removed[str(file)] = row
for path in paths:
    if path.is_file() and path.name.endswith('.trace.log'):
        packed = Path(str(path) + '.gz')
        assert not packed.exists()
        body = path.read_bytes()
        packed.write_bytes(gzip.compress(body, mtime=0))
        assert gzip.decompress(packed.read_bytes()) == body
for path in paths:
    if path.is_dir():
        shutil.rmtree(path)
    else:
        path.unlink()
assert not any(path.exists() for path in paths)
(BASE / 'retired-live-copies.json').write_text(json.dumps(dict(removed=removed,
    scope='Only six archive-verified one-shot producer workspaces/executables and seven raw trace copies; exact bytes/modes remain in custody archives. Daily stray-artifact census is separate.', residue=[]), indent=2, sort_keys=True) + '\n')
print('Retired only archive-verified one-shot own copies; all proof bytes retained, no live residue')
