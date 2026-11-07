"""Freeze actual Julia source/arity/error observations without peer policies."""
import gzip,json
from pathlib import Path
base=Path(__file__).resolve().parent;rows={}
for line in gzip.decompress((base/'intake/stdout.log.gz').read_bytes()).decode().splitlines():
 if line.startswith('HASH_VIEW_JULIA '):
  _,i,v=line.split(' ',2);assert i not in rows;rows[i]=json.loads(v)
cases=json.loads(Path('tests/fixtures/hash_view_result_guard_julia_cases.json').read_bytes());assert list(rows)==[r['id'] for r in cases]
profiles={}
for r in cases:
 actual=rows[r['id']];assert set(actual)=={'native','restored','plan','fresh'}
 assert actual['native']==actual['restored'] and actual['plan']==actual['fresh']
 if r.get('expected_error'):assert all(r['expected_error'] in v.get('error','') for v in actual.values())
 if r.get('profile_only') or r.get('expected_error'):profiles[r['id']]=dict(source=r['source'],input=r['input'],**actual)
assert len(profiles)==19
p=Path('tests/fixtures/hash_view_result_guard_julia_profiles.json');assert not p.exists();p.write_text(json.dumps(profiles,indent=2,sort_keys=True)+'\n')
print('19 actual Julia source/arity/error profiles frozen; no shared target overridden')
