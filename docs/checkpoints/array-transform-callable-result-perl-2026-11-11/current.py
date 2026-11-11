"""Pre-staging byte check of the named current SDK/instruments; not historical freshness."""
import hashlib
import json
from pathlib import Path

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
rows = json.loads((BASE / 'direct/input-identities.json').read_bytes())
private = json.loads((BASE / 'private_current/input-identities.json').read_bytes())
name = '.linkedspec-data/scratch/callable-transform-result-perl/owner.pm'
rows[name] = private[name]
for name, row in rows.items():
    path = ROOT / name
    assert path.is_file() and not path.is_symlink() and path.resolve().is_relative_to(ROOT), name
    raw = path.read_bytes()
    assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'], name
    assert path.stat().st_mode & 0o777 == row['mode'], name
print(json.dumps(dict(result='PASS', named_inputs=len(rows), scope='Pre-staging SDK/actual instruments/direct inputs/private-current image; no native/toolchain/cache closure or later freshness claim.'), sort_keys=True))
