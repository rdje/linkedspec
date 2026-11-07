"""Freeze each installed Lua host's actual independent preservation and error policies."""
import gzip,json
from pathlib import Path
BASE=Path(__file__).resolve().parent
cases=json.loads((BASE/'cases.json').read_bytes());profiles={};summary={}
def same(a,b):
    if isinstance(a,bool) or isinstance(b,bool):return type(a) is type(b) and a==b
    if isinstance(a,(int,float)) and isinstance(b,(int,float)):return a==b
    if type(a) is not type(b):return False
    if isinstance(a,list):return len(a)==len(b) and all(same(x,y) for x,y in zip(a,b))
    if isinstance(a,dict):return a.keys()==b.keys() and all(same(a[k],b[k]) for k in a)
    return a==b
for host in ('puc','luajit'):
    rows={}
    for line in gzip.decompress((BASE/'intake'/host/'normal-stdout.log.gz').read_bytes()).decode().splitlines():
        if line.startswith('HASH_VALUE_LUA '):
            _,key,value=line.split(' ',2);assert key not in rows;rows[key]=json.loads(value)
    assert list(rows)==[case['id'] for case in cases];profiles[host]={};bad=[]
    for case in cases:
        key=case['id'];actual=rows[key];assert set(actual)=={'native','restored','plan','fresh'}
        assert same(actual['native'],actual['restored']) and same(actual['plan'],actual['fresh'])
        if case.get('expected_error'):assert all(case['expected_error'] in value.get('error','') for value in actual.values())
        if case.get('profile_only') or case.get('expected_error'):profiles[host][key]=dict(source=case['source'],input=case['input'],**actual)
        elif any(not same(value,{'value':case['expected']}) for value in actual.values()):bad.append(key)
    assert len(profiles[host])==65
    summary[host]=dict(programs=89,profiles=65,shared_target_failures=bad)
out=Path('tests/fixtures/hash_value_result_guard_lua_profiles.json');assert not out.exists();out.write_text(json.dumps(profiles,indent=2,sort_keys=True)+'\n')
(BASE/'baseline-summary.json').write_text(json.dumps(summary,indent=2,sort_keys=True)+'\n')
print(json.dumps(summary,indent=2))
