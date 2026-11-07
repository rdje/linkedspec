"""Require finite four-route GREEN and unchanged healthy policies before controls."""
import gzip
import importlib.util
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('finite_array_recovery', BASE / 'review.py')
reader = importlib.util.module_from_spec(spec)
spec.loader.exec_module(reader)
cases = json.loads((BASE / 'repaired-after/cases.json').read_bytes())
profiles = json.loads(Path('tests/fixtures/array_transform_result_guard_rust_profiles.json').read_bytes())
native = reader.frames(reader.raw('repaired-after/native-stdout.log.gz'), 'ARRAY_TRANSFORM_RUST')
fresh = reader.frames(reader.raw('repaired-after/fresh-stdout.log.gz'), 'ARRAY_TRANSFORM_RUST_FRESH')
reader.validate(native, fresh, cases, profiles, set())
old_native = reader.frames(reader.raw('intake/native-stdout.log.gz'), 'ARRAY_TRANSFORM_RUST')
old_fresh = reader.frames(reader.raw('intake/fresh-stdout.log.gz'), 'ARRAY_TRANSFORM_RUST_FRESH')
red = set(json.loads((BASE / 'baseline.json').read_bytes())['red'])
assert len(red) == 21
for key in native.keys() - red:
    assert reader.same(native[key], old_native[key])
    assert reader.same(fresh[key], old_fresh[key])
assert len(native) == 195 and len(profiles) == 152
print('actual195/four routes GREEN; all174 healthy/152 policy profiles exact; no target changes')
