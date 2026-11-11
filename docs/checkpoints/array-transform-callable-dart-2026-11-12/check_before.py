"""Verify exact original Dart RED identities, full wires and parsed snapshots."""
import gzip
import json
from pathlib import Path
import re
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)

def frames(phase, stream, tag, decoded=True):
    text = gzip.decompress((BASE / phase / (stream + '.log.gz')).read_bytes()).decode()
    rows = {}
    for key, body in re.findall(r'^' + re.escape(tag) + r' (\w+) (\{.*\})$', text, re.M):
        assert key not in rows
        rows[key] = json.loads(body) if decoded else body.encode()
    return rows

def encoded(value):
    return json.dumps(value, sort_keys=True, separators=(',', ':'))

assert (BASE / 'launches/before/exit.txt').read_text() == '0\n'
stdout = gzip.decompress((BASE / 'before/normal-stdout.log.gz').read_bytes()).decode()
cold = frames('intake', 'native-stdout', 'CALLABLE_TRANSFORM_DART')
normal = frames('before', 'normal-stdout', 'CALLABLE_TRANSFORM_DART_NORMAL')
assert len(cold) == len(normal) == 312 and encoded(cold) == encoded(normal)
baseline = json.loads((BASE / 'baseline.json').read_bytes())
red = set(baseline['supported_targets']) | set(baseline['initial_source_compatibility'])
failed = set(re.findall(r'^\S+ \+\d+ -\d+: (\w+) \[E\]$', stdout, re.M))
assert failed == red and len(failed) == 31
assert '+281 -31: Some tests failed.' in stdout
assert (BASE / 'before/normal-exit.txt').read_text() == '1\n'
original_inputs = frames('intake', 'native-stdout', 'CALLABLE_TRANSFORM_DART_INPUT', False)
normal_inputs = frames('before', 'normal-stdout', 'CALLABLE_TRANSFORM_DART_NORMAL_INPUT', False)
assert original_inputs == normal_inputs and len(normal_inputs) == 312
packet = next(row for row in json.loads((BASE / 'before/custody.json').read_bytes()) if row['tag'] == 'normal-parsed')
with tarfile.open(ROOT / packet['archive']) as archive:
    assert len(archive.getnames()) == 312 and set(archive.getnames()) == packet['files'].keys()
    for member in archive:
        key = Path(member.name).stem
        assert archive.extractfile(member).read() == normal_inputs[key]
traced = frames('trace', 'trace-stdout', 'CALLABLE_TRANSFORM_DART_TRACE')
trace_inputs = frames('trace', 'trace-stdout', 'CALLABLE_TRANSFORM_DART_TRACE_INPUT', False)
assert len(traced) == 9 and traced.keys() == trace_inputs.keys()
for key, value in traced.items():
    assert encoded(value) == encoded(cold[key]['native']), key
    assert trace_inputs[key] == original_inputs[key], key
    trace = (BASE / 'trace' / (key + '.trace.log')).read_bytes()
    assert b'dart_runtime' in trace and b'dart_compiler' in trace
assert not subprocess.check_output(['git', 'diff', '--name-only', '--', 'dart/lib'], cwd=ROOT, text=True)
result = dict(original='PASS', programs=312, supported_RED=28, separate_initial_compatibility_RED=3,
    preservation_PASS=281, full_cold_records_exact=312, parsed_inputs_exact=312,
    traced_native_records_inputs_exact=9, production='unchanged',
    limits='Original finite full-wire/first-input reproduction; no peer verdict or portable initial-input admission.')
target = BASE / 'before-check.json'
assert not target.exists()
target.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
