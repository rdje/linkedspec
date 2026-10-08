"""Retain the second rejected candidate and diagnose original live book inputs."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3'
PREFIX = 'docs/checkpoints/'+LEAF+'-'
BASE = 'eb6d0d6ea7b88d13ebe669a507b3126d7508c0eb'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
def sha(raw): return hashlib.sha256(raw).hexdigest()
def envelope(raw): return {'base64':base64.b64encode(raw).decode(), 'bytes':len(raw), 'sha256':sha(raw)}
def git(*args): return subprocess.check_output(['git',*args],cwd=ROOT)

assert git('rev-parse','HEAD').decode().strip() == BASE
assert git('diff','--binary') == b''
target = ROOT/(PREFIX+'workflow-claim-rejected.json')
assert not target.exists(), 'one-shot original candidate retention'
stage = git('ls-files','--stage','-z')
patch = git('diff','--cached','--binary','--full-index')
graph, excluded, originals = [], [], []
batch = subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
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
        if path.startswith('docs/claims/') and path.endswith('.json'):
            record = json.loads(raw)
            for claim in record['claims']:
                durable = claim['durability']
                if durable.get('mode') != 'live': continue
                inputs = durable.get('inputs',[])
                matches = [item for item in inputs if item['path'] == BOOK]
                if matches and matches[0]['sha256'] != sha((ROOT/BOOK).read_bytes()):
                    assert raw == git('show',BASE+':'+path), 'previous claim unchanged at clean source'
                    for item in inputs:
                        assert sha(git('show',BASE+':'+item['path'])) == item['sha256'], 'original committed input '+item['path']
                    originals.append({'path':path,'claim_name':claim['name'],'original_record':envelope(raw),
                                      'inputs_verified_at_base':len(inputs),'original_book_sha256':matches[0]['sha256']})
finally:
    batch.stdin.close(); batch.stdout.close(); assert batch.wait() == 0
assert {item['path'] for item in excluded} == {'rgx'}
assert originals, 'actual stale prior book owner required'
entries = {item['path']:item for item in graph}
claim_path = 'docs/claims/'+LEAF+'.json'
candidate = git('show',':'+claim_path)
for item in json.loads(candidate)['claims'][0]['durability']['inputs']:
    assert entries[item['path']]['sha256'] == item['sha256'], 'rejected guard claim input exact'
log = (ROOT/'.linkedspec-data/logs/accepted-state-canonical-corrected.log').read_bytes()
assert b'stale input: '+BOOK.encode() in log and b'FAIL  CLAIM-VERIFICATION' in log
assert log.count(b'  PASS  ') == 9 and log.count(b'  FAIL  ') == 1
result = {'complete':True,'base':BASE,'producer_sha256':sha(Path(__file__).read_bytes()),
          'regular_input_graph':graph,'excluded_metadata_only':excluded,'stage_metadata_sha256':sha(stage),
          'staged_patch':{'encoding':'gzip+base64','compressed':envelope(gzip.compress(patch,compresslevel=9,mtime=0)),
                          'raw_bytes':len(patch),'raw_sha256':sha(patch)},
          'rejected_guard_claim':envelope(candidate),'rejected_guard_inputs':72,'stale_prior_claims':originals,
          'current_book_sha256':sha((ROOT/BOOK).read_bytes()),'actual_canonical_combined_log':envelope(log),
          'canonical_exit_code':1,
          'scope':'Second exact staged candidate is unadmitted. Full regular Git graph and binary delta recover all72 current guard inputs and its live-form record; submodule metadata only. All affected older live claim inputs verify individually at reachable clean eb6 before any mode/revision repair. Actual canonical combined log rejects only CLAIM-VERIFICATION, with nine other doctrines passing. Before-CI fingerprint and distinct stdout/stderr were not independently retained. No original hash, measurement, channel, source or policy refresh; independent staged recovery and mode/revision-only verification remain required.'}
assert patch == git('diff','--cached','--binary','--full-index') and stage == git('ls-files','--stage','-z')
assert git('diff','--binary') == b''
target.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'complete':True,'regular_inputs':len(graph),'stale_claims':[
    {'path':item['path'],'inputs':item['inputs_verified_at_base']} for item in originals]}))
