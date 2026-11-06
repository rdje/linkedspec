"""Readonly recovery of finite Dart Hash-view source policies and RED/GREEN."""
import copy,difflib,gzip,hashlib,json,re,subprocess,tarfile
from pathlib import Path,PurePosixPath
ROOT=Path(__file__).resolve().parents[3];BASE=Path('docs/checkpoints/hash-view-result-guard-dart-2026-11-07')
ACTIVATION='b1f55ddf71083425eb923a852ec2974f70522a2c'
OWNER='dart/lib/src/runtime/interpreter.dart';NORMAL='dart/test/hash_view_result_guard_composition_test.dart';PROBE='dart/tool/probe_hash_view_results.dart'
GRAMMAR='specs/user_function_definition.spec';FIXTURE='tests/fixtures/hash_view_result_guard_cases.json';PROFILE='tests/fixtures/hash_view_result_guard_dart_profiles.json'
PHASES=('intake','before','after','after-intake','direct','format','format-final','direct-final','after-intake-final')
RED={'free_sorted_keys_hash_guard','receiver_sorted_keys_hash_guard','free_sorted_values_hash_guard','receiver_sorted_values_hash_guard','later_with','copy_guard','logical_guard'}
def digest(b):return hashlib.sha256(b).hexdigest()
def same(a,b):
 if isinstance(a,bool) or isinstance(b,bool):return type(a) is type(b) and a==b
 if type(a) is not type(b):return False
 if isinstance(a,list):return len(a)==len(b) and all(same(x,y) for x,y in zip(a,b))
 if isinstance(a,dict):return a.keys()==b.keys() and all(same(a[k],b[k]) for k in a)
 return a==b

def raw(phase,tag,channel='stdout'):return gzip.decompress((ROOT/BASE/phase/(tag+'-'+channel+'.log.gz')).read_bytes())
def frames(body,tag):
 out={}
 for line in body.decode().splitlines():
  if line.startswith(tag+' '):
   _,i,v=line.split(' ',2);assert i not in out;out[i]=json.loads(v)
 return out

def grammar(body,tag,expected):
 lines=[line for line in body.decode().splitlines() if line.startswith(tag+' ')]
 assert len(lines)==1
 value=json.loads(lines[0].split(' ',1)[1]);assert value==dict(path=GRAMMAR,source=expected.decode())
 # The actual supplied grammar frame precedes every case observation.
 assert body.index((tag+' ').encode())<body.index(b'HASH_VIEW_DART_INPUT ' if tag=='HASH_VIEW_DART_GRAMMAR' else b'HASH_VIEW_DART_NORMAL ')

def recover(phase):
 result={};records=json.loads((ROOT/BASE/phase/'custody.json').read_bytes())
 for row in records:
  path=PurePosixPath(row['archive']);assert str(path).startswith(str(BASE/phase)+'/') and '..' not in path.parts
  tag=path.name.split('-before-first-run')[0];assert tag not in result
  files={}
  with tarfile.open(ROOT/path) as a:
   for m in a:
    p=PurePosixPath(m.name);assert m.isfile() and not p.is_absolute() and '..' not in p.parts and m.name not in files
    b=a.extractfile(m).read();v=row['files'][m.name]
    assert len(b)==v['bytes'] and digest(b)==v['sha256'] and m.mode & 0o777==v['mode'];files[m.name]=b
  assert files.keys()==row['files'].keys();result[tag]=files
 return result

def validate(native,fresh,cases,profiles,before=False):
 assert list(native)==list(fresh)==[r['id'] for r in cases]
 for case in cases:
  i=case['id'];rows={**native[i],'fresh':fresh[i]};assert set(rows)=={'native','restored','plan','fresh'}
  for route,actual in rows.items():
   if before and i in RED:
    if i.startswith(('free_sorted_','receiver_sorted_')):expected=[['a'] if 'keys' in i else [1],'KV']
    else:expected=['ran','KVDW' if i=='logical_guard' else 'KVW']
    assert same(actual,{'value':expected})
   elif i in profiles:
    assert profiles[i]['source']==case['source'] and profiles[i]['input']==case['input']
    assert same(actual,profiles[i][route])
   else:assert same(actual,{'value':case['expected']})
  if case.get('expected_error'):
   assert all(case['expected_error'] in row['error'] for row in rows.values())
   assert rows['native']['class']=='RuntimeInterpreterException' and rows['plan']['class']=='GeneratedSourceException'
  assert same(rows['native'],rows['restored']) and same(rows['plan'],rows['fresh'])

def actual_artifacts(phase,recovered,cases):
 emitted=recovered['emitted'];fresh=recovered['fresh'];supplied=frames(raw(phase,'native'),'HASH_VIEW_DART_INPUT')
 assert list(supplied)==[r['id'] for r in cases]
 result={}
 for index,r in enumerate(cases):
  module=str(BASE/phase/'fresh/lib'/f'case_{index}.dart');parsed=str(BASE/phase/'fresh/inputs'/f'case_{index}.json')
  assert emitted[module]==fresh[module] and emitted[parsed]==fresh[parsed]
  assert json.loads(fresh[parsed])==supplied[r['id']]
  assert f'case_{index}.execute' in fresh[str(BASE/phase/'fresh/bin/main.dart')].decode()
  result[r['id']]=(fresh[module],fresh[parsed])
 assert len([p for p in fresh if re.search(r'/lib/case_\d+\.dart$',p)])==len(cases)
 return result

