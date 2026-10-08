"""Preserve the completed guard claim before private origin handoff edits."""
from pathlib import Path
import copy, hashlib, json, re, subprocess
ROOT=Path(__file__).resolve().parents[2]
LEAF='SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0'
PREFIX='docs/checkpoints/'+LEAF+'-'
REVISION='32169d1282effa083a431b17b11c436fdd862771'
PRIOR='SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3'
def sha(raw): return hashlib.sha256(raw).hexdigest()
def git(*args): return subprocess.check_output(['git',*args],cwd=ROOT)
assert git('rev-parse','HEAD').decode().strip()==REVISION
assert not git('diff','--binary') and not git('diff','--cached','--binary')
assert git('ls-files','--others','--exclude-standard').decode().splitlines()==[PREFIX+'activate.py']
assert not (ROOT/'git_message_brief.txt').read_bytes()
path='docs/claims/'+PRIOR+'.json'
raw=(ROOT/path).read_bytes(); record=json.loads(raw)
assert raw==git('show',REVISION+':'+path)
assert len(record['claims'])==1
original=record['claims'][0]['durability']
assert original['mode']=='live' and len(original['inputs'])==81
for item in original['inputs']:
    assert sha((ROOT/item['path']).read_bytes())==item['sha256'],item['path']
    assert sha(git('show',REVISION+':'+item['path']))==item['sha256'],item['path']
frozen=copy.deepcopy(record)
frozen['claims'][0]['durability'].update(mode='historical',revision=REVISION)
inverse=copy.deepcopy(frozen); d=inverse['claims'][0]['durability']; d['mode']='live'; del d['revision']
assert inverse==record
(ROOT/path).write_text(json.dumps(frozen,indent=2)+'\n')
taskpath=ROOT/'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
task=taskpath.read_text(); start=task.index('- ID: `'+LEAF+'`'); end=task.index('\n- ID: ',start+1)
node=task[start:end]; assert 'Status: `pending`' in node
node=node.replace('Status: `pending`','Status: `active`',1)
node+='\n  Activation: Clean32169d1282; normal ten-doctrine hooks, promoted canonical receipt, post-commit first-parent pointer and empty brief verified. Guard81 inputs match current and exact owning Git bytes; prior claim changes mode/revision only before any bound file mutation.\n'
node+='  Owned paths: New private SourceOrigins.pm; Scanner.pm, Diagnostics.pm, CanonicalEvents.pm, CanonicalEvents/Core.pm and RewritePipeline.pm capture/copy/frame seams only. Exact leaf-prefixed authored fixture, complete regular Git snapshots, channels/review/claim; prior guard mode/revision-only preservation; relevant book/Knowledge and task/index/roadmaps/live/resume/change/notes. No replacement search/edit, public field/signature, dependency or CI registration change.\n'
node+='  Verification tier: `focused`\n'
node+='  Focused checks: Authored actual scanner/copy/frame/reference/context/error/reentrant RED/GREEN, source-identical before/after public native/fresh/diagnostic corpus, effective production inverse controls and independent input recovery; six unchanged consumers, required Phase0/syntax, doctrines, memory/Knowledge/history/diff and book render.\n'
node+='  Canonical trigger: none; independent replacement admission remains .0.3.2 after mapped repair .1.1.\n'
node+='  Claim verification: `docs/claims/'+LEAF+'.json`\n'
taskpath.write_text(task[:start]+node+task[end:])
m=(ROOT/'MEMORY.md').read_text()
fields={'activation_commit':'`'+REVISION+'` — clean accepted-state guard admission.',
'active_work_unit':'`'+LEAF+'` (active) — private original occurrence handoff.',
'next_action':'Author and retain original-origin/ref/copy/frame RED before production edits; then implement private capture/copy/frame scope while leaving replacement unchanged, prove public compatibility and focused commit.',
'in_flight_uncommitted':'Private handoff activated; guard81 original inputs preserved mode/revision only. Authored RED and production handoff remain pending.'}
for key,value in fields.items(): m=re.sub(r'^- '+key+r':.*$', '- '+key+': '+value,m,flags=re.M)
(ROOT/'MEMORY.md').write_text(m)
result={'complete':True,'revision':REVISION,'producer_sha256':sha(Path(__file__).read_bytes()),'prior_path':path,'original_sha256':sha(raw),'frozen_sha256':sha((ROOT/path).read_bytes()),'inputs_verified':81,'change':'durability mode/revision only; every original field/input hash preserved','production_unchanged':True}
(ROOT/(PREFIX+'activation.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
