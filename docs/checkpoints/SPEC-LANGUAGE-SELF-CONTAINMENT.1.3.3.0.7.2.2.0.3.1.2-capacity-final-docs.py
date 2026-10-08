"""Publish composed continuity after retaining the rejected three-scalar candidate."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2'
PREFIX = 'docs/checkpoints/'+LEAF+'-'
TASK = 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md'
SUMMARY = ('One governed rollover preserves clean 47444428a lines 155–256 as 102 lines/27,567 bytes; all 42 prior archives and rows remain exact. '
           'Engineering collection: 45 files/28,934 lines/3,225,109 bytes; manifest 44 lines/26,633 bytes. '
           'The initial full routing gate rejects decisions at 129/128 files and 13,035/13,000 lines. Its complete 5,119-file staged graph/delta, original 78-input claim and seven omitted continuity guards recover exactly; the initial candidate remains unadmitted. '
           'Accepted indexed ADR0128 composes five finite scalars: engineering files 44→45, manifest lines 43→44/bytes 26,021→26,633, decision files 128→129/aggregate lines 13,000→13,043. All prior accepted decisions and other controls remain exact. '
           'Current composition passes 13 evidence RED controls and 12 actual decision thresholds/six authority denials; retained initial proof has 14 evidence RED, 18 thresholds/seven authority denials, five instrument RED and four snapshot RED. '
           'Both initial instrument failures retain exact producers and actual error channels. Proposed/missing-status function observations remain separately owned P1 .3.1.3; no composed bypass or runtime repair is claimed. Exact staged canonical receipt and normal hooks gate landing.')
NEXT = ('Activate SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3 from clean committed HEAD. Freeze the capacity claim mode/revision only before changing its bound inputs; preserve every hash. '
        'Diagnose the complete accepted-state routing path and repair the measured gap with source-bound RED/GREEN and exact canonical proof. Private origin handoff .3.1.0, mapped replacement .1.1 and independent .2 follow; diagnosis210 freezes at 11f6a87d1 before its bound inputs change.')

paths = [TASK,'MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md','docs/TASK_TREE.md','ROADMAP.md','ROADMAP_V2.md','CHANGES.md',
         'docs/knowledge/replacement-repair-engineering-history-capacity.md']
before = {path:(ROOT/path).read_bytes() for path in paths}
changes = {path:blob.decode() for path,blob in before.items()}
review = json.loads((ROOT/(PREFIX+'capacity-composed-verification.json')).read_bytes())
assert review['complete'] and review['changed_scalars'] == 5 and len(review['composition_controls']) == 13
root_hash = hashlib.sha256((ROOT/'DEVELOPMENT_NOTES.md').read_bytes()).hexdigest()
manifest_hash = hashlib.sha256((ROOT/'docs/history/development-notes/manifest.jsonl').read_bytes()).hexdigest()

text = changes[TASK]
start = text.index('- ID: `'+LEAF+'`'); end = text.index('- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3`',start)
node = text[start:end]
assert 'Status: `active`' in node
node = node.replace('Status: `active`','Status: `done`',1)
node = re.sub(r'^  Focused checks:.*$', '  Focused checks: Independently reconstruct exact original root/manifest/archives and prior decisions; verify five scalars only, retained rejected candidate and all actual guard inputs; run current composed evidence controls, actual decision thresholds/authority denials, history/claims/Knowledge/memory/diff and normal doctrines.',node,flags=re.M)
node = re.sub(r'^  Acceptance:.*$', '  Acceptance: Admit one archive, one manifest row and one indexed accepted decision under five measured finite controls. Preserve all other fields, budgets, original history and accepted decision bytes; retain the original unadmitted candidate and errors without refreshing them. Exact canonical proof precedes clean P1 accepted-state guard work.',node,flags=re.M)
node = re.sub(r'^  Verification:.*$', '  Verification: '+SUMMARY,node,flags=re.M)
node = re.sub(r'^  Handoff:.*$', '  Handoff: '+NEXT,node,flags=re.M)
node = node.replace('finite three-scalar need.','finite engineering controls; full resulting-tree RED also exposes two decision-store limits.')
node = node.replace('One governed archive/row and exact accepted indexed ADR0128, all other fields/budgets/history bytes unchanged.','One governed archive/row and exact accepted indexed ADR0128 compose five finite controls; all other fields/budgets/history and prior accepted decisions stay unchanged.')
node = re.sub(r'^- \[x\] \*\*ADDRESSED \(verified\)\*\*.*$', '- [x] **ADDRESSED (verified)** — '+SUMMARY,node,flags=re.M)
changes[TASK] = text[:start]+node+text[end:]
changes[TASK] = changes[TASK].replace('| `'+LEAF+'` | `active` | Compose two measured decision-store prerequisites; retain original candidate before canonical proof. |',
                                       '| `'+LEAF+'` | `done` | Five finite controls independently verified; original unadmitted candidate retained. |')

text = changes['MEMORY.md']
text = re.sub(r'^- latest_completed_leaf:.*$', '- latest_completed_leaf: `'+LEAF+' - retain finite replacement-note history`.',text,flags=re.M)
text = re.sub(r'^- active_work_unit:.*$', '- active_work_unit: `'+LEAF+'` (done) — finite composed history/decision capacity.',text,flags=re.M)
text = re.sub(r'^- next_action:.*$', '- next_action: Activate .3.1.3 from clean HEAD; freeze the capacity claim mode/revision only, diagnose the full accepted-state routing path, repair with RED/GREEN and canonical proof. Private handoff .3.1.0 and mapped replacement .1.1 follow.',text,flags=re.M)
text = re.sub(r'^- in_flight_uncommitted:.*$', '- in_flight_uncommitted: None; exact staged canonical receipt and normal hooks govern this completed leaf landing.',text,flags=re.M)
text = re.sub(r'^- current_engineering_notes_capacity:.*$', '- current_engineering_notes_capacity: ADR0128 admits45 files /44 manifest lines /26633 bytes; archive4963 preserves clean47444428a lines155–256. The same finite decision admits129 decision files /13043 aggregate lines; prior accepted records and all other controls stay exact.',text,flags=re.M)
changes['MEMORY.md'] = text

text = changes['LIVE_ACHIEVEMENT_STATUS.md']
text = re.sub(r'(?<=## Current Activity\n\n).*?(?=\n\n## Latest Completed Slice)', 'Full PNT: finite five-scalar capacity verified; accepted-state routing enforcement next, then private handoff and mapped replacement.',text,flags=re.S)
text = re.sub(r'(?<=## Latest Completed Slice\n\n).*?(?=\n\n## Next Action)', '`'+LEAF+'` — '+SUMMARY,text,flags=re.S)
text = re.sub(r'(?<=## Next Action\n\n).*?(?=\n\n## Recent Completions)', NEXT,text,flags=re.S)
text = text.replace('finite archive/row, exact prior history; actual accepted-state gap owns next P1.','five finite controls; rejected original fully recoverable; accepted-state gap next P1.')
changes['LIVE_ACHIEVEMENT_STATUS.md'] = text
for path in ('ROADMAP.md','ROADMAP_V2.md'):
    rows = changes[path].splitlines(keepends=True)
    matches = [i for i,row in enumerate(rows) if row.startswith('| Expressive `.spec` self-containment |')]
    assert len(matches) == 1, 'exact roadmap owner row '+path
    rows[matches[0]] = '| Expressive `.spec` self-containment | `active: accepted-state guard prerequisite` | '+SUMMARY+' | '+NEXT+' |\n'
    changes[path] = ''.join(rows)
rows = changes['docs/TASK_TREE.md'].splitlines(keepends=True)
matches = [i for i,row in enumerate(rows) if row.startswith('| `SPEC-LANGUAGE-SELF-CONTAINMENT` |')]
assert len(matches) == 1
rows[matches[0]] = '| `SPEC-LANGUAGE-SELF-CONTAINMENT` | `active: accepted-state guard prerequisite` | `.spec language evolution / expressive self-containment and alternate authoring profiles` | '+SUMMARY+' Next: '+NEXT+' | [docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md](docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md) |\n'
changes['docs/TASK_TREE.md'] = ''.join(rows)
heading = '## 2026-10-08 — '+LEAF+' - retain finite replacement-note history\n\n'
text = changes['CHANGES.md']; start = text.index(heading)+len(heading); end = text.index('\n\n## ',start)
changes['CHANGES.md'] = text[:start]+SUMMARY+' Exact producers, original channels and recovery inputs are retained under the leaf prefix; no public book or runtime changes.'+text[end:]

card = changes['docs/knowledge/replacement-repair-engineering-history-capacity.md']
card = card.replace('title: One finite engineering-note rollover precedes selected replacement repair','title: Five finite history and decision controls precede selected replacement repair')
card = card.replace('  - "which exact controls changed for engineering segment4963"','  - "which exact controls changed for engineering segment4963"\n  - "why does ADR0128 also change decision collection limits"\n  - "where is the rejected initial capacity candidate recoverable"')
card = re.sub(r'^evidence:.*$', 'evidence: "Five exact finite controls, retained initial routing RED and complete staged recovery, current independent composed proof; all prior archives and accepted decisions remain unchanged."',card,flags=re.M)
card = re.sub(r'^reverify:.*$', 'reverify: "At the owning committed boundary run bash tools/run_python_project_data.sh '+PREFIX+'capacity-composed-review.py and its capacity-snapshot-review.py. The initial capacity-review.py belongs to the rejected three-scalar snapshot; preserve its original outputs rather than running it against the composed registry. Later bound-input changes require historical claim preservation."',card,flags=re.M)
card += ('\nThe full initial routing guard rejects the new decision at 129/128 files and\n'
         '13,035/13,000 aggregate lines. The same finite maintenance decision composes\n'
         'decision files 128→129 and aggregate lines 13,000→13,043. The final decision\n'
         'collection is 129 files/13,043 lines/959,099 bytes; every prior accepted\n'
         'decision and initial index byte stays exact. No other scalar changes.\n\n'
         'The initial candidate is unadmitted. Its complete 5,119-regular-file staged\n'
         'graph and full-index delta recover the original 78-input claim and seven\n'
         'omitted actual continuity guards. Four graph/patch mutations reject.\n'
         'Original first combined routing error has no independently recorded\n'
         'pre-fingerprint; a separate full guarded recurrence retains both channels.\n'
         'Current composed review rejects thirteen corruptions and invokes the\n'
         'unchanged production functions for twelve decision threshold observations\n'
         'and six authority denials. These controls establish finite storage only.\n\n'
         'The initial continuity writer separately stopped at undeclared CURRENT\n'
         'after writing documents. Its exact used source and actual tool-returned\n'
         'combined channel survive; claim-only continuation did not replay writes.\n'
         'Neither original error has separate stdout/stderr available. Current\n'
         'claims include all actual guarded continuity inputs and the complete\n'
         'recovery artifacts; historical sources and observations stay unchanged.\n')
changes['docs/knowledge/replacement-repair-engineering-history-capacity.md'] = card
for path,text in changes.items():
    assert text != before[path].decode(), 'intended document changes '+path
    (ROOT/path).write_text(text)
assert root_hash == hashlib.sha256((ROOT/'DEVELOPMENT_NOTES.md').read_bytes()).hexdigest()
assert manifest_hash == hashlib.sha256((ROOT/'docs/history/development-notes/manifest.jsonl').read_bytes()).hexdigest()
result = {'complete':True,'producer_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
          'guarded_inputs_before':{path:hashlib.sha256(blob).hexdigest() for path,blob in before.items()},
          'guarded_outputs_after':{path:hashlib.sha256((ROOT/path).read_bytes()).hexdigest() for path in paths},
          'engineering_root_sha256':root_hash,'engineering_manifest_sha256':manifest_hash,
          'scope':'One final continuity adaptation after preserved initial rejection; exact root/manifest unchanged. Canonical receipt and hooks still required. No replay of initial failed continuity writer.'}
(ROOT/(PREFIX+'capacity-final-docs-verification.json')).write_text(json.dumps(result,indent=2)+'\n')
print('Composed continuity written; actual engineering root/manifest unchanged; canonical admission pending.')
