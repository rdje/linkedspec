"""Prepare Julia source questions and own public observer before acquisition."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = '952f8a022c59a478614ba1413e0e36e49e7e14e8'
OLD = Path('docs/checkpoints/array-transform-callable-julia-2026-11-12')
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'cases.json').exists()
paths = [
    Path('docs/checkpoints/array-concat-open-arity-selection-2026-11-12/cases.json'),
    OLD / 'cases.json',
    Path('docs/checkpoints/array-concat-open-arity-perl-2026-11-12/own-questions.json'),
    Path('tests/fixtures/array_transform_result_guard_julia_profiles.json'),
    OLD / 'observer.jl', OLD / 'capture_intake.py', OLD / 'run_stage.py',
    Path('julia/test/callable_array_transform_observation.jl'),
    Path('tests/fixtures/array_transform_callable_result_guard_julia_profiles.json'),
    Path('julia/test/array_transform_callable_result_guard_composition_test.jl'),
]
images, sources = {}, {}
for index, path in enumerate(paths):
    body = path.read_bytes()
    assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
    image = BASE / ('template-' + str(index) + '.gz')
    image.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(image.read_bytes()) == body
    images[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(),
        mode=path.stat().st_mode & 0o777, image=str(image))
    sources[str(path)] = body
(BASE / 'template-identities.json').write_text(json.dumps(images, indent=2, sort_keys=True) + '\n')
allowed = ('id', 'body', 'source', 'input', 'rule', 'source_kind', 'array_count',
    'form', 'tail', 'empty', 'question', 'signature', 'paired_with')


def source_only(row, origin):
    result = {key: row[key] for key in allowed if key in row}
    result.update(origin=origin, profile_only=True)
    if 'expected_error' in row:
        result['question'] = 'needed-producer-error'
    assert not {'expected', 'expected_error', 'expected_observation', 'role'} & result.keys()
    return result


shared, legacy, questions = [json.loads(sources[str(path)]) for path in paths[:3]]
assert (len(shared), len(legacy), len(questions)) == (84, 312, 108)
cases = [source_only(row, 'shared84') for row in shared]
cases += [source_only(row, 'legacy312') for row in legacy]
own = [source_only(row, 'questions108') for row in questions]
cases += own
ordinary = json.loads(sources[str(paths[3])])
tail = '.set_key({order=cat(order,"K");"k"},1).with(){order=cat(order,"W");return("ran")}'
for form in ('free', 'receiver'):
    key = 'extra_concat_arrays_' + form
    source = ordinary[key]['source']
    assert source.count(tail) == 1
    for ending in ('terminal', 'composed'):
        cases.append(dict(id='ordinary_legacy_' + key + '_' + ending,
            source=source.replace(tail, '', 1) if ending == 'terminal' else source,
            input=ordinary[key]['input'], rule='Value', origin='ordinary4', legacy_id=key,
            form=form, tail=ending, question='legacy-ordinary-operand', profile_only=True))
assert len(cases) == len({row['id'] for row in cases}) == 508
(BASE / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')
(BASE / 'own-questions.json').write_text(json.dumps(own, indent=2) + '\n')

observer = sources[str(paths[4])].decode()
observer = observer.replace(str(OLD), str(BASE))
observer = observer.replace('CALLABLE_TRANSFORM_JULIA', 'ARRAY_CONCAT_JULIA')
observer = observer.replace('JuliaCallableTransformProbe', 'JuliaOpenArityConcatProbe')
anchor = '            identity = "callable-array-transform/$identifier.spec"\n'
assert observer.count(anchor) == 1
observer = observer.replace(anchor, '''            prefix = get(row, "origin", "") == "legacy312" ? "callable-array-transform" :
                get(row, "origin", "") == "ordinary4" ? "array-transform-result-guard" : "array-concat-open-arity-result-guard"
            identity = "$prefix/$identifier.spec"
''', 1)
# The older ordinary direct normal has a distinct generated-plan identity.
anchor = '                    build_generated_rule_plan(compiled), row["input"], identity)),\n'
assert observer.count(anchor) == 1
observer = observer.replace(anchor, '''                    build_generated_rule_plan(compiled), row["input"],
                    get(row, "origin", "") == "ordinary4" ? "array-transform-result-guard-assessment.spec" : identity)),
''', 1)
(BASE / 'observer.jl').write_text(observer)
capture = sources[str(paths[5])].decode().replace(str(OLD), str(BASE))
capture = capture.replace('3767c87c7167bdcb29b0092be35bc139520e3509', ACTIVATION)
capture = capture.replace('CALLABLE_TRANSFORM_JULIA', 'ARRAY_CONCAT_JULIA')
capture = capture.replace("int(match[1]) >= 30", "int(match[1]) >= 45")
capture = capture.replace('Original', 'Independent')
compile(capture, 'capture_intake.py', 'exec')
(BASE / 'capture_intake.py').write_text(capture)

# Retain this already-completed ref-bound operational result, without raw packs.
# This is custody of the actual earlier run, not first-use native closure credit.
monitor = Path('.linkedspec-data/push-monitor/20261112T142502.147800Z')
receipt = json.loads((monitor / 'result.json').read_bytes())
assert receipt['head'] == ACTIVATION and receipt['ahead'] == 103
assert receipt['estimated_non_thin_pack_bytes'] == 1269685903
target = BASE / 'push-monitor-current'
target.mkdir()
retained = {}
for path in sorted(monitor.iterdir()):
    if not path.is_file() or path.suffix in ('.pack', '.idx', '.rev', '.log'):
        continue
    body = path.read_bytes()
    destination = target / path.name
    destination.write_bytes(body)
    assert destination.read_bytes() == body
    retained[path.name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(),
        source_mode=path.stat().st_mode & 0o777, retained_mode=destination.stat().st_mode & 0o777)
(target / 'retention-identities.json').write_text(json.dumps(retained, indent=2, sort_keys=True) + '\n')
print('Prepared Julia508 source-only questions/shared84/own legacy312/new108/four exact ordinary controls; outcomes unacquired, interpreter unchanged')
