"""Preserve completed private handoff before mapped replacement edits."""
from pathlib import Path
import copy, hashlib, json, re, subprocess
ROOT=Path(__file__).resolve().parents[2]
LEAF='SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1'
PREFIX='docs/checkpoints/'+LEAF+'-'
REVISION='6feff5d40a7e0554425314c120d7ce2b73586a49'
PRIOR='SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0'
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
assert original['mode']=='live' and len(original['inputs'])==127
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
node+='\n  Activation: Clean6feff5d40; focused private handoff, normal ten-doctrine hooks, post-commit first-parent pointer and empty brief verified. All127 private-handoff inputs match current and exact owning Git bytes; prior claim changes mode/revision only before any bound file mutation.\n'
node+='  Owned paths: RewritePipeline.pm private original interval/edit translation only; SourceOrigins remains an unchanged input. Exact leaf-prefixed authored cases/probes/fixture, complete regular Git snapshots, channels/review/claim; prior private-handoff mode/revision-only preservation; relevant book/Knowledge and task/index/roadmaps/live/resume/change/notes. Preserve family order, public fields/signatures, original callbacks/args/refs, native/fresh effects/errors and dependency/CI ownership.\n'
node+='  Verification tier: `focused`\n'
node+='  Focused checks: Source-identical quoted/generated/interleaved/duplicate/nested/raw/newline/closure native/fresh replacement RED/GREEN; actual interval/edit/separator/unknown-origin callback controls; effective production inverse controls and independent input recovery; six unchanged consumers and direct private handoff recurrence, required Phase0/syntax, doctrines, memory/Knowledge/history/diff and book render.\n'
node+='  Canonical trigger: none; independent committed replacement admission remains .0.3.2, then recurring .0.4 and diagnostic origin.\n'
node+='  Claim verification: `docs/claims/'+LEAF+'.json`\n'
node+='  History scope: Clean CHANGES has58564/65536 bytes, below the58982-byte rollover boundary. Keep this leaf’s new complete summary within418 bytes and put detailed proof in its canonical task/book/claim; no prior record shortening or capacity change. Independent admission may own a subsequent mandatory rollover.\n'
task=task[:start]+node+task[end:]
task=task.replace('| `'+LEAF+'` | `pending` | Mapped replacement and original-order ownership. |','| `'+LEAF+'` | `active` | Author source-identical interval/edit translation RED before repair. |')
taskpath.write_text(task)
m=(ROOT/'MEMORY.md').read_text()
fields={'activation_commit':'`'+REVISION+'` — clean private occurrence handoff.',
'active_work_unit':'`'+LEAF+'` (active) — private original occurrence handoff.',
'next_action':'Author exact interval/edit/newline/quote/occurrence and native/fresh RED before changing replacement. Translate recorded original spans through actual prior edits, preserve family order and opaque fallback, then focused proof/book/continuity and commit before independent admission.',
'in_flight_uncommitted':'Mapped replacement activated;127 original private-handoff inputs preserved mode/revision only. Authored RED and production interval/edit translation remain pending.'}
for key,value in fields.items(): m=re.sub(r'^- '+key+r':.*$', '- '+key+': '+value,m,flags=re.M)
(ROOT/'MEMORY.md').write_text(m)
result={'complete':True,'revision':REVISION,'producer_sha256':sha(Path(__file__).read_bytes()),'prior_path':path,'original_sha256':sha(raw),'frozen_sha256':sha((ROOT/path).read_bytes()),'inputs_verified':127,'change':'durability mode/revision only; every original field/input hash preserved','production_unchanged':True}
(ROOT/(PREFIX+'activation.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
