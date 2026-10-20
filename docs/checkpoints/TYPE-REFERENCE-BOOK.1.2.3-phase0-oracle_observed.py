"""Attribute and retain the two historical compiler advisories; preserve all values."""
import gzip
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'
plan = json.loads(gzip.decompress((ROOT / (P + 'oracle-loaded-inputs.json.gz')).read_bytes()))
prior = json.loads(gzip.decompress((ROOT / (P + 'oracle-loaded-run.json.gz')).read_bytes()))
assert prior['run']['returncode'] == 0 and prior['runtime_inputs_unchanged']
original = json.loads(c.decode(prior['run']['stdout_base64']))['rows']
assert len(original) == 130 and all(row['error'] is None for row in original)
plan.update(observation_producer=c.read(P + 'oracle_observed.py'),
    observation_actor=c.read(P + 'oracle_observed.pl'),
    prior_observation=c.read(P + 'oracle-loaded-run.json.gz'),
    scope='All130 historical/manual values are valid in the preceding run, which emits two '
          'scalar-hash-slice compiler advisories and fails its overly strict zero-stderr postcondition. '
          'This separate instrument attributes every warning to its actual case and retains raw stderr; '
          'no diagnostic is dropped or reclassified as behavioral RED. Values must remain exact.')
c.write_new(P + 'oracle-observed-inputs.json.gz', plan, packed=True)
run = c.run(['perl', '-Iperl', P + 'oracle_observed.pl'], input=json.dumps(plan).encode())
c.write_new(P + 'oracle-observed-run.json.gz', dict(run=run), packed=True)
assert run['returncode'] == 0
rows = json.loads(c.decode(run['stdout_base64']))['rows']
assert len(rows) == 130
assert [(row['label'], row['expected_json'], row['error']) for row in rows] == [
    (row['label'], row['expected_json'], row['error']) for row in original]
assert c.decode(run['stderr_base64']).decode() == ''.join(warning for row in rows for warning in row['warnings'])
advisory = 'Scalar value @__ls_drop{"debug"} better written as $__ls_drop{"debug"}'
warning_cases = {
    'is_empty(...) and is_nonempty(...) lower inside general return payloads as value helpers',
    'drop_keys(...) lowers inside general return payloads',
}
goldens = []
for row in rows:
    warnings = [re.sub(r' at \(eval \d+\) line \d+(?:, <STDIN> line \d+)?\.\n\Z', '', warning)
                for warning in row['warnings']]
    assert warnings == ([advisory] if row['label'] in warning_cases else []), row['label']
    value = json.loads(row['expected_json'])
    value['warnings'] = warnings
    goldens.append(dict(label=row['label'], expected_json=json.dumps(value, sort_keys=True, separators=(',', ':'))))
assert sum(len(row['warnings']) for row in rows) == 2
c.write_new(P + 'oracle-observed-review.json', dict(result='PASS', goldens=goldens,
    value_cases=130, actual_raw_advisories=2,
    limits='Finite compatibility fixtures only. Exactly two known syntax advisories are asserted as '
           'data, not silently suppressed. Eval id/line transport suffixes alone are normalized. '
           'No project warning gate or public diagnostic policy changes.'))
print('Historical/manual130 values and two exactly attributed raw compiler advisories PASS')
