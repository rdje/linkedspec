"""Freeze independently observed Julia policies and author the ordinary normal."""
import gzip
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
PROFILE = Path('tests/fixtures/array_pipeline_result_guard_julia_profiles.json')
CASES = Path('tests/fixtures/array_pipeline_result_guard_julia_cases.json')
NORMAL = Path('julia/test/array_pipeline_result_guard_composition_test.jl')
assert not any(path.exists() for path in (PROFILE, CASES, NORMAL))
rows = {}
for line in gzip.open(BASE / 'intake/native-stdout.log.gz', 'rt'):
    if line.startswith('ARRAY_PIPELINE_JULIA '):
        _, key, value = line.split(' ', 2)
        assert key not in rows
        rows[key] = json.loads(value)
cases = json.loads((BASE / 'cases.json').read_bytes())
assert len(rows) == len(cases) == 173
profiles, red = {}, []
for row in cases:
    key = row['id']
    observed = rows[key]
    assert set(observed) == {'native', 'restored', 'plan', 'fresh'}
    if row.get('profile_only') or row.get('expected_error'):
        profiles[key] = dict(row, **observed)
    if 'expected' in row and any(value != {'value': row['expected']} for value in observed.values()):
        red.append(key)
    if row.get('expected_error'):
        assert all(row['expected_error'] in value['error'] for value in observed.values())
assert len(red) == 17
for key in ('invalid_range_free_composed', 'invalid_range_receiver_composed'):
    for route in ('native', 'restored', 'plan', 'fresh'):
        assert profiles[key][route] == {'value': []}
        profiles[key][route] = {'value': None}
    profiles[key]['guard_target'] = 'Actual Array result rejects Hash consumer before coalesce; terminal fallback remains[]'
    red.append(key)
assert len(profiles) == 141 and len(red) == 19
PROFILE.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
CASES.write_bytes((BASE / 'cases.json').read_bytes())
(BASE / 'baseline.json').write_text(json.dumps(dict(cases=173, shared=36, own=137, profiles=141,
    red=red, healthy=154, own_targets=['invalid_range_free_composed', 'invalid_range_receiver_composed'],
    scope='Finite independently observed Julia preservation/repair controls; not population or performance measurement'), indent=2) + '\n')
prior = Path('julia/test/array_transform_result_guard_composition_test.jl').read_text()
source = prior.replace('JuliaArrayTransformComposition', 'JuliaArrayPipelineComposition')
source = source.replace('Array-transform', 'Array-pipeline').replace('array-transform', 'array-pipeline')
source = source.replace('ARRAY_TRANSFORM', 'ARRAY_PIPELINE').replace('array_transform', 'array_pipeline')
source = source.replace('ArrayTransformGenerated', 'ArrayPipelineGenerated')
NORMAL.write_text(source)
owner = Path('julia/src/runtime/Interpreter.jl')
original = subprocess.check_output(['git', 'show', 'HEAD:' + str(owner)])
assert owner.read_bytes() == original
(BASE / 'owner-before.jl.gz').write_bytes(gzip.compress(original, mtime=0))
runner = Path('julia/test/runtests.jl')
body = runner.read_bytes()
assert body == subprocess.check_output(['git', 'show', 'HEAD:' + str(runner)])
(BASE / 'runner-before.jl.gz').write_bytes(gzip.compress(body, mtime=0))
anchor = 'include("array_transform_result_guard_composition_test.jl")'
assert body.decode().count(anchor) == 1
runner.write_text(body.decode().replace(anchor, anchor + '\ninclude("array_pipeline_result_guard_composition_test.jl")'))
print('Frozen141 profiles/173 cases,19 targets/154 preservation controls and one normal-runner include')
