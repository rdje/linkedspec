"""Prepare source-bound Dart normal/private/direct epochs for frozen312."""
import gzip
from pathlib import Path

BASE = Path(__file__).resolve().parent
assert not (BASE / 'capture.py').exists()

def adapt(index):
    text = gzip.decompress((BASE / ('template-' + str(index) + '.gz')).read_bytes()).decode()
    for old, new in (
        ('9ed018787cac456a0e0bf95942bcdb735f5e4e6c', '5ac1fac5eb7126cd8f952858f8df194914884830'),
        ('array-pipeline-callable-dart-2026-11-11', BASE.name),
        ('probe_callable_array_pipeline_results', 'probe_callable_array_transform_results'),
        ('array_pipeline_callable_result_guard_composition', 'array_transform_callable_result_guard_composition'),
        ('array_pipeline_callable_result_guard_dart_profiles', 'array_transform_callable_result_guard_dart_profiles'),
        ('callable_array_pipeline_observation', 'callable_array_transform_observation'),
        ('callable-pipeline-dart-normal', 'callable-transform-dart-normal'),
        ('array_pipeline_callable', 'array_transform_callable'),
        ('array-pipeline-callable', 'array-transform-callable'),
        ('CALLABLE_PIPELINE', 'CALLABLE_TRANSFORM'),
        ('CallablePipeline', 'CallableTransform')):
        text = text.replace(old, new)
    return text

capture = adapt(6)
capture = capture.replace("BASE / 'profile-sources.json'", "BASE / 'own-questions.json'")
start = capture.index('    paths += [BASE / name for name in (')
end = capture.index("    paths += [Path('specs')", start)
names = ('prepare.py', 'prepare_epochs.py', 'freeze_policy.py', 'capture_intake.py',
    'capture.py', 'private_control.py', 'cases.json', 'own-questions.json',
    'template-identities.json', 'baseline.json', 'owner-before.dart.gz', 'repair.py')
capture = capture[:start] + '    paths += [BASE / name for name in ' + repr(names) + ']\n' + capture[end:]
start = capture.index("    paths += [Path('docs/checkpoints/")
end = capture.index('    if CONFIG.exists():', start)
external = ('docs/checkpoints/array-transform-result-guard-dart-2026-11-10/cases.json',
    'docs/checkpoints/array-pipeline-callable-dart-2026-11-11/cases.json')
capture = capture[:start] + '    paths += [Path(name) for name in ' + repr(external) + ']\n' + capture[end:]
capture = capture.replace("tests += ['test/array_pipeline_result_guard_composition_test.dart', 'test/key_count_callable_result_guard_composition_test.dart']", "tests += ['test/array_transform_result_guard_composition_test.dart', 'test/array_pipeline_callable_result_guard_composition_test.dart']")
capture = capture.replace('== 194\n', '== 312\n')
capture = capture.replace("b'+175 -19: Some tests failed.'", "b'+281 -31: Some tests failed.'")
capture = capture.replace("b'+383: All tests passed!'", "b'+647: All tests passed!'")
(BASE / 'capture.py').write_text(capture)

private = adapt(7)
private = private.replace("assert observed == expected and len(observed) == 194, 'actual private normal observations'", "assert json.dumps(observed, sort_keys=True, separators=(',', ':')) == json.dumps(expected, sort_keys=True, separators=(',', ':')) and len(observed) == 312, 'actual private normal observations'")
private = private.replace("b'+175 -19: Some tests failed.'", "b'+281 -31: Some tests failed.'")
private = private.replace("b'+194: All tests passed!'", "b'+312: All tests passed!'")
private = private.replace('== 194\n', '== 312\n').replace('actual194 semantic', 'actual312 semantic')
anchor = "    declared += [Path('tools')"
start = private.index(anchor)
private = private[:start] + "    declared += [BASE / name for name in ('prepare.py', 'prepare_epochs.py', 'freeze_policy.py', 'baseline.json', 'own-questions.json')]\n" + private[start:]
(BASE / 'private_control.py').write_text(private)

repair = adapt(9).replace('_isOrdinaryArrayPipelineResultChain', '_isOrdinaryArrayTransformResultChain')
repair = repair.replace('pipeline', 'transform')
(BASE / 'repair.py').write_text(repair)
(BASE / 'run_repair.py').write_text(adapt(10))
(BASE / 'seal.py').write_text(adapt(12))
(BASE / 'check_current.py').write_text(adapt(13))
(BASE / 'capture_current.py').write_text(adapt(14))
assert 'profile-sources.json' not in capture and 'signature-sources.json' not in capture
print('Prepared frozen312/31RED/private-current/direct647 source-bound epochs; no production writer or SDK invoked')
