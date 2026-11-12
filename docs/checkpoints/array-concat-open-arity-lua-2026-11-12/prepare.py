"""Prepare source-only Lua questions and finite selected before-use inputs."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = 'fb613736f68f7d1f90df5ade3c0e73c98160ca3f'
OLD = Path('docs/checkpoints/array-transform-callable-lua-2026-11-12')
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'cases.json').exists()
paths = [Path('docs/checkpoints/array-concat-open-arity-selection-2026-11-12/cases.json'),
    OLD / 'cases.json', Path('docs/checkpoints/array-concat-open-arity-perl-2026-11-12/own-questions.json'),
    Path('tests/fixtures/array_transform_result_guard_lua_profiles.json')]
paths += [OLD / name for name in ('proof_io.py', 'observer.lua', 'capture_intake.py')]
paths += [Path('lua/test/array_transform_callable_result_guard_composition_test.lua'),
    Path('lua/test/callable_array_transform_observation.lua')]
sources, images = {}, {}
for index, path in enumerate(paths):
    body = path.read_bytes()
    assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
    target = BASE / ('template-' + str(index) + '.gz')
    target.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(target.read_bytes()) == body
    sources[str(path)] = body
    images[str(path)] = dict(image=str(target), bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
(BASE / 'template-identities.json').write_text(json.dumps(images, indent=2, sort_keys=True) + '\n')
allowed = ('id', 'source', 'body', 'input', 'rule', 'source_kind', 'array_count', 'form', 'tail', 'empty', 'question', 'signature', 'paired_with')
def source_only(row, origin):
    out = {key: row[key] for key in allowed if key in row}
    out.update(origin=origin, profile_only=True)
    if 'expected_error' in row:
        out['question'] = 'needed-producer-error'
    assert not {'expected', 'expected_error', 'expected_observation', 'role'} & out.keys()
    return out
shared, legacy, questions = [json.loads(sources[str(p)]) for p in paths[:3]]
assert (len(shared), len(legacy), len(questions)) == (84, 312, 108)
cases = [source_only(row, origin) for origin, rows in (('shared84', shared), ('legacy312', legacy), ('questions108', questions)) for row in rows]
ordinary = json.loads(sources[str(paths[3])])
tail = '.set_key({order=cat(order,"K");"k"},1).with(){order=cat(order,"W");return("ran")}'
for form in ('free', 'receiver'):
    key = 'extra_concat_arrays_' + form
    own = [ordinary[host][key] for host in ('puc', 'luajit')]
    assert own[0]['source'] == own[1]['source'] and own[0]['input'] == own[1]['input']
    assert own[0]['source'].count(tail) == 1
    for ending in ('terminal', 'composed'):
        cases.append(dict(id='ordinary_legacy_' + key + '_' + ending, source=own[0]['source'].replace(tail, '', 1) if ending == 'terminal' else own[0]['source'],
            input=own[0]['input'], rule='Value', origin='ordinary4', legacy_id=key, form=form, tail=ending, question='legacy-ordinary-operand', profile_only=True))
assert len(cases) == len({r['id'] for r in cases}) == 508
(BASE / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')
fixture = Path('tests/fixtures/array_concat_open_arity_lua_cases.json')
assert not fixture.exists()
fixture.write_bytes((BASE / 'cases.json').read_bytes())

def adapt(text):
    return text.replace(str(OLD), str(BASE)).replace('CALLABLE_TRANSFORM', 'ARRAY_CONCAT').replace('array_transform_callable_result_guard_lua', 'array_concat_open_arity_lua').replace('array_transform_callable_result_guard_composition_test', 'array_concat_open_arity_result_guard_composition_test').replace('fff959ef7e8896b5b97f311a276cabc4f5034551', ACTIVATION)
proof = adapt(sources[str(OLD / 'proof_io.py')].decode())
# The shared old public observation helper is an actual selected input.
(BASE / 'proof_io.py').write_text(proof)
observer = adapt(sources[str(OLD / 'observer.lua')].decode())
observer = observer.replace('array%-transform%-callable%-lua', 'array%-concat%-open%-arity%-lua')
observer = observer.replace('local function observe(identifier, source, input)', 'local function observe(identifier, source, input, origin)')
observer = observer.replace('    local identity = "callable-array-transform/" .. identifier .. ".spec"', '''    local prefix = origin == "legacy312" and "callable-array-transform" or
      origin == "ordinary4" and "array-transform-result-guard" or "array-concat-open-arity-result-guard"
    local identity = prefix .. "/" .. identifier .. ".spec"''')
observer = observer.replace('observe(row.id, row.source, row.input)', 'observe(row.id, row.source, row.input, row.origin)')
(BASE / 'observer.lua').write_text(observer)
# Capture all Lua SDK/test source, but only fixtures consumed by selected normals.
fixtures = ['array_transform_callable_result_guard_lua_cases.json', 'array_transform_callable_result_guard_lua_profiles.json',
    'array_transform_result_guard_lua_cases.json', 'array_transform_result_guard_lua_profiles.json',
    'array_pipeline_callable_result_guard_lua_cases.json', 'array_pipeline_callable_result_guard_lua_profiles.json']
selected = [Path(p) for p in subprocess.check_output(['git', 'ls-files', 'lua'], text=True).splitlines()]
selected += [Path('tests/fixtures') / name for name in fixtures]
selected += [Path('specs') / name for name in ('spec.spec', 'user_function_definition.spec', 'pplugin.spec')]
selected += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh', 'run_lua_project_data.sh', 'build_lua_native.sh')]
(BASE / 'selected-inputs.json').write_text(json.dumps([str(p) for p in sorted(set(selected))], indent=2) + '\n')
capture = adapt(sources[str(OLD / 'capture_intake.py')].decode()).replace('== 312', '== 508').replace('=312', '=508').replace('== 624', '== 1016').replace('original312', 'original508').replace('>= 30', '>= 45')
start = capture.index('    paths = [Path(p) for p in subprocess.check_output')
end = capture.index('    records = proof.freeze', start)
capture = capture[:start] + '''    paths = [Path(p) for p in json.loads((BASE / 'selected-inputs.json').read_bytes())]
    paths += [proof.FIXTURE, OUT / 'cases.json']
    paths += [p for p in BASE.iterdir() if p.is_file() and p.suffix in ('.py', '.lua', '.json', '.gz')]
''' + capture[end:]
compile(capture, 'capture_intake.py', 'exec')
(BASE / 'capture_intake.py').write_text(capture)
monitor = Path('.linkedspec-data/push-monitor/20261112T162616.339595Z')
receipt = json.loads((monitor / 'result.json').read_bytes())
assert receipt['head'] == ACTIVATION and receipt['estimated_non_thin_pack_bytes'] == 1325660163
out = BASE / 'push-monitor-current'
out.mkdir()
for p in sorted(monitor.iterdir()):
    if p.is_file() and p.suffix not in ('.pack', '.idx'):
        (out / p.name).write_bytes(p.read_bytes())
print('Prepared508 source-only Lua questions and selected direct-input closure; no peer verdict or production edit')
