"""Readonly activation-bound current Dart input identity; no replay writers."""
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
packets = json.loads((BASE / 'direct/custody.json').read_bytes())
rows = dict(packets[0]['files'])
for packet in packets:
    if packet['tag'] == 'resolved':
        rows.update(packet['files'])
trace = json.loads((BASE / 'trace/custody.json').read_bytes())[0]['files']
name = 'dart/tool/trace_callable_array_transform_results.dart'
rows[name] = trace[name]
selected = {name: row for name, row in rows.items() if name.startswith(('dart/', 'tests/fixtures/', 'specs/', 'tools/'))}
for name, row in selected.items():
    path = ROOT / name
    assert path.is_file() and not path.is_symlink()
    body = path.read_bytes()
    assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'], name
    assert path.stat().st_mode & 0o777 == row['mode'], name
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == '5ac1fac5eb7126cd8f952858f8df194914884830'
assert subprocess.check_output(['git', 'diff', '--name-only', '--', 'dart/lib', 'specs'], cwd=ROOT, text=True).splitlines() == ['dart/lib/src/runtime/interpreter.dart']
untracked = subprocess.check_output(['git', 'ls-files', '--others', '--exclude-standard', '--', 'dart'], cwd=ROOT, text=True).splitlines()
assert untracked == sorted([
    'dart/test/array_transform_callable_result_guard_composition_test.dart',
    'dart/tool/callable_array_transform_observation.dart',
    'dart/tool/probe_callable_array_transform_results.dart',
    'dart/tool/trace_callable_array_transform_results.dart'])
print(json.dumps(dict(current_source='PASS', inputs=len(selected),
    scope='Owned Dart/fixtures/grammar/wrappers/new includes/trace match actual declared epochs; current resolved package data supersedes its pre-resolution snapshot. One production owner changed. Bound to activation/pre-staging.')))
