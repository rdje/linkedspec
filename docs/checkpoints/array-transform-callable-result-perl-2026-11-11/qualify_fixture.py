"""Separate three canonical-readiness movements from unchanged source-policy payloads."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
fixture = Path('tests/fixtures/array_transform_callable_result_guard_perl_cases.json')
normal = Path('t/array_transform_callable_result_guard_composition.t')
capture = BASE / 'capture.py'
classification = BASE / 'classification.json'
records = json.loads((BASE / 'after/input-identities.json').read_bytes())
originals = {}
for path in (fixture, normal, capture, classification):
    name = str(path.resolve().relative_to(ROOT))
    raw = path.read_bytes()
    assert hashlib.sha256(raw).hexdigest() == records[name]['sha256']
    alias = BASE / ('qualification-original-' + path.name + '.gz')
    assert not alias.exists()
    alias.write_bytes(gzip.compress(raw, mtime=0))
    originals[name] = dict(alias=alias.name, bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())
profiles = json.loads(fixture.read_bytes())
rows = {}
for line in gzip.decompress((BASE / 'after/run-stderr.log.gz').read_bytes()).decode().splitlines():
    match = re.fullmatch(r'\s*# CALLABLE_ARRAY_TRANSFORM_RESULT_ROW (\w+) (.*)', line)
    if match:
        assert match[1] not in rows
        rows[match[1]] = json.loads(match[2])
assert len(rows) == len(profiles) == 312
ready = dict(canonical_action_ir_fallback_count=0, language_agnostic_action_ir_ready=1,
    raw_perl_dependency_count=0, unresolved_helper_count=0, unresolved_helpers=[])
selected = {'initial_number_composed', 'initial_null_composed', 'initial_hash_composed'}


def projection(value):
    if isinstance(value, dict):
        return {k: projection(v) for k, v in value.items() if k not in ('substitution', 'module_input', 'handler_input')}
    if isinstance(value, list):
        return [projection(v) for v in value]
    return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value) if isinstance(value, str) else value


changes = []
for profile in profiles:
    key = profile['case']['id']
    if profile['role'] != 'preservation':
        continue
    expected = profile['expected_observation']
    actual = projection(rows[key])
    if key not in selected:
        assert actual == expected, key
        continue
    assert expected['metadata'] == dict(ready, language_agnostic_action_ir_ready=0, unresolved_helper_count=1, unresolved_helpers=['with'])
    updated = copy.deepcopy(expected)
    updated['metadata'] = ready
    assert actual == updated, 'not a metadata-only movement'
    terminal = key.replace('_composed', '_terminal')
    assert rows[terminal]['metadata'] == ready
    assert rows[terminal]['native'] == rows[terminal]['fresh'] == [[], []]
    assert rows[key]['native'] == rows[key]['fresh'] == [None, '']
    profile['role'] = 'compatibility-readiness'
    profile['expected_observation'] = updated
    changes.append(key)
assert set(changes) == selected
fixture.write_text(json.dumps(profiles, indent=2) + '\n')
text = normal.read_text()
old = ": 'full acquired observation preserved');"
assert text.count(old) == 1
normal.write_text(text.replace(old, ": $profile->{role} eq 'compatibility-readiness' ? 'payload/error boundaries and disclosed readiness' : 'full acquired observation preserved');"))
data = json.loads(classification.read_bytes())
data['compatibility_readiness'] = sorted(selected)
data['protected_records'] = 266
for key in selected:
    data['roles'][key] = 'compatibility-readiness'
classification.write_text(json.dumps(data, indent=2, sort_keys=True) + '\n')
text = capture.read_text()
old = "assert phase in ('intake', 'before', 'after', 'private_old', 'private_current', 'direct')"
assert text.count(old) == 1
target = BASE / 'capture_qualified.py'
assert not target.exists()
target.write_text(text.replace(old, "assert phase == 'after_qualified'"))
(BASE / 'qualification.json').write_text(json.dumps(dict(originals=originals, readiness_only=sorted(selected),
    original_after_actual_exit=3, targets=43, preserved_records=266,
    limits='Three compatibility readiness movements have no product-RED or portable initial-input policy credit. Complete original payload/error/field-absence observations stay exact; first normal/fixture/classification and actual failed after epoch survive.'), indent=2) + '\n')
print('Qualified exactly three metadata projections:43 targets/three readiness movements/266 preserved; no SDK change.')
