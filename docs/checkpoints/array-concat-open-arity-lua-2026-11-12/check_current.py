"""Point-in-time direct input identities at activation/pre-staging only."""
import hashlib
import json
from pathlib import Path
import subprocess
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
assert subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()=='fb613736f68f7d1f90df5ade3c0e73c98160ca3f'
assert subprocess.run(['git','diff','--cached','--quiet']).returncode==0
rows=json.loads((BASE/'direct/input-identities.json').read_bytes())
for name,row in rows.items():
 p=Path(name)
 assert not p.is_absolute() and '..' not in p.parts and p.is_file() and not p.is_symlink()
 assert p.stat().st_dev==Path.cwd().stat().st_dev
 raw=p.read_bytes()
 assert len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256'],name
 assert p.stat().st_mode&0o777==row['mode'],name
print(json.dumps(dict(current_inputs='PASS',declared_inputs=len(rows),scope='Activation/pre-staging only; no future freshness or complete native/cache/transitive/toolchain/OS closure.')))
