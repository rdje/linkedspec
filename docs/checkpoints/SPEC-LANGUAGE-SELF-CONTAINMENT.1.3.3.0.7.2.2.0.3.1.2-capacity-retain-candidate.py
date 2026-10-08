"""Retain the complete initial staged input graph and rerun its actual routing RED."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2-'
REVISION = '47444428a8ceb65cb0ced06625db4eb8a44b8209'

def git(*args):
    return subprocess.check_output(['git',*args],cwd=ROOT)

def sha(raw):
    return hashlib.sha256(raw).hexdigest()

def channel(raw):
    return {'base64':base64.b64encode(raw).decode(),'bytes':len(raw),'sha256':sha(raw)}

assert git('rev-parse','HEAD').decode().strip() == REVISION
assert subprocess.run(['git','diff','--quiet','--'],cwd=ROOT).returncode == 0, 'initial candidate fully staged'
patch = git('diff','--cached','--binary','--full-index')
assert patch, 'actual staged delta'
patch_path = PREFIX+'capacity-initial-staged.patch.gz'
assert not (ROOT/patch_path).exists()
(ROOT/patch_path).write_bytes(gzip.compress(patch,mtime=0))
entries=[]; excluded=[]
for record in git('ls-files','--stage','-z').split(b'\0'):
    if not record: continue
    metadata,path=record.split(b'\t',1)
    mode,object_id,stage=metadata.decode().split()
    assert stage == '0', 'no unresolved index entry'
    name=path.decode()
    if mode not in ('100644','100755'):
        excluded.append({'path':name,'mode':mode,'payload_inspected':False})
        continue
    entries.append({'path':name,'mode':mode,'object_id':object_id})
ids=list(dict.fromkeys(item['object_id'] for item in entries))
checked=subprocess.check_output(['git','cat-file','--batch-check=%(objectname) %(objecttype) %(objectsize)'],
    cwd=ROOT,input=('\n'.join(ids)+'\n').encode()).decode().splitlines()
sizes={}
for line in checked:
    object_id,kind,size=line.split()
    assert kind == 'blob'
    sizes[object_id]=int(size)
for entry in entries: entry['bytes']=sizes[entry['object_id']]
manifest={'complete':True,'base_revision':REVISION,'entries':entries,'excluded_metadata_only':excluded,
          'staged_patch':{'path':patch_path,'raw_bytes':len(patch),'raw_sha256':sha(patch),
                          'compressed_sha256':sha((ROOT/patch_path).read_bytes())},
          'producer_sha256':sha(Path(__file__).read_bytes()),
          'scope':'Complete regular staged Git superset, not minimal IO. Reachable base commit supplies unchanged objects; full-index binary patch retains every changed/new staged byte including the initial78-input claim and seven continuity guard inputs it omitted. Gitlinks/nonregular payload excluded without inspection. SHA-1 object identities, regular modes and sizes are explicit; staged delta has SHA-256 and compressed recovery. Initial candidate is unadmitted.'}
manifest_path=PREFIX+'capacity-initial-staged-inputs.json'
(ROOT/manifest_path).write_text(json.dumps(manifest,indent=2)+'\n')
original_log=(ROOT/'.linkedspec-data/logs/replacement-note-capacity-routing.log').read_bytes()
assert b'surface decisions exceeds control: files 129/128' in original_log
assert b'surface decisions exceeds control: aggregate lines 13035/13000' in original_log
before={'patch_sha256':sha(git('diff','--cached','--binary','--full-index')),
        'worktree_matches_index':subprocess.run(['git','diff','--quiet','--'],cwd=ROOT).returncode == 0,
        'producer_sha256':sha(Path(__file__).read_bytes())}
args=['bash','scripts/check_readme_stability.sh']
process=subprocess.run(args,cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
after={'patch_sha256':sha(git('diff','--cached','--binary','--full-index')),
       'worktree_matches_index':subprocess.run(['git','diff','--quiet','--'],cwd=ROOT).returncode == 0,
       'producer_sha256':sha(Path(__file__).read_bytes())}
result={'complete':True,'revision':REVISION,'args':args,'exit_code':process.returncode,
        'stdout':channel(process.stdout),'stderr':channel(process.stderr),
        'input_boundary_before':before,'input_boundary_after':after,
        'initial_staged_inputs':{'path':manifest_path,'sha256':sha((ROOT/manifest_path).read_bytes())},
        'original_first_combined_log':channel(original_log),
        'scope':'Actual complete guarded recurrence of the rejected initial staged candidate. Original first combined log is retained separately; its before fingerprint was not independently recorded. Complete regular staged inputs recover from reachable base plus exact binary patch; no accepted record or producer is refreshed.'}
(ROOT/(PREFIX+'capacity-routing-red.json')).write_text(json.dumps(result,indent=2)+'\n')
assert before == after and before['worktree_matches_index'], 'complete staged input boundary unchanged'
assert process.returncode == 1, 'actual resulting-tree routing RED'
failures=[line for line in (process.stdout+process.stderr).decode().splitlines() if line.startswith('[readme-routing] FAIL:')]
assert failures == ['[readme-routing] FAIL: surface decisions exceeds control: files 129/128',
                    '[readme-routing] FAIL: surface decisions exceeds control: aggregate lines 13035/13000'], 'exact independent two-control decision pressure'
print(json.dumps({'complete':True,'regular_staged_inputs':len(entries),'actual_routing_red':failures,'patch_bytes':len(patch)}))
