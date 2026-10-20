"""Measure the twelve complete recurring consumers from an explicit input closure."""
import gzip
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-required/'
preserved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
proposals = json.loads(gzip.decompress((ROOT / (P + 'proposals.json.gz')).read_bytes()))
assert c.unchanged(proposals['after'])
assert c.read('perl/LinkedSpec/ActionIR/MethodLowering.pm') == proposals['current_module']
for path, item in preserved['inputs'].items():
    expected = proposals['after'].get(path, item)
    assert all(c.read(path)[key] == expected[key] for key in ('sha256', 'mode')), path
selected = sorted(proposals['before'])
assert len(selected) == 12 and all(path.startswith('t/') and path.endswith('.t') for path in selected)
paths = set(preserved['inputs']) | set(proposals['after']) | {
    P + 'preserve.py', P + 'preservation.json.gz', P + 'baseline.json',
    P + 'apply.py', P + 'proposals.json.gz', P + 'capture.py'}
inputs = {path: {key: c.read(path)[key] for key in ('sha256', 'mode')} for path in sorted(paths)}
c.write_new(P + 'focused-inputs.json', dict(inputs=inputs, selected=selected,
    producer=c.read(P + 'capture.py'),
    scope='Actual identities/modes of the whole previous closure, exact changed tests and '
          'new test-only support precede complete unfiltered prove execution. Production '
          'module bytes are unchanged; each original native record remains exact.'))
syntax = [c.run(['perl', '-c', '-Iperl', path]) for path in selected + ['t/lib/LinkedSpecTest/MethodLocations.pm']]
run = c.run(['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'prove', '-v', '-Iperl'] + selected)
c.write_new(P + 'focused-run.json.gz', dict(syntax=syntax, run=run,
    producer=c.read(P + 'capture.py'), input_identities=inputs,
    inputs_bytes_modes_unchanged=all(all(c.read(path)[key] == item[key] for key in ('sha256', 'mode'))
                                   for path, item in inputs.items())), packed=True)
assert all(result['returncode'] == 0 for result in syntax)
assert run['returncode'] == 0
text = c.decode(run['stdout_base64']).decode()
assert 'Files=12, Tests=4998,' in text and 'Result: PASS' in text
assert not re.search(r'^\s*not ok \d+', text, re.M)
assert all(all(c.read(path)[key] == item[key] for key in ('sha256', 'mode')) for path, item in inputs.items())
c.write_new(P + 'focused-review.json', dict(result='PASS', files=12, assertions=4998,
    syntax_checks=len(syntax), production_module_unchanged=True, inputs_bytes_modes_unchanged=True,
    scope='Complete original plans/assertions execute. Current source coordinates are '
          'compared through same-routine unchanged-statement correspondence; one source '
          'spelling check executes its nested value. Parent/private admission stays separate.'))
print('Recurring consumers PASS:12 files/4998 assertions; original plans and production bytes unchanged')
