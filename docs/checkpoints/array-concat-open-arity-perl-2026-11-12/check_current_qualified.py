"""Pre-staging identity gate of actual direct-run SDK/test/instrument inputs."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == 'b15ca562e8044d9a8a369e613926bf016598f708'
assert subprocess.run(['git', 'diff', '--cached', '--quiet']).returncode == 0
rows = json.loads((BASE / 'direct/input-identities.json').read_bytes())
retired = json.loads((BASE / 'retired-receipts.json').read_bytes())
selected = {name: row for name, row in rows.items() if name not in retired}
assert selected and all(name in rows for name in (str(BASE / 'cases.json'),
    't/array_concat_open_arity_result_guard_composition.t', 'tests/fixtures/array_concat_open_arity_result_guard_perl_cases.json'))
for name, row in selected.items():
    path = BASE / 'patch_archive/source-and-profile.diff.gz' if name == str(BASE / 'source-and-profile.diff') else Path(name)
    assert not path.is_absolute() and '..' not in path.parts and path.is_file() and not path.is_symlink()
    assert path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    if name == str(BASE / 'source-and-profile.diff'):
        body = gzip.decompress(body)
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256']
    assert path.stat().st_mode & 0o777 == row['mode']
print(json.dumps(dict(current_inputs='PASS', declared_inputs=len(selected),
    scope='Actual direct-run SDK/spec/test/fixture/packet/wrapper identities at activation/pre-staging. Four retired contextual receipts remain exact compressed evidence; historical archives do not require old absolute checkout paths. No future freshness or complete native/cache/transitive closure.')))
