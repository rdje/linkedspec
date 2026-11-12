"""Retire only used, fully archived qualification/private/executable duplicates."""
import hashlib
import json
from pathlib import Path
import shutil
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
assert (BASE / 'ordinary-qualification.json').is_file()
assert (BASE / 'launches/qualified-direct/exit.txt').read_text() == '0\n'
targets = [BASE / 'direct' / name for name in ('normal-exec', 'array_transform_result_guard_composition-exec')]
targets += [BASE / phase / name for phase in ('ordinary-old', 'ordinary-fixed') for name in ('native', 'fresh', 'native-exec', 'fresh-exec')]
targets += [BASE / 'ordinary-qualification-owner']
records = {}
for phase in ('direct', 'ordinary-old', 'ordinary-fixed'):
    for packet in json.loads((BASE / phase / 'custody.json').read_bytes()):
        with tarfile.open(ROOT / packet['archive']) as archive:
            assert set(archive.getnames()) == packet['files'].keys()
            for member in archive:
                assert member.isfile()
                body = archive.extractfile(member).read(); row = packet['files'][member.name]
                assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
                records[member.name] = row
selected = {}
for target in targets:
    assert target.exists() and target.is_relative_to(BASE) and not target.is_symlink()
    paths = list(target.rglob('*')) if target.is_dir() else [target]
    for path in paths:
        assert not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        if path.is_dir():
            continue
        assert path.is_file()
        name = str(path.relative_to(ROOT)); row = records[name]; body = path.read_bytes()
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
        selected[name] = row
names = [str(path.relative_to(ROOT)) for path in targets]
expected = {name: row for name, row in records.items() if any(name == target or name.startswith(target + '/') for target in names)}
assert selected == expected, 'complete exact target census'
for target in targets:
    if target.is_dir():
        shutil.rmtree(target)
    else:
        target.unlink()
assert not any(target.exists() for target in targets)
(BASE / 'retired-qualified.json').write_text(json.dumps(dict(targets=names, files=selected,
    scope='Used exact archived duplicate source trees/executables only. No caches, original channels, other repositories, physical-reclamation or general cleanup-census claim.'), indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(retired_exact_duplicates=len(selected), archived_before_use=True)))
