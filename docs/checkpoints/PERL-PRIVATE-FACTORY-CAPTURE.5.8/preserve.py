"""Preserve whole accepted live claims before finite-continuity bound writes."""
import base64
import copy
import hashlib
import json
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BASE='54bb5eb65178a57ac6e61e53324c9291863e716d'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.8/'
CLAIM='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.7.json'
OWNED={
    'doctrine/readme_stability/routes.jsonl','docs/decisions/INDEX.md',
    'CHANGES.md','DEVELOPMENT_NOTES.md','MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md',
    'ROADMAP.md','ROADMAP_V2.md','docs/TASK_TREE.md',
    'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md','KNOWLEDGE_MAP.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md',
    'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
    'docs/history/changes/manifest.jsonl',
}
# Current live reverify routes must follow the new complete publication together.
OWNED.update('docs/knowledge/'+name+'.md' for name in (
    'finite-engineering-notes-member-0131','perl-emitcontext-callback-capture',
    'perl-factory-capture-framework','perl-legacy-hash-kind-callback',
    'perl-match-alias-writability','perl-method-assignment-required-capture',
    'perl-method-ast-call-capture','perl-method-block-component-capture',
    'perl-method-default-capture','perl-method-trim-capture',
    'perl-private-emission-foundation','project-root-evidence-filesystem-modes',
    'repo-generated-artifact-cleanup-boundary'))
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
old=lambda p:subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()==BASE
target=ROOT/(PREFIX+'preservation.json');assert not target.exists()
paths=subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--','docs/claims'],cwd=ROOT,text=True).splitlines()
census=[];selected=[];writes=[]
for path in paths:
    raw=old(path);assert (ROOT/path).read_bytes()==raw
    value=json.loads(raw);changed=copy.deepcopy(value);hits=[]
    for index,claim in enumerate(value['claims']):
        durability=claim['durability']
        if durability.get('mode')!='live':continue
        overlap=sorted(OWNED & {item['path'] for item in durability['inputs']})
        if not overlap:continue
        bindings={}
        for item in durability['inputs']:
            source=ROOT/item['path'];payload=source.read_bytes()
            assert source.is_file() and not source.is_symlink()
            assert sha(payload)==item['sha256']==sha(old(item['path']))
            bindings[item['path']]=dict(sha256=item['sha256'],mode=source.stat().st_mode&0o7777,bytes=len(payload))
        hits.append(dict(claim_index=index,overlap=overlap,bindings=bindings))
        changed['claims'][index]['durability'].update(mode='historical',revision=BASE)
    census.append(dict(path=path,sha256=sha(raw),intersections=[dict(claim_index=r['claim_index'],overlap=r['overlap']) for r in hits]))
    if hits:
        selected.append(dict(path=path,sha256=sha(raw),bytes=len(raw),original_base64=encode(raw),hits=hits))
        writes.append((path,(json.dumps(changed,indent=2)+'\n').encode()))
assert [v['path'] for v in selected]==[CLAIM]
assert selected[0]['bytes']==129686 and len(selected[0]['hits'])==1 and len(selected[0]['hits'][0]['bindings'])==565
command=['bash','tools/run_python_project_data.sh','docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/publish.py']
run=subprocess.run(command,cwd=ROOT,capture_output=True)
baseline=dict(command=command,returncode=run.returncode,stdout_base64=encode(run.stdout),stderr_base64=encode(run.stderr))
with (ROOT/(PREFIX+'baseline.json')).open('x') as output:output.write(json.dumps(baseline,indent=2)+'\n')
assert run.returncode==0 and not run.stderr
assert run.stdout==b'Corrected default publication PASS: 565 live inputs; 129686 bytes\n'
assert all(sha((ROOT/p).read_bytes())==v['sha256'] for p,v in selected[0]['hits'][0]['bindings'].items())
record=dict(result='PASS',base=BASE,producer_sha256=sha(Path(__file__).read_bytes()),
    owned_bound_paths=sorted(OWNED),census=census,selected=selected,baseline=baseline,
    scope='Complete accepted Git claim namespace and whole129686-byte publication; all565 original binding bytes and actual filesystem modes checked before any bound write. Accepted Git retains every producer/input byte. Only durability mode/revision changes, with no refreshed prior observation or fabricated historical state. Existing .5.7 logical-draft archive/replay remains untouched; system tools remain read-only environmental dependencies.')
with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
for path,raw in writes:(ROOT/path).write_bytes(raw)
print('Finite continuity preservation PASS: whole565-input/129686-byte claim;actual baseline;mode/revision-only preservation')
