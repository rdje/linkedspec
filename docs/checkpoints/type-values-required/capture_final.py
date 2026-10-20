"""Measure complete recurring consumers after the retained source-comparison correction."""
import gzip
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-required/'
load = lambda name: json.loads(gzip.decompress((ROOT / (P + name)).read_bytes()))
preserved, first, fix = map(load, ('preservation.json.gz', 'proposals.json.gz', 'source-fix.json.gz'))
targets = first['after'] | fix['after']
assert c.unchanged(targets)
assert c.read('perl/LinkedSpec/ActionIR/MethodLowering.pm') == first['current_module']
for path, item in preserved['inputs'].items():
    expected = targets.get(path, item)
    assert all(c.read(path)[key] == expected[key] for key in ('sha256', 'mode')), path
selected = sorted(first['before'])
assert len(selected) == 12
paths = set(preserved['inputs']) | set(targets) | {
    str(path.relative_to(ROOT)) for path in (ROOT / P).iterdir() if path.is_file()}
inputs = {path: {key: c.read(path)[key] for key in ('sha256', 'mode')} for path in sorted(paths)}
c.write_new(P + 'focused-final-inputs.json', dict(inputs=inputs, selected=selected,
    producer=c.read(P + 'capture_final.py'),
    scope='Complete prior closure plus exact correction chain and all retained instruments; '
          'identities/modes precede execution. Frozen native records and production stay exact.'))
syntax = [c.run(['perl', '-c', '-Iperl', path]) for path in selected +
          ['t/lib/LinkedSpecTest/MethodLocations.pm', 't/lib/LinkedSpecTest/EmittedValues.pm']]
run = c.run(['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'prove', '-v', '-Iperl'] + selected)
unchanged = all(all(c.read(path)[key] == item[key] for key in ('sha256', 'mode'))
                for path, item in inputs.items())
c.write_new(P + 'focused-final-run.json.gz', dict(syntax=syntax, run=run,
    producer=c.read(P + 'capture_final.py'), input_identities=inputs,
    inputs_bytes_modes_unchanged=unchanged), packed=True)
assert all(result['returncode'] == 0 for result in syntax)
assert run['returncode'] == 0
text = c.decode(run['stdout_base64']).decode()
assert 'Files=12, Tests=5001,' in text and 'Result: PASS' in text
assert not re.search(r'^\s*not ok \d+', text, re.M)
assert unchanged
c.write_new(P + 'focused-final-review.json', dict(result='PASS', files=12, assertions=5001,
    original_assertions=4998, new_independent_goldens=3, syntax_checks=len(syntax),
    production_module_unchanged=True, inputs_bytes_modes_unchanged=True,
    scope='198 diagnostic-coordinate and four emitted-source comparisons preserve their '
          'full original plans; three independent value/ABI goldens are additional. '
          'No historical observation refresh or runtime/private admission is inferred.'))
print('Recurring consumers PASS:12 files/5001 assertions; production and frozen inputs unchanged')
