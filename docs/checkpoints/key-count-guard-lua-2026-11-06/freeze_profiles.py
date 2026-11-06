"""One-shot independent installed-host profile freezing before production."""
import json
from pathlib import Path
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
FIXTURES=('tests/fixtures/key_count_result_guard_cases.json','tests/fixtures/key_count_count_source_ownership_cases.json')
cases=[row for name in FIXTURES for row in json.loads(Path(name).read_text())]
def same(a,b):
    return json.dumps(a,sort_keys=True,separators=(',',':'))==json.dumps(b,sort_keys=True,separators=(',',':'))
def write_new(path,value):
    assert not path.exists()
    path.write_text(json.dumps(value,indent=2,sort_keys=True)+'\n')
hosts={};versions={}
for host in ('puc','luajit'):
    rows={}
    for line in (BASE/'probe-before'/host/'normal-stdout.log').read_text().splitlines():
        if line.startswith('KEY_COUNT_LUA '):
            _,identifier,body=line.split(' ',2);assert identifier not in rows;rows[identifier]=json.loads(body)
    assert list(rows)==[c['id'] for c in cases]
    assert all(set(v)=={'native','restored','plan','fresh'} for v in rows.values())
    for row in cases:
        actual=rows[row['id']]
        if 'expected_error' in row:
            assert all(row['expected_error'] in v.get('error','') for v in actual.values())
        else:
            assert all(same(v,actual['native']) for v in actual.values())
    hosts[host]=rows
    folder=BASE/'probe-before'/host
    versions[host]=((folder/'version-stdout.log').read_text()+(folder/'version-stderr.log').read_text()).strip()
assert same(hosts['puc'],hosts['luajit']), 'only merge independently matching profiles'
rows=hosts['puc'];domain_row=next(c for c in cases if c['id']=='source_domain')
domain=dict(id=domain_row['id'],source=domain_row['source'],expected=rows['source_domain']['native']['value'],hosts=versions,provenance='Independent Lua75.5 actual probe-before on both hosts; no peer policy imported.')
errors={c['id']:rows[c['id']] for c in cases if 'expected_error' in c}
red=[]
for row in cases:
    if 'expected_error' not in row:
        expected=row['expected'] if 'expected' in row else domain['expected']
        if not same(rows[row['id']]['native'],{'value':expected}):red.append(row['id'])
write_new(Path('tests/fixtures/key_count_result_guard_lua_domain.json'),domain)
write_new(Path('tests/fixtures/key_count_result_guard_lua_errors.json'),errors)
write_new(BASE/'intake-result.json',dict(programs=len(cases),healthy=len(cases)-len(red),red=red,hosts=versions,source_domain=domain['expected']))
print(json.dumps(dict(programs=len(cases),healthy=len(cases)-len(red),red=red,hosts=versions),sort_keys=True))
