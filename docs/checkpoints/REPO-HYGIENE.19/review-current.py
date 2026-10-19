"""Readonly retained-review custody; --capture records the independent review once."""
import base64
import copy
import gzip
import hashlib
import io
import json
import subprocess
import sys
import tarfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BASE='e953f69a9934c4ab48e643e69c9efaba0cb1d534'
PREFIX='docs/checkpoints/REPO-HYGIENE.19/'
CLAIM='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.8.json'
WARNING='docs/knowledge/rust-dependency-warning-baseline.md'
CHAPTER='docs/linkedspec-book/src/development/documentation-workflow.md'
sha=lambda v:hashlib.sha256(v).hexdigest()
decode=lambda v:base64.b64decode(v,validate=True)
assert sys.argv[1:] in ([],['--capture'])
inputs=set()
def raw(p):inputs.add(p);return (ROOT/p).read_bytes()
def load(n):return json.loads(raw(PREFIX+n))
cache={}
def old(p):
    if p not in cache:cache[p]=subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)
    return cache[p]

preserved=load('preservation.json')
assert preserved['result']=='PASS' and preserved['base']==BASE
assert preserved['producer_sha256']==sha(raw(PREFIX+'preserve.py'))
names=subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--','docs/claims'],cwd=ROOT,text=True).splitlines()
owned=set(preserved['owned_bound_paths'])
expected=[];selected=[]
for p in names:
    original=old(p);record=json.loads(original);hits=[]
    for index,claim in enumerate(record['claims']):
        d=claim['durability']
        if d.get('mode')!='live':continue
        overlap=sorted(owned & {v['path'] for v in d['inputs']})
        if overlap:hits.append(dict(claim_index=index,overlap=overlap))
    expected.append(dict(path=p,sha256=sha(original),intersections=hits))
    if hits:selected.append(p)
assert preserved['census']==expected,'complete accepted claim namespace'
assert selected==[CLAIM] and len(preserved['selected'])==1
chosen=preserved['selected'][0]
original=old(CLAIM)
assert decode(chosen['original_base64'])==original and chosen['sha256']==sha(original),'whole accepted claim bytes'
assert chosen['bytes']==len(original)==128458
hit=chosen['hits'];assert len(hit)==1 and hit[0]['claim_index']==0
original_claim=json.loads(original)
bindings=original_claim['claims'][0]['durability']['inputs']
assert len(bindings)==550 and len({v['path'] for v in bindings})==550
assert set(hit[0]['bindings'])=={v['path'] for v in bindings},'complete original binding population'
tree=subprocess.check_output(['git','ls-tree','-r',BASE],cwd=ROOT,text=True).splitlines()
modes={line.split('\t',1)[1]:int(line.split()[0],8)&0o7777 for line in tree}
for item in bindings:
    p=item['path'];value=old(p);saved=hit[0]['bindings'][p]
    assert saved==dict(sha256=sha(value),bytes=len(value),mode=modes[p])
    assert item['sha256']==sha(value),'original binding accepted bytes'
changed=copy.deepcopy(original_claim)
changed['claims'][0]['durability'].update(mode='historical',revision=BASE)
assert json.loads(raw(CLAIM))==changed,'mode/revision-only historical preservation'
baseline=load('baseline.json')
assert baseline==preserved['baseline'] and baseline['returncode']==0
assert decode(baseline['stdout_base64'])==b'Finite continuity publication PASS: 550 live inputs; 128458 bytes\n'
assert not decode(baseline['stderr_base64'])
assert preserved['activation_only_unbound_paths']==['docs/tasks/REPO-HYGIENE.md']
assert 'docs/tasks/REPO-HYGIENE.md' not in {v['path'] for v in bindings}

