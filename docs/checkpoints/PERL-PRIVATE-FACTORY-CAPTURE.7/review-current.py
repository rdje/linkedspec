"""Readonly complete preservation, Knowledge and direct-dependent admission review."""
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
BASE='858eba97c89239d187765c4af9ad18057d28a1b0'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
CLAIM='docs/claims/REPO-HYGIENE.19.json'
CARD='docs/knowledge/perl-receiver-copy-canonical-selection.md'
CHAPTER='docs/linkedspec-book/src/development/documentation-workflow.md'
sha=lambda v:hashlib.sha256(v).hexdigest()
decode=lambda v:base64.b64decode(v,validate=True)
assert sys.argv[1:] in ([],['--capture'])
inputs=set();cache={}
def raw(p):inputs.add(p);return (ROOT/p).read_bytes()
def load(n):return json.loads(raw(PREFIX+n))
def old(p):
    if p not in cache:cache[p]=subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)
    return cache[p]
preserved=load('preservation.json')
assert preserved['result']=='PASS' and preserved['base']==BASE
assert preserved['producer_sha256']==sha(raw(PREFIX+'preserve.py'))
names=subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--','docs/claims'],cwd=ROOT,text=True).splitlines()
owned=set(preserved['owned_bound_paths']);census=[];selected=[]
for p in names:
    value=old(p);claim=json.loads(value);hits=[]
    for index,row in enumerate(claim['claims']):
        d=row['durability']
        if d.get('mode')!='live':continue
        overlap=sorted(owned & {v['path'] for v in d['inputs']})
        if overlap:hits.append(dict(claim_index=index,overlap=overlap))
    census.append(dict(path=p,sha256=sha(value),intersections=hits))
    if hits:selected.append(p)
assert census==preserved['census'],'complete fixed accepted claim namespace'
assert selected==[CLAIM] and len(preserved['selected'])==1
chosen=preserved['selected'][0];original=old(CLAIM)
assert decode(chosen['original_base64'])==original and chosen['sha256']==sha(original),'whole accepted predecessor claim'
assert chosen['bytes']==len(original)==43696
prior=json.loads(original);bindings=prior['claims'][0]['durability']['inputs']
assert len(bindings)==175 and len(chosen['hits'])==1 and chosen['hits'][0]['claim_index']==0
saved=chosen['hits'][0]['bindings']
assert set(saved)=={v['path'] for v in bindings},'whole accepted predecessor input population'
tree=subprocess.check_output(['git','ls-tree','-r',BASE],cwd=ROOT,text=True).splitlines()
modes={v.split('\t',1)[1]:int(v.split()[0],8)&0o7777 for v in tree}
for item in bindings:
    p=item['path'];value=old(p)
    assert item['sha256']==sha(value) and saved[p]==dict(sha256=sha(value),bytes=len(value),mode=modes[p])
expected=copy.deepcopy(prior);expected['claims'][0]['durability'].update(mode='historical',revision=BASE)
assert json.loads(raw(CLAIM))==expected,'mode/revision-only predecessor preservation'
baseline=load('baseline.json')
assert baseline==preserved['baseline'] and baseline['returncode']==0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64'])==b'Retained metadata/output publication PASS: 175 live inputs; 43696 bytes\n'
assert preserved['activation_only_unbound_paths']==['docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md']
assert 'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md' not in saved

archive=subprocess.check_output(['git','archive',BASE,'--','docs/knowledge','docs/decisions'],cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(archive)) as stream:
    accepted={v.name:(stream.extractfile(v).read(),v.mode) for v in stream if v.isfile() and v.name.endswith('.md')}
knowledge=load('knowledge.json');packed=raw(PREFIX+'knowledge-inputs.json.gz')
assert knowledge['result']=='PASS' and knowledge['producer_sha256']==sha(raw(PREFIX+'knowledge.py'))
assert sha(packed)==knowledge['capsule_sha256']
capsule=json.loads(gzip.decompress(packed))
assert len(accepted)==knowledge['markdown']==1487 and set(accepted)==set(capsule['original'])
for p,(value,mode) in accepted.items():
    row=capsule['original'][p]
    assert decode(row['bytes_base64'])==value and row['mode']==mode,'complete original Knowledge archive'
