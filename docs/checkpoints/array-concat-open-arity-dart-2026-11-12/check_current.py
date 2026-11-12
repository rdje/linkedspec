"""Compare current Dart inputs with their actual direct-run identities, before staging."""
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
packets = json.loads((BASE / 'direct/custody.json').read_bytes())
rows = dict(next(p['files'] for p in packets if p['tag'] == 'root'))
rows.update(next(p['files'] for p in packets if p['tag'] == 'resolved'))
selected = {name: row for name, row in rows.items() if name.startswith(('dart/', 'tests/fixtures/', 'specs/', 'tools/'))}
for name, row in selected.items():
    path = ROOT / name
    assert not Path(name).is_absolute() and '..' not in Path(name).parts
    assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
    raw = path.read_bytes()
    assert len(raw) == row['bytes'] and hashlib.sha256(raw).hexdigest() == row['sha256'], name
    assert path.stat().st_mode & 0o777 == row['mode'], name
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == '1753884257bed7ce0b842bc406c665671403a828'
assert subprocess.run(['git', 'diff', '--cached', '--quiet'], cwd=ROOT).returncode == 0
assert subprocess.check_output(['git', 'diff', '--name-only', '--', 'dart/lib', 'specs'], cwd=ROOT, text=True).splitlines() == ['dart/lib/src/runtime/interpreter.dart']
assert subprocess.check_output(['git', 'ls-files', '--others', '--exclude-standard', '--', 'dart'], cwd=ROOT, text=True).splitlines() == [
    'dart/test/array_concat_open_arity_result_guard_composition_test.dart',
    'dart/tool/probe_open_arity_array_concat_results.dart']
print(json.dumps(dict(current_inputs='PASS', declared_inputs=len(selected),
    scope='Actual direct-run Dart/test/fixture/grammar/wrapper identities at activation/pre-staging. Resolved package data supersedes initial config. No SDK replay or future/native/cache/transitive closure claim.'), sort_keys=True))
