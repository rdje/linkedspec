"""Read complete retained Dart observations without executing acquisition writers."""
import json
import gzip
from pathlib import Path
import sys

BASE=Path(__file__).resolve().parent
phase=sys.argv[1]
root=BASE/phase
cases=json.loads((root/'cases.json').read_text())


def same(a,b):
    if isinstance(a,bool) or isinstance(b,bool): return type(a) is type(b) and a==b
    if isinstance(a,(int,float)) and isinstance(b,(int,float)): return a==b
    if type(a) is not type(b): return False
    if isinstance(a,list): return len(a)==len(b) and all(same(x,y) for x,y in zip(a,b))
    if isinstance(a,dict): return a.keys()==b.keys() and all(same(a[k],b[k]) for k in a)
    return a==b


def read(tag,prefix):
    assert (root/(tag+'-exit.txt')).read_text()=='0\n'
    rows={}
    path=root/(tag+'-stdout.log')
    body=path.read_bytes() if path.exists() else gzip.decompress(Path(str(path)+'.gz').read_bytes())
    for line in body.decode().splitlines():
        if line.startswith(prefix+' '):
            _,identifier,body=line.split(' ',2)
            assert identifier not in rows
            rows[identifier]=json.loads(body)
    assert list(rows)==[r['id'] for r in cases], 'complete ordered observations'
    return rows


native=read('native','LENGTH_DART');fresh=read('fresh','LENGTH_DART_FRESH')
for case in cases:
    row=native[case['id']]
    assert set(row)=={'native','restored','plan'},row
    routes={**row,'fresh':fresh[case['id']]}
    if case.get('expected_error'):
        matched=all(isinstance(v.get('error'),str) and case['expected_error'] in v['error'] for v in routes.values())
        actual=routes
    else:
        assert all(same(row['native'],v) for v in routes.values()),'value routes differ: '+case['id']
        matched=(all(set(v)=={'value'} and same(v['value'],case['expected']) for v in routes.values()) if 'expected' in case else None)
        actual=row['native']
    print(json.dumps(dict(id=case['id'],actual=actual,matches_target=matched),sort_keys=True))