assert set(capsule['current'])==set(knowledge['inputs'])
for p,row in capsule['current'].items():
    value=raw(p)
    assert decode(row['bytes_base64'])==value and row['sha256']==sha(value),'complete current Knowledge population'
    assert row['mode']==(ROOT/p).stat().st_mode&0o7777
    assert knowledge['inputs'][p]==dict(sha256=sha(value),mode=row['mode'])
cards=sorted(p for p in owned if p.startswith('docs/knowledge/'))
assert len(cards)==15 and sorted(p for p,(value,mode) in accepted.items() if raw(p)!=value)==cards
assert knowledge['changed_cards']==cards
prep=load('knowledge-preparation-final.json')
assert sorted(prep['originals'])==cards==sorted(prep['current'])
for p in cards:
    value=accepted[p][0]
    assert decode(prep['originals'][p]['bytes_base64'])==value and prep['originals'][p]['sha256']==sha(value)
    assert prep['current'][p]==sha(raw(p))
    if p!=CARD:assert raw(p).split(b'\n---\n',1)[1]==value.split(b'\n---\n',1)[1],'fourteen exact original card bodies'
    assert (PREFIX+'publish.py').encode() in raw(p).split(b'\n---\n',1)[0]
repair=load('knowledge-source-repair.json');first_source=raw(PREFIX+'prepare-knowledge.py')
assert repair['producer_sha256']==sha(raw(PREFIX+'finalize-knowledge.py')) and repair['original_sha256']==sha(first_source)
before,after=decode(repair['old_base64']),decode(repair['new_base64'])
assert first_source.count(before)==1
corrected=first_source.replace(before,after,1).replace(b"'knowledge-preparation.json'",b"'knowledge-preparation-final.json'",1)
corrected=corrected.replace(b"header+b'\\n---\\n'+body+addition.encode()",b"header+b'\\n---\\n'+addition.encode()",1)
corrected=corrected.replace(b'one canonical-selection body keeps its entire original body and appends the bounded current population/inverse scope.',
    b'one canonical-selection body condenses the fully preserved older account with the bounded current population/inverse scope.',1)
corrected=corrected.replace(b'15 routes/one appended body',b'15 routes/one condensed body',1)
assert corrected==raw(PREFIX+'prepare-knowledge-final.py') and sha(corrected)==repair['corrected_sha256']
assert prep['producer_sha256']==sha(corrected)

# Reconstruct only pure proposed values from real accepted Git bytes. Physical
# one-shot/current-epoch guards are bypassed; execution stops before totals/writes.
def proposal(source,path):
    prefix=source.split(b'\ntotal=sum(',1)[0]
    guard=b'    assert (ROOT/p).read_bytes()==value\n'
    assert prefix.count(guard)==1 and prefix.count(b'assert not target.exists()')==1
    prefix=prefix.replace(guard,b'    pass\n',1).replace(b'assert not target.exists()',b'pass',1)
    previous=sys.argv
    try:
        sys.argv=[path,'--preflight'];namespace={'__file__':str(ROOT/path)}
        exec(compile(prefix,path,'exec'),namespace)
    finally:sys.argv=previous
    assert {p:sha(v) for p,v in namespace['originals'].items()}=={p:sha(accepted[p][0]) for p in cards}
    return namespace['values']
draft=proposal(first_source,PREFIX+'prepare-knowledge.py')
final=proposal(corrected,PREFIX+'prepare-knowledge-final.py')
preflight=load('knowledge-preflight.json');final_preflight=load('knowledge-preflight-final.json')
for observation,source,values in ((preflight,first_source,draft),(final_preflight,corrected,final)):
    assert decode(observation['producer_base64'])==source and observation['producer_sha256']==sha(source)
    assert observation['originals']=={p:sha(accepted[p][0]) for p in cards}
    assert observation['proposed']=={p:sha(v) for p,v in values.items()}
    total=sum(len(values.get(p,value)) for p,(value,mode) in accepted.items() if p.startswith('docs/knowledge/'))
    assert observation['knowledge_bytes']==total
