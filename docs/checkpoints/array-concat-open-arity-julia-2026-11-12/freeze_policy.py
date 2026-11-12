"""Freeze only own observed Julia fences and supported concat result intents."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OLD = Path('docs/checkpoints/array-transform-callable-julia-2026-11-12')
ACTIVATION = '952f8a022c59a478614ba1413e0e36e49e7e14e8'
ROUTES = ('native', 'restored', 'plan', 'fresh')
CASES = Path('tests/fixtures/array_concat_open_arity_julia_cases.json')
PROFILE = Path('tests/fixtures/array_concat_open_arity_result_guard_julia_profiles.json')
NORMAL = Path('julia/test/array_concat_open_arity_result_guard_composition_test.jl')
assert all(not path.exists() for path in (CASES, PROFILE, NORMAL, BASE / 'baseline.json'))
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert (BASE / 'launches/inspect-intake/exit.txt').read_text() == '0\n'
assessment = json.loads((BASE / 'intake-assessment.json').read_bytes())
cases = json.loads((BASE / 'cases.json').read_bytes())
targets, compatibility, cold = (assessment[key] for key in ('targets', 'compatibility', 'observed'))
assert len(cases) == 508 and len(targets) == 20 and len(compatibility) == 4
assert len(assessment['initial_policy_ids']) == 80 and len(assessment['invalid_signature_ids']) == 8
assert not targets.keys() & compatibility.keys()
expected = copy.deepcopy(cold)
expected.update(copy.deepcopy(targets))
expected.update(copy.deepcopy(compatibility))
profiles = []
for case in cases:
    key = case['id']
    role = 'supported-target' if key in targets else 'legacy-operand-compatibility' if key in compatibility else 'preservation'
    profiles.append(dict(id=key, case=case, role=role, expected=expected[key]))
failures = sum(json.dumps(cold[key][route], sort_keys=True) != json.dumps(expected[key][route], sort_keys=True)
    for key in cold for route in ROUTES)
assert failures == 96
PROFILE.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
CASES.write_bytes((BASE / 'cases.json').read_bytes())
(BASE / 'baseline.json').write_text(json.dumps(dict(observed=cold, expected=expected,
    programs=len(cases), routes=list(ROUTES), supported_targets=sorted(targets),
    legacy_operand_compatibility=sorted(compatibility), preserved=assessment['preserved'],
    original_assertion_failures=failures, initial_policy_ids=assessment['initial_policy_ids'],
    invalid_signature_ids=assessment['invalid_signature_ids'],
    limits='Finite own Julia authored controls; compatibility retains actual terminal scalar operands without new input authority. Full errors/absence remain; native/cache/transitive/toolchain/OS4.2/SESSION5 separate.'),
    indent=2, sort_keys=True) + '\n')

templates = {}
for path in (Path('julia/test/array_transform_callable_result_guard_composition_test.jl'), OLD / 'capture.py'):
    body = path.read_bytes()
    assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
    target = BASE / ('freeze-template-' + path.name + '.gz')
    target.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(target.read_bytes()) == body
    templates[str(path)] = dict(image=str(target), bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
(BASE / 'freeze-template-identities.json').write_text(json.dumps(templates, indent=2, sort_keys=True) + '\n')
source = gzip.decompress((BASE / 'freeze-template-array_transform_callable_result_guard_composition_test.jl.gz').read_bytes()).decode()
source = source.replace('JuliaCallableTransformComposition', 'JuliaOpenArityConcatComposition')
source = source.replace('CALLABLE_TRANSFORM_JULIA', 'ARRAY_CONCAT_JULIA')
source = source.replace('array_transform_callable_result_guard_julia_cases', 'array_concat_open_arity_julia_cases')
source = source.replace('array_transform_callable_result_guard_julia_profiles', 'array_concat_open_arity_result_guard_julia_profiles')
source = source.replace(str(OLD), str(BASE))
source = source.replace('Julia callable Array-transform result guards', 'Julia existing concat arity result guards')
anchor = '    identity = "callable-array-transform/$identifier.spec"\n'
assert source.count(anchor) == 1
source = source.replace(anchor, '''    prefix = row["origin"] == "legacy312" ? "callable-array-transform" :
        row["origin"] == "ordinary4" ? "array-transform-result-guard" : "array-concat-open-arity-result-guard"
    identity = "$prefix/$identifier.spec"
''', 1)
anchor = '            build_generated_rule_plan(compiled), row["input"], identity)),\n'
assert source.count(anchor) == 1
source = source.replace(anchor, '''            build_generated_rule_plan(compiled), row["input"],
            row["origin"] == "ordinary4" ? "array-transform-result-guard-assessment.spec" : identity)),
''', 1)
NORMAL.write_text(source)
capture = gzip.decompress((BASE / 'freeze-template-capture.py.gz').read_bytes()).decode()
capture = capture.replace(str(OLD), str(BASE))
capture = capture.replace('3767c87c7167bdcb29b0092be35bc139520e3509', ACTIVATION)
capture = capture.replace('CALLABLE_TRANSFORM_JULIA', 'ARRAY_CONCAT_JULIA')
capture = capture.replace('array_transform_callable_result_guard_composition_test.jl', NORMAL.name)
capture = capture.replace('array_transform_callable_result_guard_julia_cases.json', CASES.name)
capture = capture.replace('array_transform_callable_result_guard_julia_profiles.json', PROFILE.name)
capture = capture.replace('int(match[1]) >= 30', 'int(match[1]) >= 45')
capture = capture.replace('len(observed) == 312', 'len(observed) == 508')
start = capture.index('    pattern = ')
end = capture.index("    baseline = json.loads", start)
capture = capture[:start] + '''    pattern = rb'Julia existing concat arity result guards\\s*\\|\\s*1936\\s+96\\s+2032\\s' if before else rb'Julia existing concat arity result guards\\s*\\|\\s*2032\\s+2032\\s'
    assert re.search(pattern, result.stdout), 'actual finite semantic count'
    if phase == 'direct':
        assert re.search(rb'Julia ordinary Array-transform result guards\\s*\\|\\s*903\\s+903\\s', result.stdout)
        assert re.search(rb'Julia callable Array-transform result guards\\s*\\|\\s*1248\\s+1248\\s', result.stdout)
        assert re.search(rb'Julia callable Array-pipeline result guards\\s*\\|\\s*776\\s+776\\s', result.stdout)
''' + capture[end:]
capture = capture.replace("tests += ['julia/test/array_transform_result_guard_composition_test.jl', 'julia/test/array_pipeline_callable_result_guard_composition_test.jl']",
    "tests += ['julia/test/array_transform_callable_result_guard_composition_test.jl', 'julia/test/array_transform_result_guard_composition_test.jl', 'julia/test/array_pipeline_callable_result_guard_composition_test.jl']")
capture = capture.replace('actual312 four-route', 'actual508 four-route')
compile(capture, 'capture.py', 'exec')
(BASE / 'capture.py').write_text(capture)
for name, path in (('owner', Path('julia/src/runtime/Interpreter.jl')), ('runner', Path('julia/test/runtests.jl'))):
    body = path.read_bytes()
    assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
    (BASE / (name + '-before.jl.gz')).write_bytes(gzip.compress(body, mtime=0))
print('Frozen own Julia508:20 supported/four legacy compatibility/484 preserved;80 initial/eight invalid signatures. Original normal must expose96 route failures before repair')
