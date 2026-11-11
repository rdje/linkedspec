"""Freeze independent Dart wire records and bounded callable pipeline targets."""
import gzip
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
PROFILE = Path('tests/fixtures/array_pipeline_callable_result_guard_dart_profiles.json')
assert not PROFILE.exists()
assessment = json.loads((BASE / 'intake-assessment.json').read_bytes())
cases = json.loads((BASE / 'cases.json').read_bytes())
targets = set(assessment['shared_differences']) | {
    'own_signature_variadic_empty_composed', 'own_signature_variadic_multi_composed',
    'invalid_range_receiver_composed'}
compatibility = {'own_pattern_' + kind + '_composed' for kind in ('string', 'variable', 'block')}
assert len(targets) == 16 and len(compatibility) == 3


def frames(name, tag):
    result = {}
    for line in gzip.open(BASE / 'intake' / name, 'rt'):
        if line.startswith(tag + ' '):
            _, key, body = line.split(' ', 2)
            assert key not in result
            result[key] = json.loads(body)
    return result


native = frames('native-stdout.log.gz', 'CALLABLE_PIPELINE_DART')
fresh = frames('fresh-stdout.log.gz', 'CALLABLE_PIPELINE_DART_FRESH')
assert len(native) == len(fresh) == len(cases) == 194
profiles = {}
for case in cases:
    key = case['id']; role = 'preservation'
    observed = dict(native[key], fresh=fresh[key])
    assert set(observed) == {'native', 'restored', 'plan', 'fresh'}
    if key in targets | compatibility:
        role = 'supported-target' if key in targets else 'pattern-compatibility'
        effects = ('S' if key == 'own_signature_variadic_multi_composed' else
            'P' if key == 'own_pattern_block_composed' else '')
        expected = {'value': None if key == 'invalid_range_receiver_composed' else [None, effects]}
        observed = {route: expected for route in ('native', 'restored', 'plan', 'fresh')}
    profiles[key] = dict(case=case, role=role, **observed)
PROFILE.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
(BASE / 'baseline.json').write_text(json.dumps(dict(programs=194, supported_targets=sorted(targets),
    compatibility=sorted(compatibility), preserved=175,
    limits='Three noncanonical pattern compatibility changes confer no new pattern admission; terminal Rust/Perl observations are not Dart verdicts.'), indent=2) + '\n')
owner = Path('dart/lib/src/runtime/interpreter.dart')
source = subprocess.check_output(['git', 'show', 'HEAD:' + str(owner)])
assert owner.read_bytes() == source
(BASE / 'owner-before.dart.gz').write_bytes(gzip.compress(source, mtime=0))
print('Frozen194 full-wire profiles:16 supported targets/three separate compatibility/175 preserved; production unchanged')