# Independently retain original Git bytes and distinguish archive and actual modes.
archive=subprocess.check_output(['git','archive',BASE,'--','docs/knowledge','docs/decisions'],cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as stream:
    accepted={v.name:(stream.extractfile(v).read(),v.mode) for v in stream if v.isfile() and v.name.endswith('.md')}
packed=raw(PREFIX+'knowledge-inputs.json.gz');capsule=json.loads(gzip.decompress(packed))
knowledge=load('knowledge.json');prep=load('knowledge-preparation-final.json');failed=load('knowledge-preflight.json')
assert set(capsule['original'])==set(accepted) and len(accepted)==knowledge['markdown']==1487
for p,(value,mode) in accepted.items():
    row=capsule['original'][p]
    assert decode(row['bytes_base64'])==value and row['mode']==mode,'whole original Knowledge archive'
assert knowledge['capsule_sha256']==sha(packed) and knowledge['producer_sha256']==sha(raw(PREFIX+'knowledge.py'))
assert set(capsule['current'])==set(knowledge['inputs'])
for p,row in capsule['current'].items():
    value=raw(p)
    assert decode(row['bytes_base64'])==value and row['sha256']==sha(value),'complete current Knowledge input bytes'
    assert row['mode']==(ROOT/p).stat().st_mode&0o7777
    assert knowledge['inputs'][p]==dict(sha256=sha(value),mode=row['mode'])
cards=sorted(p for p in owned if p.startswith('docs/knowledge/'))
assert len(cards)==14 and set(prep['originals'])==set(cards)==set(failed['unchanged_cards'])
changed_cards=sorted(p for p in accepted if raw(p)!=accepted[p][0])
assert changed_cards==knowledge['changed_cards']==cards
for p in cards:
    assert decode(prep['originals'][p]['bytes_base64'])==accepted[p][0]
    assert prep['originals'][p]['sha256']==failed['unchanged_cards'][p]==sha(accepted[p][0])
    assert prep['current'][p]==sha(raw(p))
    if p!=WARNING:assert raw(p).split(b'\n---\n',1)[1]==accepted[p][0].split(b'\n---\n',1)[1],'thirteen exact original card bodies'
    assert (PREFIX+'publish.py').encode() in raw(p).split(b'\n---\n',1)[0]
total=sum(len(raw(p)) for p in accepted if p.startswith('docs/knowledge/'))
assert total==knowledge['knowledge_bytes']==prep['knowledge_bytes']==8388524<=8388608
assert len([p for p in accepted if p.startswith('docs/knowledge/')])==1350
assert knowledge['returncode']==0 and not decode(knowledge['stdout_base64'])
assert decode(knowledge['stderr_base64'])==b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
assert failed['result']=='PASS' and failed['returncode']!=0
assert failed['producer_sha256']==sha(raw(PREFIX+'knowledge-preflight.py'))
assert failed['failed_source_sha256']==sha(raw(PREFIX+'prepare-knowledge.py'))
assert b"('prewrite Knowledge budget', 8388673)" in decode(failed['stderr_base64'])
source=raw(PREFIX+'prepare-knowledge.py');final=raw(PREFIX+'prepare-knowledge-final.py')
source_lines=source.splitlines();final_lines=final.splitlines()
assert len(source_lines)==len(final_lines)
differences=[(a,b) for a,b in zip(source_lines,final_lines) if a!=b]
assert len(differences)==2 and differences[0][0].startswith(b'target=') and differences[1][0].startswith(b'evidence=')
assert prep['producer_sha256']==sha(final),'precise evidence-header-only correction and distinct report path'

bookprep=load('book-preparation.json')
assert bookprep['result']=='PASS' and bookprep['base']==BASE
assert decode(bookprep['original_base64'])==old(CHAPTER),'whole original workflow chapter'
assert bookprep['producer_sha256']==sha(raw(PREFIX+'prepare-book.py'))
native='docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
assert raw(native)==old(native),'unchanged native teaching'
assert raw('docs/checkpoints/REPO-HYGIENE.18-census.py')==old('docs/checkpoints/REPO-HYGIENE.18-census.py')

observations={}
for name in ('actual-review.py','metadata-evidence.py','warning-review.py','warning-evidence.py','book-review.py'):
    command=['python3',PREFIX+name]
    run=subprocess.run(command,cwd=ROOT,capture_output=True)
    assert run.returncode==0 and not run.stderr,('readonly direct-dependent proof',name,run.stderr)
    observations[name]=dict(command=command,returncode=run.returncode,stdout_base64=base64.b64encode(run.stdout).decode(),stderr_base64='')
metadata=load('actual-review.json');warnings=load('warning-review.json');book=load('book-review.json')
assert metadata['parent_files']==16443 and metadata['parent_bytes']==17576851726
assert metadata['rust']['rust/target/debug/incremental']==dict(files=483,bytes=2390810573,exists=True)
assert warnings['summary_occurrences']==24 and warnings['counts_by_crate']=={'pgen':12,'rgx-core':12}
assert warnings['reported_values']=={'pgen':[7093],'rgx-core':[26]}
assert book['source_count']==89 and book['actual_controls']==4
for report in (metadata,warnings):
    for p,identity in report['inputs'].items():assert sha(raw(p))==identity
for field in ('oracle_inputs','source_inputs'):
    for p,identity in book[field].items():assert sha(raw(p))==identity
warning_tree=raw('docs/tasks/RUST-DEPENDENCY-WARNING-ZERO.md')
assert b'- ID: `RUST-DEPENDENCY-WARNING-ZERO.1`\n  Status: `pending`' in warning_tree
assert b'7093' in warning_tree and PREFIX.encode() in warning_tree
assert b'1870' in raw(WARNING) and b'distinct' in raw(WARNING)
# No implementation, registration, limit or dependency owner may move in retention.
unrelated=subprocess.check_output(['git','diff',BASE,'--','perl','t','tests','tools','scripts','doctrine','rust','dart','julia','lua','.githooks','.gitmodules','rgx'],cwd=ROOT)
assert not unrelated,'no runtime/gate/budget/dependency change'
for p in sorted((ROOT/PREFIX).iterdir()):
    if p.is_file() and p.name not in {'review-current.json','evidence.py','evidence.json','evidence-originals.json.gz','evidence-reached.json.gz','publish.py'}:raw(p.relative_to(ROOT).as_posix())
population=dict(original_claim_inputs=550,original_claim_bytes=128458,knowledge_markdown=1487,
    knowledge_facts=1349,changed_cards=14,changed_bodies=1,knowledge_bytes=total,book_inputs=89,
    book_controls=4,parent_files=16443,parent_bytes=17576851726,rust_incremental_files=483,
    rust_incremental_bytes=2390810573,warning_occurrences=24,metadata_controls=4,warning_controls=8)
report=dict(result='PASS',base=BASE,producer_sha256=sha(raw(PREFIX+'review-current.py')),
    population=population,observations=observations,inputs={p:sha((ROOT/p).read_bytes()) for p in sorted(inputs)},
    scope='Independent complete accepted claim census/whole publication and original binding custody, actual baseline, archive/current Knowledge representations, fourteen routes/thirteen exact bodies and precise prewrite budget refusal/header correction; complete dated metadata/channel/summary/receipt and rendered-book direct dependents. No liveness, purge, distinct dependency-defect count, comparable configuration, internal cause or new admission claim.')
target=ROOT/(PREFIX+'review-current.json')
if sys.argv[1:]:
    with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
else:assert json.loads(target.read_bytes())==report
print('Retained review PASS:whole550/full128458;Knowledge1487/14/one body;metadata16443;warnings24;book89/four')
