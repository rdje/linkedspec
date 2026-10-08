"""Add only the measured finite decision-store prerequisite; preserve the rejected candidate."""
from pathlib import Path
import copy
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2-'
REGISTRY = 'doctrine/readme_stability/routes.jsonl'
ADR = 'docs/decisions/0128-replacement-note-history-capacity.md'
REVISION = '47444428a8ceb65cb0ced06625db4eb8a44b8209'

def sha(raw): return hashlib.sha256(raw).hexdigest()
def canonical(value): return json.dumps(value,sort_keys=True,separators=(',',':'))
def original(path): return subprocess.check_output(['git','show',REVISION+':'+path],cwd=ROOT)

red=json.loads((ROOT/(PREFIX+'capacity-routing-red.json')).read_bytes())
assert red['complete'] and red['exit_code']==1 and red['input_boundary_before']==red['input_boundary_after']
assert (ROOT/REGISTRY).read_bytes()==subprocess.check_output(['git','show',':'+REGISTRY],cwd=ROOT), 'retained initial registry'
assert (ROOT/ADR).read_bytes()==subprocess.check_output(['git','show',':'+ADR],cwd=ROOT), 'retained initial decision'
paths=sorted(p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/decisions').glob('*.md'))
before={path:(ROOT/path).read_bytes() for path in paths}
assert len(before)==129 and sum(raw.count(b'\n') for raw in before.values())==13035, 'actual rejected collection independently rederived'
base_rows=[json.loads(line) for line in original(REGISTRY).splitlines()]
old=next(row for row in base_rows if row.get('id')=='decisions')['limits']
assert old['max_files']==128 and old['max_total_lines']==13000
new=copy.deepcopy(old);new['max_files']=len(paths)
text=before[ADR].decode()
tick=chr(96)
def block(limits):
    return ('\n## Decision-collection prerequisite authorization\n\n'
            '- Routed surface: '+tick+'decisions'+tick+'\n'
            '- Previous routed limits: '+tick+canonical(old)+tick+'\n'
            '- New routed limits: '+tick+canonical(limits)+tick+'\n')
context=('The full initial resulting-tree guard rejects this new decision at collection files129/128 and '
         'aggregate lines13035/13000. All prior accepted decision records are immutable. Removing an accepted '
         'record or omitting the required new indexed decision cannot meet the policy. Admit only this one '
         'additional decision file and its measured final aggregate-line allowance, with all other decision '
         'limits, ownership, lifecycle, verifier and bytes unchanged. The complete initial staged graph/delta '
         'and actual guarded RED remain retained, including the initial claim and its previously omitted '
         'continuity guard inputs.\n\n')
assert '\n## Context\n\n' in text and '## Decision-collection prerequisite authorization' not in text
text=text.replace('\n## Context\n\n',block(new)+'\n## Context\n\n'+context,1)
text=text.replace('Preserve every other control, surface, field and prior immutable byte.',
                  'Preserve every other engineering-note control and prior immutable byte; the two finite decision-store controls are separately authorized above.')
text=text.replace('One archive member and one exact row are admitted.',
                  'One archive member, one exact manifest row and one additional decision file are admitted under five exact scalar changes.')
projected={**before,ADR:text.encode()}
new['max_total_lines']=sum(raw.count(b'\n') for raw in projected.values())
placeholder='- New routed limits: '+tick+canonical({**old,'max_files':len(paths)})+tick
replacement='- New routed limits: '+tick+canonical(new)+tick
assert text.count(placeholder)==1
text=text.replace(placeholder,replacement)
assert sum(raw.count(b'\n') for raw in {**before,ADR:text.encode()}.values())==new['max_total_lines'], 'stable exact final line budget'
(ROOT/ADR).write_text(text)
lines=(ROOT/REGISTRY).read_bytes().splitlines(keepends=True)
changes=0
for i,line in enumerate(lines):
    row=json.loads(line)
    if row.get('id')!='decisions':continue
    assert row['limits']==old
    row['limits']=new
    # Preserve the selected row's existing key order as well as every unrelated byte.
    lines[i]=(json.dumps(row,separators=(',',':'))+'\n').encode();changes+=1
assert changes==1
(ROOT/REGISTRY).write_bytes(b''.join(lines))
after={path:(ROOT/path).read_bytes() for path in paths}
assert all(after[path]==raw for path,raw in before.items() if path!=ADR), 'every previous accepted decision/index byte'
record={'complete':True,'revision':REVISION,'producer_sha256':sha(Path(__file__).read_bytes()),
        'old_decision_limits':old,'new_decision_limits':new,
        'initial_collection':{'files':len(before),'lines':sum(raw.count(b'\n') for raw in before.values()),'bytes':sum(map(len,before.values()))},
        'final_collection':{'files':len(after),'lines':sum(raw.count(b'\n') for raw in after.values()),'bytes':sum(map(len,after.values()))},
        'initial_decision_sha256':sha(before[ADR]),'final_decision_sha256':sha(after[ADR]),
        'unchanged_other_decision_inputs':{path:sha(raw) for path,raw in before.items() if path!=ADR},
        'scope':'Two measured decision-store scalars compose with the retained three engineering-note scalars. Original rejected staged graph/delta and input hashes remain exact; no accepted prior decision, other control, parser, test, book, checker, hook or dependency changes. Final source-bound composition review and canonical admission remain required.'}
(ROOT/(PREFIX+'capacity-composition.json')).write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps({'complete':True,'old_limits':old,'new_limits':new,'final_decision_collection':record['final_collection']}))
