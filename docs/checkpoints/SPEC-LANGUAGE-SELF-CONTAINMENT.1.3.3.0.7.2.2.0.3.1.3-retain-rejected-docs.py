"""Preserve the complete rejected staged candidate before routing its book explanation."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3-'
CLAIM = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3.json'
BASE = 'eb6d0d6ea7b88d13ebe669a507b3126d7508c0eb'
BOOK = 'docs/linkedspec-book/src/development/local-ci-and-regression.md'
def sha(raw): return hashlib.sha256(raw).hexdigest()
def envelope(raw): return {'base64':base64.b64encode(raw).decode(),'bytes':len(raw),'sha256':sha(raw)}
def git(*args): return subprocess.check_output(['git',*args],cwd=ROOT)

assert git('rev-parse','HEAD').decode().strip() == BASE
assert git('diff','--binary') == b'', 'original staged/worktree agreement before retention'
patch = git('diff','--cached','--binary','--full-index')
assert patch
claim_raw = git('show',':'+CLAIM)
initial = json.loads(claim_raw)
publisher_raw = git('show',':'+PREFIX+'publish.py')
assert not (ROOT/(PREFIX+'initial-claim.json')).exists(), 'one-shot original candidate retention'
(ROOT/(PREFIX+'initial-claim.json')).write_bytes(claim_raw)
(ROOT/(PREFIX+'publish-initial.py')).write_bytes(publisher_raw)
graph,excluded = [],[]
stage_raw = git('ls-files','--stage','-z')
batch = subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
try:
    for row in stage_raw.split(b'\0'):
        if not row: continue
        header,path = row.split(b'\t',1); mode,oid,stage = header.decode().split()
        assert stage == '0'
        if mode not in ('100644','100755'):
            excluded.append({'path':path.decode(),'mode':mode,'object_id':oid,'payload_inspected':False}); continue
        batch.stdin.write((oid+'\n').encode()); batch.stdin.flush()
        actual_oid,kind,size = batch.stdout.readline().split(); size = int(size)
        assert actual_oid.decode() == oid and kind == b'blob'
        raw = batch.stdout.read(size)
        assert len(raw) == size and batch.stdout.read(1) == b'\n'
        graph.append({'path':path.decode(),'mode':mode,'object_id':oid,'bytes':size,'sha256':sha(raw)})
finally:
    batch.stdin.close(); batch.stdout.close(); assert batch.wait() == 0
entries = {entry['path']:entry for entry in graph}
assert {row['path'] for row in excluded} == {'rgx'}
for claim in initial['claims']:
    for item in claim['durability']['inputs']:
        assert entries[item['path']]['sha256'] == item['sha256'], 'complete original claim input '+item['path']
book = git('show',':'+BOOK)
registry = git('show',':doctrine/readme_stability/routes.jsonl')
surface = next(row for row in map(json.loads,registry.splitlines()) if row.get('id') == 'diagnostics')
limit = surface['limits']['max_lines_per_file']
assert len(book.splitlines()) == 2064 and limit == 2048
log = (ROOT/'.linkedspec-data/logs/accepted-state-canonical.log').read_bytes()
assert b'lines 2064/2048' in log and b'FAIL  README-STABILITY' in log and b'doctrines: one or more doctrines FAILED' in log
assert log.count(b'  PASS  ') == 9 and log.count(b'  FAIL  ') == 1
compressed = gzip.compress(patch,compresslevel=9,mtime=0)
result = {'complete':True,'producer_sha256':sha(Path(__file__).read_bytes()),'base':BASE,
          'regular_input_graph':graph,'excluded_metadata_only':excluded,'stage_metadata_sha256':sha(stage_raw),
          'staged_patch':{'encoding':'gzip+base64','compressed':envelope(compressed),'raw_bytes':len(patch),'raw_sha256':sha(patch)},
          'initial_claim_path':PREFIX+'initial-claim.json','initial_claim_sha256':sha(claim_raw),
          'original_publisher_path':PREFIX+'publish-initial.py','original_publisher_sha256':sha(publisher_raw),
          'original_claim_inputs':len(initial['claims'][0]['durability']['inputs']),
          'actual_canonical_combined_log':envelope(log),'canonical_exit_code':1,
          'pressure':{'path':BOOK,'lines':len(book.splitlines()),'limit':limit,'source_sha256':sha(book)},
          'scope':'Complete original regular staged Git superset and recoverable full-index binary delta from reachable eb6; every original61 claim input matches. Retention occurs after the completed failed canonical gate and before any original candidate edit; the new owned retention producer is outside the original staged graph. Original before-CI fingerprint/distinct stdout-stderr are not independently retained; complete actual combined log rejects only the chapter line limit, with nine other doctrines passing. Initial claim/publication remains unadmitted, not falsely historical at eb6. No source/runtime/cap changes or submodule payload access; independent private-index recovery remains required.'}
assert patch == git('diff','--cached','--binary','--full-index') and stage_raw == git('ls-files','--stage','-z') and git('diff','--binary') == b''
(ROOT/(PREFIX+'rejected-docs.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'complete':True,'regular_inputs':len(graph),'original_claim_inputs':result['original_claim_inputs'],'chapter_lines':2064,'unchanged_limit':limit,'raw_patch_bytes':len(patch)}))
