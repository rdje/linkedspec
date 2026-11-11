"""Freeze own Dart result targets, separate continuations and complete wire fences."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
PROFILE = Path('tests/fixtures/array_transform_callable_result_guard_dart_profiles.json')
NORMAL = Path('dart/test/array_transform_callable_result_guard_composition_test.dart')
assert not PROFILE.exists() and not NORMAL.exists() and not (BASE / 'baseline.json').exists()
assessment = json.loads((BASE / 'intake-assessment.json').read_bytes())
cases = json.loads((BASE / 'cases.json').read_bytes())
observed = assessment['observed']
ROUTES = ('native', 'restored', 'plan', 'fresh')

def encoded(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))

targets = {}
shared = {row['id']: row for row in cases[:45]}
assert len(assessment['shared_differences']) == 12
for key in assessment['shared_differences']:
    assert 'expected' in shared[key]
    targets[key] = {route: {'value': shared[key]['expected']} for route in ROUTES}
for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice'):
    key = 'own_optional_' + helper + '_receiver_composed'
    contrast = observed['own_optional_' + helper + '_free_composed']
    assert all(row == {'value': [None, 'S']} for row in contrast.values())
    assert encoded(observed['own_optional_' + helper + '_receiver']) == encoded(observed['own_optional_' + helper + '_free'])
    targets[key] = contrast
for key in ('own_signature_variadic_empty', 'own_signature_variadic_multi'):
    targets[key + '_composed'] = {}
    for route in ROUTES:
        array, effects = observed[key + '_terminal'][route]['value']
        assert isinstance(array, list) and effects in ('', 'S')
        targets[key + '_composed'][route] = {'value': [None, effects]}
targets['own_source_before_rejection'] = {route: {'value': [None, 'S']} for route in ROUTES}
for helper in ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted', 'reversed', 'concat_arrays'):
    key = 'positive_' + helper + '_receiver_composed'
    targets[key] = {}
    for route in ROUTES:
        array, effects = observed['positive_' + helper + '_receiver_terminal'][route]['value']
        assert isinstance(array, list) and effects in ('S', 'SN', 'SNC', 'ST')
        targets[key][route] = {'value': [None, effects]}
assert len(targets) == 28 and all(encoded(observed[key]) != encoded(row) for key, row in targets.items())

compatibility = {}
for kind in ('number', 'null', 'hash'):
    terminal = observed['initial_' + kind + '_terminal']
    immediate = observed['own_initial_' + kind + '_take_receiver_with']
    key = 'initial_' + kind + '_composed'
    assert shared[key]['profile_only'] is True
    assert all(row == {'value': [[], []]} for row in terminal.values())
    assert all(row == {'value': [0, 'W']} for row in immediate.values())
    assert all(row == {'value': ['ran', 'KVW']} for row in observed[key].values())
    # Existing actual-Array ownership governs the later Hash consumer. The
    # acquired initial producer/first-with policies remain preservation fences.
    compatibility[key] = {route: {'value': [None, '']} for route in ROUTES}
assert len(compatibility) == 3 and not targets.keys() & compatibility.keys()
assert all(row == {'value': [None, '']} for row in observed['own_scalar_bool_receiver_with'].values())
assert all(row == {'value': [0, 'W']} for row in observed['own_scalar_bool_free_with'].values())
profiles = {}
for case in cases:
    key = case['id']
    role = 'supported-target' if key in targets else 'initial-source-compatibility' if key in compatibility else 'preservation'
    profiles[key] = dict(case=case, role=role, **targets.get(key, compatibility.get(key, observed[key])))
assert len(profiles) == 312 and sum(row['role'] == 'preservation' for row in profiles.values()) == 281
PROFILE.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
(BASE / 'baseline.json').write_text(json.dumps(dict(programs=312, supported_targets=sorted(targets),
    initial_source_compatibility=sorted(compatibility), preserved=281,
    initial_policy_fences=104, shared_healthy=26, shared_profiles=7,
    limits='Dart-only cold/terminal contrasts precede production. Three initial-source continuations are separate compatibility, never portable input/product-RED credit. Boolean receiver-null/free-empty and all first-producer/error policies remain exact.'), indent=2, sort_keys=True) + '\n')

source = gzip.decompress((BASE / 'template-3.gz').read_bytes()).decode()
for old, new in (
    ('TYPE-REFERENCE-BOOK.1.2.23.3.79.6.3', 'TYPE-REFERENCE-BOOK.1.2.23.3.78.6.3'),
    ('registered pipeline', 'registered transform'),
    ('array-pipeline-callable-dart-2026-11-11', BASE.name),
    ('array_pipeline_callable_result_guard_dart_profiles', 'array_transform_callable_result_guard_dart_profiles'),
    ('callable_array_pipeline_observation', 'callable_array_transform_observation'),
    ('callable-pipeline-dart-normal', 'callable-transform-dart-normal'),
    ('array-pipeline-callable', 'array-transform-callable'),
    ('CALLABLE_PIPELINE', 'CALLABLE_TRANSFORM'),
    ('CallablePipeline', 'CallableTransform')):
    source = source.replace(old, new)
NORMAL.write_text(source)
owner = Path('dart/lib/src/runtime/interpreter.dart')
old = subprocess.check_output(['git', 'show', 'HEAD:' + str(owner)])
assert owner.read_bytes() == old
(BASE / 'owner-before.dart.gz').write_bytes(gzip.compress(old, mtime=0))
formatter = (BASE / 'format_tools.py').read_text()
formatter = formatter.replace("BASE / 'tool-format'", "BASE / 'normal-format'", 1)
start = formatter.index('targets = [')
end = formatter.index('\npaths = ', start)
formatter = formatter[:start] + "targets = [Path('dart/test/array_transform_callable_result_guard_composition_test.dart')]" + formatter[end:]
anchor = 'paths += targets\n'
assert formatter.count(anchor) == 1
formatter = formatter.replace(anchor, anchor + "paths += [Path('tests/fixtures/array_transform_callable_result_guard_dart_profiles.json'), Path('dart/tool/callable_array_transform_observation.dart'), Path('dart/tool/probe_callable_array_transform_results.dart')]\n")
(BASE / 'format_normal.py').write_text(formatter)
print('Frozen312 complete Dart profiles:28 supported targets/three separate initial continuations/281 preserved; production unchanged')
