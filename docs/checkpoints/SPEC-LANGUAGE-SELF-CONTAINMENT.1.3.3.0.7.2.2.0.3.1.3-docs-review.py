"""Independently recover the rejected candidate and verify lossless book routing."""
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
CI = 'docs/linkedspec-book/src/development/local-ci-and-regression.md'
WORKFLOW = 'docs/linkedspec-book/src/development/documentation-workflow.md'
CLAIM = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3.json'
BASE = 'eb6d0d6ea7b88d13ebe669a507b3126d7508c0eb'
def sha(raw): return hashlib.sha256(raw).hexdigest()
def read(path): return (ROOT/path).read_bytes()
def data(name): return json.loads(read(PREFIX+name+'.json'))
def channel(item):
    raw = base64.b64decode(item['base64'],validate=True)
    assert item == {'base64':base64.b64encode(raw).decode(),'bytes':len(raw),'sha256':sha(raw)}
    return raw

snapshot = data('rejected-docs')
routing = data('book-routing')
assert snapshot['complete'] and routing['complete'] and snapshot['base'] == BASE
assert snapshot['producer_sha256'] == sha(read(PREFIX+'retain-rejected-docs.py')) and routing['producer_sha256'] == sha(read(PREFIX+'route-book.py'))
patch = gzip.decompress(channel(snapshot['staged_patch']['compressed']))
assert len(patch) == snapshot['staged_patch']['raw_bytes'] and sha(patch) == snapshot['staged_patch']['raw_sha256']
assert snapshot['staged_patch']['encoding'] == 'gzip+base64'
objects = Path(subprocess.check_output(['git','rev-parse','--git-path','objects'],cwd=ROOT).decode().strip())
if not objects.is_absolute(): objects = ROOT/objects
scratch = ROOT/'.linkedspec-data/scratch/accepted-state-doc-recovery'
scratch.mkdir(parents=True,exist_ok=True)
assert scratch.stat().st_dev == objects.stat().st_dev == ROOT.stat().st_dev
recovered = {}
with tempfile.TemporaryDirectory(dir=scratch,prefix='index.') as temporary:
    tree = Path(temporary); metadata = tree/'.git'
    (metadata/'objects').mkdir(parents=True); (metadata/'refs').mkdir()
    (metadata/'HEAD').write_text(BASE+'\n')
    (metadata/'config').write_text('[core]\n\trepositoryformatversion = 0\n\tbare = false\n\tfsmonitor = false\n')
    env = {k:v for k,v in os.environ.items() if not k.startswith('GIT_')}
    env.update(GIT_DIR=str(metadata),GIT_WORK_TREE=str(tree),GIT_INDEX_FILE=str(metadata/'index'),
               GIT_OBJECT_DIRECTORY=str(metadata/'objects'),GIT_ALTERNATE_OBJECT_DIRECTORIES=str(objects.resolve()),GIT_OPTIONAL_LOCKS='0')
    def git(*args,raw=None):
        process = subprocess.run(['git','-c','core.fsmonitor=false',*args],cwd=tree,env=env,input=raw,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
        assert process.returncode == 0 and process.stderr == b'', 'actual private snapshot recovery '+str(args)+': '+process.stderr.decode(errors='replace')
        return process.stdout
    git('read-tree',BASE)
    git('apply','--cached','--binary','--whitespace=nowarn','-',raw=patch)
    assert git('diff','--cached','--binary','--full-index') == patch, 'complete original binary staged delta'
    stage_raw = git('ls-files','--stage','-z')
    assert sha(stage_raw) == snapshot['stage_metadata_sha256']
    graph,excluded = [],[]
    expected = {entry['path']:entry for entry in snapshot['regular_input_graph']}
    for row in stage_raw.split(b'\0'):
        if not row: continue
        header,path = row.split(b'\t',1); mode,oid,stage = header.decode().split()
        assert stage == '0'
        path = path.decode()
        if mode not in ('100644','100755'):
            excluded.append({'path':path,'mode':mode,'object_id':oid,'payload_inspected':False}); continue
        raw = git('cat-file','blob',oid)
        entry = {'path':path,'mode':mode,'object_id':oid,'bytes':len(raw),'sha256':sha(raw)}
        assert entry == expected[path], 'exact recovered original regular input '+path
        graph.append(entry)
        if path in (CI,WORKFLOW,CLAIM,PREFIX+'publish.py'): recovered[path] = raw
    assert graph == snapshot['regular_input_graph'] and excluded == snapshot['excluded_metadata_only'], 'complete original graph membership'
assert recovered[CLAIM] == read(PREFIX+'initial-claim.json') and sha(recovered[CLAIM]) == snapshot['initial_claim_sha256']
assert recovered[PREFIX+'publish.py'] == read(PREFIX+'publish-initial.py') and sha(recovered[PREFIX+'publish.py']) == snapshot['original_publisher_sha256']
original_claim = json.loads(recovered[CLAIM])
items = original_claim['claims'][0]['durability']['inputs']
assert len(items) == snapshot['original_claim_inputs'] == 61
for item in items: assert expected[item['path']]['sha256'] == item['sha256'], 'all original61 artifact inputs recover'
log = channel(snapshot['actual_canonical_combined_log'])
assert snapshot['canonical_exit_code'] == 1 and b'lines 2064/2048' in log and log.count(b'  PASS  ') == 9 and log.count(b'  FAIL  ') == 1

old_ci = recovered[CI].decode(); old_workflow = recovered[WORKFLOW].decode()
start = old_ci.index('An authority record must contain exactly one canonical')
end = old_ci.index('#### Bounded views over exact history',start)
block = old_ci[start:end]
old_link = 'lives in `docs/knowledge/readme-stability-policy.md` and `docs/tasks/README-STABILITY-POLICY.md`.'
new_link = old_link+' See [accepted decision authority](documentation-workflow.md#accepted-decision-authority) for the Status rule and examples.'
expected_ci = (old_ci[:start]+old_ci[end:]).replace(old_link,new_link,1).encode()
expected_workflow = old_workflow.replace('proves 62 exact routes over 20 surfaces and all 32 mutation classes before the README doctrine can pass.',
                                         'proves 62 exact routes over 20 surfaces and all 40 mutation classes before the README doctrine can pass.',1).replace('## Public book\n','## Accepted decision authority\n\n'+block+'## Public book\n',1).encode()

def check_books(ci,workflow):
    assert ci == expected_ci, 'CI chapter preserves all other content and adds only canonical link'
    assert workflow == expected_workflow, 'workflow preserves all other content and complete exact teaching block'
    assert len(ci.splitlines()) == 2047 and b'## Accepted decision authority\n' in workflow
    assert sha(block.encode()) == routing['moved_block_sha256'] and len(block.encode()) == routing['moved_block_bytes']
check_books(read(CI),read(WORKFLOW))
assert routing['before_hashes'] == {CI:sha(recovered[CI]),WORKFLOW:sha(recovered[WORKFLOW])} and routing['after_hashes'] == {CI:sha(read(CI)),WORKFLOW:sha(read(WORKFLOW))}
assert read('doctrine/readme_stability/routes.jsonl') == subprocess.check_output(['git','show',BASE+':doctrine/readme_stability/routes.jsonl'],cwd=ROOT), 'all caps remain unchanged'
controls = []
for name,ci,workflow in [('lost_example',read(CI),read(WORKFLOW).replace(b'- Status: accepted; qualified engineering decision',b'- Status: proposed',1)),
                         ('stale_workflow_counter',read(CI),read(WORKFLOW).replace(b'all 40 mutation classes',b'all 32 mutation classes',1)),
                         ('lost_canonical_link',read(CI).replace(new_link.encode(),old_link.encode(),1),read(WORKFLOW)),
                         ('unrelated_ci_edit',read(CI)+b'\n',read(WORKFLOW))]:
    try: check_books(ci,workflow)
    except AssertionError as failure: controls.append({'name':name,'observed_red':str(failure)})
    else: raise AssertionError('ineffective book migration control '+name)
result = {'complete':True,'producer_sha256':sha(Path(__file__).read_bytes()),'recovered_regular_inputs':len(graph),
          'original_claim_inputs_recovered':len(items),'raw_patch_bytes':len(patch),'ci_chapter_lines':len(read(CI).splitlines()),
          'book_migration_red_controls':controls,'source_hashes':{path:sha(read(path)) for path in (CI,WORKFLOW)},
          'scope':'Independent private-index recovery of the complete original rejected staged candidate and all61 original artifact inputs; exact full-index binary delta and metadata/membership/bytes match. Full teaching block moves byte-for-byte with exact reciprocal canonical link and updated current workflow oracle counter; four content-sensitive controls reject. All registry caps unchanged. This review does not replay original publication/CI or claim an original before-CI fingerprint or separate original error channels. Corrected actual routing/render and fresh canonical admission remain required.'}
(ROOT/(PREFIX+'docs-verification.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
