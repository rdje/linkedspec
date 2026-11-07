"""Readonly finite Julia Hash-view RED/GREEN and exact declared-input recovery."""
import copy,difflib,gzip,hashlib,json,re,subprocess,tarfile
from pathlib import Path,PurePosixPath
ROOT=Path(__file__).resolve().parents[3];BASE=Path('docs/checkpoints/hash-view-result-guard-julia-2026-11-07')
ACTIVATION='c3bfc3038e55daec196ffe7f74895c98c05b907e'
OWNER='julia/src/runtime/Interpreter.jl';RUNNER='julia/test/runtests.jl';NORMAL='julia/test/hash_view_result_guard_composition_test.jl'
GRAMMAR='specs/user_function_definition.spec';FIXTURE='tests/fixtures/hash_view_result_guard_julia_cases.json';PROFILE='tests/fixtures/hash_view_result_guard_julia_profiles.json'
PHASES=('intake','before','after','direct')
RED={'free_sorted_keys_hash_guard','receiver_sorted_keys_hash_guard','free_sorted_values_hash_guard','receiver_sorted_values_hash_guard','later_with','copy_guard','logical_guard'}
def digest(b):return hashlib.sha256(b).hexdigest()
def same(a,b):
 if isinstance(a,bool) or isinstance(b,bool):return type(a) is type(b) and a==b
 if isinstance(a,(int,float)) and isinstance(b,(int,float)):return a==b
 if type(a) is not type(b):return False
 if isinstance(a,list):return len(a)==len(b) and all(same(x,y) for x,y in zip(a,b))
 if isinstance(a,dict):return a.keys()==b.keys() and all(same(a[k],b[k]) for k in a)
 return a==b

def raw(phase,channel='stdout'):return gzip.decompress((ROOT/BASE/phase/(channel+'.log.gz')).read_bytes())
def frames(body,tag):
 out={}
 for line in body.decode().splitlines():
  if line.startswith(tag+' '):
   _,i,v=line.split(' ',2);assert i not in out;out[i]=json.loads(v)
 return out

def recover(phase,artifact=False):
 stem='artifact' if artifact else 'input';name='actual-emitted-parsed.tar.gz' if artifact else 'inputs-before-first-run.tar.gz'
 expected=json.loads((ROOT/BASE/phase/(stem+'-identities.json')).read_bytes());files={}
 with tarfile.open(ROOT/BASE/phase/name) as archive:
  for member in archive:
   p=PurePosixPath(member.name);assert member.isfile() and not p.is_absolute() and '..' not in p.parts and member.name not in files
   b=archive.extractfile(member).read();r=expected[member.name]
   assert len(b)==r['bytes'] and digest(b)==r['sha256'] and member.mode & 0o777==r['mode'];files[member.name]=b
 assert files.keys()==expected.keys();return files

def grammar(phase,expected):
 body=raw(phase);tag='HASH_VIEW_JULIA_GRAMMAR' if phase=='intake' else 'HASH_VIEW_JULIA_NORMAL_GRAMMAR'
 lines=[line for line in body.decode().splitlines() if line.startswith(tag+' ')];assert len(lines)==1
 assert json.loads(lines[0].split(' ',1)[1])==dict(path=GRAMMAR,source=expected.decode())
 after=b'HASH_VIEW_JULIA_INPUT ' if phase=='intake' else b'HASH_VIEW_JULIA_NORMAL '
 assert body.index((tag+' ').encode())<body.index(after)

def validate(rows,cases,profiles,before=False):
 assert list(rows)==[r['id'] for r in cases]
 for case in cases:
  i=case['id'];actual=rows[i];assert set(actual)=={'native','restored','plan','fresh'}
  for route,value in actual.items():
   if before and i in RED:
    if i.startswith(('free_sorted_','receiver_sorted_')):expected=[['a'] if 'keys' in i else [1],'KV']
    else:expected=['ran','KVDW' if i=='logical_guard' else 'KVW']
    assert same(value,{'value':expected})
   elif i in profiles:
    assert profiles[i]['source']==case['source'] and profiles[i]['input']==case['input']
    assert same(value,profiles[i][route])
   else:assert same(value,{'value':case['expected']})
  if case.get('expected_error'):
   assert all(case['expected_error'] in value['error'] for value in actual.values())
   assert actual['native']['class']=='RuntimeInterpreterException' and actual['plan']['class']=='GeneratedSourceException'
  assert same(actual['native'],actual['restored']) and same(actual['plan'],actual['fresh'])

