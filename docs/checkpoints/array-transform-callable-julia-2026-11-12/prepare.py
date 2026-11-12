"""Prepare Julia's own acquisition from authored sources, without peer verdicts."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
ACTIVATION = '3767c87c7167bdcb29b0092be35bc139520e3509'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == ACTIVATION
assert not (BASE / 'cases.json').exists()
old_base = 'docs/checkpoints/array-pipeline-callable-julia-2026-11-11/'
paths = [old_base + name for name in ('observer.jl', 'capture_intake.py', 'inspect_intake.py',
    'capture_trace.py', 'trace.jl', 'capture.py', 'repair.py', 'run_repair.py', 'review.py',
    'seal.py', 'check_current.py', 'capture_current.py', 'record_review.py', 'freeze_policy.py')]
paths += ['julia/test/callable_array_pipeline_observation.jl',
    'julia/test/array_pipeline_callable_result_guard_composition_test.jl',
    'tests/fixtures/array_transform_callable_result_guard_cases.json',
    'docs/checkpoints/array-transform-callable-dart-2026-11-12/own-questions.json',
    'docs/checkpoints/array-transform-callable-dart-2026-11-12/run_stage.py']
templates = {}
for index, name in enumerate(paths):
    path = ROOT / name
    body = path.read_bytes()
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
assert all(row['source'] and row['rule'] == 'Value' for row in cases)
for name, value in (('cases.json', cases), ('own-questions.json', own)):
    (BASE / name).write_text(json.dumps(value, indent=2) + '\n')

def adapt(text):
    return (text.replace('array-pipeline-callable-julia-2026-11-11', 'array-transform-callable-julia-2026-11-12')
        .replace('580fe233a7d0299d177ecbd442ad8ba027bbe6da', ACTIVATION)
        .replace('pipeline', 'transform').replace('PIPELINE', 'TRANSFORM').replace('Pipeline', 'Transform'))

helper = ROOT / 'julia/test/callable_array_transform_observation.jl'
assert not helper.exists()
helper.write_text(adapt((ROOT / 'julia/test/callable_array_pipeline_observation.jl').read_text()))
(BASE / 'observer.jl').write_text(adapt((ROOT / (old_base + 'observer.jl')).read_text()))
capture = adapt((ROOT / (old_base + 'capture_intake.py')).read_text())
capture = capture.replace("    run('version', ['--version'])", '''    # Check the shared host before any Julia compilation/precompilation. Keep
    # both complete channels and the actual command, not only its percentage.
    memory_command = ['bash', 'tools/project_data_run.sh', 'memory_pressure']
    (OUT / 'memory-command.json').write_text(json.dumps(dict(argv=memory_command, cwd='.', environment={}), indent=2) + '\\n')
    memory = subprocess.run(memory_command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (OUT / ('memory-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(memory, channel), mtime=0))
    (OUT / 'memory-exit.txt').write_text(str(memory.returncode) + '\\n')
    assert memory.returncode == 0
    import re
    match = re.search(rb'System-wide memory free percentage: (\\d+)%', memory.stdout)
    assert match and int(match[1]) >= 30, 'Defer Julia job: conservative4GiB peak plus headroom unavailable'
    run('version', ['--version'])''', 1)
(BASE / 'capture_intake.py').write_text(capture)
print('Prepared Julia shared45/own267 source-only questions and complete-error observer; no peer roles/outcomes or production changes')
