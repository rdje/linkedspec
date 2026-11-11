"""Adapt retained Rust instruments to the frozen twenty-target transform lane."""
import gzip
from pathlib import Path

BASE = Path(__file__).resolve().parent
assert not (BASE / 'capture.py').exists()

def template(index):
    text = gzip.decompress((BASE / ('template-' + str(index) + '.gz')).read_bytes()).decode()
    for old, new in (
        ('7e99813d1a88b748cf310992a4ef6ffadf7e978f', '238da4cc727e9f5921990ef5e8575b45ceac2887'),
        ('array-pipeline-callable-rust-2026-11-11', BASE.name),
        ('array-pipeline-callable', 'array-transform-callable'),
        ('array_pipeline_callable', 'array_transform_callable'),
        ('CALLABLE_PIPELINE', 'CALLABLE_TRANSFORM')):
        text = text.replace(old, new)
    return text

capture = template(2)
start = capture.index('    paths += [BASE / name for name in (')
end = capture.index("    sdk = Path('rust')", start)
names = ('prepare.py', 'prepare_trace.py', 'prepare_epochs.py', 'capture_intake.py',
    'freeze_policy.py', 'capture.py', 'observer.rs', 'trace_observer.rs', 'cases.json',
    'own-questions.json', 'baseline.json', 'owner-before.rs.gz', 'repair.py',
    'intake-assessment.json', 'normal-template.rs.gz', 'normal-template-identity.json',
    'template-identities.json')
capture = capture[:start] + '    paths += [BASE / name for name in ' + repr(names) + ']\n' + capture[end:]
start = capture.index("        cases = json.loads(Path('tests/fixtures/")
end = capture.index("        (OUT / 'cases.json').write_text", start)
capture = capture[:start] + "        cases = json.loads(CASES.read_bytes())\n        assert len(cases) == len({c['id'] for c in cases}) == 312\n" + capture[end:]
capture = capture.replace("list((directory / 'inputs').glob('*.json'))", "list((directory / 'inputs').glob('*.json')) + list((directory / 'parsed-inputs').glob('*.json'))")
capture = capture.replace("names += ['array_pipeline_result_guard_composition', 'key_count_callable_result_guard_composition']", "names += ['array_transform_result_guard_composition', 'array_pipeline_callable_result_guard_composition']")
capture = capture.replace("== 194\n", "== 312\n")
capture = capture.replace("'183 passed; 11 failed'", "'292 passed; 20 failed'").replace("'194 passed; 0 failed'", "'312 passed; 0 failed'")
capture = capture.replace("'173 passed; 0 failed' if index == 1 else '16 passed; 0 failed'", "'195 passed; 0 failed' if index == 1 else '194 passed; 0 failed'")
anchor = "        freeze('normal-serialized', list((OUT / 'normal-inputs').glob('*.json')))\n"
assert capture.count(anchor) == 1
capture = capture.replace(anchor, anchor + "        freeze('normal-parsed', list((OUT / 'normal-parsed').glob('*.json')))\n")
assert 'pattern-sources.json' not in capture and 'signature-sources.json' not in capture
(BASE / 'capture.py').write_text(capture)

repair = template(6).replace('pipeline_result_chain', 'transform_result_chain').replace('pipeline_result_call', 'transform_result_call')
repair = repair.replace('pipeline classifier', 'transform classifier').replace('source pipeline', 'source transform')
repair = repair.replace('canonical pipeline', 'canonical transform')
(BASE / 'repair.py').write_text(repair)
(BASE / 'run_repair.py').write_text(template(7))

retire = template(8)
retire = retire.replace('import hashlib\n', 'import gzip\nimport hashlib\n', 1)
anchor = "paths += [BASE / 'trace' / name for name in ('runner', 'trace-exec')]\n"
assert retire.count(anchor) == 1
retire = retire.replace(anchor, anchor + "paths += list((BASE / 'trace').glob('*.trace.log'))\n")
anchor = 'for path in paths:\n    if path.is_dir():\n'
assert retire.count(anchor) == 1
packing = '''for path in paths:
    if path.is_file() and path.name.endswith('.trace.log'):
        packed = Path(str(path) + '.gz')
        assert not packed.exists()
        body = path.read_bytes()
        packed.write_bytes(gzip.compress(body, mtime=0))
        assert gzip.decompress(packed.read_bytes()) == body
'''
retire = retire.replace(anchor, packing + anchor)
retire = retire.replace('Only six archive-verified one-shot producer workspaces/executables;', 'Only six archive-verified one-shot producer workspaces/executables and seven raw trace copies;')
(BASE / 'retire_live_copies.py').write_text(retire)
current = template(9)
current = current.replace("if name.startswith(('rust/', 'tests/fixtures/', 'specs/', 'cli_conformance/', 'tools/'))", "if name.startswith(('rust/', 'tests/fixtures/', 'specs/', 'cli_conformance/', 'tools/', str(BASE.relative_to(ROOT)) + '/'))")
(BASE / 'check_current.py').write_text(current)
(BASE / 'seal.py').write_text(template(10))
print('Prepared scoped capture/repair/private/direct/recovery custody instruments; no SDK or production writer invoked')
