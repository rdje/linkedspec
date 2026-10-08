"""Complete bounded continuity after accepted-state proof, before exact canonical admission."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3'
PREFIX = 'docs/checkpoints/'+LEAF+'-'
SUMMARY = ('Five README/routing authority paths now require one accepted Status field; qualified/bare acceptance and exact index/transition/pressure checks remain. '
           'Original15 component and six full-gate policy violations reject after repair. Nine complete Git-tree gates per epoch, nine effective inverse mutants, ten authority denials,21 pressure boundaries and seven evidence RED pass; all5137 original regular inputs/18 staged boundaries and447 prior historical inputs recover exactly. '
           'Three verification preparation errors retain exact sources/actual recurrences. No cap/runtime changes; exact canonical receipt and normal hooks govern admission.')
NEXT = ('Activate .3.1.0 from clean committed HEAD; freeze this live guard claim mode/revision only before bound inputs change, then author private original-origin/ref/copy/frame RED/GREEN. '
        'Keep replacement behavior unchanged; mapped .1.1, independent .2, recurring .0.4, diagnostics and comments follow.')
record_path = ROOT/(PREFIX+'continuity.json')
assert not record_path.exists(), 'one-shot continuity adaptation'
review = json.loads((ROOT/(PREFIX+'verification.json')).read_bytes())
assert review['complete'] and review['complete_full_gate_observations_each_epoch'] == 9
paths = ['CHANGES.md','DEVELOPMENT_NOTES.md','LIVE_ACHIEVEMENT_STATUS.md','ROADMAP.md','ROADMAP_V2.md','docs/TASK_TREE.md','docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md']
def sha(raw): return hashlib.sha256(raw).hexdigest()
before = {path:sha((ROOT/path).read_bytes()) for path in paths}

for path,title,body in [('CHANGES.md','2026-10-08 — '+LEAF+' - require accepted README routing decisions',SUMMARY+' Full sources/channels, original errors and independent recovery remain under the leaf checkpoint prefix; the book explains the authority rule.'),
                        ('DEVELOPMENT_NOTES.md','2026-10-08 — Accepted decision status (.0.3.1.3)',
                         'Exact indexed markers formerly authorized proposed, missing and duplicate Status across five paths. Unique accepted-state checks now guard both implementations; independent cap Git fixtures avoid earlier routed-limit refusal masking the cap branch. Keep original capture/review sources and error channels separate, recover declared modes and initialize private HEAD before read-tree. No policy cap or parser/runtime movement.')]:
    target = ROOT/path
    text = target.read_text()
    match = re.search(r'^## ',text,re.M)
    assert match and LEAF not in text[:match.start()]
    target.write_text(text[:match.start()]+'## '+title+'\n\n'+body+'\n\n'+text[match.start():])

target = ROOT/'LIVE_ACHIEVEMENT_STATUS.md'
text = target.read_text()
for heading,content in [('Current Activity','Full PNT: accepted-state guard verified; private occurrence handoff and mapped replacement next.'),
                        ('Latest Completed Slice','`'+LEAF+'` — '+SUMMARY),('Next Action',NEXT)]:
    text,count = re.subn(r'(## '+re.escape(heading)+r'\n\n).*?(?=\n## )',lambda match:match.group(1)+content+'\n',text,count=1,flags=re.S)
    assert count == 1
match = re.search(r'(## Recent Completions\n\n)(.*?)(?=\n## History)',text,re.S)
assert match
rows = ['- `'+LEAF+'` — five accepted-state paths; complete Git-tree RED/GREEN, source inverses and original input recovery.']+match.group(2).strip().splitlines()
assert all(row.startswith('- ') for row in rows)
text = text[:match.start(2)]+'\n'.join(rows[:16])+'\n'+text[match.end(2):]
target.write_text(text)

for path in ('ROADMAP.md','ROADMAP_V2.md','docs/TASK_TREE.md'):
    target = ROOT/path
    lines = target.read_text().splitlines(keepends=True)
    indices = [i for i,line in enumerate(lines) if line.startswith('| '+('`SPEC-LANGUAGE-SELF-CONTAINMENT`' if path == 'docs/TASK_TREE.md' else 'Expressive `.spec` self-containment')+' |')]
    assert len(indices) == 1
    i = indices[0]
    if path == 'docs/TASK_TREE.md':
        lines[i] = '| `SPEC-LANGUAGE-SELF-CONTAINMENT` | `active: private occurrence handoff next` | `.spec language evolution / expressive self-containment and alternate authoring profiles` | '+SUMMARY+' Next: '+NEXT+' | [docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md](docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md) |\n'
    else: lines[i] = '| Expressive `.spec` self-containment | `active: private occurrence handoff next` | '+SUMMARY+' | '+NEXT+' |\n'
    target.write_text(''.join(lines))

target = ROOT/'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
text = target.read_text()
for heading,entry in [('Verification Log','October8 `'+LEAF+'`: '+SUMMARY),
                      ('Commit Log','- `'+LEAF+' - require accepted README routing decisions` — accepted-state infrastructure; exact canonical receipt and normal hooks gate landing; Git owns identity.'),
                      ('Changelog','- `2026-10-08`: .0.3.1.3 verifies five-path accepted-state admission; before/after complete input/channel proof retained. Private handoff remains next; no runtime/cap/readiness promotion.')]:
    marker = '## '+heading+'\n'
    assert text.count(marker) == 1
    text = text.replace(marker,marker+'\n'+entry+'\n',1)
target.write_text(text)
result = {'complete':True,'producer_sha256':sha(Path(__file__).read_bytes()),'proof_sha256':sha((ROOT/(PREFIX+'verification.json')).read_bytes()),
          'document_hashes_before':before,'document_hashes_after':{path:sha((ROOT/path).read_bytes()) for path in paths},
          'scope':'One-shot routine continuity adaptation after complete verified proof. Current final documents are explicit claim/publisher inputs; this journal does not claim an independently replayed intermediate document state. No earlier notes/history/decision bytes are edited; pressure checks and exact canonical admission remain required.'}
record_path.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'complete':True,'documents':len(paths),'canonical_pending':True}))
