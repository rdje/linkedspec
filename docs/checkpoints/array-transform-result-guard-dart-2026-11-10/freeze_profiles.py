"""Publish acquired Dart profiles and a normal using unchanged authored targets."""
import gzip
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
profile = ROOT / 'tests/fixtures/array_transform_result_guard_dart_profiles.json'
normal = ROOT / 'dart/test/array_transform_result_guard_composition_test.dart'
assert not profile.exists() and not normal.exists()
profiles = json.loads((BASE / 'intake-profiles.json').read_bytes())
assert len(profiles) == 108 and sum(row['profile_only'] for row in profiles.values()) == 104
profile.write_bytes((BASE / 'intake-profiles.json').read_bytes())
source = (ROOT / 'dart/test/hash_value_result_guard_composition_test.dart').read_text()
source = source.replace('TYPE-REFERENCE-BOOK.1.2.23.3.77.3', 'TYPE-REFERENCE-BOOK.1.2.23.3.78.3')
source = source.replace('pure Hash-helper', 'ordinary Array-transform')
source = source.replace('HASH_VALUE_DART', 'ARRAY_TRANSFORM_DART')
source = source.replace('hash_value_result_guard', 'array_transform_result_guard')
source = source.replace('hash-value-result-guard-dart-2026-11-07', 'array-transform-result-guard-dart-2026-11-10')
source = source.replace('hash-value-result-guard', 'array-transform-result-guard')
normal.write_text(source)
(BASE / 'normal-before-format.dart.gz').write_bytes(gzip.compress(normal.read_bytes(), mtime=0))
print('Acquired108 full profiles frozen; authored141 ordinary tests, unchanged shared targets')
