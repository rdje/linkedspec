"""Freeze own observed Dart policy before the demonstrated concat guard repair."""
import gzip
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
PROFILE = ROOT / 'tests/fixtures/array_concat_open_arity_result_guard_dart_profiles.json'
CASES = ROOT / 'tests/fixtures/array_concat_open_arity_dart_cases.json'
NORMAL = ROOT / 'dart/test/array_concat_open_arity_result_guard_composition_test.dart'
assert not any(p.exists() for p in (PROFILE, CASES, NORMAL, BASE / 'baseline.json'))
assessment = json.loads((BASE / 'intake-assessment.json').read_bytes())
cases = json.loads((BASE / 'cases.json').read_bytes())
targets, compatibility, observed = (assessment[k] for k in ('targets', 'compatibility', 'observed'))
assert len(cases) == 508 and len(targets) == 20 and len(compatibility) == 4
assert not targets.keys() & compatibility.keys()
profiles = {}
for case in cases:
    key = case['id']
    role = 'supported-target' if key in targets else 'legacy-operand-compatibility' if key in compatibility else 'preservation'
    profiles[key] = dict(case=case, role=role, **targets.get(key, compatibility.get(key, observed[key])))
assert sum(row['role'] == 'preservation' for row in profiles.values()) == 484
for key in targets.keys() | compatibility.keys():
    assert json.dumps(observed[key], sort_keys=True) != json.dumps({r: profiles[key][r] for r in observed[key]}, sort_keys=True)
PROFILE.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
CASES.write_bytes((BASE / 'cases.json').read_bytes())
(BASE / 'baseline.json').write_text(json.dumps(dict(programs=508, supported_targets=sorted(targets),
    legacy_operand_compatibility=sorted(compatibility), preserved=484, initial_policy_fences=80,
    invalid_signature_fences=8, limits='Own Dart terminal/continuation contrasts; scalar operands remain legacy compatibility, not supported Array-input authority. Complete own error fields and source identities are retained.'), indent=2, sort_keys=True) + '\n')

template = ROOT / 'dart/test/array_transform_callable_result_guard_composition_test.dart'
template_body = template.read_bytes()
assert template_body == subprocess.check_output(['git', 'show', 'HEAD:' + str(template.relative_to(ROOT))], cwd=ROOT)
(BASE / 'normal-template.dart.gz').write_bytes(gzip.compress(template_body, mtime=0))
source = gzip.decompress((BASE / 'normal-template.dart.gz').read_bytes()).decode()
for old, new in (
    ('1.2.23.3.78.6.3', '1.2.23.3.80.3'),
    ('registered transform result guards', 'existing concat arity result guards'),
    ('LINKEDSPEC_CALLABLE_TRANSFORM_DART_CAPTURE', 'LINKEDSPEC_ARRAY_CONCAT_DART_CAPTURE'),
    ('callable-transform-dart-normal', 'open-arity-concat-dart-normal'),
    ('CALLABLE_TRANSFORM_DART_NORMAL', 'ARRAY_CONCAT_DART_NORMAL'),
    ('docs/checkpoints/array-transform-callable-dart-2026-11-12/cases.json', 'tests/fixtures/array_concat_open_arity_dart_cases.json'),
    ('array_transform_callable_result_guard_dart_profiles', 'array_concat_open_arity_result_guard_dart_profiles'),
):
    assert old in source
    source = source.replace(old, new)
source = source.replace('  String grammar,\n) {', '  String grammar,\n  String origin,\n) {', 1)
anchor = '  return {\n'
assert source.count(anchor) == 1
source = source.replace(anchor, "  final identityPrefix = switch (origin) {\n    'legacy312' => 'array-transform-callable-result-guard',\n    'ordinary4' => 'array-transform-result-guard',\n    _ => 'array-concat-open-arity-result-guard',\n  };\n" + anchor)
source = source.replace("'array-transform-callable-result-guard-assessment.spec'", "'$identityPrefix-assessment.spec'")
source = source.replace('        grammar,\n', "        grammar,\n        row['origin'] as String,\n", 1)
NORMAL.write_text(source)
owner = ROOT / 'dart/lib/src/runtime/interpreter.dart'
old = subprocess.check_output(['git', 'show', 'HEAD:dart/lib/src/runtime/interpreter.dart'], cwd=ROOT)
assert owner.read_bytes() == old
(BASE / 'owner-before.dart.gz').write_bytes(gzip.compress(old, mtime=0))
print('Frozen508 own profiles:20 supported/four compatibility/484 preserved; interpreter unchanged')
