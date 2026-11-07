"""Freeze only the unchanged eligible projection after actual intake validation."""
import gzip
import json
from pathlib import Path
import runpy

BASE = Path(__file__).resolve().parent
reader = runpy.run_path(str(BASE / 'review.py'))
cases = json.loads((BASE / 'cases.json').read_bytes())
raw = gzip.decompress((BASE / 'intake/stdout.log.gz').read_bytes())
rows = reader['frames'](raw, 'HASH_VALUE_PERL')
reader['validate'](rows, cases)
targets = [case for case in cases if not case.get('profile_only')]
reader['validate_projection'](targets, cases)
profiles = [dict(case=c, observation=rows[c['id']]) for c in cases if c.get('profile_only')]
for path, data in ((Path('tests/fixtures/hash_value_result_guard_cases.json'), targets),
                   (BASE / 'zero-key-profiles.json', profiles)):
    assert not path.exists(), 'one-shot target freeze'
    path.write_text(json.dumps(data, indent=2) + '\n')
print('Original28 eligible sources unchanged; separate4 unready Perl zero-key profiles frozen')
