"""Retain a rejected preparation guard and target the recurring branch explicitly."""
import ast
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-required/'
before = {P + name: c.read(P + name) for name in ('warning_fix.py', 'warning_capture.py')}
failed = c.run(['bash', 'tools/run_python_project_data.sh', P + 'warning_fix.py'])
assert failed['returncode'] == 1 and b'AssertionError' in c.decode(failed['stderr_base64'])
assert not (ROOT / (P + 'warning-proposals.json.gz')).exists()
fix = c.decode(before[P + 'warning_fix.py']['base64']).decode()
anchor = "needle = '    if fresh:\\n        repeated = c.run'\n"
start = fix.index(anchor)
end = fix.index("needle = \"        assert repeated", start)
part = fix[start:end]
assert part.count('assert records.count(needle) == 1') == 1
part = part.replace('assert records.count(needle) == 1', 'assert records.count(needle) >= 1')
part = part.replace('records = records.replace(needle, replacement, 1)',
    'position = records.rindex(needle)\nrecords = records[:position] + records[position:].replace(needle, replacement, 1)')
fix = fix[:start] + part + fix[end:]
fix = fix.replace('warning_fix.py', 'warning_fix_final.py').replace('warning_capture.py', 'warning_capture_final.py')
capture = c.decode(before[P + 'warning_capture.py']['base64']).decode()
capture = capture.replace('warning_capture.py', 'warning_capture_final.py')
old = '    "LinkedSpec::CodeblockRuntime::invoke($set, [], {}, q{set}, undef, {}) }\');"])\n'
new = r'''    "LinkedSpec::CodeblockRuntime::invoke($set, [], {set => \\$set}, q{set}, undef, "
    "{descriptor => $descr, input => $STRING, match_info => $minfo}) }');"])
'''
assert capture.count(old) == 1
capture = capture.replace(old, new, 1)
texts = {P + 'warning_fix_final.py': fix, P + 'warning_capture_final.py': capture}
after = {path: dict(base64=c.encode(text.encode()), sha256=c.sha(text.encode()), mode=0o644)
         for path, text in texts.items()}
for path, text in texts.items():
    ast.parse(text, filename=path)
c.write_new(P + 'warning-preparation.json.gz', dict(before=before, after=after, run=failed,
    producer=c.read(P + 'prepare_warning.py'),
    scope='The first warning-fix preparer encounters two identical fresh-branch prefixes '
          'and rejects before any writes. The separate corrected actor targets the last, '
          'recurring branch; the observer probe supplies its complete declared lexical ABI.'),
    packed=True)
for path, item in after.items():
    assert not (ROOT / path).exists()
    (ROOT / path).write_bytes(c.decode(item['base64']))
print('Warning preparation corrected before writes; original failure retained')
