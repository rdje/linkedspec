"""Freeze each installed Lua host's actual independent source/error profiles."""
import gzip,json
from pathlib import Path
base=Path(__file__).resolve().parent;cases=json.loads(Path('tests/fixtures/hash_view_result_guard_lua_cases.json').read_bytes());profiles={}
for host in ('puc','luajit'):
 rows={}
 for line in gzip.decompress((base/'intake'/host/'normal-stdout.log.gz').read_bytes()).decode().splitlines():
  if line.startswith('HASH_VIEW_LUA '):
   _,i,v=line.split(' ',2);assert i not in rows;rows[i]=json.loads(v)
 assert list(rows)==[r['id'] for r in cases];profiles[host]={}
 for row in cases:
  actual=rows[row['id']];assert set(actual)=={'native','restored','plan','fresh'}
  assert actual['native']==actual['restored'] and actual['plan']==actual['fresh']
  if row.get('expected_error'):assert all(row['expected_error'] in value.get('error','') for value in actual.values())
  if row.get('profile_only') or row.get('expected_error'):profiles[host][row['id']]=dict(source=row['source'],input=row['input'],**actual)
 assert len(profiles[host])==19
p=Path('tests/fixtures/hash_view_result_guard_lua_profiles.json');assert not p.exists();p.write_text(json.dumps(profiles,indent=2,sort_keys=True)+'\n')
print('Each installed host independently freezes19 own profiles; shared targets remain untouched')
