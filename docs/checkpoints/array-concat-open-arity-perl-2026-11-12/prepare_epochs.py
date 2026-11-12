"""Prepare full before/current wire expectations from already acquired terminal oracles."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
target = BASE / 'epoch-expectations.json'
assert not target.exists()
profiles = json.loads(Path('tests/fixtures/array_concat_open_arity_result_guard_perl_cases.json').read_bytes())
cold = json.loads((BASE / 'baseline.json').read_bytes())['observed']


def normalize(value):
    if isinstance(value, dict):
        return {key: normalize(child) for key, child in value.items()}
    if isinstance(value, list):
        return [normalize(child) for child in value]
    return re.sub(r'\(eval \d+\)', '(eval SERIAL)', value) if isinstance(value, str) else value


def project(row):
    return normalize({key: value for key, value in row.items() if key not in ('substitution', 'module_input', 'handler_input')})


expected = {}
for profile in profiles:
    case = profile['case']; key = case['id']
    if profile['role'] != 'result-target':
        expected[key] = profile['expected_observation']
    else:
        tail = case['tail']
        terminal = key[:-len(tail)] + 'terminal'
        assert terminal in cold and cold[terminal]['loaded'] == cold[terminal]['native_callable'] == 1
        row = project(cold[terminal])
        assert row['native_error'] is None and row['fresh_error'] is None and not row['warnings']
        row['native'] = copy.deepcopy(profile['expected'])
        row['fresh'] = copy.deepcopy(profile['expected'])
        expected[key] = row
assert len(expected) == 504
target.write_text(json.dumps(dict(before={key: project(row) for key, row in cold.items()}, current=expected), indent=2, sort_keys=True) + '\n')
print('Prepared504 full wire expectations from frozen own producer/terminal observations')