assert preflight['result']=='OVER_CAP' and preflight['knowledge_bytes']==8389286>8388608
assert final_preflight['result']=='PASS' and final_preflight['knowledge_bytes']==8388024<=8388608
assert all(raw(p)==value for p,value in final.items()),'exact final proposed card bytes'
total=sum(len(raw(p)) for p in accepted if p.startswith('docs/knowledge/'))
assert total==knowledge['knowledge_bytes']==prep['knowledge_bytes']==8388024 and knowledge['facts']==1349 and knowledge['question_keys']==10442
assert knowledge['generation']['returncode']==knowledge['check']['returncode']==0
assert decode(knowledge['generation']['stderr_base64'])==b'knowledge-map: wrote KNOWLEDGE_MAP.md (1349 facts, 10442 question keys)\n'
assert decode(knowledge['check']['stderr_base64'])==b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
bookprep=load('book-preparation.json')
assert decode(bookprep['original_base64'])==old(CHAPTER) and bookprep['original_sha256']==sha(old(CHAPTER))
assert bookprep['producer_sha256']==sha(raw(PREFIX+'prepare-book.py')) and bookprep['current_sha256']==sha(raw(CHAPTER))
native='docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
assert raw(native)==old(native),'unchanged native teaching'

observations={}
for name in ('inventory-final.py','review-selection.py','review-audit.py','book-review.py'):
    command=['python3',PREFIX+name];run=subprocess.run(command,cwd=ROOT,capture_output=True)
    assert run.returncode==0 and not run.stderr,('readonly direct-dependent review',name,run.stderr)
    observations[name]=dict(command=command,returncode=run.returncode,stdout_base64=base64.b64encode(run.stdout).decode(),stderr_base64='')
selection=load('selection-review.json');audit=load('audit-review.json');book=load('book-review.json')
assert selection['suites']==91 and selection['helpers']==46 and selection['supplied_inputs']==363 and selection['actual_faults']==4
assert audit['audit_inputs']==194 and audit['restored_inputs']==134 and audit['evolution_denials']==368 and audit['new_evolution_denials']==280
assert book['source_count']==89 and book['actual_controls']==4
for report in (selection,audit):
    for p,identity in report['inputs'].items():assert sha(raw(p))==identity
for field in ('oracle_inputs','source_inputs'):
    for p,identity in book[field].items():assert sha(raw(p))==identity
changed=subprocess.check_output(['git','diff',BASE,'--name-only','--','perl','t','tests','tools','scripts','doctrine','rust','dart','julia','lua','.githooks','.gitmodules','rgx'],cwd=ROOT,text=True).splitlines()
assert sorted(changed)==['tests/language-readiness/verify_objectives.py','tools/run_ci_local.sh'],'only owned CI/auditor code changes'
for p in sorted((ROOT/PREFIX).iterdir()):
    if p.is_file() and p.name not in {'review-current.json','evidence.py','evidence.json','evidence-originals.json.gz','evidence-reached.json.gz','publish.py'}:raw(p.relative_to(ROOT).as_posix())
population=dict(original_claim_inputs=175,original_claim_bytes=43696,suites=91,helpers=46,supplied_inputs=363,assertions=30394,
    selected_faults=4,runner_lines=150,recovered_inputs=134,recovered_bytes=84613241,recovery_controls=22,evolution_denials=368,new_evolution_denials=280,
    knowledge_markdown=1487,knowledge_facts=1349,question_keys=10442,changed_cards=15,changed_bodies=1,knowledge_bytes=total,book_inputs=89,book_controls=4)
report=dict(result='PASS',base=BASE,producer_sha256=sha(raw(PREFIX+'review-current.py')),population=population,
    observations=observations,inputs={p:sha((ROOT/p).read_bytes()) for p in sorted(inputs)},
    scope='Complete fixed accepted namespace/whole predecessor175/full43696 and actual baseline; every original binding byte/mode and mode/revision-only preservation. Complete original/current1487 Markdown, all15 original cards,14 exact bodies and precise dry-run/condensation lineage; readonly pure proposals rederive totals from accepted Git without writer/native replay. Actual selected-block and complete historical-audit actors/inputs/controls and full89-input rendered book pass. Only CI/auditor code changes; exact staged canonical receipt and normal hooks still govern admission. No runtime/dependency, indirect-coverage census, immutable host-toolchain, liveness/recovery/purge or broader private/pipeline/parent claim.')
target=ROOT/(PREFIX+'review-current.json')
if sys.argv[1:]:
    with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
else:assert json.loads(target.read_bytes())==report
print('Complete fixture review PASS:175/full43696 preserved;91/46/363/30394;134/22/368;Knowledge1487/15/one body;book89/four')
