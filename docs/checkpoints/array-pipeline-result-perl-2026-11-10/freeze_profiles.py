"""Freeze acquired observations with explicit defect/exclusion roles, not blessings."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent


def observations(phase):
    result = {}
    for line in gzip.decompress((BASE / phase / 'stdout.log.gz').read_bytes()).decode().splitlines():
        if line.startswith('ARRAY_PIPELINE_PERL '):
            _, key, value = line.split(' ', 2)
            assert key not in result
            result[key] = json.loads(value)
    return result


cases = json.loads((BASE / 'cases.json').read_bytes())
rows = observations('preflight')
supplement = json.loads((BASE / 'delimiter-cases.json').read_bytes())
later = observations('delimiter_controls')
assert list(rows) == [case['id'] for case in cases]
assert list(later) == [case['id'] for case in supplement]
profiles = {}
for case in cases[36:] + supplement:
    actual = (rows if case['id'] in rows else later)[case['id']]
    key = case['id']
    role = ('source-defect' if case.get('host_literal') and case['seed'] == 'main' else
            'composition-error-defect' if key == 'needed_split_delimiter_receiver' else
            'syntax-exclusion' if key.startswith('invalid_pattern_') else
            'arity-exclusion' if key.startswith('extra_') else
            'regex-compile-policy' if key.startswith('invalid_range_') else 'preservation')
    excluded = {'substitution', 'module_input', 'handler_input'}
    profiles[key] = dict(source=case['source'], input=case['input'], seed=case.get('seed', 'empty'),
        role=role, observation={name: value for name, value in actual.items() if name not in excluded})
assert len(profiles) == 148
target = BASE / 'acquired-profiles.json'; assert not target.exists()
target.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
result = dict(programs=184, original_common=36, own_questions=98, additional_host_cases=42,
    supplement=8, full_profiles=148, source_defects=sum(row['role'] == 'source-defect' for row in profiles.values()),
    extra_error_target=sum(row['role'] == 'composition-error-defect' for row in profiles.values()),
    producer_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    limit='Historical observations and explicit roles; source-defect/required-error-defect outputs are not accepted producer policies.')
(BASE / 'profile-freeze-result.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result))
