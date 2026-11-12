"""Prepare installed Lua authored questions and actual before-use instruments."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
ACTIVATION = 'fff959ef7e8896b5b97f311a276cabc4f5034551'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == ACTIVATION
assert not (BASE / 'cases.json').exists()
old_base = 'docs/checkpoints/array-pipeline-callable-lua-2026-11-11/'
paths = [old_base + name for name in ('proof_io.py', 'capture.py', 'observer.lua',
    'trace_qualified.lua', 'capture_trace_qualified.py', 'freeze_profiles.py',
    'repair.py', 'run_repair.py', 'review.py', 'seal.py', 'check_current.py', 'capture_current.py')]
paths += ['lua/test/callable_array_pipeline_observation.lua',
    'lua/test/array_pipeline_callable_result_guard_composition_test.lua',
    'tests/fixtures/array_transform_callable_result_guard_cases.json',
    'docs/checkpoints/array-transform-callable-julia-2026-11-12/own-questions.json',
    'docs/checkpoints/array-transform-callable-julia-2026-11-12/run_stage.py']
templates = {}
for index, name in enumerate(paths):
    body = (ROOT / name).read_bytes()
    assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + name], cwd=ROOT)
    target = BASE / ('template-' + str(index) + '.gz')
    assert not target.exists()
    target.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(target.read_bytes()) == body
    templates[name] = dict(image=target.relative_to(ROOT).as_posix(), bytes=len(body), sha256=hashlib.sha256(body).hexdigest())
(BASE / 'template-identities.json').write_text(json.dumps(templates, indent=2, sort_keys=True) + '\n')
shared = json.loads((ROOT / paths[-3]).read_bytes())
own = json.loads((ROOT / paths[-2]).read_bytes())
assert len(shared) == 45 and len(own) == 267
allowed = {'id', 'source', 'body', 'input', 'rule', 'question', 'profile_only', 'paired_with', 'form'}
assert all(set(row) <= allowed and row.get('profile_only') is True for row in own)
cases = shared + own
assert len(cases) == len({row['id'] for row in cases}) == 312
for name, rows in (('cases.json', cases), ('own-questions.json', own)):
    (BASE / name).write_text(json.dumps(rows, indent=2) + '\n')
fixture = ROOT / 'tests/fixtures/array_transform_callable_result_guard_lua_cases.json'
assert not fixture.exists()
fixture.write_text(json.dumps(cases, indent=2) + '\n')

def adapt(body):
    return (body.replace('array-pipeline-callable-lua-2026-11-11', BASE.name)
        .replace('2026%-11%-11', '2026%-11%-12')
        .replace('pipeline', 'transform').replace('PIPELINE', 'TRANSFORM').replace('Pipeline', 'Transform'))

for target, original in (('proof_io.py', old_base + 'proof_io.py'), ('observer.lua', old_base + 'observer.lua')):
    (BASE / target).write_text(adapt((ROOT / original).read_text()))
helper = ROOT / 'lua/test/callable_array_transform_observation.lua'
assert not helper.exists()
helper.write_text((ROOT / 'lua/test/callable_array_pipeline_observation.lua').read_text())
print('Prepared installed Lua shared45/own267 source-only questions and full public error observer; no peer outcomes or production edit')
