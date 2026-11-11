"""Preserve original39; qualify only the two unsupported pattern expectations."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
original = json.loads((BASE / 'cases.json').read_bytes())
omitted = {'needed_pattern_terminal', 'needed_pattern_composed'}
cases = [row for row in original if row['id'] not in omitted]
assert len(cases) == 37
consumer = '.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).coalesce("masked")'
for form, expression in (
    ('free', 'filter_match(supply(["head"]),/[z-a]/)'),
    ('receiver', 'supply(["head"]).filter_match(/[z-a]/)'),
):
    for composed in (False, True):
        body = 'order="";return(' + expression + (consumer if composed else '') + ')'
        cases.append(dict(id='invalid_range_' + form + ('_composed' if composed else '_terminal'),
            body=body, source='fn supply(seed) {return(seed)}\n\nValue:: I {' + body + '}\n',
            input='x', rule='Value', expected_regex_error='Invalid [] range'))
assert len(cases) == 41 and len({row['id'] for row in cases}) == 41
target = BASE / 'qualified-cases.json'
assert not target.exists()
target.write_text(json.dumps(cases, indent=2) + '\n')
observer = (BASE / 'observer.pl').read_bytes()
output = BASE / 'qualified_observer.pl'
assert not output.exists()
output.write_bytes(observer.replace(b'/cases.json', b'/qualified-cases.json'))
(BASE / 'qualification.json').write_text(json.dumps(dict(original='cases.json',
    original_sha256=hashlib.sha256((BASE / 'cases.json').read_bytes()).hexdigest(),
    removed_unsupported_expectations=sorted(omitted), preserved_ids=[row['id'] for row in cases[:37]],
    added_ids=[row['id'] for row in cases[37:]],
    reason='Published filter_match regex-operand signature does not require an eager computed-block pattern. Retain original39; acquire four literal-range controls independently before target freeze.'), indent=2) + '\n')
print('Unchanged original37 plus four literal-range questions; original39 untouched')
