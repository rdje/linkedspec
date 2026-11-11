"""Preserve original44; qualify one unsupported literal-source oracle separately."""
import copy
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path.cwd().resolve()
HERE = Path(__file__).resolve().parent
BASE = HERE.relative_to(ROOT)
original = json.loads((HERE / 'cases.json').read_bytes())
assert len(original) == 44 and not (HERE / 'qualified-cases.json').exists()
qualified = copy.deepcopy(original)
control = next(row for row in qualified if row['id'] == 'constructor_rejection_oracle')
assert control.pop('expected') == [None, '']
control['profile_only'] = True
oracle_path = 'tests/fixtures/array_transform_result_guard_cases.json'
oracle_raw = (ROOT / oracle_path).read_bytes()
(HERE / 'oracle-template.json.gz').write_bytes(gzip.compress(oracle_raw, mtime=0))
assert gzip.decompress((HERE / 'oracle-template.json.gz').read_bytes()) == oracle_raw
oracle = copy.deepcopy(next(row for row in json.loads(oracle_raw) if row['id'] == 'constructor_array_guard'))
oracle['id'] = 'established_constructor_guard'
oracle['source'] = 'fn supply(seed) {return(seed)}\n\nValue:: I {' + oracle['body'] + '}\n'
qualified.append(oracle)
(HERE / 'qualified-cases.json').write_text(json.dumps(qualified, indent=2) + '\n')
templates = {}
for name in ('observer.pl', 'capture.py', 'inspect.py'):
    raw = (HERE / name).read_bytes()
    (HERE / (name + '-qualification-template.gz')).write_bytes(gzip.compress(raw, mtime=0))
    templates[str(BASE / name)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())
observer = (HERE / 'observer.pl').read_text()
assert observer.count(str(BASE / 'cases.json')) == 1
observer = observer.replace(str(BASE / 'cases.json'), str(BASE / 'qualified-cases.json'))
(HERE / 'qualified_observer.pl').write_text(observer)
capture = (HERE / 'capture.py').read_text()
assert capture.count("OUT = BASE / 'intake'") == 1
capture = capture.replace("OUT = BASE / 'intake'", "OUT = BASE / 'qualified'")
assert capture.count("'cases.json'") == capture.count("'observer.pl'") == 2
capture = capture.replace("'cases.json'", "'qualified-cases.json'").replace("'observer.pl'", "'qualified_observer.pl'")
needle = 'records = {}'
assert capture.count(needle) == 1
capture = capture.replace(needle, "paths += [BASE / name for name in ('capture_qualified.py', 'inspect_qualified.py', 'qualify.py',\n"
    "    'run_qualified.py', 'qualification.json', 'oracle-template.json.gz',\n"
    "    'observer.pl-qualification-template.gz', 'capture.py-qualification-template.gz',\n"
    "    'inspect.py-qualification-template.gz', 'cases.json', 'observer.pl',\n"
    "    'qualified-capture-producer-images.json.gz')]\n"
    "paths += [Path('tests/fixtures/array_transform_result_guard_cases.json')]\n" + needle)
(HERE / 'capture_qualified.py').write_text(capture)
inspection = (HERE / 'inspect.py').read_text()
inspection = inspection.replace("'cases.json'", "'qualified-cases.json'")
inspection = inspection.replace("'intake/observer-stdout.log.gz'", "'qualified/observer-stdout.log.gz'")
for name in ('observations.json', 'input-records.json', 'assessment.json'):
    inspection = inspection.replace("'" + name + "'", "'qualified-" + name + "'")
needle = "assert not (HERE / 'qualified-assessment.json').exists()"
assert inspection.count(needle) == 1
preservation = '''old_rows = json.loads((HERE / 'observations.json').read_bytes())
old_inputs = json.loads((HERE / 'input-records.json').read_bytes())
for identifier, old in old_rows.items():
    normalized = json.loads(json.dumps(rows[identifier]))
    for field in ('module_input', 'handler_input'):
        if normalized[field] is not None:
            normalized[field]['path'] = normalized[field]['path'].replace('/qualified/', '/intake/')
    assert normalized == old, 'original full record changed: ' + identifier
    assert inputs[identifier] == old_inputs[identifier], 'original source/module/handler changed: ' + identifier
assert len(old_rows) == 44
'''
inspection = inspection.replace(needle, preservation + needle)
(HERE / 'inspect_qualified.py').write_text(inspection)
(HERE / 'qualification.json').write_text(json.dumps(dict(
    original_questions=44, qualified_questions=45, unsupported_expectation='constructor_rejection_oracle',
    original_preserved=True, changed_expectation_fields=['expected removed', 'profile_only true'],
    reason='The established oracle uses array(...). The original literal Array initial wrong-Hash-consumer policy is not admitted by the selected produced-result contract; preserve its actual wrapped host error as a profile, with inventory owner TYPE-REFERENCE-BOOK.1.2.1.3.1.',
    oracle_template=oracle_path, oracle_sha256=hashlib.sha256(oracle_raw).hexdigest(),
    actual_source_templates=templates), indent=2) + '\n')
print(json.dumps(dict(result='PASS', original_questions=44, qualified_questions=45,
    original_sources_unchanged=True, next='separate actual qualified acquisition'), sort_keys=True))
