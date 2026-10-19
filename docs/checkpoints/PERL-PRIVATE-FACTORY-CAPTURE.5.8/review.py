"""Readonly independent finite-continuity reconstruction; --capture freezes once."""
import base64
import copy
import gzip
import hashlib
import io
import json
import re
import subprocess
import sys
import tarfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BASE='54bb5eb65178a57ac6e61e53324c9291863e716d'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.8/'
REG='doctrine/readme_stability/routes.jsonl'
INDEX='docs/decisions/INDEX.md'
ADR='docs/decisions/0136-finite-continuity-capacity.md'
MANIFEST='docs/history/changes/manifest.jsonl'
CLAIM='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.7.json'
CARD='docs/knowledge/finite-engineering-notes-member-0131.md'
sha=lambda v:hashlib.sha256(v).hexdigest()
decode=lambda v:base64.b64decode(v,validate=True)
compact=lambda v:json.dumps(v,sort_keys=True,separators=(',',':')).encode()
assert sys.argv[1:] in ([],['--capture'])
inputs=set()
def raw(p):inputs.add(p);return (ROOT/p).read_bytes()
def load(name):return json.loads(raw(PREFIX+name))
objects=subprocess.Popen(['git','cat-file','--batch'],cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
def at(revision,p):
    objects.stdin.write((revision+':'+p+'\n').encode());objects.stdin.flush()
    header=objects.stdout.readline().split()
    assert len(header)==3 and header[1]==b'blob',('accepted Git artifact',revision,p)
    value=objects.stdout.read(int(header[2]));assert objects.stdout.read(1)==b'\n';return value
old=lambda p:at(BASE,p)
def paths(directory):return subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--',directory],cwd=ROOT,text=True).splitlines()
def producer(record,name):assert record['producer_sha256']==sha(raw(PREFIX+name)),('actual producer',name)
def metrics(names):
    values=[raw(p) for p in names]
    return dict(files=len(values),lines=sum(v.count(b'\n') for v in values),bytes=sum(map(len,values)))
def history_names(family,current):return [current,'docs/history/'+family+'/manifest.jsonl']+sorted(p.relative_to(ROOT).as_posix() for p in (ROOT/('docs/history/'+family)).glob('*.md'))
def contract(row):
    names=('authority','control','lifecycle','member_limits','members','owner','route_targets','state','verifier')
    return {**{k:row.get(k) for k in names},'transition_owners':row.get('transition',{}).get('owners')}

preserved=load('preservation.json');producer(preserved,'preserve.py')
assert preserved['result']=='PASS' and preserved['base']==BASE
claim_names=paths('docs/claims')
assert [v['path'] for v in preserved['census']]==claim_names,'fixed accepted claim namespace'
selected=preserved['selected'];assert [v['path'] for v in selected]==[CLAIM]
original_claim=decode(selected[0]['original_base64'])
assert original_claim==old(CLAIM) and len(original_claim)==selected[0]['bytes']==129686,'whole accepted publication custody'
assert sha(original_claim)==selected[0]['sha256']
original=json.loads(original_claim);expected=copy.deepcopy(original)
assert len(original['claims'])==len(selected[0]['hits'])==1
bindings=original['claims'][0]['durability']['inputs'];assert len(bindings)==565
assert original['claims'][0]['durability']['mode']=='live'
for item in bindings:assert sha(old(item['path']))==item['sha256'],'every original accepted binding'
expected['claims'][0]['durability'].update(mode='historical',revision=BASE)
assert raw(CLAIM)==(json.dumps(expected,indent=2)+'\n').encode(),'mode/revision-only preservation'
assert set(selected[0]['hits'][0]['bindings'])=={v['path'] for v in bindings}
for item in bindings:assert selected[0]['hits'][0]['bindings'][item['path']]['sha256']==item['sha256']
owned=set(preserved['owned_bound_paths'])
for row in preserved['census']:
    value=old(row['path']);assert sha(value)==row['sha256']
    if row['path']!=CLAIM:assert raw(row['path'])==value
    hits=[dict(claim_index=i,overlap=sorted(owned & {v['path'] for v in c['durability']['inputs']}))
        for i,c in enumerate(json.loads(value)['claims']) if c['durability'].get('mode')=='live' and owned & {v['path'] for v in c['durability']['inputs']}]
    assert row['intersections']==hits
baseline=load('baseline.json');assert baseline==preserved['baseline']
assert baseline['returncode']==0 and not decode(baseline['stderr_base64'])
assert decode(baseline['stdout_base64'])==b'Corrected default publication PASS: 565 live inputs; 129686 bytes\n'

measurement=load('measurement.json');producer(measurement,'measure.py')
assert measurement['result']=='PASS' and measurement['base']==BASE
prior=sorted(p for d in ('docs/history/changes','docs/history/development-notes','docs/decisions') for p in paths(d) if p not in (MANIFEST,INDEX))
assert len(prior)==230 and sorted(measurement['preserved'])==prior,'complete prior immutable census'
for p in prior:assert sha(raw(p))==measurement['preserved'][p]==sha(old(p)),'unchanged prior history/decision bytes'
for p,item in measurement['original_inputs'].items():assert decode(item['bytes_base64'])==old(p) and item['sha256']==sha(old(p))
assert set(measurement['original_inputs'])=={'CHANGES.md','DEVELOPMENT_NOTES.md',REG,INDEX,MANIFEST}
change=decode(measurement['records']['changes_base64']);note=decode(measurement['records']['engineering_base64'])
for record in (change,note):assert record.startswith(b'## 2026-10-19') and record.count(b'\n')==4 and record.endswith(b'\n\n')
def prepend(value,addition):
    position=re.search(rb'^## ',value,re.M).start();return value[:position]+addition+value[position:]
unrolled=prepend(old('CHANGES.md'),change)
assert unrolled.count(b'\n')==369 and len(unrolled)==59429
pieces=re.split(rb'(?=^## )',old('CHANGES.md'),flags=re.M)
preamble,records=pieces[0],pieces[1:];keep=len(records)
while keep and (len(preamble+change+b''.join(records[:keep]))>32768 or (preamble+change+b''.join(records[:keep])).count(b'\n')>256):keep-=1
assert 0<keep<len(records)
archive=b''.join(records[keep:])
current=re.sub(rb'\n{2,}\Z',b'\n',preamble+change+b''.join(records[:keep]))
assert raw('CHANGES.md')==current and len(current)==32530 and current.count(b'\n')==111,'exact retained current records'
assert len(archive)==26898 and archive.count(b'\n')==257 and old('CHANGES.md').endswith(archive)
assert raw('DEVELOPMENT_NOTES.md')==prepend(old('DEVELOPMENT_NOTES.md'),note),'exact complete note insertion'
previous=[json.loads(v) for v in old(MANIFEST).splitlines()]
manifest=[json.loads(v) for v in raw(MANIFEST).splitlines()]
meta=copy.deepcopy(previous[0]);meta['segment_count']+=1
assert manifest[0]==meta and manifest[2:]==previous[1:]
assert raw(MANIFEST).splitlines(True)[2:]==old(MANIFEST).splitlines(True)[1:],'byte-exact prior manifest rows'
number=f"{int(previous[1]['segment_id'])-1:04d}"
member='docs/history/changes/segment-'+number+'-'+sha(archive)[:12]+'.md'
start=old('CHANGES.md')[:-len(archive)].count(b'\n')+1
blob=subprocess.check_output(['git','rev-parse',BASE+':CHANGES.md'],cwd=ROOT,text=True).strip()
segment=dict(byte_count=len(archive),current_path='CHANGES.md',immutable=True,line_count=archive.count(b'\n'),
    retrieval_command='perl tools/read_document_history.pl --surface change_history --segment '+number,
    segment_id=number,sha256=sha(archive),source_blob=blob,source_commit=BASE,source_end_line=start+archive.count(b'\n')-1,
    source_path='CHANGES.md',source_start_line=start,surface='change_history',target_path=member,type='segment')
assert manifest[1]==segment and raw(member)==archive,'exact source suffix/blob/range/digest'
assert number=='4962' and start==109

# Full original-project observations retain data, helper/config and historical Git inputs.
stage_data={}
for name,count in (('original',1980),('unrolled',1980),('rolled',1981)):
    identity=measurement['captures'][name];payload=raw(identity['path'])
    assert sha(payload)==identity['sha256']
    data=json.loads(gzip.decompress(payload));assert len(data)==identity['files']==count
    for p,item in data.items():
        assert p==Path(p).as_posix() and not Path(p).is_absolute() and '..' not in Path(p).parts
        assert not p.startswith(('rgx/','pgen/')) and sha(decode(item['bytes_base64']))==item['sha256']
    stage_data[name]=data
expected_paths={'.gitattributes','.gitignore','.knowledge_map.conf','README.md','README_POLICY.md',PREFIX+'measure.py'}
support=set()
for d in ('tools','scripts','capability_conformance','doctrine','knowledge-map/scripts'):support.update(paths(d))
expected_paths.update(support)
accepted=set(subprocess.check_output(['git','ls-tree','-r','--name-only',BASE],cwd=ROOT,text=True).splitlines())
for row in map(json.loads,old(REG).splitlines()):
    for pattern in row.get('members',[]):
        expected_paths.update(p.relative_to(ROOT).as_posix() for p in ROOT.glob(pattern) if p.is_file() and not p.is_symlink() and p.relative_to(ROOT).as_posix() in accepted)
    for p in row.get('members',[])+row.get('route_targets',[]):
        if p in accepted and (ROOT/p).is_file():expected_paths.add(p)
assert set(stage_data['original'])==expected_paths,'complete fixed original supplied population'
for p in support:assert decode(stage_data['original'][p]['bytes_base64'])==old(p) and (ROOT/p).read_bytes()==old(p),'unchanged actual helper/config source'
for name in ('unrolled','rolled'):
    expected_stage=copy.deepcopy(stage_data['original'])
    deltas={'CHANGES.md':unrolled if name=='unrolled' else current,'DEVELOPMENT_NOTES.md':raw('DEVELOPMENT_NOTES.md')}
    if name=='rolled':deltas.update({MANIFEST:raw(MANIFEST),member:archive})
    for p,value in deltas.items():expected_stage[p]=dict(bytes_base64=base64.b64encode(value).decode(),sha256=sha(value),mode=(ROOT/p).stat().st_mode&0o7777)
    assert stage_data[name]==expected_stage,'exact complete supplied stage transformation'
revision=re.search(rb'^SOURCE_REVISION = "([0-9a-f]{40})"$',old('tools/test_document_history_rollover.py'),re.M).group(1).decode()
assert set(measurement['git_inputs'])=={revision+':'+p for p in ('CHANGES.md','DEVELOPMENT_NOTES.md',MANIFEST,'docs/history/development-notes/manifest.jsonl')}
for key,item in measurement['git_inputs'].items():
    revision,p=key.split(':',1);assert decode(item['bytes_base64'])==at(revision,p) and sha(decode(item['bytes_base64']))==item['sha256']
commands=measurement['commands'];assert len(commands)==3 and [v['returncode'] for v in commands]==[255,0,1]
assert b'369/512 lines, 59429/65536 bytes' in decode(commands[0]['stderr_base64'])
assert b'archived 257 line(s) as 4962' in decode(commands[1]['stdout_base64'])
for reason in (b'files 51/50',b'lines 50/49',b'bytes 28559/27983',b'aggregate lines 29516/29512'):assert reason in decode(commands[2]['stderr_base64'])
for row in commands:
    assert 'tracked_namespace_base64' in row and 'untracked_namespace_base64' in row
    assert b'rgx\x00' in decode(row['tracked_namespace_base64'])

plan=load('plan.json');producer(plan,'admit.py')
assert plan['result']=='PASS' and plan['measurement_sha256']==sha(raw(PREFIX+'measurement.json'))
rows=[json.loads(v) for v in old(REG).splitlines()]
before={v['id']:v for v in rows if 'id' in v};after=copy.deepcopy(before)
after['change_history']['limits']['max_files']+=1
after['change_history']['member_limits'][MANIFEST]=dict(max_bytes=len(raw(MANIFEST)),max_lines=raw(MANIFEST).count(b'\n'))
after['engineering_notes']['limits']['max_total_lines']+=before['engineering_notes']['member_limits']['DEVELOPMENT_NOTES.md']['max_lines']
after['decisions']['limits']['max_files']+=1
adr=raw(ADR)
assert re.findall(rb'^- Status:([^\n]*)$',adr,re.M)==[b' accepted engineering maintenance under `PERL-PRIVATE-FACTORY-CAPTURE.5.8`; exact canonical admission required'],'accepted sole authority'
after['decisions']['limits']['max_total_lines']+=adr.count(b'\n')+1
expected_registry=b''.join((compact(after[v['id']])+b'\n') if v.get('id') in ('change_history','engineering_notes','decisions') else line for line,v in zip(old(REG).splitlines(True),rows))
assert decode(plan['changed'][REG]['bytes_base64'])==expected_registry==raw(REG),'exact finite registry delta'
assert plan['old_limits']=={n:before[n]['limits'] for n in ('change_history','engineering_notes','decisions')}
assert plan['new_limits']=={n:after[n]['limits'] for n in ('change_history','engineering_notes','decisions')}
assert plan['old_contract']==contract(before['change_history']) and plan['new_contract']==contract(after['change_history'])
index_row=b'| [0136](0136-finite-continuity-capacity.md) | One finite change-history member and note envelope | 2026-10-19 | accepted engineering maintenance; canonical admission required | history, capacity, verification |\n'
last=re.findall(rb'^\| \[0135\].*\n',old(INDEX),re.M);assert len(last)==1
assert raw(INDEX)==old(INDEX).replace(last[0],last[0]+index_row,1),'exact sole index row placement'
assert raw(INDEX).index(index_row)<raw(INDEX).index(b'\n## How to add a record')
assert adr.count(b'\n')==plan['decision_physical_lines']==40 and plan['index_added_lines']==1 and plan['engineering_envelope']==512
for name in ('change_history','engineering_notes','decisions'):
    assert b'- Routed surface: `'+name.encode()+b'`\n' in adr
    for marker,value in (('Previous',before[name]['limits']),('New',after[name]['limits'])):assert b'- '+marker.encode()+b' routed limits: `'+compact(value)+b'`\n' in adr
for marker,value in (('Previous',contract(before['change_history'])),('New',contract(after['change_history']))):assert b'- '+marker.encode()+b' routed contract: `'+compact(value)+b'`\n' in adr
for p,item in plan['changed'].items():assert decode(item['bytes_base64'])==raw(p) and sha(raw(p))==item['sha256']
for name,census in (('change_history',metrics(history_names('changes','CHANGES.md'))),('engineering_notes',metrics(history_names('development-notes','DEVELOPMENT_NOTES.md'))),('decisions',metrics(sorted(p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/decisions').glob('*.md'))))):assert plan['measured'][name]==census

for name in ('control-census.py','book-review.py'):
    run=subprocess.run(['python3',PREFIX+name],cwd=ROOT,capture_output=True)
    assert run.returncode==0 and not run.stderr,('readonly component',name,run.stderr)
for name in ('control-census.json','book-review.json'):
    component=load(name)
    for field in ('inputs','source_inputs','oracle_inputs'):
        for p,identity in component.get(field,{}).items():assert sha(raw(p))==identity
knowledge=load('knowledge.json');producer(knowledge,'knowledge.py')
data=json.loads(gzip.decompress(raw(PREFIX+'knowledge-inputs.json.gz')))
assert knowledge['capsule_sha256']==sha(raw(PREFIX+'knowledge-inputs.json.gz')) and knowledge['returncode']==0
accepted_archive=subprocess.check_output(['git','archive',BASE,'--','docs/knowledge','docs/decisions'],cwd=ROOT)
with tarfile.open(fileobj=io.BytesIO(accepted_archive)) as stream:
    originals={v.name:dict(bytes_base64=base64.b64encode(stream.extractfile(v).read()).decode(),mode=v.mode) for v in stream if v.isfile() and v.name.endswith('.md')}
assert data['original']==originals and len(originals)==1486
markdown=sorted(p.relative_to(ROOT).as_posix() for d in ('docs/knowledge','docs/decisions') for p in (ROOT/d).rglob('*.md') if p.is_file())
assert len(markdown)==knowledge['markdown']==1487 and set(markdown)==set(originals)|{ADR}
changed=sorted(p for p in markdown if p.startswith('docs/knowledge/') and data['current'][p]['bytes_base64']!=originals[p]['bytes_base64'])
assert changed==knowledge['changed_cards'] and len(changed)==13
for p,item in data['current'].items():
    assert sha(decode(item['bytes_base64']))==item['sha256']==sha((ROOT/p).read_bytes())
    if p not in originals or p in changed:raw(p)
for p in changed:
    if p!=CARD:assert decode(data['current'][p]['bytes_base64']).split(b'\n---\n',1)[1]==decode(originals[p]['bytes_base64']).split(b'\n---\n',1)[1],'twelve exact fact bodies'
assert sum((ROOT/p).stat().st_size for p in markdown if p.startswith('docs/knowledge/'))==knowledge['knowledge_bytes']==8388337<=8388608
assert sum(bool(re.search(rb'^id:\s+\S+',decode(data['current'][p]['bytes_base64']).split(b'\n---\n',1)[0],re.M)) for p in markdown)==1349
preparation=load('knowledge-preparation.json');producer(preparation,'prepare-knowledge.py')
for p,item in preparation['originals'].items():assert decode(item['bytes_base64'])==old(p) and item['sha256']==sha(old(p))
for p,identity in preparation['current'].items():assert sha(raw(p))==identity
assert set(preparation['originals'])==set(changed)
assert (ROOT/'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md').read_bytes()==old('docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md')
assert not subprocess.check_output(['git','diff',BASE,'--name-only','--','perl','t','scripts','tools','rust','dart','julia','lua','rgx'],cwd=ROOT),'no runtime/test/checker/dependency changes'
for name in ('preserve.py','baseline.json','preservation.json','measure.py','measurement.json','admit.py','plan.json',
    'controls.pl','controls.json','capture-controls.py','controls-final.pl','controls-final.json','capture-controls-final.py',
    'control-census.py','control-census.json','prepare-knowledge.py','knowledge-preparation.json','knowledge.py','knowledge.json',
    'knowledge-inputs.json.gz','book.py','book.json','book-review.py','book-review.json','review.py'):raw(PREFIX+name)
for p in ('scripts/check_readme_routing_pressure.pl','tools/roll_document_history.pl','tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh','KNOWLEDGE_MAP.md'):raw(p)
objects.stdin.close();objects.stdout.close();assert objects.wait()==0
report=dict(result='PASS',base=BASE,producer_sha256=sha(raw(PREFIX+'review.py')),
    population=dict(original_claim_inputs=565,original_claim_bytes=129686,unchanged_prior_files=230,
        original_observation_inputs=1980,rolled_observation_inputs=1981,archive_lines=257,archive_bytes=26898,
        current_lines=111,current_bytes=32530,numeric_observations=60,authority_red=31,
        knowledge_markdown=1487,knowledge_facts=1349,knowledge_bytes=8388337,book_inputs=89,book_controls=4),
    inputs={p:sha((ROOT/p).read_bytes()) for p in sorted(inputs)},
    scope='Independent complete source/history/manifest and six-scalar finite registry reconstruction, whole accepted claim custody and actual original baseline. All original-project observations and historical/helper inputs are retained without copied-root portability. Original wrong census is rejected before exact corrected controls. Current Knowledge/book and unchanged runtime sources are checked; exact staged canonical CI/receipt separately governs admission.')
target=ROOT/(PREFIX+'review.json')
if sys.argv[1:]:
    with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
else:assert json.loads(target.read_bytes())==report
print('Finite continuity review PASS:',len(inputs),'inputs;230 prior files;257-line suffix;60 numeric/31 authority controls')
