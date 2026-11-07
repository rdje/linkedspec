"""Readonly installed-host Lua Hash-view RED/GREEN and exact input recovery."""
import copy,difflib,gzip,hashlib,json,subprocess,tarfile
from pathlib import Path,PurePosixPath
ROOT=Path(__file__).resolve().parents[3];BASE=Path('docs/checkpoints/hash-view-result-guard-lua-2026-11-07')
ACTIVATION='c85d50b2d47a13be39ed065f869606978140d2ae';PHASES=('intake','before','after','direct');HOSTS=('puc','luajit')
OWNER='lua/src/linkedspec/interpreter.lua';RUNNER='lua/test/run.lua';NORMAL='lua/test/hash_view_result_guard_composition_test.lua'
GRAMMAR='specs/user_function_definition.spec';FIXTURE='tests/fixtures/hash_view_result_guard_lua_cases.json';PROFILE='tests/fixtures/hash_view_result_guard_lua_profiles.json';NEUTRAL='tests/fixtures/hash_view_result_guard_cases.json'
RED={'free_sorted_keys_hash_guard','receiver_sorted_keys_hash_guard','free_sorted_values_hash_guard','receiver_sorted_values_hash_guard','later_with','copy_guard','logical_guard'}
def digest(b):return hashlib.sha256(b).hexdigest()
def same(a,b):
 if isinstance(a,bool) or isinstance(b,bool):return type(a) is type(b) and a==b
 if isinstance(a,(int,float)) and isinstance(b,(int,float)):return a==b
 if type(a) is not type(b):return False
 if isinstance(a,list):return len(a)==len(b) and all(same(x,y) for x,y in zip(a,b))
 if isinstance(a,dict):return a.keys()==b.keys() and all(same(a[k],b[k]) for k in a)
 return a==b

def raw(phase,host,tag='normal',channel='stdout'):return gzip.decompress((ROOT/BASE/phase/host/(tag+'-'+channel+'.log.gz')).read_bytes())
def frames(body,tag):
 out={}
 for line in body.decode().splitlines():
  if line.startswith(tag+' '):
   _,i,v=line.split(' ',2);assert i not in out;out[i]=json.loads(v)
 return out

def recover(phase,host=None):
 directory=BASE/phase if host is None else BASE/phase/host
 name='inputs-before-first-run.tar.gz' if host is None else 'actual-emitted-parsed.tar.gz';metadata='input-identities.json' if host is None else 'artifact-identities.json'
 expected=json.loads((ROOT/directory/metadata).read_bytes());out={}
 with tarfile.open(ROOT/directory/name) as archive:
  for member in archive:
   p=PurePosixPath(member.name);assert member.isfile() and not p.is_absolute() and '..' not in p.parts and member.name not in out
   b=archive.extractfile(member).read();r=expected[member.name];assert len(b)==r['bytes'] and digest(b)==r['sha256'] and member.mode & 0o777==r['mode'];out[member.name]=b
 assert out.keys()==expected.keys();return out

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
    assert profiles[i]['source']==case['source'] and profiles[i]['input']==case['input'];assert same(value,profiles[i][route])
   else:assert same(value,{'value':case['expected']})
  if case.get('expected_error'):
   assert all(case['expected_error'] in value['error'] for value in actual.values())
   assert actual['native']['runtime'] is True and actual['native']['generated'] is False and actual['native']['code']=='binding_kind_mismatch'
   assert actual['native']['diagnostic_stage']=='runtime_execution'
   assert actual['plan']['runtime'] is False and actual['plan']['generated'] is True and actual['plan']['code']=='generated_execution_failed'
  assert same(actual['native'],actual['restored']) and same(actual['plan'],actual['fresh'])

def git_bodies(paths):
 result=subprocess.run(['git','cat-file','--batch'],cwd=ROOT,input=''.join(ACTIVATION+':'+p+'\n' for p in paths).encode(),stdout=subprocess.PIPE,check=True)
 body=result.stdout;position=0;out={}
 for p in paths:
  end=body.index(b'\n',position);header=body[position:end].split();assert header[1]==b'blob';size=int(header[2]);position=end+1;out[p]=body[position:position+size];position+=size+1
 assert position==len(body);return out

