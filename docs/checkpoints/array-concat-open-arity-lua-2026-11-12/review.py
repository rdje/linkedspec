"""Read retained historical Lua proof only; never run SDKs or completed producers."""
import copy
import gzip
import hashlib
import importlib.util
import io
import json
from pathlib import Path
import re
import subprocess
import sys
import tarfile
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[3]
BASE=Path('docs/checkpoints/array-concat-open-arity-lua-2026-11-12')
ACTIVATION='fb613736f68f7d1f90df5ade3c0e73c98160ca3f'
OWNER='lua/src/linkedspec/interpreter.lua'
RUNNER='lua/test/run.lua'
NORMAL='lua/test/array_concat_open_arity_result_guard_composition_test.lua'
CASES='tests/fixtures/array_concat_open_arity_lua_cases.json'
PROFILE='tests/fixtures/array_concat_open_arity_lua_profiles.json'
LEGACY='tests/fixtures/array_transform_callable_result_guard_lua_profiles.json'
ORDINARY='tests/fixtures/array_transform_result_guard_lua_profiles.json'
ROUTES=('native','restored','plan','fresh')
def require(value,reason): assert value,reason
def wire(value): return json.dumps(value,sort_keys=True,separators=(',',':'))
def read(path):
 path=Path(path);require(not path.is_absolute() and '..' not in path.parts,'relative input')
 p=ROOT/path;require(p.is_file() and not p.is_symlink(),'retained input');return p.read_bytes()
def digest(body): return hashlib.sha256(body).hexdigest()
def unpack(body,rows):
 result={}
 with tarfile.open(fileobj=io.BytesIO(body)) as source:
  for member in source:
   require(member.isfile() and not Path(member.name).is_absolute() and '..' not in Path(member.name).parts,'safe archive')
   require(member.name in rows and member.name not in result,'archive census')
   raw=source.extractfile(member).read();row=rows[member.name]
   require(len(raw)==row['bytes'] and digest(raw)==row['sha256'],'archive bytes')
   require(member.mode&0o777==row['mode'],'archive full modes');result[member.name]=raw
 require(result.keys()==rows.keys(),'archive census');return result
def capsule(out,stem='input',name='inputs-before-first-run.tar.gz'):
 return unpack(read(out/name),json.loads(read(out/(stem+'-identities.json'))))
def channel(out,tag,name): return gzip.decompress(read(out/(tag+'-'+name+'.log.gz')))
def frames(body,tag):
 rows={}
 for line in body.decode().splitlines():
  if line.startswith(tag+' '):
   _,key,raw=line.split(' ',2);require(key not in rows,'frame census');rows[key]=json.loads(raw)
 return rows
