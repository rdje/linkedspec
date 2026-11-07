"""Derive finite candidate outcomes from the original full public observation."""
import gzip,json
from pathlib import Path
BASE=Path(__file__).resolve().parent
cases=json.loads((BASE/'cases.json').read_bytes());rows={}
for line in gzip.decompress((BASE/'intake/stdout.log.gz').read_bytes()).decode().splitlines():
    if line.startswith('ARRAY_TRANSFORM_PERL '):
        _,key,value=line.split(' ',2);assert key not in rows;rows[key]=json.loads(value)
assert list(rows)==[case['id'] for case in cases]
def same(a,b):
    if isinstance(a,bool) or isinstance(b,bool):return type(a) is type(b) and a==b
    if isinstance(a,(int,float)) and isinstance(b,(int,float)):return a==b
    if type(a) is not type(b):return False
    if isinstance(a,list):return len(a)==len(b) and all(same(x,y) for x,y in zip(a,b))
    if isinstance(a,dict):return a.keys()==b.keys() and all(same(a[k],b[k]) for k in a)
    return a==b
summary={};bad=[]
for case in cases:
    key=case['id'];row=rows[key];expected_error=case.get('expected_error')
    if expected_error:
        passed=all(expected_error in json.dumps(row.get(route+'_error')) for route in ('native','fresh')) and bool(row.get('native_callable')) and bool(row.get('loaded'))
    else:
        passed=bool(row.get('native_callable')) and bool(row.get('loaded')) and same(row.get('native'),case['expected']) and same(row.get('fresh'),case['expected']) and all(row.get(field) is None for field in ('native_error','fresh_error','build_error','load_error'))
    if not passed:bad.append(key)
    summary[key]=dict(passed=passed,metadata=row['metadata'],native=row.get('native'),fresh=row.get('fresh'),native_error=row.get('native_error'),fresh_error=row.get('fresh_error'),build_error=row.get('build_error'),load_error=row.get('load_error'),warnings=row.get('warnings'))
result=dict(programs=37,failed_targets=bad,healthy_targets=[case['id'] for case in cases if case['id'] not in bad],observations=summary)
out=BASE/'first-summary.json';assert not out.exists();out.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print(json.dumps(dict(programs=37,failed_targets=bad,healthy_targets=result['healthy_targets'],stderr_bytes=len(gzip.decompress((BASE/'intake/stderr.log.gz').read_bytes()))),indent=2))
