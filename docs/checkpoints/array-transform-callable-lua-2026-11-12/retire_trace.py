"""Verify archived member bytes/full modes before retiring exact plain duplicates."""
import hashlib
import json
from pathlib import Path
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
target = BASE / 'retired-live-copies.json'
assert not target.exists()
retired = {}
for phase, archive_name in (('trace', 'actual-trace-inputs.tar.gz'), ('fieldprobe', 'actual-parsed-inputs.tar.gz')):
    for host in ('puc', 'luajit'):
        folder = BASE / phase / host
        rows = json.loads((folder / 'artifact-identities.json').read_bytes())
        assert len(rows) == (27 if phase == 'trace' else 2)
        with tarfile.open(folder / archive_name) as archive:
            assert set(archive.getnames()) == rows.keys()
            for member in archive:
                path = Path(member.name)
                assert member.isfile() and not path.is_absolute() and '..' not in path.parts
                assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
                row = rows[member.name]
                body = path.read_bytes()
                assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
                assert body == archive.extractfile(member).read()
                assert path.stat().st_mode & 0o777 == member.mode & 0o777 == row['mode']
                retired[member.name] = dict(**row, archive=str(folder / archive_name))
        for name in rows:
            Path(name).unlink()
assert len(retired) == 58 and all(not Path(name).exists() for name in retired)
target.write_text(json.dumps(retired, indent=2, sort_keys=True) + '\n')
print('Retired58 archive-verified exact plain duplicates:54 trace artifacts/four field-probe inputs; no evidence loss')
