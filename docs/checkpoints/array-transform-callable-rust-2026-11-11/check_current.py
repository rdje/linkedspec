"""Readonly pre-staging SDK identity; historical recovery has no live dependency."""
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
packets = json.loads((BASE / 'direct/custody.json').read_bytes())
rows = packets[0]['files']
selected = {name: row for name, row in rows.items()
    if name.startswith(('rust/', 'tests/fixtures/', 'specs/', 'cli_conformance/', 'tools/', str(BASE.relative_to(ROOT)) + '/'))}
for name, row in selected.items():
    path = ROOT / name
    assert path.is_file() and not path.is_symlink()
    raw = path.read_bytes()
    assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'], name
    assert path.stat().st_mode & 0o777 == row['mode'], name
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == '238da4cc727e9f5921990ef5e8575b45ceac2887'
assert subprocess.check_output(['git', 'diff', '--name-only', '--', 'rust', 'specs'], cwd=ROOT, text=True).splitlines() == ['rust/linkedspec-runtime/src/engine.rs']
assert subprocess.check_output(['git', 'ls-files', '--others', '--exclude-standard', '--', 'rust'], cwd=ROOT, text=True).splitlines() == ['rust/linkedspec-runtime/tests/array_transform_callable_result_guard_composition.rs']
print(json.dumps(dict(current_source='PASS', inputs=len(selected),
    scope='Owned Rust/fixtures/grammars/help/wrappers and new includes match the direct epoch; one production owner and one new normal. Bound to activation/pre-staging only.')))
