"""Retain exact own pre-production observations; no ambient leak is accepted policy."""
import gzip
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
FIELDS = ('metadata native_callable loaded substitution_error descriptor_error emission_error build_error load_error native fresh native_error fresh_error native_cursor fresh_cursor warnings').split()


def normalize(value):
    if isinstance(value, list):
        return [normalize(v) for v in value]
    if isinstance(value, dict):
        return {k: normalize(v) for k, v in value.items()}
    return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value) if isinstance(value, str) else value


profiles = []
for phase, fixture in (('preflight', 'cases.json'), ('supplement', 'supplement_cases.json')):
    rows = {}
    for line in gzip.decompress((BASE / phase / 'stdout.log.gz').read_bytes()).decode().splitlines():
        if line.startswith('ARRAY_TRANSFORM_PERL '):
            _, identifier, raw = line.split(' ', 2)
            assert identifier not in rows
            rows[identifier] = json.loads(raw)
    for case in json.loads((BASE / fixture).read_text()):
        if case.get('profile_only'):
            observation = rows[case['id']]
            profiles.append(dict(case=case, expected_observation=normalize({k: observation[k] for k in FIELDS if k in observation})))
target = Path('tests/fixtures/array_transform_result_guard_perl_profiles.json')
assert not target.exists()
target.write_text(json.dumps(profiles, indent=2, sort_keys=True) + '\n')
print('Own original source/arity/error profiles frozen:', len(profiles))
