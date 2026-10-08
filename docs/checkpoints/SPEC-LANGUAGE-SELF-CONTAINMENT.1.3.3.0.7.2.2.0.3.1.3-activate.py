"""Preserve exact prior claim boundaries before activating accepted-state repair."""
from pathlib import Path
import copy
import hashlib
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3'
PREFIX = 'docs/checkpoints/'+LEAF+'-'
REVISION = 'eb6d0d6ea7b88d13ebe669a507b3126d7508c0eb'
TASK = 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'

def sha(raw): return hashlib.sha256(raw).hexdigest()
def git(*args): return subprocess.check_output(['git',*args],cwd=ROOT)

assert git('rev-parse','HEAD').decode().strip() == REVISION
assert git('diff','--binary') == b'' and git('diff','--cached','--binary') == b''
assert git('ls-files','--others','--exclude-standard').decode().splitlines() == [PREFIX+'activate.py'], 'only this owned activation producer after clean boundary'
assert (ROOT/'git_message_brief.txt').read_bytes() == b''
task = (ROOT/TASK).read_text()
start = task.index('- ID: `'+LEAF+'`'); end = task.index('\n- ID: ',start+1)
node = task[start:end]
assert 'Status: `pending`' in node and 'Freeze bound prior claims mode/revision only' in node

records = [
    ('SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0','11f6a87d136ce213899ca6a0cd98cf3f0833f720',210),
    ('SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2',REVISION,237),
]
changes = []
for owner,revision,count in records:
    path = 'docs/claims/'+owner+'.json'
    original_bytes = (ROOT/path).read_bytes()
    record = json.loads(original_bytes); frozen = copy.deepcopy(record)
    assert len(record['claims']) == 1
    durable = record['claims'][0]['durability']
    assert durable['mode'] == 'live' and len(durable['inputs']) == count
    for item in durable['inputs']:
        assert sha((ROOT/item['path']).read_bytes()) == item['sha256'], 'unchanged live input '+item['path']
        assert sha(git('show',revision+':'+item['path'])) == item['sha256'], 'exact original committed input '+item['path']
    frozen['claims'][0]['durability'].update(mode='historical',revision=revision)
    inverse = copy.deepcopy(frozen)
    inverse['claims'][0]['durability']['mode'] = 'live'
    del inverse['claims'][0]['durability']['revision']
    assert inverse == record, 'mode/revision only; no new measurement, producer or hash refresh'
    changes.append((path,original_bytes,frozen,revision,count))

# Preserve all original hashes before changing any bound continuity or checker input.
for path,original_bytes,frozen,revision,count in changes:
    (ROOT/path).write_text(json.dumps(frozen,indent=2)+'\n')

node = node.replace('Status: `pending`','Status: `active`',1)
node += ('\n  Activation: Clean '+REVISION+'; capacity canonical receipt, all ten normal hooks, first-parent pointer and empty brief pass. Prior diagnosis210 freezes at11f6a87d1 and capacity237 at eb6d0d6ea by mode/revision only; every original input hash matches both current bytes and its original committed home before mutation.\n'
         '  Owned paths: Accepted-state admission in scripts/check_readme_routing_pressure.pl and scripts/check_readme_stability.sh; exact leaf-prefixed probes, full resulting-tree fixtures, reviewers/channels and claim; prior claim mode/revision-only preservation; relevant Toolbox/book/Knowledge/task/index/roadmap/live/resume/change/notes. No runtime/parser/schema/dependency/capacity changes.\n'
         '  Verification tier: `canonical`\n'
         '  Focused checks: Actual source-bound authorization and full resulting-tree admission before/after; accepted/proposed/missing/duplicate status, exact index/old/new markers and independent pressure oracles; source inverse controls, historical hash preservation, syntax, book render, Knowledge/memory/history/diff and normal doctrines.\n'
         '  Canonical trigger: README/routing doctrine implementation; exact staged canonical receipt and normal hooks precede private occurrence handoff.\n'
         '  Claim verification: `docs/claims/'+LEAF+'.json`\n'
         '  Additional diagnosis candidates: The initial route-registry authority branch and both new/initial README-cap authority helpers also omit an explicit Status predicate on inspection. Exercise actual source-bound branches and complete resulting-tree paths before classifying their impact or changing them; retain independent hash/pressure defenses and never infer a global doctrine bypass. Own necessary accepted-state repairs within this coherent admission leaf, splitting before unsafe growth.\n')
task = task[:start]+node+task[end:]
task = task.replace('| `'+LEAF+'` | `pending` | Actual accepted-state guard gap; compose and repair before private handoff. |',
                    '| `'+LEAF+'` | `active` | Preserve prior boundaries; verify complete accepted-state admission before repair. |')
(ROOT/TASK).write_text(task)
memory = (ROOT/'MEMORY.md').read_text()
memory = re.sub(r'^- activation_commit:.*$', '- activation_commit: `'+REVISION+'` — clean finite capacity admission.',memory,flags=re.M)
memory = re.sub(r'^- active_work_unit:.*$', '- active_work_unit: `'+LEAF+'` (active) — accepted-state admission diagnosis and repair.',memory,flags=re.M)
memory = re.sub(r'^- next_action:.*$', '- next_action: Retain actual full resulting-tree and authority-branch before observations; preserve accepted positives and distinguish proposed/missing/duplicate Status before the smallest checker repairs. Then source-bound RED/GREEN, book/continuity and exact canonical proof; private handoff remains next.',memory,flags=re.M)
memory = re.sub(r'^- in_flight_uncommitted:.*$', '- in_flight_uncommitted: Accepted-state leaf active; exact diagnosis210/capacity237 original hashes preserved by historical mode/revision only. Before capture and checker repair remain pending.',memory,flags=re.M)
(ROOT/'MEMORY.md').write_text(memory)
result = {'complete':True,'revision':REVISION,'producer_sha256':sha(Path(__file__).read_bytes()),
          'records':[{'path':path,'revision':revision,'inputs_checked':count,'original_sha256':sha(original_bytes),
                      'frozen_sha256':sha((ROOT/path).read_bytes()),'change':'mode/revision only'} for path,original_bytes,frozen,revision,count in changes],
          'scope':'Clean capacity boundary verified before owned activation producer. All447 original inputs match current and exact original Git bytes before any bound input change. No historical measurement, source, channel or input hash refresh; initial unadmitted capacity claim remains unchanged. Accepted-state repair pending.'}
(ROOT/(PREFIX+'activation.json')).write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'complete':True,'original_inputs_checked':447,'owner':LEAF,'production_unchanged':True}))
