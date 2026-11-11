"""Prepare source-only Dart questions and prospective four-route instruments."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
ACTIVATION = '5ac1fac5eb7126cd8f952858f8df194914884830'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'cases.json').exists()
prior = Path('docs/checkpoints/array-pipeline-callable-dart-2026-11-11')
sources = [
    Path('docs/checkpoints/array-transform-callable-rust-2026-11-11/run_stage.py'),
    Path('dart/tool/probe_callable_array_pipeline_results.dart'),
    Path('dart/tool/callable_array_pipeline_observation.dart'),
    Path('dart/test/array_pipeline_callable_result_guard_composition_test.dart'),
    Path('dart/tool/trace_callable_array_pipeline_results.dart'),
]
sources += [prior / name for name in ('capture_intake.py', 'capture.py', 'private_control.py',
    'capture_trace.py', 'repair.py', 'run_repair.py', 'review.py', 'seal.py',
    'check_current.py', 'capture_current.py', 'inspect_intake.py')]
sources += [Path('tests/fixtures/array_transform_callable_result_guard_cases.json'),
    Path('docs/checkpoints/array-transform-callable-result-perl-2026-11-11/cases.json')]
images = {}
for index, path in enumerate(sources):
    raw = (ROOT / path).read_bytes()
    assert raw == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(path)])
    artifact = BASE / ('template-' + str(index) + '.gz')
    artifact.write_bytes(gzip.compress(raw, mtime=0))
    assert gzip.decompress(artifact.read_bytes()) == raw
    images[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), artifact=str(artifact.relative_to(ROOT)))
(BASE / 'template-identities.json').write_text(json.dumps(images, indent=2, sort_keys=True) + '\n')
shared = json.loads((ROOT / sources[-2]).read_bytes())
previous = json.loads((ROOT / sources[-1]).read_bytes())
assert len(shared) == 45 and len(previous) == 312 and previous[:45] == shared
own = []
for original in previous[45:]:
    row = {key: original[key] for key in ('id', 'body', 'source', 'input', 'rule', 'question', 'paired_with', 'form') if key in original}
    row['profile_only'] = True
    row.setdefault('question', 'source-order-or-terminal-question')
    assert not {'expected', 'expected_error', 'expected_observation', 'role'} & row.keys()
    own.append(row)
cases = shared + own
assert len(cases) == len({row['id'] for row in cases}) == 312
(BASE / 'cases.json').write_text(json.dumps(cases, indent=2) + '\n')
(BASE / 'own-questions.json').write_text(json.dumps(own, indent=2) + '\n')

def adapt(index):
    text = gzip.decompress((BASE / ('template-' + str(index) + '.gz')).read_bytes()).decode()
    for old, new in (
        ('9ed018787cac456a0e0bf95942bcdb735f5e4e6c', ACTIVATION),
        ('array-pipeline-callable-dart-2026-11-11', BASE.name),
        ('probe_callable_array_pipeline_results', 'probe_callable_array_transform_results'),
        ('callable_array_pipeline_observation', 'callable_array_transform_observation'),
        ('array_pipeline_callable', 'array_transform_callable'),
        ('array-pipeline-callable', 'array-transform-callable'),
        ('CALLABLE_PIPELINE', 'CALLABLE_TRANSFORM'),
        ('CallablePipeline', 'CallableTransform')):
        text = text.replace(old, new)
    return text

probe = Path('dart/tool/probe_callable_array_transform_results.dart')
observation = Path('dart/tool/callable_array_transform_observation.dart')
assert not probe.exists() and not observation.exists()
probe.write_text(adapt(1))
observation.write_text(adapt(2))
capture = adapt(5)
start = capture.index("    paths += [PROBE, BASE / 'prepare.py'")
end = capture.index("    paths += [Path('specs')", start)
capture = capture[:start] + "    paths += [PROBE, Path('dart/tool/callable_array_transform_observation.dart'), BASE / 'prepare.py', BASE / 'capture_intake.py', BASE / 'run_stage.py', BASE / 'cases.json', BASE / 'own-questions.json', BASE / 'template-identities.json']\n" + capture[end:]
capture = capture.replace("== 194\n", "== 312\n").replace('Original194', 'Original312')
(BASE / 'capture_intake.py').write_text(capture)
print(json.dumps(dict(prepared='PASS', shared=45, source_only_own=267, total=312,
    scope='Authored source questions only. Dart policies/verdicts remain unacquired; full available error maps and parsed-before-compile/restore conventions are retained.')))
