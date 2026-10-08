"""Recover the complete rejected staged graph in an isolated project-local Git index."""
from pathlib import Path
import ast
import base64
import copy
import gzip
import hashlib
import json
import os
import subprocess
import tempfile

ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2-'
REVISION='47444428a8ceb65cb0ced06625db4eb8a44b8209'
def sha(raw): return hashlib.sha256(raw).hexdigest()
manifest=json.loads((ROOT/(PREFIX+'capacity-initial-staged-inputs.json')).read_bytes())
red=json.loads((ROOT/(PREFIX+'capacity-routing-red.json')).read_bytes())
patch=gzip.decompress((ROOT/manifest['staged_patch']['path']).read_bytes())
assert sha(patch)==manifest['staged_patch']['raw_sha256'] and len(patch)==manifest['staged_patch']['raw_bytes']
assert sha((ROOT/manifest['staged_patch']['path']).read_bytes())==manifest['staged_patch']['compressed_sha256']
assert red['complete'] and red['exit_code']==1 and red['input_boundary_before']==red['input_boundary_after']
assert red['input_boundary_before']['patch_sha256']==sha(patch)
assert red['initial_staged_inputs']['sha256']==sha((ROOT/(PREFIX+'capacity-initial-staged-inputs.json')).read_bytes())
for name in ('stdout','stderr'):
 raw=base64.b64decode(red[name]['base64'],validate=True)
 assert len(raw)==red[name]['bytes'] and sha(raw)==red[name]['sha256']
source_objects=subprocess.check_output(['git','rev-parse','--git-path','objects'],cwd=ROOT).decode().strip()
objects=Path(source_objects)
if not objects.is_absolute(): objects=ROOT/objects
objects=objects.resolve()
assert objects.stat().st_dev==ROOT.stat().st_dev, 'read-only original objects on repository volume'
scratch=ROOT/'.linkedspec-data/scratch/capacity-snapshot-review'
scratch.mkdir(parents=True,exist_ok=True)
assert scratch.resolve().stat().st_dev==ROOT.stat().st_dev

