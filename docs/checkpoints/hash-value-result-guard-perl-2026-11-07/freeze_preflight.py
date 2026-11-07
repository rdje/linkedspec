"""Freeze independently checked clean-host policies and host-isolation targets."""
import gzip
import json
from pathlib import Path
import runpy

BASE = Path(__file__).resolve().parent
reader = runpy.run_path(str(BASE / 'review_preflight.py'))
cases = json.loads((BASE / 'cases.json').read_bytes())
rows = reader['frames'](gzip.decompress((BASE / 'before/stdout.log.gz').read_bytes()), 'HASH_VALUE_GUARD_PERL')
seeds = json.loads((BASE / 'seed-cases.json').read_bytes())
seed_rows = reader['frames'](gzip.decompress((BASE / 'seed_before/stdout.log.gz').read_bytes()), 'HASH_VALUE_SEED_PERL')
reader['validate_profiles'](rows, cases)
reader['validate_seed'](seed_rows, seeds)
profiles = [dict(case=c, expected_observation=reader['projection'](rows[c['id']])) for c in cases if c.get('policy_profile')]
targets = [dict(c, expected={'b': 2} if any(h in c['id'] for h in ('merge_hash', 'set_key')) else {}) for c in seeds]
for name, data in (('hash_value_result_guard_perl_profiles.json', profiles), ('hash_helper_source_isolation_perl_cases.json', targets)):
    target = Path('tests/fixtures') / name
    assert not target.exists(), 'one-shot preflight freeze'
    target.write_text(json.dumps(data, indent=2) + '\n')
print('48 clean-host own policies and10 scalar host-isolation targets frozen; no SDK edit')
