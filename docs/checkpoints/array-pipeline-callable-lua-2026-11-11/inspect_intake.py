"""Present each installed host's own complete observations; no peer policy oracle."""
import collections
import gzip
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
cases = json.loads((BASE / 'cases.json').read_bytes())
for host in ('puc', 'luajit'):
    folder = BASE / 'intake' / host
    body = gzip.decompress((folder / 'normal-stdout.log.gz').read_bytes()).decode()
    rows = {}
    for line in body.splitlines():
        if line.startswith('CALLABLE_PIPELINE_LUA '):
            _, key, raw = line.split(' ', 2)
            assert key not in rows
            rows[key] = json.loads(raw)
    assert list(rows) == [case['id'] for case in cases]
    assert all(set(row) == {'native', 'restored', 'plan', 'fresh'} for row in rows.values())
    print('HOST', host, [line for line in body.splitlines() if line.startswith('HOST ')])
    for case in cases[:37]:
        print('SHARED', host, case['id'], json.dumps(dict(question=case, actual=rows[case['id']]), sort_keys=True))
    groups = collections.defaultdict(list)
    for case in cases[37:]:
        groups[case['question']].append(case)
    for question, values in groups.items():
        print('QUESTION', host, question, len(values))
        for case in values:
            print('FULL', host, case['id'], json.dumps(rows[case['id']], sort_keys=True))