commands=[]
def recover(value,record_commands=False):
 with tempfile.TemporaryDirectory(prefix='index.',dir=scratch) as temporary:
  workspace=Path(temporary);(workspace/'objects').mkdir()
  env=dict(os.environ)
  env.update(GIT_INDEX_FILE=str(workspace/'index'),GIT_OBJECT_DIRECTORY=str(workspace/'objects'),
             GIT_ALTERNATE_OBJECT_DIRECTORIES=str(objects),GIT_OPTIONAL_LOCKS='0')
  def git(*args,input_bytes=None):
   command=['git','-c','core.fsmonitor=false',*args]
   process=subprocess.run(command,cwd=ROOT,env=env,input=input_bytes,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
   if record_commands:
    commands.append({'args':command,'exit_code':process.returncode,
                     'stdout_bytes':len(process.stdout),'stdout_sha256':sha(process.stdout),
                     'stderr_base64':base64.b64encode(process.stderr).decode(),'stderr_sha256':sha(process.stderr)})
   assert process.returncode==0, 'actual isolated Git recovery command: '+str(args)
   return process.stdout
  git('read-tree',REVISION)
  git('apply','--cached','--binary','--whitespace=nowarn',input_bytes=value['patch'])
  entries=[]
  for raw in git('ls-files','--stage','-z').split(b'\0'):
   if not raw:continue
   metadata,path=raw.split(b'\t',1);mode,oid,stage=metadata.decode().split()
   assert stage=='0'
   if mode not in ('100644','100755'):continue
   entries.append({'path':path.decode(),'mode':mode,'object_id':oid})
  ids=list(dict.fromkeys(row['object_id'] for row in entries))
  lines=git('cat-file','--batch-check=%(objectname) %(objecttype) %(objectsize)',input_bytes=('\n'.join(ids)+'\n').encode()).decode().splitlines()
  sizes={}
  for line in lines:
   oid,kind,size=line.split();assert kind=='blob';sizes[oid]=int(size)
  for entry in entries:entry['bytes']=sizes[entry['object_id']]
  assert entries==value['manifest']['entries'], 'complete original regular graph object/mode/size identity'
  def blob(path):return git('show',':'+path)
  initial_claim=blob('docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2.json')
  assert initial_claim==(ROOT/(PREFIX+'capacity-initial-claim.json')).read_bytes(), 'exact original unadmitted claim'
  inputs=json.loads(initial_claim)['claims'][0]['durability']['inputs']
  assert len(inputs)==78, 'original declared selection'
  for row in inputs:
   assert sha(blob(row['path']))==row['sha256'], 'all original declared input bytes'
  publication=json.loads(blob(PREFIX+'capacity-publication-verification.json'))
  publisher=ast.parse(blob(PREFIX+'capacity-publish-claim.py'))
  constants={}
  expected_guard=None
  for node in publisher.body:
   if not isinstance(node,ast.Assign) or len(node.targets)!=1 or not isinstance(node.targets[0],ast.Name):continue
   name=node.targets[0].id
   if isinstance(node.value,ast.Constant) and isinstance(node.value.value,str):constants[name]=node.value.value
   if name=='guarded':
    assert isinstance(node.value,ast.List)
    expected_guard=[constants[item.id] if isinstance(item,ast.Name) else ast.literal_eval(item) for item in node.value.elts]
  assert expected_guard and set(publication['guarded_document_inputs'])==set(expected_guard), 'complete actual publisher guard input population'
  assert publication['producer_sha256']==sha(blob(PREFIX+'capacity-publish-claim.py'))
  for path in expected_guard:
   assert sha(blob(path))==publication['guarded_document_inputs'][path], 'all actual guarded continuity input bytes'
  declared={row['path'] for row in inputs}
  omitted=sorted(set(expected_guard)-declared)
  assert omitted==['CHANGES.md','LIVE_ACHIEVEMENT_STATUS.md','MEMORY.md','ROADMAP.md','ROADMAP_V2.md','docs/TASK_TREE.md','docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'], 'seven previously omitted inputs now fully recoverable'
  return {'regular_inputs':len(entries),'declared_inputs_recovered':len(inputs),'omitted_guard_inputs_recovered':omitted}

observed={'manifest':manifest,'patch':patch}
proof=recover(observed,True)
controls=[]
for name in ('missing_regular_input','wrong_object','wrong_mode','changed_patch'):
 bad=copy.deepcopy(observed)
 if name=='missing_regular_input':bad['manifest']['entries'].pop()
 elif name=='wrong_object':bad['manifest']['entries'][0]['object_id']='0'*40
 elif name=='wrong_mode':bad['manifest']['entries'][0]['mode']='100755' if bad['manifest']['entries'][0]['mode']=='100644' else '100644'
 else:
  assert b'new file mode 100644' in bad['patch']
  bad['patch']=bad['patch'].replace(b'new file mode 100644',b'new file mode 100755',1)
 try:recover(bad)
 except AssertionError as error:controls.append({'name':name,'observed_red':str(error)})
 else:raise AssertionError('snapshot corruption admitted: '+name)
result={'complete':True,'revision':REVISION,'producer_sha256':sha(Path(__file__).read_bytes()),
        'recovery':proof,'controls':controls,'actual_recovery_commands':commands,
        'scope':'Actual isolated project-local alternate-index/object-store recovery of every regular staged input from reachable base and exact patch. No original index/object/branch write, no other repository or excluded payload inspection. All78 declared inputs and seven omitted actual continuity guards recover byte-exactly. Four distinguishing graph/patch controls reject. Original candidate remains unadmitted; actual routing RED channels retain complete bytes.'}
(ROOT/(PREFIX+'capacity-snapshot-verification.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'complete':True,**proof,'snapshot_red':len(controls)}))
