"""Apply only own reproduced concat guard and exact legacy continuation transfers."""
import copy
import difflib
import gzip
import hashlib
import io
import json
from pathlib import Path
import subprocess
import tarfile
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
ACTIVATION='fb613736f68f7d1f90df5ade3c0e73c98160ca3f'
assert subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()==ACTIVATION
assert (BASE/'before-check.json').is_file()
assert all((BASE/'before'/h/'normal-exit.txt').read_text()=='1\n' for h in ('puc','luajit'))
out=BASE/'repair-run';out.mkdir()
owner=Path('lua/src/linkedspec/interpreter.lua');runner=Path('lua/test/run.lua')
legacy=Path('tests/fixtures/array_transform_callable_result_guard_lua_profiles.json')
ordinary=Path('tests/fixtures/array_transform_result_guard_lua_profiles.json')
paths=(owner,runner,legacy,ordinary)
before={p:p.read_bytes() for p in paths}
for p,b in before.items(): assert b==subprocess.check_output(['git','show',ACTIVATION+':'+str(p)])
old=b'  return name == "concat_arrays" and count == 2\n';new=b'  return name == "concat_arrays" and count >= 1\n'
anchor=b'''test("Callable Array-transform result guards", function()
  dofile("lua/test/array_transform_callable_result_guard_composition_test.lua")
end)
'''
addition=b'''test("Existing concat arity result guards", function()
  dofile("lua/test/array_concat_open_arity_result_guard_composition_test.lua")
end)
'''
assert before[owner].count(old)==1 and before[runner].count(anchor)==1 and addition not in before[runner]
after={owner:before[owner].replace(old,new,1),runner:before[runner].replace(anchor,anchor+addition,1)}
baseline=json.loads((BASE/'baseline.json').read_bytes())
for path,is_legacy in ((legacy,True),(ordinary,False)):
 prior=json.loads(before[path]);current=copy.deepcopy(prior)
 for host in ('puc','luajit'):
  for form in ('free','receiver'):
   key=('own_extra_concat_arrays_' if is_legacy else 'extra_concat_arrays_')+form
   question=key if is_legacy else 'ordinary_legacy_'+key+'_composed'
   assert {r:prior[host][key][r] for r in ('native','restored','plan','fresh')}==baseline[host]['observed'][question]
   current[host][key].update(baseline[host]['expected'][question])
   comparison=copy.deepcopy(current[host][key]);comparison.update({r:prior[host][key][r] for r in ('native','restored','plan','fresh')})
   assert comparison==prior[host][key], 'source and metadata remain exact'
  for key in prior[host]:
   if key not in [(('own_extra_concat_arrays_' if is_legacy else 'extra_concat_arrays_')+form) for form in ('free','receiver')]: assert prior[host][key]==current[host][key]
 after[path]=(json.dumps(current,indent=2,sort_keys=True)+'\n').encode()
for tag,images in (('before',before),('after',after)):
 rows={}
 with tarfile.open(out/(tag+'.tar.gz'),'x:gz') as archive:
  for path,body in images.items():
   member=tarfile.TarInfo(str(path));member.size=len(body);member.mode=path.stat().st_mode&0o777
   archive.addfile(member,io.BytesIO(body));rows[str(path)]=dict(bytes=len(body),sha256=hashlib.sha256(body).hexdigest(),mode=member.mode)
 with tarfile.open(out/(tag+'.tar.gz')) as archive:
  assert set(archive.getnames())==rows.keys()
  for member in archive:
   b=archive.extractfile(member).read();r=rows[member.name]
   assert len(b)==r['bytes'] and hashlib.sha256(b).hexdigest()==r['sha256'] and member.mode&0o777==r['mode']
 (out/(tag+'.json')).write_text(json.dumps(rows,indent=2,sort_keys=True)+'\n')
for p,name in ((owner,'owner'),(runner,'runner')):
 (BASE/(name+'-after.lua.gz')).write_bytes(gzip.compress(after[p],mtime=0))
patch=''.join(''.join(difflib.unified_diff(before[p].decode().splitlines(True),after[p].decode().splitlines(True),fromfile=str(p),tofile=str(p))) for p in (owner,runner))
(BASE/'source.diff.gz').write_bytes(gzip.compress(patch.encode(),mtime=0))
assert gzip.decompress((BASE/'source.diff.gz').read_bytes())==patch.encode()
for p in paths:
 assert p.read_bytes()==before[p]
 mode=p.stat().st_mode&0o777;p.write_bytes(after[p]);assert p.read_bytes()==after[p] and p.stat().st_mode&0o777==mode
(out/'result.json').write_text(json.dumps(dict(owner_lines=1,runner_groups=1,legacy_route_objects_per_host=4,scope='Only four separately acquired compatibility continuations transfer; no chunk locals, producer/signature/format/initial-kind authority.'),indent=2)+'\n')
print('Applied one concat selector line/one runner group and four exact legacy continuation projections per installed host')
