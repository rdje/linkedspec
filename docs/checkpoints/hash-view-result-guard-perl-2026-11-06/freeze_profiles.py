"""Freeze own observed Perl source/arity/error profiles before production edits."""
import gzip
import hashlib
import json
from pathlib import Path
import re

BASE = Path('docs/checkpoints/hash-view-result-guard-perl-2026-11-06')
destination = BASE / 'frozen-profiles.json'
assert not destination.exists(), 'one-shot independent profile freeze'
raw = gzip.decompress((BASE / 'profile-before/stdout.log.gz').read_bytes())
rows = {}
for line in raw.decode().splitlines():
    match = re.match(r'^HASH_VIEW_PERL ([a-z0-9_]+) (.*)$', line)
    if match:
        assert match[1] not in rows
        rows[match[1]] = json.loads(match[2])
assert list(rows) == [case['id'] for case in json.loads((BASE / 'profiles.json').read_bytes())]
assert rows['values_scalar_null_profile']['native'] == [[], [], [], 0]
assert rows['keys_null_profile']['native'] == [[], 0]
for name, helper in (('arity_profile', 'sorted_keys'), ('free_values_arity_profile', 'sorted_values')):
    row = rows[name]
    assert row['native'] == row['fresh'] == ['ran', 'W']
    assert row['metadata']['language_agnostic_action_ir_ready'] == 0
    assert row['metadata']['unresolved_helpers'] == [helper]
row = rows['values_array_error_profile']
assert row['native_error']['stage'] == 'rule_handler_eval'
assert row['fresh_error']['stage'] == 'execute_generated'
assert 'Not a HASH reference' in row['native_error']['detail']
destination.write_text(json.dumps(dict(observations=rows,
    raw_stdout_sha256=hashlib.sha256(raw).hexdigest(),
    scope='Own Perl profile, excluded malformed/source-domain behavior; no portable admission'), indent=2, sort_keys=True) + '\n')
print('Five own raw Perl profiles frozen before any production edit')