def git_bodies(paths):
 proc=subprocess.run(['git','cat-file','--batch'],cwd=ROOT,input=''.join(ACTIVATION+':'+p+'\n' for p in paths).encode(),stdout=subprocess.PIPE,check=True)
 body=proc.stdout;position=0;result={}
 for p in paths:
  end=body.index(b'\n',position);header=body[position:end].split();assert header[1]==b'blob'
  size=int(header[2]);position=end+1;result[p]=body[position:position+size];position+=size+1
 assert position==len(body);return result

def equal(a,b):assert a==b

def main():
 sealed=json.loads((ROOT/BASE/'sealed-identities.json').read_bytes())
 for p,v in sealed.items():
  path=PurePosixPath(p);assert not path.is_absolute() and '..' not in path.parts
  b=(ROOT/path).read_bytes();assert len(b)==v['bytes'] and digest(b)==v['sha256']
 for p,v in json.loads((ROOT/BASE/'raw-identities.json').read_bytes()).items():
  b=gzip.decompress((ROOT/(p+'.gz')).read_bytes());assert len(b)==v['bytes'] and digest(b)==v['sha256']
 recovered={p:recover(p) for p in PHASES}
 cases=json.loads(recovered['intake']['root'][str(BASE/'cases.json')]);profiles=json.loads(recovered['before']['root'][PROFILE]);assert len(cases)==33 and len(profiles)==19
 shared=json.loads(recovered['intake']['root'][FIXTURE]);assert cases[:15]==shared and len(shared)==15
 assert all(r.get('profile_only') and set(r)=={'id','source','input','profile_only'} for r in cases[15:])
 paths=sorted(p for p in recovered['intake']['root'] if p.startswith('dart/') and p!=PROBE and not p.startswith('dart/.dart_tool/'))
 historical=git_bodies(paths+[GRAMMAR,FIXTURE]);original=recovered['intake']['root'][OWNER];changed=recovered['direct-final']['root'][OWNER];unformatted=recovered['after']['root'][OWNER]
 assert changed.decode()==unformatted.decode().replace("const {'sorted_keys', 'sorted_values'}.contains(calls.first.method)","const {\n              'sorted_keys',\n              'sorted_values',\n            }.contains(calls.first.method)")
 initial_probe=recovered['intake']['root'][PROBE];final_probe=recovered['direct-final']['root'][PROBE]
 assert final_probe.decode()==initial_probe.decode().replace("emitDartSourceV2(compiled, 'hash-view-result-guard/$id.spec');","emitDartSourceV2(\n        compiled,\n        'hash-view-result-guard/$id.spec',\n      );")
 with tarfile.open(ROOT/BASE/'format/formatted-result.tar.gz') as archive:
  for path in (OWNER,PROBE,NORMAL):assert archive.extractfile(path).read()==recovered['direct-final']['root'][path]
 for path,value in json.loads((ROOT/BASE/'qualified-identities.json').read_bytes()).items():assert digest((ROOT/path).read_bytes())==value
 expected_patch=''.join(difflib.unified_diff((ROOT/BASE/'review.py').read_text().splitlines(True),Path(__file__).read_text().splitlines(True),fromfile='a/review.py',tofile='b/review-qualified.py')).encode()
 assert gzip.decompress((ROOT/BASE/'review-qualification.patch.gz').read_bytes())==expected_patch
 capture_v1=recovered['intake']['root'][str(BASE/'capture.py')];capture_v2=recovered['direct-final']['root'][str(BASE/'capture.py')]
 capture_patch=''.join(difflib.unified_diff(capture_v1.decode().splitlines(True),capture_v2.decode().splitlines(True),fromfile='a/capture.py',tofile='b/capture.py')).encode()
 assert gzip.decompress((ROOT/BASE/'capture-final-phases.patch.gz').read_bytes())==capture_patch
 assert original==historical[OWNER] and original!=changed
 for phase,items in recovered.items():
  root=items['root'];assert root[GRAMMAR]==historical[GRAMMAR] and root[FIXTURE]==historical[FIXTURE]
  assert root[PROBE]==(final_probe if phase.endswith('-final') else initial_probe)
  assert root[str(BASE/'capture.py')]==(capture_v2 if phase.endswith('-final') else capture_v1)
  assert root[OWNER]==(original if phase in {'intake','before'} else changed if phase.endswith('-final') else unformatted)
  for p in paths:
   if p!=OWNER:assert root[p]==historical[p],p
  if phase!='intake':
   assert root[NORMAL]==recovered['before']['root'][NORMAL] and json.loads(root[PROFILE])==profiles
  assert (ROOT/BASE/phase/'activation.txt').read_text().strip()==ACTIVATION
  for tag in ('version','resolution'):assert (ROOT/BASE/phase/(tag+'-exit.txt')).read_text()=='0\n'
  command=json.loads((ROOT/BASE/phase/'resolution-command.json').read_bytes());assert command['argv'][-3:]==['get','--offline','--enforce-lockfile']
 patch=''.join(difflib.unified_diff(original.decode().splitlines(True),changed.decode().splitlines(True),fromfile='a/'+OWNER,tofile='b/'+OWNER)).encode()
 assert gzip.decompress((ROOT/BASE/'producer-change.patch.gz').read_bytes())==patch
 artifacts={};observations={}
 for phase in ('intake','after-intake','after-intake-final'):
  for tag in ('analysis','native','fresh-resolution','fresh-analysis','fresh'):assert (ROOT/BASE/phase/(tag+'-exit.txt')).read_text()=='0\n'
  grammar(raw(phase,'native'),'HASH_VIEW_DART_GRAMMAR',historical[GRAMMAR])
  n=frames(raw(phase,'native'),'HASH_VIEW_DART');f=frames(raw(phase,'fresh'),'HASH_VIEW_DART_FRESH');validate(n,f,cases,profiles,before=phase=='intake');observations[phase]=(n,f)
  artifacts[phase]=actual_artifacts(phase,recovered[phase],cases)
 assert artifacts['intake']==artifacts['after-intake']==artifacts['after-intake-final']
 for phase,count,code in [('before',26,1),('after',33,0),('direct',62,0),('direct-final',62,0)]:
  assert (ROOT/BASE/phase/'analysis-exit.txt').read_text()=='0\n' and (ROOT/BASE/phase/'normal-exit.txt').read_text()==str(code)+'\n'
  body=raw(phase,'normal');grammar(body,'HASH_VIEW_DART_NORMAL_GRAMMAR',historical[GRAMMAR]);normal=frames(body,'HASH_VIEW_DART_NORMAL')
  assert normal==observations['intake' if phase=='before' else 'after-intake'][0]
  if phase=='before':assert set(re.findall(r': ([a-z][a-z0-9_]*) \[E\]',body.decode()))==RED and '+26 -7: Some tests failed.' in body.decode()
  else:assert f'+{count}: All tests passed!' in body.decode()
 assert (ROOT/BASE/'format/format-exit.txt').read_text()=='1\n'
 assert (ROOT/BASE/'format/format-apply-exit.txt').read_text()=='0\n'
 assert b'output=none changed no source' in (ROOT/BASE/'format/partial-format-note.txt').read_bytes()
 assert not (ROOT/BASE/'format-final/empty-phase-exit.txt').exists()
 assert (ROOT/BASE/'format-final/format-exit.txt').read_text()=='0\n'
 assert (ROOT/BASE/'format-final/empty-phase-exit.txt').read_text()=='255\n'
 assert b'phase must stay relative to the repository root' in raw('format-final','empty-phase','stderr') and raw('format-final','empty-phase')==b''
 n,f=observations['after-intake-final'];rejected=[]
 def reject(name,operation):
  try:operation()
  except (AssertionError,KeyError):rejected.append(name)
  else:raise AssertionError('ineffective corruption '+name)
 def mutation(i,route,value,before=False):
  a,b=copy.deepcopy(observations['intake'] if before else (n,f))
  if route=='fresh':b[i]=value
  else:a[i][route]=value
  validate(a,b,cases,profiles,before)
 reject('compatible result drift',lambda:mutation('keys_compatible','native',{'value':['b,a',0,'B']}))
 reject('initial source permission lost',lambda:mutation('initial_sorted_keys_number','native',{'value':None}))
 reject('free arity peer normalization',lambda:mutation('free_values_arity_profile','native',{'value':['ran','AW']}))
 reject('needed error masked',lambda:mutation('needed_source_error','plan',{'value':None}))
 lost=copy.deepcopy(f);lost.pop('logical_guard');reject('missing fresh member',lambda:validate(n,lost,cases,profiles))
 reject('grammar string drift',lambda:grammar(raw('intake','native'),'HASH_VIEW_DART_GRAMMAR',historical[GRAMMAR]+b'\n'))
 reject('actual module drift',lambda:equal(digest(artifacts['intake']['keys_compatible'][0]+b'\n'),digest(artifacts['after-intake']['keys_compatible'][0])))
 reject('original RED already green',lambda:mutation('free_sorted_keys_hash_guard','native',{'value':[None,'']},True))
 return dict(original_controls=33,original_healthy=26,original_RED=7,after_PASS=33,direct_PASS=62,independent_profiles=19,actual_modules_and_parsed_inputs_unchanged=33,original_format_RED=1,original_reader_format_token_assumption_RED=1,final_format_and_analysis_PASS=True,recovery_corruptions=rejected,scope='finite actual direct grammar/source/module recovery; full native/cache/transitive custody4.2/SESSION5, contexts, isolation, registration and23.4 remain separate')
if __name__=='__main__':print(json.dumps(main(),indent=2,sort_keys=True))
