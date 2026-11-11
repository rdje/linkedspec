"""Require the exact normal RED set and unchanged cold observed policies."""
import gzip
import json
from pathlib import Path
import re
import subprocess

BASE = Path(__file__).resolve().parent
baseline = json.loads((BASE / 'baseline.json').read_bytes())
expected = set(baseline['supported_targets']) | set(baseline['compatibility'])
stdout = gzip.decompress((BASE / 'before/normal-stdout.log.gz').read_bytes()).decode()
stderr = gzip.decompress((BASE / 'before/normal-stderr.log.gz').read_bytes()).decode()
failed = set(re.findall(r'^test (\w+) \.\.\. FAILED$', stdout, re.M))
assert failed == expected and len(failed) == 11
assert '183 passed; 11 failed' in stdout
assert (BASE / 'before/normal-exit.txt').read_text() == '101\n'
normal = {key: json.loads(body) for key, body in re.findall(
    r'^CALLABLE_PIPELINE_RUST_NORMAL (\w+) (\{.*\})$', stderr, re.M)}
cold = {key: json.loads(body) for key, body in re.findall(
    r'^CALLABLE_PIPELINE_RUST (\w+) (\{.*\})$',
    gzip.decompress((BASE / 'intake/native-stdout.log.gz').read_bytes()).decode(), re.M)}
assert len(normal) == len(cold) == 194
encoded = lambda value: json.dumps(value, sort_keys=True, separators=(',', ':'))
assert encoded(normal) == encoded(cold)
inputs = {key: json.loads(body) for key, body in re.findall(
    r'^CALLABLE_PIPELINE_RUST_NORMAL_INPUT (\w+) (\{.*\})$', stderr, re.M)}
assert inputs.keys() == normal.keys()
for key, row in inputs.items():
    assert (BASE / 'before/normal-inputs' / (key + '.json')).read_bytes() == row['compiled'].encode()
assert not subprocess.check_output(['git', 'diff', '--name-only', '--',
    'rust/linkedspec-runtime/src', 'specs'], text=True)
print(json.dumps(dict(baseline='PASS', normal_groups=194, actual_normal_exit=101,
    supported_RED=baseline['supported_targets'], separate_compatibility_RED=baseline['compatibility'],
    cold_full_route_records_preserved=194, normal_serialized_inputs=194,
    current_production='unchanged before repair'), indent=2))
