"""Check original normal RED identities, cold records and trace contrasts."""
import gzip
import hashlib
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]

def frames(phase, channel, tag):
    raw = gzip.decompress((BASE / phase / (channel + '.log.gz')).read_bytes()).decode()
    result = {}
    for key, value in re.findall(r'^' + re.escape(tag) + r' (\w+) (\{.*\})$', raw, re.M):
        assert key not in result
        result[key] = json.loads(value)
    return result

def same(left, right):
    assert json.dumps(left, sort_keys=True, separators=(',', ':')) == json.dumps(right, sort_keys=True, separators=(',', ':'))

assert (BASE / 'launches/before/exit.txt').read_text() == '0\n'
assert (BASE / 'before/normal-exit.txt').read_text() == '101\n'
baseline = json.loads((BASE / 'baseline.json').read_bytes())
stdout = gzip.decompress((BASE / 'before/normal-stdout.log.gz').read_bytes())
failed = {key.decode() for key in re.findall(rb'^test (\w+) \.\.\. FAILED$', stdout, re.M)}
assert failed == set(baseline['supported_targets']) and len(failed) == 20
assert b'292 passed; 20 failed' in stdout
native = frames('intake', 'native-stdout', 'CALLABLE_TRANSFORM_RUST')
normal = frames('before', 'normal-stderr', 'CALLABLE_TRANSFORM_RUST_NORMAL')
assert len(native) == len(normal) == 312
same(native, normal)
for directory, tag, field, origin in (
    ('normal-inputs', 'CALLABLE_TRANSFORM_RUST_NORMAL_INPUT', 'compiled', 'inputs'),
    ('normal-parsed', 'CALLABLE_TRANSFORM_RUST_NORMAL_PARSED_INPUT', 'parsed', 'parsed-inputs')):
    inputs = frames('before', 'normal-stderr', tag)
    assert inputs.keys() == normal.keys()
    for key, row in inputs.items():
        body = row[field].encode()
        assert (BASE / 'before' / directory / (key + '.json')).read_bytes() == body
        assert (BASE / 'intake/fresh' / origin / (key + '.json')).read_bytes() == body
traced = frames('trace', 'trace-stdout', 'CALLABLE_TRANSFORM_TRACE')
assert len(traced) == 7
for key, value in traced.items():
    same(value, native[key]['native'])
    trace = (BASE / 'trace' / (key + '.trace.log')).read_bytes()
    assert b'rust_runtime:engine:lifecycle_block' in trace
assert (ROOT / 'rust/linkedspec-runtime/src/engine.rs').read_bytes() == gzip.decompress((BASE / 'owner-before.rs.gz').read_bytes())
report = dict(original_normal='PASS', actual_normal_exit=101, programs=312, exact_supported_red=sorted(failed),
    preservation_pass=292, cold_three_route_records_exact=312, parsed_and_serialized_input_pairs_exact=312,
    public_trace_contrasts=7, production_unchanged=True,
    limits='Finite original RED preflight; trace exposes lifecycle/output, not finer expression guard events.')
target = BASE / 'before-check.json'
assert not target.exists()
target.write_text(json.dumps(report, indent=2) + '\n')
print(json.dumps(report, indent=2))
