"""Read-only committed control reconciliation; no runtime replay is claimed."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess
ROOT=Path(__file__).resolve().parents[2]
OWNER='SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.6'
BASE='fdc21053294bfed95a26444d9e072ce69f205587'
WHILE='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.5-'
PREFIX='docs/checkpoints/'+OWNER+'-'
def require(ok,message):
 if not ok: raise ValueError(message)
def digest(raw): return hashlib.sha256(raw).hexdigest()
def read(path): return (ROOT/path).read_bytes()
def blob(path): return subprocess.check_output(['git','show',BASE+':'+path],cwd=ROOT)
def check_inputs(inputs):
 require(len(inputs)==250,'input population')
 for path,expected in inputs.items():
  require(digest(read(path))==expected and read(path)==blob(path),'current committed input drift: '+path)
def check_tests(report):
 require(len(report['tests'])==len(report['logs'])==14,'suite population')
 counts=[]
 for test,log in zip(report['tests'],report['logs']):
  require(log['command']==['prove','-v','-Iperl',test['path']] and log['exit']==0,'suite command/exit')
  match=re.search(r'Files=1, Tests=(\d+),',log['stdout'])
  require(match and int(match.group(1))==test['tests'] and 'Result: PASS' in log['stdout'],'complete TAP/count')
  counts.append(test['tests'])
 require(sum(counts)==1014,'test total')
def main():
 report=json.loads(read(WHILE+'verification.json'))
 require(read(WHILE+'verification.json')==blob(WHILE+'verification.json'),'committed report drift')
 check_inputs(report['tracked_inputs']);check_tests(report)
 spec=importlib.util.spec_from_file_location('while_reviewer',ROOT/(WHILE+'review.py'))
 module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
 cases=json.loads(read(WHILE+'cases.json'));green=json.loads(read(WHILE+'green.json'));red=json.loads(read(WHILE+'red.json'))
 module.check(green,cases);module.check(red,cases,True)
 predecessor={}
 for suffix in ('5.0','5.1','5.2','5.3','5.4','5.5'):
  path='docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.'+suffix+'.json'
  claim=json.loads(read(path));durability=claim['claims'][0]['durability']
  require(durability['mode']=='historical','prior boundary must remain historical')
  original=json.loads(blob(path))
  # Only the immediately preceding live claim gains historical mode/revision.
  if suffix=='5.5':
   require(durability['revision']==BASE,'while historical boundary')
   original['claims'][0]['durability']['mode']='historical'
   original['claims'][0]['durability']['revision']=BASE
  require(claim==original,'prior claim result/hash drift')
  predecessor[path]={'revision':durability['revision'],'sha256':digest(read(path))}
 original=next(c for c in cases if c['id']=='original')
 successors={}
 for family,id in (('5.1','loop_excluded'),('5.2','while_excluded'),('5.3','while_excluded'),('5.4','while_excluded')):
  path='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.'+family+'-cases.json'
  old=next(c for c in json.loads(read(path)) if c['id']==id)
  require(old['source']==original['source'],'source-identical successor drift')
  successors[family]={'id':id,'source_sha256':digest(old['source'].encode()),'expected':original['expected']}
 controls=[]
 def reject(name,checker,value):
  try: checker(value)
  except ValueError as error: controls.append({'name':name,'reason':str(error)})
  else: raise ValueError('corruption accepted: '+name)
 bad=copy.deepcopy(report['tracked_inputs']);bad['perl/LinkedSpec/CodeblockRuntime.pm']='0'*64
 reject('runtime-input',check_inputs,bad)
 for name in ('count','exit','TAP'):
  bad=copy.deepcopy(report)
  if name=='count': bad['tests'][0]['tests']+=1
  elif name=='exit':bad['logs'][0]['exit']=1
  else:bad['logs'][0]['stdout']=bad['logs'][0]['stdout'].replace('Result: PASS','Result: FAIL')
  reject('retained-suite-'+name,check_tests,bad)
 for name in ('guard-count','caller-slot','source','local-return'):
  bad=copy.deepcopy(green);rows={r['id']:r for r in bad['cases']}
  if name=='guard-count':rows['guard_exhaustion']['fresh']['exception']['detail']['iterations_executed']=10001
  elif name=='caller-slot':rows['parameter_scope']['native']['invocations'][0]['x_same_actual_slot']=0
  elif name=='source':rows['original']['source']+=' changed'
  else:rows['eager_local']['fresh']['value']='inner'
  reject(name,lambda value:module.check(value,cases),bad)
 paths=set(report['tracked_inputs'])|set(predecessor)
 paths.update((WHILE+'verification.json',PREFIX+'review.py','tools/run_ci_local.sh','tools/verification_receipt.sh'))
 print(json.dumps({'owner':OWNER,'activation_commit':BASE,'runtime_replay':False,'current_input_count':250,'retained_suites':report['tests'],'retained_test_total':1014,'cases':30,'controls':controls,'predecessor_claims':predecessor,'source_identical_successors':successors,'tracked_inputs':{path:digest(read(path)) for path in sorted(paths)},'limits':'Exact committed input/evidence reconciliation and corruption controls only; prior runtime/TAP/native execution is reused, not rerun or newly claimed. Exact staged canonical gate/receipt independently governs parent acceptance. No all-statement/helper/function/next/numeric/literal/readiness/full16 or backend closure.'},indent=2,sort_keys=True))
if __name__=='__main__':main()
