"""Freeze only actual Dart intake profiles; shared targets remain independent."""
import json
from pathlib import Path
base=Path(__file__).resolve().parent

def frames(name,tag):
 out={}
 for line in (base/'intake'/name).read_text().splitlines():
  if line.startswith(tag+' '):
   _,i,v=line.split(' ',2);assert i not in out;out[i]=json.loads(v)
 return out
native=frames('native-stdout.log','HASH_VIEW_DART');fresh=frames('fresh-stdout.log','HASH_VIEW_DART_FRESH')
cases=json.loads((base/'cases.json').read_text());assert list(native)==list(fresh)==[r['id'] for r in cases]
profiles={}
for r in cases:
 i=r['id'];rows={**native[i],'fresh':fresh[i]};assert set(rows)=={'native','restored','plan','fresh'}
 assert rows['native']==rows['restored'] and rows['plan']==rows['fresh']
 if r.get('expected_error'):
  assert all(r['expected_error'] in row['error'] for row in rows.values())
 else:assert all(row==rows['native'] for row in rows.values())
 if r.get('profile_only') or r.get('expected_error'):profiles[i]=dict(source=r['source'],input=r['input'],**rows)
assert len(profiles)==19
p=Path('tests/fixtures/hash_view_result_guard_dart_profiles.json');assert not p.exists();p.write_text(json.dumps(profiles,indent=2,sort_keys=True)+'\n')
print('19 actual independent Dart source/arity/error profiles frozen; seven shared targets still RED')