def git_bodies(paths):
 result=subprocess.run(['git','cat-file','--batch'],cwd=ROOT,input=''.join(ACTIVATION+':'+p+'\n' for p in paths).encode(),stdout=subprocess.PIPE,check=True)
 body=result.stdout;position=0;out={}
 for p in paths:
  end=body.index(b'\n',position);header=body[position:end].split();assert header[1]==b'blob';size=int(header[2]);position=end+1
  out[p]=body[position:position+size];position+=size+1
 assert position==len(body);return out

def patch(old,new,path):return ''.join(difflib.unified_diff(old.decode().splitlines(True),new.decode().splitlines(True),fromfile='a/'+path,tofile='b/'+path)).encode()
def equal(a,b):assert a==b

def main():
 for p,r in json.loads((ROOT/BASE/'sealed-identities.json').read_bytes()).items():
  path=PurePosixPath(p);assert not path.is_absolute() and '..' not in path.parts
  b=(ROOT/path).read_bytes();assert len(b)==r['bytes'] and digest(b)==r['sha256']
 inputs={phase:recover(phase) for phase in PHASES};artifacts={phase:recover(phase,True) for phase in PHASES}
 cases=json.loads(inputs['intake'][FIXTURE]);profiles=json.loads(inputs['before'][PROFILE]);assert len(cases)==33 and len(profiles)==19
 neutral='tests/fixtures/hash_view_result_guard_cases.json';assert cases[:15]==json.loads(inputs['intake'][neutral])
 assert all(set(row)=={'id','source','input','profile_only'} and row['profile_only'] for row in cases[15:])
 paths=sorted(p for p in inputs['intake'] if p.startswith('julia/') and p!=NORMAL)
 historical=git_bodies(paths+[GRAMMAR,neutral]);original=inputs['intake'][OWNER];changed=inputs['after'][OWNER]
 assert original==historical[OWNER] and original!=changed
 runner=inputs['after'][RUNNER];old_runner=historical[RUNNER]
 needle=b'include("key_count_callable_result_guard_composition_test.jl")'
 assert runner==old_runner.replace(needle,needle+b'\ninclude("hash_view_result_guard_composition_test.jl")',1)
 assert runner.count(b'include("hash_view_result_guard_composition_test.jl")')==1
 for phase,files in inputs.items():
  assert files[FIXTURE]==inputs['intake'][FIXTURE] and files[NORMAL]==inputs['intake'][NORMAL]
  assert files[GRAMMAR]==historical[GRAMMAR] and files[neutral]==historical[neutral]
  for name in ('prepare.py','capture.py','observer.jl','freeze_profiles.py'):assert files[str(BASE/name)]==inputs['intake'][str(BASE/name)]
  for p in paths:
   if p==OWNER:assert files[p]==(original if phase in {'intake','before'} else changed)
   elif p==RUNNER:assert files[p]==(old_runner if phase in {'intake','before'} else runner)
   else:assert files[p]==historical[p],p
  if phase!='intake':assert json.loads(files[PROFILE])==profiles
  assert (ROOT/BASE/phase/'activation.txt').read_text().strip()==ACTIVATION
  command=json.loads((ROOT/BASE/phase/'command.json').read_bytes())
  assert command['environment']['JULIA_NUM_THREADS']=='1' and command['environment']['OPENBLAS_NUM_THREADS']=='1'
  assert '--depwarn=error' in command['argv'] and command['argv'][:2]==['bash','tools/run_julia_project_data.sh']
  grammar(phase,historical[GRAMMAR])
 assert gzip.decompress((ROOT/BASE/'producer-change.patch.gz').read_bytes())==patch(original,changed,OWNER)
 assert gzip.decompress((ROOT/BASE/'runner-registration.patch.gz').read_bytes())==patch(old_runner,runner,RUNNER)
 observations={};pairs={}
 supplied=frames(raw('intake'),'HASH_VIEW_JULIA_INPUT');assert list(supplied)==[r['id'] for r in cases]
 for phase in PHASES:
  tag='HASH_VIEW_JULIA' if phase=='intake' else 'HASH_VIEW_JULIA_NORMAL';rows=frames(raw(phase),tag)
  validate(rows,cases,profiles,before=phase in {'intake','before'});observations[phase]=rows
  assert (ROOT/BASE/phase/'exit.txt').read_text()==('1\n' if phase=='before' else '0\n')
  assert len(artifacts[phase])==66;pairs[phase]={}
  for case in cases:
   i=case['id'];module=artifacts[phase][str(BASE/phase/'emitted'/(i+'.jl'))];parsed=artifacts[phase][str(BASE/phase/'parsed'/(i+'.json'))]
   assert json.loads(parsed)==supplied[i];pairs[phase][i]=(module,parsed)
 assert observations['intake']==observations['before'] and observations['after']==observations['direct']
 assert all(pairs[phase]==pairs['intake'] for phase in PHASES)
 before=raw('before').decode();assert re.search(r'Julia Hash-view result guards\s*\|\s*156\s+28\s+184\s',before)
 for phase in ('after','direct'):assert re.search(r'Julia Hash-view result guards\s*\|\s*184\s+184\s',raw(phase).decode())
 for title,count in [('Julia retained constructor result guards',116),('Julia value-copy contract',12),('Receiver copy arity before effects',3)]:assert re.search(re.escape(title)+rf'\s*\|\s*{count}\s+{count}\s',raw('direct').decode())
 assert raw('intake','stderr')==raw('direct','stderr')==b''
 assert b'Some tests did not pass: 156 passed, 28 failed, 0 errored' in raw('before','stderr')
 after_error=raw('after','stderr');assert b'LinkedSpecJulia' in after_error and b'successfully precompiled' in after_error and b'ERROR:' not in after_error
 final=observations['after'];rejected=[]
 def reject(name,operation):
  try:operation()
  except (AssertionError,KeyError):rejected.append(name)
  else:raise AssertionError('ineffective corruption '+name)
 def mutate(i,route,value,before=False):
  rows=copy.deepcopy(observations['intake'] if before else final);rows[i][route]=value;validate(rows,cases,profiles,before)
 reject('compatible result drift',lambda:mutate('keys_compatible','native',{'value':['b,a',0,'B']}))
 reject('initial Array policy lost',lambda:mutate('initial_sorted_values_array','native',{'value':None}))
 reject('free arity Dart normalization',lambda:mutate('free_values_arity_profile','native',{'value':['ran','W']}))
 reject('needed error masked',lambda:mutate('needed_source_error','plan',{'value':None}))
 lost=copy.deepcopy(final);lost.pop('logical_guard');reject('missing source member',lambda:validate(lost,cases,profiles))
 bad_profiles=copy.deepcopy(profiles);bad_profiles['arity_profile']['source']+=' ';reject('profile source drift',lambda:validate(final,cases,bad_profiles))
 reject('actual module drift',lambda:equal(digest(pairs['intake']['keys_compatible'][0]+b'\n'),digest(pairs['after']['keys_compatible'][0])))
 reject('original RED already green',lambda:mutate('free_sorted_keys_hash_guard','native',{'value':[None,'']},True))
 return dict(original_programs=33,healthy=26,RED_groups=7,normal_assertions_before=dict(PASS=156,FAIL=28),normal_assertions_after=184,direct_assertions=315,independent_profiles=19,actual_module_and_parsed_pairs_unchanged=33,recovery_corruptions=rejected,scope='finite declared direct source/grammar recovery; fresh Modules share runtime/process; full native/cache/transitive custody4.2/SESSION5, contexts, isolation, registration and23.4 remain separate')
if __name__=='__main__':print(json.dumps(main(),indent=2,sort_keys=True))
