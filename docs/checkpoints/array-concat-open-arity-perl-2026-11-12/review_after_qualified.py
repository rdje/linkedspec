"""Compare retained original after2 to qualified oracles; never relabel its actual exit."""
import gzip
import hashlib
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
assert not (BASE / 'after-qualified-review.json').exists()
assert (BASE / 'after/normal-exit.txt').read_text() == '2\n'
assert (BASE / 'launches/after/exit.txt').read_text() == '1\n'
assert (BASE / 'outcome_qualification/complete.txt').is_file()
expected = json.loads((BASE / 'epoch-expectations-qualified.json').read_bytes())['current']
baseline = json.loads((BASE / 'baseline-qualified.json').read_bytes())
rows = {}
for channel in ('stdout', 'stderr'):
    for line in gzip.decompress((BASE / 'after' / ('normal-' + channel + '.log.gz')).read_bytes()).decode().splitlines():
        line = line.lstrip()
        if line.startswith('# '):
            line = line[2:]
        if line.startswith('ARRAY_CONCAT_NORMAL_ROW '):
            _, key, raw = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(raw)


def normalize(value):
    if isinstance(value, dict):
        return {key: normalize(child) for key, child in value.items()}
    if isinstance(value, list):
        return [normalize(child) for child in value]
    return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value) if isinstance(value, str) else value


assert len(rows) == len(expected) == 504 and set(rows) == set(expected)
for key, row in rows.items():
    actual = normalize({name: value for name, value in row.items() if name not in ('substitution', 'module_input', 'handler_input')})
    assert actual == expected[key], key
for key in baseline['preserved']:
    actual = normalize({name: value for name, value in rows[key].items() if name not in ('substitution', 'module_input', 'handler_input')})
    cold = normalize({name: value for name, value in baseline['observed'][key].items() if name not in ('substitution', 'module_input', 'handler_input')})
    assert actual == cold
assert len(baseline['preserved']) == 474 and len(baseline['separate_compatibility']) == 4
owner = ROOT / 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
assert owner.read_bytes() == gzip.decompress((BASE / 'owner-after.pm.gz').read_bytes())
(BASE / 'after-qualified-review.json').write_text(json.dumps(dict(
    retained_record_recovery='PASS', programs=504, supported_targets=26, separate_compatibility=4,
    full_preserved_records=474, original_normal_exit=2, original_capture_exit=1,
    current_sdk_sha256=hashlib.sha256(owner.read_bytes()).hexdigest(),
    scope='Readonly comparison of retained after records to independently qualified expectations. Original normal2/capture1 remains; this is not a new passing normal execution. Private restored/direct normals must validate the current regression fixture.'), indent=2) + '\n')
print('Retained original after2 records match qualified504:26 supported/four compatibility/474 full preserved; actual exits unchanged')
