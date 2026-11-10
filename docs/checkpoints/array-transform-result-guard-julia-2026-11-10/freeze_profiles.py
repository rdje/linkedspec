"""Freeze acquired Julia policies and author the unchanged-target ordinary normal."""
from pathlib import Path
import json

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
profile = ROOT / 'tests/fixtures/array_transform_result_guard_julia_profiles.json'
normal = ROOT / 'julia/test/array_transform_result_guard_composition_test.jl'
assert not profile.exists() and not normal.exists()
rows = json.loads((BASE / 'intake-profiles.json').read_bytes())
assert len(rows) == 123 and sum(row['profile_only'] for row in rows.values()) == 119
profile.write_bytes((BASE / 'intake-profiles.json').read_bytes())
source = (ROOT / 'julia/test/hash_value_result_guard_composition_test.jl').read_text()
source = source.replace('JuliaHashValueComposition', 'JuliaArrayTransformComposition')
source = source.replace('pure Hash-helper', 'ordinary Array-transform')
source = source.replace('HASH_VALUE_JULIA', 'ARRAY_TRANSFORM_JULIA')
source = source.replace('LINKEDSPEC_HASH_VALUE_CAPTURE', 'LINKEDSPEC_ARRAY_TRANSFORM_CAPTURE')
source = source.replace('HashValueGenerated', 'ArrayTransformGenerated')
source = source.replace('hash-value-result-guard', 'array-transform-result-guard')
source = source.replace('hash_value_result_guard', 'array_transform_result_guard')
normal.write_text(source)
print('Acquired123 full own/error profiles frozen; authored156 unchanged-target ordinary cases')
