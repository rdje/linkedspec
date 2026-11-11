"""Remove only owned live intake copies after exact archived-byte verification."""
import hashlib
import json
from pathlib import Path
import shutil
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'intake'
retained = {}
for packet in json.loads((OUT / 'custody.json').read_bytes()):
    with tarfile.open(packet['archive']) as archive:
        assert set(archive.getnames()) == set(packet['files'])
        for member in archive:
            body = archive.extractfile(member).read()
            row = packet['files'][member.name]
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
            retained[member.name] = row
paths = [OUT / name for name in ('native', 'fresh', 'native-exec', 'fresh-exec')]
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
    if path.is_dir():
        shutil.rmtree(path)
    else:
        path.unlink()
assert not any(path.exists() for path in paths)
(BASE / 'intake-live-cleanup.json').write_text(json.dumps(dict(removed=removed,
    scope='Only four one-shot intake source/executable copies; exact bytes/modes remain in custody archives', residue=[]), indent=2, sort_keys=True) + '\n')
print('Removed only archive-verified own intake copies; all proof bytes retained, no live residue')
