"""Recover the second rejected candidate and independently verify historical qualification."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import json
import os
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3-'
CLAIM = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3.json'
REVISION = '864b1a93934ab7fd4b059b0a7cb9d4b417e33c66'
def sha(raw): return hashlib.sha256(raw).hexdigest()
def read(path): return (ROOT/path).read_bytes()
def data(name): return json.loads(read(PREFIX+name+'.json'))
def channel(item):
    raw = base64.b64decode(item['base64'],validate=True)
    assert item == {'base64':base64.b64encode(raw).decode(),'bytes':len(raw),'sha256':sha(raw)}, 'complete byte channel'
    return raw

snapshot = data('workflow-claim-rejected'); freeze = data('workflow-claim-freeze')
assert snapshot['complete'] and freeze['complete']
patch = gzip.decompress(channel(snapshot['staged_patch']['compressed']))
assert len(patch) == snapshot['staged_patch']['raw_bytes'] and sha(patch) == snapshot['staged_patch']['raw_sha256']
objects = Path(subprocess.check_output(['git','rev-parse','--git-path','objects'],cwd=ROOT).decode().strip())
if not objects.is_absolute(): objects = ROOT/objects
scratch = ROOT/'.linkedspec-data/scratch/accepted-state-workflow-claim-recovery'
scratch.mkdir(parents=True,exist_ok=True)
assert scratch.stat().st_dev == objects.stat().st_dev == ROOT.stat().st_dev
graph, excluded, recovered = [], [], {}
with tempfile.TemporaryDirectory(dir=scratch,prefix='index.') as temporary:
    tree = Path(temporary); metadata = tree/'.git'
    (metadata/'objects').mkdir(parents=True); (metadata/'refs').mkdir()
    (metadata/'HEAD').write_text(snapshot['base']+'\n')
    (metadata/'config').write_text('[core]\n\trepositoryformatversion = 0\n\tbare = false\n\tfsmonitor = false\n')
    env = {key:value for key,value in os.environ.items() if not key.startswith('GIT_')}
    env.update(GIT_DIR=str(metadata),GIT_WORK_TREE=str(tree),GIT_INDEX_FILE=str(metadata/'index'),
               GIT_OBJECT_DIRECTORY=str(metadata/'objects'),GIT_ALTERNATE_OBJECT_DIRECTORIES=str(objects.resolve()),GIT_OPTIONAL_LOCKS='0')
    def git(*args,raw=None):
        process = subprocess.run(['git','-c','core.fsmonitor=false',*args],cwd=tree,env=env,input=raw,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        assert process.returncode == 0 and process.stderr == b'', 'private Git recovery '+str(args)+': '+process.stderr.decode(errors='replace')
        return process.stdout
    git('read-tree',snapshot['base']); git('apply','--cached','--binary','--whitespace=nowarn','-',raw=patch)
    assert git('diff','--cached','--binary','--full-index') == patch
    stage = git('ls-files','--stage','-z'); assert sha(stage) == snapshot['stage_metadata_sha256']
    wanted = {CLAIM,freeze['path']}
    batch = subprocess.Popen(['git','cat-file','--batch'],cwd=tree,env=env,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
    try:
        for row in stage.split(b'\0'):
            if not row: continue
            header,path = row.split(b'\t',1); mode,oid,number = header.decode().split()
            path = path.decode(); assert number == '0'
            if mode not in ('100644','100755'):
                excluded.append({'path':path,'mode':mode,'object_id':oid,'payload_inspected':False}); continue
            batch.stdin.write((oid+'\n').encode()); batch.stdin.flush()
            actual,kind,size = batch.stdout.readline().split(); size = int(size)
            assert actual.decode() == oid and kind == b'blob'
            raw = batch.stdout.read(size); assert len(raw) == size and batch.stdout.read(1) == b'\n'
            graph.append({'path':path,'mode':mode,'object_id':oid,'bytes':size,'sha256':sha(raw)})
            if path in wanted: recovered[path] = raw
    finally:
        batch.stdin.close(); batch.stdout.close(); assert batch.wait() == 0

original = snapshot['stale_prior_claims'][0]
assert len(snapshot['stale_prior_claims']) == 1 and original['path'] == freeze['path']
assert recovered[freeze['path']] == channel(original['original_record'])
original_record = json.loads(recovered[freeze['path']])
for item in original_record['claims'][0]['durability']['inputs']:
    raw = subprocess.check_output(['git','show',REVISION+':'+item['path']],cwd=ROOT)
    assert sha(raw) == item['sha256'], 'all original cleanup inputs at exact owning commit'
assert subprocess.check_output(['git','show',REVISION+':'+freeze['path']],cwd=ROOT) == recovered[freeze['path']]
frozen = json.loads(read(freeze['path']))

def check_snapshot(candidate):
    assert candidate['producer_sha256'] == sha(read(PREFIX+'retain-workflow-claim.py')), 'actual retention producer'
    assert candidate['regular_input_graph'] == graph and candidate['excluded_metadata_only'] == excluded, 'complete original staged graph'
    assert channel(candidate['rejected_guard_claim']) == recovered[CLAIM], 'original unadmitted guard record'
    inputs = json.loads(recovered[CLAIM])['claims'][0]['durability']['inputs']
    assert len(inputs) == candidate['rejected_guard_inputs'] == 72, 'all rejected guard inputs'
    entries = {entry['path']:entry for entry in graph}
    for item in inputs: assert entries[item['path']]['sha256'] == item['sha256'], 'original72 guard hash'
    log = channel(candidate['actual_canonical_combined_log'])
    assert candidate['canonical_exit_code'] == 1 and b'FAIL  CLAIM-VERIFICATION' in log, 'actual rejected canonical status'
    assert b'stale input: docs/linkedspec-book/src/development/documentation-workflow.md' in log
    assert log.count(b'  PASS  ') == 9 and log.count(b'  FAIL  ') == 1

def check_freeze(candidate):
    inverse = copy.deepcopy(candidate)
    durable = inverse['claims'][0]['durability']
    assert durable['mode'] == 'historical' and durable['revision'] == REVISION, 'exact owning historical boundary'
    durable['mode'] = 'live'; del durable['revision']
    assert inverse == original_record, 'only durability mode/revision may change'
    assert freeze['producer_sha256'] == sha(read(PREFIX+'freeze-workflow-claim.py'))
    assert freeze['original_inputs_verified'] == original['inputs_verified_at_base'] == 21
    assert freeze['original_sha256'] == sha(recovered[freeze['path']]) and freeze['frozen_sha256'] == sha(read(freeze['path']))

check_snapshot(snapshot); check_freeze(frozen)
controls = []
mutations = [('lost_graph_entry','snapshot',lambda value:value['regular_input_graph'].pop()),
             ('forged_retention_source','snapshot',lambda value:value.update(producer_sha256='0'*64)),
             ('forged_success','snapshot',lambda value:value.update(canonical_exit_code=0)),
             ('lost_claim_input','snapshot',lambda value:value.update(rejected_guard_inputs=71)),
             ('wrong_historical_revision','freeze',lambda value:value['claims'][0]['durability'].update(revision=snapshot['base'])),
             ('refreshed_original_hash','freeze',lambda value:value['claims'][0]['durability']['inputs'][0].update(sha256='0'*64)),
             ('changed_measurement','freeze',lambda value:value['claims'][0].update(statement='refreshed measurement'))]
for name,kind,mutate in mutations:
    candidate = copy.deepcopy(snapshot if kind == 'snapshot' else frozen); mutate(candidate)
    try: (check_snapshot if kind == 'snapshot' else check_freeze)(candidate)
    except AssertionError as failure: controls.append({'name':name,'observed_red':str(failure)})
    else: raise AssertionError('ineffective historical preservation control '+name)
result = {'complete':True,'producer_sha256':sha(Path(__file__).read_bytes()),'recovered_regular_inputs':len(graph),
          'rejected_guard_inputs_recovered':72,'original_cleanup_inputs_verified':21,'original_cleanup_revision':REVISION,
          'preservation_red_controls':controls,
          'scope':'Independent private-index recovery reproduces the complete second rejected staged graph, exact binary delta/metadata and all72 guard input hashes. The unadmitted record remains retained verbatim; it is not historical at eb6. Older dated cleanup evidence verifies all21 original input hashes at its exact owning commit and changes mode/revision only. Seven content-sensitive historical/evidence corruptions reject. No original measurement/source/channel/hash refresh, cleanup rerun, new runtime evidence or canonical admission claim.'}
(ROOT/(PREFIX+'workflow-claim-verification.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
