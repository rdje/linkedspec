"""Pre-staging identities of actual SDK/instruments; no SDK execution or future freshness."""
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == 'd21b84a4c8da663ee2a7600a2dc814d354502612'
assert subprocess.run(['git', 'diff', '--cached', '--quiet']).returncode == 0
rows = json.loads((BASE / 'intake/input-identities.json').read_bytes())
selected = {name: row for name, row in rows.items() if name.startswith(('perl/', 'specs/', str(BASE) + '/'))
    or name in ('tools/project_data_env.sh', 'tools/project_data_run.sh')}
assert selected
for name, row in selected.items():
    path = Path(name)
    assert not path.is_absolute() and '..' not in path.parts and path.is_file() and not path.is_symlink()
    assert path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
    assert path.stat().st_mode & 0o777 == row['mode']
print(json.dumps(dict(current_inputs='PASS', declared_inputs=len(selected),
    scope='Actual declared Perl/spec/own packet/wrapper inputs at activation/pre-staging. Historical documentation/templates retain archived Git identities; no future freshness/native/transitive closure.')))
