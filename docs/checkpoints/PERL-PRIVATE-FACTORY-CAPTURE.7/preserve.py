"""Preserve complete intersecting live evidence before canonical registration writes."""
import base64
import copy
import hashlib
import json
import subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BASE='858eba97c89239d187765c4af9ad18057d28a1b0'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
CLAIM='docs/claims/REPO-HYGIENE.19.json'
prior=json.loads((ROOT/'docs/checkpoints/REPO-HYGIENE.19/preservation.json').read_bytes())
OWNED={p for p in prior['owned_bound_paths'] if p.startswith('docs/knowledge/')}
OWNED.update({'docs/knowledge/perl-receiver-copy-canonical-selection.md',
    'tools/run_ci_local.sh','tests/language-readiness/verify_objectives.py',
    'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md','docs/TASK_TREE.md','MEMORY.md',
    'ROADMAP.md','ROADMAP_V2.md','CHANGES.md','DEVELOPMENT_NOTES.md','LIVE_ACHIEVEMENT_STATUS.md',
    'KNOWLEDGE_MAP.md','docs/linkedspec-book/src/development/documentation-workflow.md'})
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
old=lambda p:subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()==BASE
target=ROOT/(PREFIX+'preservation.json');assert not target.exists()
names=subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--','docs/claims'],cwd=ROOT,text=True).splitlines()
census=[];selected=[];writes=[]
for p in names:
    value=old(p);assert (ROOT/p).read_bytes()==value
    source=json.loads(value);changed=copy.deepcopy(source);hits=[]
    for index,claim in enumerate(source['claims']):
        d=claim['durability']
        if d.get('mode')!='live':continue
        overlap=sorted(OWNED & {v['path'] for v in d['inputs']})
        if not overlap:continue
        bindings={}
        for item in d['inputs']:
            path=ROOT/item['path'];data=path.read_bytes()
            assert path.is_file() and not path.is_symlink()
            assert sha(data)==item['sha256']==sha(old(item['path']))
            bindings[item['path']]=dict(sha256=item['sha256'],bytes=len(data),mode=path.stat().st_mode&0o7777)
        hits.append(dict(claim_index=index,overlap=overlap,bindings=bindings))
        changed['claims'][index]['durability'].update(mode='historical',revision=BASE)
    census.append(dict(path=p,sha256=sha(value),intersections=[dict(claim_index=v['claim_index'],overlap=v['overlap']) for v in hits]))
    if hits:
        selected.append(dict(path=p,sha256=sha(value),bytes=len(value),original_base64=encode(value),hits=hits))
        writes.append((p,(json.dumps(changed,indent=2)+'\n').encode()))
assert [v['path'] for v in selected]==[CLAIM]
assert selected[0]['bytes']==43696 and len(selected[0]['hits'])==1 and len(selected[0]['hits'][0]['bindings'])==175
assert not any('docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md' in v['overlap'] for row in census for v in row['intersections'])
command=['bash','tools/run_python_project_data.sh','docs/checkpoints/REPO-HYGIENE.19/publish.py']
run=subprocess.run(command,cwd=ROOT,capture_output=True)
baseline=dict(command=command,returncode=run.returncode,stdout_base64=encode(run.stdout),stderr_base64=encode(run.stderr))
with (ROOT/(PREFIX+'baseline.json')).open('x') as output:output.write(json.dumps(baseline,indent=2)+'\n')
assert run.returncode==0 and not run.stderr
assert run.stdout==b'Retained metadata/output publication PASS: 175 live inputs; 43696 bytes\n'
assert all(sha((ROOT/p).read_bytes())==v['sha256'] for p,v in selected[0]['hits'][0]['bindings'].items())
record=dict(result='PASS',base=BASE,producer_sha256=sha(Path(__file__).read_bytes()),
    owned_bound_paths=sorted(OWNED),census=census,selected=selected,baseline=baseline,
    activation_only_unbound_paths=['docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md'],
    scope='Fixed accepted claim namespace, whole175-input/43696-byte publication and successful actual baseline before all bound writes. Every binding byte and actual mode matches accepted Git. Only durability mode/revision changes; original producers/observations stay at the real accepted boundary. Activation task edits are explicitly unbound; resume pointers are not measured inputs.')
with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
for p,value in writes:(ROOT/p).write_bytes(value)
print('Fixture preservation PASS:whole175/full43696;actual baseline;fixed namespace;mode/revision only')