def compare(actual,expected): require(wire(actual)==wire(expected),'complete route records')
def main():
 seal=json.loads(read(BASE/'sealed-identities.json'))
 for name,row in seal.items():
  raw=read(name);require(len(raw)==row['bytes'] and digest(raw)==row['sha256'],'sealed bytes')
 oracle_path=BASE/'semantic_oracle.py';require(str(oracle_path) in seal,'oracle custody')
 spec=importlib.util.spec_from_file_location('historical_lua_concat_oracle',ROOT/oracle_path)
 oracle=importlib.util.module_from_spec(spec);spec.loader.exec_module(oracle)
 before=unpack(read(BASE/'repair-run/before.tar.gz'),json.loads(read(BASE/'repair-run/before.json')))
 after=unpack(read(BASE/'repair-run/after.tar.gz'),json.loads(read(BASE/'repair-run/after.json')))
 old=b'  return name == "concat_arrays" and count == 2\n';new=b'  return name == "concat_arrays" and count >= 1\n'
 require(before[OWNER].count(old)==1 and after[OWNER]==before[OWNER].replace(old,new,1),'exact owner change')
 anchor=b'''test("Callable Array-transform result guards", function()
  dofile("lua/test/array_transform_callable_result_guard_composition_test.lua")
end)
'''
 added=b'''test("Existing concat arity result guards", function()
  dofile("lua/test/array_concat_open_arity_result_guard_composition_test.lua")
end)
'''
 require(before[RUNNER].count(anchor)==1 and after[RUNNER]==before[RUNNER].replace(anchor,anchor+added,1),'exact runner change')
 for name,body in before.items(): require(body==subprocess.check_output(['git','show',ACTIVATION+':'+name],cwd=ROOT),'activation body')
 root=capsule(BASE/'intake');cases=json.loads(root[str(BASE/'cases.json')]);baseline=json.loads(read(BASE/'baseline.json'))
 selected=json.loads(root[str(BASE/'selected-inputs.json')])
 with subprocess.Popen(['git','archive',ACTIVATION,*selected],cwd=ROOT,stdout=subprocess.PIPE) as process:
  names=set()
  with tarfile.open(fileobj=process.stdout,mode='r|') as source:
   for member in source:
    if member.isfile():
     require(source.extractfile(member).read()==root[member.name],'activation selected input');names.add(member.name)
  require(process.wait()==0 and names==set(selected),'selected activation census')
 phases=('intake','before','after','inverse','restored','direct');allroots={phase:capsule(BASE/phase) for phase in phases}
 for phase,current in allroots.items():
  wanted=set(selected)|{CASES}|(set() if phase=='intake' else {NORMAL,PROFILE})
  require({name for name in current if name.startswith(('lua/','tests/fixtures/','specs/','tools/'))}==wanted,'selected epoch census')
  for name in selected:
   body=before[name] if name in before and phase in ('intake','before') else after[name] if name in after else root[name]
   require(current[name]==body,'selected epoch bytes')
  if phase in ('inverse','restored'):
   prefix=str(BASE/'control-owner')+'/'
   require({name.removeprefix(prefix) for name in current if name.startswith(prefix)}==wanted,'private scope')
   for name in wanted:
    require(current[prefix+name]==(before[OWNER] if phase=='inverse' and name==OWNER else current[name]),'same-path private inputs')
 normal=allroots['after'][NORMAL];observer=root[str(BASE/'observer.lua')]
 for body in (normal,observer):
  require(body.index(b'persist("parsed"')<body.index(b'from_json(')<body.index(b'compile_spec(parsed)') if body==observer else body.index(b'retained_input(output, "parsed"')<body.index(b'from_json(')<body.index(b'compile_spec(parsed)'),'parsed first-use order')
  require(body.index(b'persist("emitted"')<body.index(b'(loadstring or load)(emitted)') if body==observer else body.index(b'retained_input(output, "emitted"')<body.index(b'(loadstring or load)(emitted)'),'emitted first-use order')
 controls=[];last_expected=None;last_cold=None
 for host in ('puc','luajit'):
  first=BASE/'intake'/host;cold=frames(channel(first,'normal','stdout'),'ARRAY_CONCAT_LUA')
  expected,supported,compatibility=oracle.semantic_oracle(cases,cold)
  compare(baseline[host]['observed'],cold);compare(baseline[host]['expected'],expected)
  require(baseline[host]['supported_targets']==supported and baseline[host]['legacy_operand_compatibility']==compatibility,'role census')
  require(len(baseline[host]['preserved'])==484 and len(baseline[host]['initial_policies'])==80 and len(baseline[host]['invalid_signatures'])==8,'preservation census')
  profiles=json.loads(allroots['after'][PROFILE])[host]
  compare({k:{r:p[r] for r in ROUTES} for k,p in profiles.items()},expected)
  require({r['id']:r['source'] for r in cases}=={k:p['source'] for k,p in profiles.items()},'source-bound profiles')
  for name,is_legacy in ((LEGACY,True),(ORDINARY,False)):
   prior=json.loads(before[name])[host];current=json.loads(after[name])[host];wanted=copy.deepcopy(prior)
   for form in ('free','receiver'):
    key=('own_extra_concat_arrays_' if is_legacy else 'extra_concat_arrays_')+form
    question=key if is_legacy else 'ordinary_legacy_'+key+'_composed'
    wanted[key].update(expected[question])
   compare(current,wanted)
  first_artifacts=capsule(first,'artifact','actual-emitted-parsed.tar.gz');first_native=capsule(first,'native','native-before-first-run.tar.gz')
  require(len(first_artifacts)==1016 and len(first_native)==3,'cold artifact census')
  require(read(first/'headers-exit.txt')==b'0\n' and read(first/'build-exit.txt')==b'0\n','native preflight exit')
  banner=channel(first,'version','stdout')+channel(first,'version','stderr')
  version=re.search(rb'Lua ([0-9]+\.[0-9]+\.[0-9]+)' if host=='puc' else rb'LuaJIT ([0-9]+\.[0-9]+\.[0-9]+)',banner)
  require(version and version[1].decode()==channel(first,'headers','stdout').decode().splitlines()[0],'actual interpreter/header identity')
  for phase in phases:
   out=BASE/phase/host;stdout=channel(out,'normal','stdout');tag='ARRAY_CONCAT_LUA' if phase=='intake' else 'ARRAY_CONCAT_LUA_NORMAL'
   actual=frames(stdout,tag);compare(actual,cold if phase in ('intake','before','inverse') else expected)
   require(list(actual)==[r['id'] for r in cases],'actual case order')
   old_epoch=phase in ('before','inverse');require(read(out/'normal-exit.txt')==(b'1\n' if old_epoch else b'0\n'),'actual normal exit')
   require(channel(out,'normal','stderr')==b'' if not old_epoch else b'function_1_free_hash' in channel(out,'normal','stderr'),'actual SDK stderr')
   if phase!='intake': require(b'ARRAY_CONCAT_LUA_SUMMARY 3048 checks '+(b'96' if old_epoch else b'0')+b' failures\n' in stdout,'actual assertion summary')
   prefix=str(BASE/'control-owner')+'/' if phase in ('inverse','restored') else ''
   require(('ARRAY_CONCAT_LUA_OWNER @'+prefix+OWNER+'\n').encode() in stdout,'actual loaded owner')
   artifacts=capsule(out,'artifact','actual-emitted-parsed.tar.gz');natives=capsule(out,'native','native-before-first-run.tar.gz')
   require(len(artifacts)==1016 and len(natives)==3,'actual artifact census')
   for key in actual:
    for folder,suffix in (('parsed','.json'),('emitted','.lua')):
     compare_body=first_artifacts[str(first/folder/(key+suffix))]
     require(artifacts[str(out/folder/(key+suffix))]==compare_body,'actual product bytes')
   require({Path(k).name:v for k,v in natives.items()}=={Path(k).name:v for k,v in first_native.items()},'exact native reuse')
   native_rows=json.loads(read(out/'native-identities.json'));first_rows=json.loads(read(first/'native-identities.json'))
   require({Path(k).name:v for k,v in native_rows.items()}=={Path(k).name:v for k,v in first_rows.items()},'native mode reuse')
   command=json.loads(read(out/'normal-command.json'))
   require(command['cwd']=='.' and command['argv'][:2]==['bash','tools/project_data_run.sh'],'actual SDK command')
   require(command['environment']['LINKEDSPEC_ARRAY_CONCAT_CAPTURE']==str(out) and command['environment']['LINKEDSPEC_ARRAY_CONCAT_INPUT_ROOT']==prefix,'actual capture/input roots')
   require(command['environment']['LUA_CPATH']==str(out/'native/?.so')+';;','actual native path')
   for t in ('memory','version'): require(read(out/(t+'-exit.txt'))==b'0\n','preflight exit')
   require(channel(out,'version','stdout')==channel(first,'version','stdout') and channel(out,'version','stderr')==channel(first,'version','stderr'),'executable version')
   if phase=='intake':
    compare(frames(stdout,'ARRAY_CONCAT_LUA_INPUT'),{k:json.loads(artifacts[str(out/'parsed'/(k+'.json'))]) for k in actual})
   if phase=='direct':
    for name,count in (('CALLABLE_TRANSFORM_LUA',1872),('ARRAY_TRANSFORM_LUA',903),('CALLABLE_PIPELINE_LUA',1164)):
     require((name+'_SUMMARY '+str(count)+' checks 0 failures\n').encode() in stdout,'direct dependent summary')
    for tag,path in (('CALLABLE_TRANSFORM_LUA',LEGACY),('ARRAY_TRANSFORM_LUA',ORDINARY),('CALLABLE_PIPELINE_LUA','tests/fixtures/array_pipeline_callable_result_guard_lua_profiles.json')):
     rows=frames(stdout,tag+'_NORMAL');p=json.loads(allroots[phase][path])[host]
     for key,profile in p.items(): compare(rows[key],{r:profile[r] for r in ROUTES})
  last_expected,last_cold=expected,cold
 for tag in ('prepare','intake','inspect-intake','freeze-policy','prepare-checks','before','check-before','repair','after','check-after','inverse','check-inverse','restored','check-restored','direct','check-direct','prepare-review'):
  out=BASE/'launches'/tag
  require(read(out/'exit.txt')==b'0\n' and gzip.decompress(read(out/'stderr.log.gz'))==b'','completed launch')
  images=unpack(read(out/'inputs.tar.gz'),json.loads(read(out/'identities.json')))
  command=json.loads(read(out/'command.json'))
  require(command['cwd']=='.' and command['argv'][:2]==['bash','tools/project_data_run.sh'],'launch command')
  used=next(a for a in command['argv'] if a.startswith(str(BASE)+'/') and a.endswith('.py'))
  require(used in images and str(BASE/'run_stage.py') in images,'delegated producer custody')
 def reject(label,operation,reason):
  try: operation()
  except (AssertionError,KeyError) as failure: require(reason in str(failure),'RED reason:'+label)
  else: raise AssertionError('corruption accepted:'+label)
  controls.append(label)
 def alter(label,mutate):
  changed=copy.deepcopy(last_expected);mutate(changed);reject(label,lambda:compare(changed,last_expected),'complete route records')
 alter('Hash operand leak',lambda x:x['function_1_free_hash']['native']['value'].__setitem__(1,'SK'))
 alter('later-body restart',lambda x:x['function_3_free_later']['fresh']['value'].__setitem__(0,'ran'))
 nested=next(r['id'] for r in cases if r['origin']=='questions108' and r.get('question')=='nested-kinds')
 require(last_expected[nested]['native']['value'][2] is False,'Boolean control precondition')
 alter('Boolean Number collapse',lambda x:x[nested]['native']['value'].__setitem__(2,0))
 error=next(k for k,r in last_expected.items() if 'error_json' in r['native'])
 alter('lost public JSON',lambda x:x[error]['native'].pop('error_json'))
 alter('wrong source identity',lambda x:x[error]['fresh']['error_json'].__setitem__('source_identity','wrong.spec'))
 alter('invented absent field',lambda x:x[error]['native'].__setitem__('actual_arity',None))
 alter('missing route',lambda x:x['function_1_free_hash'].pop('fresh'))
 changed=copy.deepcopy(last_cold);changed.pop('ordinary_1_free_terminal');reject('missing terminal',lambda:oracle.semantic_oracle(cases,changed),'program census')
 changed=copy.deepcopy(cases);changed[0]['expected']=None;reject('peer verdict',lambda:oracle.semantic_oracle(changed,last_cold),'source-only questions')
 rows=json.loads(read(BASE/'repair-run/after.json'));rows[OWNER]['mode']^=0o100
 reject('archived mode',lambda:unpack(read(BASE/'repair-run/after.tar.gz'),rows),'archive full modes')
 rows=json.loads(read(BASE/'repair-run/after.json'));rows[OWNER]['sha256']='0'*64
 reject('archived body digest',lambda:unpack(read(BASE/'repair-run/after.tar.gz'),rows),'archive bytes')
 print(json.dumps(dict(historical_recovery='PASS',hosts=2,programs_per_host=508,routes=4,supported_per_host=20,separate_compatibility_per_host=4,preserved_per_host=484,parsed_emitted_pairs_per_host=3048,direct_checks_per_host=6987,reason_sensitive_controls=controls,limits='Historical finite authored proof/full available published JSON-text/outer flags and absent fields only; no current-code freshness/full raw table/native-cache-transitive-toolchain-OS4.2/SESSION5/declared5.4/full admission. Operational telemetry has own30/4.2 gaps.')))
if __name__=='__main__': main()
