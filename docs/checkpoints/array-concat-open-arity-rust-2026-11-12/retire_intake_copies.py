"""Retire only exact archived intake build trees and executed copies after use."""
import hashlib
import json
from pathlib import Path
import shutil
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
targets = [BASE / 'intake' / name for name in ('native', 'fresh', 'native-exec', 'fresh-exec')]
assert (BASE / 'after-validation.json').is_file()
rows = {}
for packet in json.loads((BASE / 'intake/custody.json').read_bytes()):
    with tarfile.open(ROOT / packet['archive']) as archive:
        assert set(archive.getnames()) == packet['files'].keys()
        for member in archive:
            row = packet['files'][member.name]
            body = archive.extractfile(member).read()
            assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
            assert member.mode & 0o777 == row['mode']
            if member.name in rows:
                assert rows[member.name] == row
            rows[member.name] = row
files = []
for target in targets:
    assert target.exists() and not target.is_symlink() and target.is_relative_to(BASE / 'intake')
    paths = list(target.rglob('*')) if target.is_dir() else [target]
    for path in paths:
        assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        if path.is_dir():
            continue
        assert path.is_file()
        name = str(path.relative_to(ROOT)); row = rows[name]
        body = path.read_bytes()
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
        assert path.stat().st_mode & 0o777 == row['mode']
        files.append(dict(path=name, **row))
for target in targets:
    if target.is_dir():
        shutil.rmtree(target)
    else:
        target.unlink()
assert not any(target.exists() for target in targets)
(BASE / 'retired-intake.json').write_text(json.dumps(dict(targets=[str(path.relative_to(ROOT)) for path in targets],
    files=files, scope='Exact already-used archived duplicates only; no caches, old evidence, physical-reclamation claim or general cleanup census.'), indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(retired_exact_copies=len(files), archived=True)))
