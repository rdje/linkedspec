"""Read complete retained public route observations; no historical writers."""
import json
from pathlib import Path
import sys

BASE = Path(__file__).resolve().parent
phase = sys.argv[1]
root = BASE / phase
cases = json.loads((root / 'cases.json').read_text())


def same(a, b):
    if isinstance(a, bool) or isinstance(b, bool):
        return type(a) is type(b) and a == b
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return a == b
    if type(a) is not type(b):
        return False
    if isinstance(a, list):
        return len(a) == len(b) and all(same(x,y) for x,y in zip(a,b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    return a == b


def read(tag, prefix):
    assert (root / (tag+'-exit.txt')).read_text() == '0\n'
    rows = {}
    for line in (root / (tag+'-stdout.log')).read_text().splitlines():
        if line.startswith(prefix+' '):
            _, name, body = line.split(' ', 2)
            assert name not in rows
            rows[name] = json.loads(body)
    assert list(rows) == [r['id'] for r in cases], 'complete ordered case population'
    return rows


native = read('native', 'LENGTH_RUST')
fresh = read('fresh', 'LENGTH_RUST_FRESH')
for case in cases:
    row = native[case['id']]
    assert set(row) == {'native','restored','plan'}, row
    routes = [row[k] for k in ('native','restored','plan')] + [fresh[case['id']]]
    assert all(same(routes[0], value) for value in routes), 'routes differ: '+case['id']
    if case.get('expected_error'):
        match = all(set(r)=={'error'} and case['expected_error'] in r['error'] for r in routes)
    elif 'expected' in case:
        match = all(set(r)=={'value'} and same(r['value'],case['expected']) for r in routes)
    else:
        match = None
    print(json.dumps(dict(id=case['id'], actual=routes[0], matches_target=match),sort_keys=True))
