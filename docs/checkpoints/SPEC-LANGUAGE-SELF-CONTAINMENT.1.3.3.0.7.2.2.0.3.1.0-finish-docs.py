"""Publish bounded continuity for the verified private handoff; preserve replacement ownership."""
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parents[2]
LEAF='SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0'
PREFIX='docs/checkpoints/'+LEAF+'-'
proof=json.loads((ROOT/(PREFIX+'verification.json')).read_bytes())
assert proof['complete'] and proof['original_regular_inputs']==5185 and proof['public_pairs']==42
assert proof['source_inverse_controls']==11 and len(proof['evidence_controls'])==8
summary='Private original occurrence authority now survives selected scanner events, diagnostic/canonical copies and actual splitter frames within one rewrite invocation. Corrected RED7/GREEN10,42 exact public pairs,144 unchanged consumer groups per epoch,11 source inverse controls and eight evidence RED pass; all5185 original regular inputs and81 prior guard hashes recover. Replacement behavior remains unchanged.'
next_action='Activate mapped replacement .3.1.1 from clean committed HEAD; preserve this private claim mode/revision only before bound inputs change. Check finite history headroom before authoring interval/edit-translation RED, then repair selected original occurrences without changing family order or public contracts.'
for filename in ('CHANGES.md','DEVELOPMENT_NOTES.md'):
    path=ROOT/filename;text=path.read_text();start=text.index('\n## ')
    if filename=='CHANGES.md':
        record='\n## 2026-10-08 — Private occurrence handoff (.0.3.1.0)\n\n'+summary+' Complete producers/channels and independent recovery: '+PREFIX+'verification.json. Two instrument/import corrections retain their original bytes and actual channels; the interrupted after capture is not acceptance.\n'
    else:
        record='\n## 2026-10-08 — Private origins before mapped replacement (.0.3.1.0)\n\nRetain actual event references strongly in invocation-local source authority; copy coordinates only from recorded identities. Canonical synthetic events use returned-array/index frames, never helper raw-key guesses. Preserve callback scalar context and its successful error effect across the private collector. Correct only the authored copied-array cardinality and Core standalone import root; retain original sources/channels and restart final capture. Actual replacement stays unchanged for .1.1.\n'
    path.write_text(text[:start]+record+text[start:])
path=ROOT/'LIVE_ACHIEVEMENT_STATUS.md';text=path.read_text()
for header,body in [('Current Activity','Full PNT: private occurrence handoff verified; mapped interval replacement next, then independent acceptance/recurring/diagnostic/comment owners.'),('Latest Completed Slice','`'+LEAF+'` — '+summary),('Next Action',next_action)]:
    text=re.sub(r'(## '+header+r'\n\n).*?(?=\n## )',lambda match:match[1]+body+'\n',text,flags=re.S)
start=text.index('## Recent Completions\n\n')+len('## Recent Completions\n\n');end=text.index('\n## History',start)
rows=[line for line in text[start:end].splitlines() if line.startswith('- ')]
rows=['- `'+LEAF+'` — actual origin/copy/frame RED7/GREEN10; public42/consumer144;11 source inverses/eight evidence RED.']+rows
text=text[:start]+'\n'.join(rows[:16])+'\n'+text[end:];path.write_text(text)
for filename in ('ROADMAP.md','ROADMAP_V2.md','docs/TASK_TREE.md'):
    path=ROOT/filename;text=path.read_text()
    lines=text.splitlines(keepends=True)
    for i,line in enumerate(lines):
        if line.startswith('| Expressive `.spec` self-containment |'):
            lines[i]='| Expressive `.spec` self-containment | `active: mapped replacement next` | '+summary+' | '+next_action+' |\n'
        elif line.startswith('| `SPEC-LANGUAGE-SELF-CONTAINMENT` |'):
            lines[i]='| `SPEC-LANGUAGE-SELF-CONTAINMENT` | `active: mapped replacement next` | `.spec language evolution / expressive self-containment and alternate authoring profiles` | '+summary+' Next: '+next_action+' | [docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md](docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md) |\n'
    path.write_text(''.join(lines))
path=ROOT/'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md';text=path.read_text();start=text.index('- ID: `'+LEAF+'`');end=text.index('\n- ID: ',start+1)
node=text[start:end];assert 'Status: `active`' in node;node=node.replace('Status: `active`','Status: `done`',1)
node+='\n  Verification: Corrected authored original fixture RED7/10, final GREEN10/10; eleven effective source inverses reach named assertions. Four complete supplied graphs independently recover all5185 original regular Git entries plus exact epoch overlays. Forty-two complete public before/after pairs preserve AST/source/args/reference relations, generated code, diagnostics and native/fresh values/errors/effects; only exact owner locator, independently source-validated one-line import offset and dated trace-prefix clocks normalize. Six unchanged suites pass144 groups in each epoch. Eight content/history/input/channel controls reject. Original pipeline restores byte-for-byte after removing only invocation/import wrapping; search/edit logic stays untouched. Guard81 verifies original Git/current hashes before mode/revision-only freeze.\n'
node+='  Corrections: Original copied-array expectation and first Core import version remain exact tracked sources with complete actual channels. Only copied flags [0]→[0,0] and Core module-directory starting point change; standalone no-I syntax has actual RED/GREEN. Initial after tree/runs/log stays incomplete; final fresh capture is the accepted proof.\n'
node+='  Public/lockstep: The book explains private handoff without claiming the quoted-first repair or readiness. Knowledge, bounded live/change/notes, roadmap/index/task/resume and watched claim are synchronized. Required Phase0/syntax, book render, histories, memory/Knowledge/diff and normal doctrines govern focused landing. Recurring CI ownership remains .0.4; mapped replacement .1.1 precedes independent .0.3.2 canonical acceptance.\n'
node+='  Commit: `'+LEAF+' - preserve private original occurrence authority` (Git owns identity).\n'
text=text[:start]+node+text[end:]
text=text.replace('| `'+LEAF+'` | `active` | Authored occurrence/ref/copy/frame proof before private handoff edits. |','| `'+LEAF+'` | `done` | Invocation-local origin/copy/frame RED/GREEN; replacement unchanged. |')
path.write_text(text)
path=ROOT/'MEMORY.md';text=path.read_text()
values={'latest_completed_leaf':'`'+LEAF+' - preserve private original occurrence authority`.','active_work_unit':'`'+LEAF+'` (done) — private occurrence authority verified; mapped replacement next.','next_action':next_action,'in_flight_uncommitted':'none; completed private handoff/proof/book/continuity is committed under focused verification. Continue full PNT with mapped replacement, independent acceptance, recurring ownership, diagnostics and comments.'}
for key,value in values.items():text=re.sub(r'^- '+key+r':.*$','- '+key+': '+value,text,flags=re.M)
path.write_text(text)
print('Bounded private handoff continuity prepared; required verification/normal hooks govern landing.')
