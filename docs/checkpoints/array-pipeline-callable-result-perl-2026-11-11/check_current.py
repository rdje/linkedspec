"""Readonly current source identity, separate from historical SDK recovery."""
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
rows = json.loads((BASE / 'after/input-identities.json').read_bytes())
selected = {name: row for name, row in rows.items() if name.startswith(('perl/', 'specs/', 'tools/'))
    or name in ('t/array_pipeline_callable_result_guard_composition.t', 'tests/fixtures/array_pipeline_callable_result_guard_perl_cases.json')}
for name, row in selected.items():
    path = ROOT / name
    assert path.is_file() and not path.is_symlink()
    assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'], name
    assert path.stat().st_mode & 0o777 == row['mode'], name
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == '5f22dae8d3a10cd10f4d2ecfbc6d0be9fd71e172'
assert subprocess.check_output(['git', 'diff', '--name-only', '--', 'perl', 'specs'], cwd=ROOT, text=True).splitlines() == ['perl/LinkedSpec/ActionIR/MethodLowering.pm']
print(json.dumps(dict(current_source='PASS', inputs=len(selected),
    scope='Tracked owned Perl/specs, selected wrappers and new normal/fixture match the repaired SDK epoch; one production owner changed.')))
