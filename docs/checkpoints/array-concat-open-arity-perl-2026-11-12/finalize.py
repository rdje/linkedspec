"""Close the finite actual-launch list and retire only exact archived path receipts."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert (BASE / 'remaining/complete.txt').is_file()
completed = {}
for path in sorted((BASE / 'launches').iterdir()):
    if path.name == 'finalize':
        # This producer's own unfinished launcher is checked after it completes.
        continue
    assert path.is_dir() and (path / 'exit.txt').is_file(), path
    completed[path.name] = int((path / 'exit.txt').read_text())
assert len(completed) == 25
assert {key: value for key, value in completed.items() if value} == dict(after=1, **{'check-before': 1, 'qualify-outcomes': 1})
target = BASE / 'completed-launches.json'
assert not target.exists()
target.write_text(json.dumps(completed, indent=2, sort_keys=True) + '\n')
retired = {}
for phase in ('before', 'inverse', 'restored', 'direct'):
    path = BASE / (phase + '-check.json')
    raw = path.read_bytes()
    row = json.loads(raw)
    assert row['full_wire_records'] == 'PASS'
    archive = path.with_suffix(path.suffix + '.gz')
    assert not archive.exists() and not path.is_symlink()
    mode = path.stat().st_mode & 0o777
    archive.write_bytes(gzip.compress(raw, mtime=0))
    archive.chmod(mode)
    assert gzip.decompress(archive.read_bytes()) == raw and archive.stat().st_mode & 0o777 == mode
    retired[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=mode, archive=str(archive))
    path.unlink()
assert all(not Path(name).exists() for name in retired)
(BASE / 'retired-receipts.json').write_text(json.dumps(retired, indent=2, sort_keys=True) + '\n')
print('Closed25 completed actual launches; four raw path receipts preserved byte/mode-exact as gzip, plain duplicates retired')
