"""Require the unchanged Dart runtime's exact RED set and full cold records."""
import gzip
import json
from pathlib import Path
import re
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]


def frames(text, tag):
    rows = {}
    for key, body in re.findall(r'^' + tag + r' (\w+) (\{.*\})$', text, re.M):
        assert key not in rows
        rows[key] = json.loads(body)
    return rows


stdout = gzip.decompress((BASE / 'before/normal-stdout.log.gz').read_bytes()).decode()
cold = frames(gzip.decompress((BASE / 'intake/native-stdout.log.gz').read_bytes()).decode(), 'CALLABLE_PIPELINE_DART')
normal = frames(stdout, 'CALLABLE_PIPELINE_DART_NORMAL')
assert len(normal) == len(cold) == 194
encoded = lambda value: json.dumps(value, sort_keys=True, separators=(',', ':'))
assert encoded(normal) == encoded(cold)
baseline = json.loads((BASE / 'baseline.json').read_bytes())
red = set(baseline['supported_targets']) | set(baseline['compatibility'])
failed = set(re.findall(r'^\S+ \+\d+ -\d+: (\w+) \[E\]$', stdout, re.M))
assert failed == red and len(failed) == 19, failed
assert '+175 -19: Some tests failed.' in stdout
assert (BASE / 'before/normal-exit.txt').read_text() == '1\n'
inputs = frames(stdout, 'CALLABLE_PIPELINE_DART_NORMAL_INPUT')
assert inputs.keys() == normal.keys()
folder = ROOT / '.linkedspec-data/scratch/callable-pipeline-dart-normal/before'
for key, row in inputs.items():
    assert encoded(json.loads((folder / (key + '.json')).read_bytes())) == encoded(row)
assert not subprocess.check_output(['git', 'diff', '--name-only', '--', 'dart/lib'], text=True)
print(json.dumps(dict(baseline='PASS', programs=194, actual_normal_exit=1,
    supported_RED=baseline['supported_targets'], separate_compatibility_RED=baseline['compatibility'],
    preserved=175, complete_cold_records=194, capture_mode_parsed_inputs=194,
    production='unchanged'), indent=2))