def patch(old,new,path):return ''.join(difflib.unified_diff(old.decode().splitlines(True),new.decode().splitlines(True),fromfile='a/'+path,tofile='b/'+path)).encode()
def equal(a,b):assert a==b

def main():
 for p,r in json.loads((ROOT/BASE/'sealed-identities.json').read_bytes()).items():
  path=PurePosixPath(p);assert not path.is_absolute() and '..' not in path.parts;b=(ROOT/path).read_bytes();assert len(b)==r['bytes'] and digest(b)==r['sha256']
 inputs={p:recover(p) for p in PHASES};cases=json.loads(inputs['intake'][FIXTURE]);profiles=json.loads(inputs['before'][PROFILE])
 assert len(cases)==33 and set(profiles)==set(HOSTS) and all(len(profiles[h])==19 for h in HOSTS)
 assert cases[:15]==json.loads(inputs['intake'][NEUTRAL]) and all(set(row)=={'id','source','input','profile_only'} and row['profile_only'] for row in cases[15:])
 paths=sorted(p for p in inputs['intake'] if p.startswith('lua/') and p!=NORMAL);historical=git_bodies(paths+[GRAMMAR,NEUTRAL])
 original=inputs['intake'][OWNER];changed=inputs['after'][OWNER];old_runner=historical[RUNNER];runner=inputs['after'][RUNNER]
 needle=b'test("Callable CountKeys preservation", function()\n  dofile("lua/test/key_count_callable_result_guard_composition_test.lua")\nend)'
 addition=b'\ntest("Hash-view Array result guards", function()\n  dofile("lua/test/hash_view_result_guard_composition_test.lua")\nend)'
 assert original==historical[OWNER] and changed!=original and runner==old_runner.replace(needle,needle+addition,1)
 assert runner.count(b'dofile("lua/test/hash_view_result_guard_composition_test.lua")')==1
 assert b'function typed_source.receiver_mutation.is_ordinary_hash_view_result_chain' in changed
 for phase,files in inputs.items():
  assert (ROOT/BASE/phase/'complete.txt').read_text()=='Both installed host epochs complete; declared sources unchanged.\n'
  assert (ROOT/BASE/phase/'activation.txt').read_text().strip()==ACTIVATION
  assert files[FIXTURE]==inputs['intake'][FIXTURE] and files[NORMAL]==inputs['intake'][NORMAL]
  assert files[GRAMMAR]==historical[GRAMMAR] and files[NEUTRAL]==historical[NEUTRAL]
  for name in ('prepare.py','capture.py','observer.lua','freeze_profiles.py'):assert files[str(BASE/name)]==inputs['intake'][str(BASE/name)]
  for p in paths:
   if p==OWNER:assert files[p]==(original if phase in {'intake','before'} else changed)
   elif p==RUNNER:assert files[p]==(old_runner if phase in {'intake','before'} else runner)
   else:assert files[p]==historical[p],p
  if phase!='intake':assert json.loads(files[PROFILE])==profiles
 assert gzip.decompress((ROOT/BASE/'producer-change.patch.gz').read_bytes())==patch(original,changed,OWNER)
 assert gzip.decompress((ROOT/BASE/'runner-registration.patch.gz').read_bytes())==patch(old_runner,runner,RUNNER)
 observations={};pairs={}
 for host in HOSTS:
  observations[host]={};pairs[host]={}
  for phase in PHASES:
   target=BASE/phase/host
   assert (ROOT/target/'version-exit.txt').read_text()=='0\n'
   version=raw(phase,host,'version')+raw(phase,host,'version','stderr');assert (b'Lua 5.5.1' if host=='puc' else b'LuaJIT 2.1.1788460057') in version
   command=json.loads((ROOT/target/'normal-command.json').read_bytes());assert command['argv'][:3]==['bash','tools/run_lua_project_data.sh',host] and command['environment']==dict(LINKEDSPEC_HASH_VIEW_CAPTURE=str(target))
   body=raw(phase,host);tag='HASH_VIEW_LUA' if phase=='intake' else 'HASH_VIEW_LUA_NORMAL';rows=frames(body,tag)
   validate(rows,cases,profiles[host],before=phase in {'intake','before'});observations[host][phase]=rows
   grammar_tag='HASH_VIEW_LUA_GRAMMAR' if phase=='intake' else 'HASH_VIEW_LUA_NORMAL_GRAMMAR'
   grammars=[line for line in body.decode().splitlines() if line.startswith(grammar_tag+' ')];assert len(grammars)==1
   assert json.loads(grammars[0].split(' ',1)[1])==dict(path=GRAMMAR,source=historical[GRAMMAR].decode())
   assert body.index((grammar_tag+' ').encode())<body.index(b'HASH_VIEW_LUA_INPUT ')
   assert (ROOT/target/'normal-exit.txt').read_text()==('1\n' if phase=='before' else '0\n')
   if phase=='before':assert b'HASH_VIEW_LUA_SUMMARY 184 checks 28 failures' in body and b'free_sorted_keys_hash_guard native' in raw(phase,host,'normal','stderr')
   else:assert raw(phase,host,'normal','stderr')==b''
   if phase in {'after','direct'}:assert b'HASH_VIEW_LUA_SUMMARY 184 checks 0 failures' in body
   artifact=recover(phase,host);assert len(artifact)==66;pairs[host][phase]={};supplied=frames(body,'HASH_VIEW_LUA_INPUT');assert list(supplied)==[r['id'] for r in cases]
   for case in cases:
    i=case['id'];module=artifact[str(target/'emitted'/(i+'.lua'))];parsed=artifact[str(target/'parsed'/(i+'.json'))];assert json.loads(parsed)==supplied[i];pairs[host][phase][i]=(module,parsed)
  assert observations[host]['intake']==observations[host]['before'] and observations[host]['after']==observations[host]['direct']
  assert all(pairs[host][p]==pairs[host]['intake'] for p in PHASES)
  direct=raw('direct',host);assert b'CONSTRUCTOR_SUMMARY 116 checks 0 failures' in direct and b'value copy checks passed' in direct and b'receiver copy arity checks passed' in direct
  assert len([line for line in direct.splitlines() if line.startswith(b'COPY_OBSERVATION ')])==12
 rejected=[]
 def reject(name,operation):
  try:operation()
  except (AssertionError,KeyError):rejected.append(name)
  else:raise AssertionError('ineffective corruption '+name)
 def mutate(host,i,route,value,before=False):
  rows=copy.deepcopy(observations[host]['intake' if before else 'after']);rows[i][route]=value;validate(rows,cases,profiles[host],before)
 reject('PUC compatible result drift',lambda:mutate('puc','keys_compatible','native',{'value':['b,a',0,'B']}))
 reject('LuaJIT initial Array policy lost',lambda:mutate('luajit','initial_sorted_values_array','native',{'value':None}))
 reject('PUC free arity Dart normalization',lambda:mutate('puc','free_values_arity_profile','native',{'value':['ran','W']}))
 reject('LuaJIT needed error masked',lambda:mutate('luajit','needed_source_error','plan',{'value':None}))
 lost=copy.deepcopy(observations['puc']['after']);lost['logical_guard'].pop('fresh');reject('PUC missing fresh route',lambda:validate(lost,cases,profiles['puc']))
 bad=copy.deepcopy(profiles['luajit']);bad['arity_profile']['source']+=' ';reject('LuaJIT profile source drift',lambda:validate(observations['luajit']['after'],cases,bad))
 reject('PUC actual module drift',lambda:equal(digest(pairs['puc']['intake']['keys_compatible'][0]+b'\n'),digest(pairs['puc']['after']['keys_compatible'][0])))
 reject('LuaJIT original RED already green',lambda:mutate('luajit','free_sorted_keys_hash_guard','native',{'value':[None,'']},True))
 return dict(per_installed_host=dict(original_programs=33,healthy=26,RED_groups=7,normal_checks=184,normal_failures_before=28,normal_failures_after=0,direct_counted_checks=300,value_copy_observation_rows=12,receiver_arity_controls_PASS=True,independent_profiles=19,actual_module_and_parsed_pairs_unchanged=33),hosts=list(HOSTS),recovery_corruptions=rejected,scope='finite actual installed-host direct inputs/grammar/artifacts; fresh modules share runtime/process; full native/cache/transitive custody4.2/SESSION5, contexts, isolation, registration, declared5.4 and23.4 remain separate')
if __name__=='__main__':print(json.dumps(main(),indent=2,sort_keys=True))
