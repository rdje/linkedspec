"""Publish bounded finite-capacity evidence and clean intended canonical handoff."""
from pathlib import Path
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
SUBJECT = LEAF + ' - retain finite replacement-note history'
summary = ('Actual pressure RED and governed rollover GREEN preserve clean47444428a lines155–256 '
           'as102 lines/27,567 bytes; all42 prior archives and manifest rows remain exact. '
           'The new root157/31,811 and manifest44/26,633 yield45 files/28,934 lines/3,225,109 bytes. '
           'Only files44→45, manifest lines43→44 and bytes26,021→26,633 change. '
           'Complete history query3,166,665 bytes,14 evidence RED,18 actual thresholds/7 authority RED '
           'and five exact instrument RED pass. Initial wrong-dictionary reviewer/source/combined error '
           'and reached channels remain retained. Two separate proposed/missing-status fixtures expose '
           'four authorizing function answers; P1 .3.1.3 owns composed diagnosis/repair. '
           'ADR0128 is explicitly accepted and independently checked; autonomous maintenance, '
           'no new explicit director grant or unlimited reserve. All other controls, production, tests, '
           'book, dependencies, hooks and checker bytes stay unchanged. Exact staged canonical receipt '
           'and normal hooks govern landing.')
next_action = ('Activate SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3 from clean committed HEAD. '
               'Freeze this capacity claim mode/revision only before changing its bound inputs; retain all original hashes. '
               'Verify the composed accepted-state routing path and repair the measured gap with RED/GREEN and exact '
               'canonical proof. Then private original-origin handoff .3.1.0, mapped replacement .1.1 and independent .2 remain required; '
               'freeze diagnosis210 at11f6a87d1 before changing its bound producers.')
plan = json.loads((ROOT/(PREFIX+'capacity-plan.json')).read_bytes())
verification = json.loads((ROOT/(PREFIX+'capacity-verification.json')).read_bytes())
instrument = json.loads((ROOT/(PREFIX+'capacity-instrument-verification.json')).read_bytes())
assert verification['complete'] and len(verification['evidence_controls']) == 14
assert instrument['complete'] and len(instrument['controls']) == 5
p=ROOT/'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md';s=p.read_text()
s=s.replace('- ID: '+chr(96)+LEAF+chr(96)+'\n  Status: '+chr(96)+'active'+chr(96),
            '- ID: '+chr(96)+LEAF+chr(96)+'\n  Status: '+chr(96)+'done'+chr(96),1)
start=s.index('- ID: '+chr(96)+LEAF+chr(96));end=s.index('\n- ID: ',start+1)
node=s[start:end]
node += ('\n  Verification: '+summary+'\n  Commit: '+chr(96)+SUBJECT+chr(96)+' (Git owns identity).\n'
         '  Handoff: '+next_action+'\n\n'
         '## Acceptance Checklist — '+LEAF+'\n\n'
         '- [x] **REPRODUCE / ISSUE** — LinkedSpec tools/roll_document_history.pl actual --check rejects the authored complete record at the unchanged90% boundary; full command/input/error channels retained.\n'
         '- [x] **ROOT CAUSE (WHY + WHERE)** — Canonical engineering_notes file and manifest controls are full; actual rollover source and routing threshold/authorization functions select the exact clean suffix and finite three-scalar need.\n'
         '- [x] **FIX** — One governed archive/row and exact accepted indexed ADR0128, all other fields/budgets/history bytes unchanged. Proposed/missing-status function gap remains independently owned P1 .3.1.3, not repaired here.\n'
         '- [x] **ADDRESSED (verified)** — Independent original-root/manifest/archive reconstruction, actual pressure RED/rollover GREEN, full query,14 evidence RED,18 actual thresholds/7 authority RED and five instrument RED. Initial incomplete instrument and actual channels retained.\n'
         '- [x] **NO REGRESSION** — Production/test/book/CI/hook/checker/dependency bytes unchanged; exact staged canonical receipt and all normal hooks gate this infrastructure landing. No product or composed-bypass claim.\n'
         '- [x] **LOCKSTEP** — Claims, two Knowledge facts, exact indexed decision, task/index/roadmaps/live/resume/change/notes/history and memory/diff gates agree; book N/A because no public behavior changes.\n')
s=s[:start]+node+s[end:]
s=s.replace('| '+chr(96)+LEAF+chr(96)+' | '+chr(96)+'active'+chr(96)+' | One exact engineering-note rollover; canonical infrastructure proof. |',
            '| '+chr(96)+LEAF+chr(96)+' | '+chr(96)+'done'+chr(96)+' | Exact finite history proof; canonical receipt governs landing. |',1)
# Keep the current production frontier distinct from historical diagnosis handoffs.
s=s.replace('Finte history prerequisite', 'Finite history prerequisite')
for section,record in [('Verification Log','October8 '+chr(96)+LEAF+chr(96)+': '+summary+'\n\n'),
                       ('Commit Log','- '+chr(96)+SUBJECT+chr(96)+' — finite infrastructure prerequisite; Git owns identity.\n\n'),
                       ('Changelog','- 2026-10-08: Finite replacement-note history preserves every prior byte; accepted-state function gap owned .3.1.3 before private handoff.\n\n')]:
 marker='## '+section+'\n';assert marker in s;s=s.replace(marker,marker+'\n'+record,1)
p.write_text(s)
p=ROOT/'MEMORY.md';s=p.read_text();updates={'latest_completed_leaf':chr(96)+SUBJECT+chr(96)+'.',
'active_work_unit':chr(96)+LEAF+chr(96)+' (done) — finite engineering-note history prerequisite.',
'next_action':next_action,'in_flight_uncommitted':'None; intended clean post-landing handoff. Exact staged canonical receipt and normal hooks govern this infrastructure leaf.',
'current_engineering_notes_capacity':'ADR0128 admits45 files /44 manifest lines /26633 bytes; resulting manifest44/26633 is exact. Archive4963 preserves clean47444428a lines155–256; all prior immutable bytes and other controls stay exact.'}
for k,v in updates.items():s,n=re.subn(r'^- '+re.escape(k)+r':.*$',lambda m:'- '+k+': '+v,s,count=1,flags=re.M);assert n==1,k
s=s.replace('  Legacy segment4964 preserves201 lines/27233 bytes from clean da3d; all prior immutable rows/bytes remain exact.\n','')
assert len(s.encode())<=8192 and len(s.splitlines())<=60;p.write_text(s)
p=ROOT/'LIVE_ACHIEVEMENT_STATUS.md';s=p.read_text()
for k,v in {'Current Activity':'Full PNT: finite engineering-note capacity verified; accepted-state routing enforcement next, then private handoff and mapped replacement.',
'Latest Completed Slice':chr(96)+LEAF+chr(96)+' — '+summary,'Next Action':next_action}.items():
 s,n=re.subn(r'(## '+re.escape(k)+r'\n\n).*?(?=\n## )',lambda m:m.group(1)+v+'\n',s,count=1,flags=re.S);assert n==1
start=s.index('## Recent Completions\n\n')+len('## Recent Completions\n\n');end=s.index('\n## History',start)
rows=[r for r in s[start:end].splitlines() if r.startswith('- ')];rows=['- '+chr(96)+LEAF+chr(96)+' — finite archive/row, exact prior history; actual accepted-state gap owns next P1.']+rows
s=s[:start]+'\n'.join(rows[:16])+'\n'+s[end:];p.write_text(s)
p=ROOT/'docs/TASK_TREE.md';lines=p.read_text().splitlines(keepends=True)
for i,line in enumerate(lines):
 if line.startswith('| '+chr(96)+'SPEC-LANGUAGE-SELF-CONTAINMENT'+chr(96)+' |'):
  parts=line.split(' | ');parts[1]=chr(96)+'active: accepted-state guard prerequisite'+chr(96);parts[3]=summary+' Next: '+next_action;lines[i]=' | '.join(parts)
p.write_text(''.join(lines))
for name in ('ROADMAP.md','ROADMAP_V2.md'):
 p=ROOT/name;s=p.read_text();lines=s.splitlines(keepends=True)
 for i,line in enumerate(lines):
  if line.startswith('| Expressive self-containment '):
   line=line.replace('Next: Activate REPO-HYGIENE.12', 'Next: Activate REPO-HYGIENE.12')
   # Preserve the lane's accepted behavior statement; add the new bounded prerequisite pointer.
   if 'Finite note-history' not in line:
    parts=line.split(' | ');parts[-2] += ' Finite note-history .0.3.1.2 is verified; accepted-state guard .0.3.1.3 precedes private handoff.';line=' | '.join(parts)
   lines[i]=line
 p.write_text(''.join(lines))
p=ROOT/'CHANGES.md';s=p.read_text();m=re.search(r'^## ',s,re.M);assert m
entry='## 2026-10-08 — '+SUBJECT+'\n\n'+summary+' Full details and actual producers/channels are leaf-prefixed under docs/checkpoints/; P1 guard repair remains tracked before production handoff.\n\n'
p.write_text(s[:m.start()]+entry+s[m.start():])
(ROOT/'git_message_brief.txt').write_text(SUBJECT+'\n\nPreserve one clean-source archive and exact manifest row under the indexed finite\nmaintenance decision. Retain actual pressure, history, authority and instrument\nchannels; separately own accepted-state guard diagnosis/repair before handoff.\n')
extras=[CURRENT,MANIFEST,REGISTRY,'docs/decisions/0128-replacement-note-history-capacity.md','docs/decisions/INDEX.md',
 'docs/knowledge/replacement-repair-engineering-history-capacity.md','docs/knowledge/routing-decision-accepted-state-gap.md',
 'tools/roll_document_history.pl','tools/read_document_history.pl','scripts/check_readme_routing_pressure.pl',
 'tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh',
 plan['archive_record']['target_path'],*[row['path'] for row in plan['prior_archives']]]
paths=sorted(set(extras+[p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/checkpoints').glob(LEAF+'-*') if p.is_file()]))
inputs=[{'path':p,'sha256':hashlib.sha256((ROOT/p).read_bytes()).hexdigest(),
         'role':'producer' if p.endswith(('.py','.pl','.sh')) else 'input'} for p in paths]
claim={'version':1,'owner':LEAF,'claims':[{'name':'finite-clean-source-engineering-history-admission',
 'statement':summary,
 'scope':'Exactly one governed engineering archive/manifest row at clean47444428a, three scalar controls and explicitly accepted indexed ADR0128. Current actual ROOT/manifest/registry,42 original immutable archives and actual producer/input channels are bound; original clean Git source/blob reconstructs independently. Complete actual pressure RED/rollover GREEN and full history query,14 record corruptions,18 actual production thresholds/7 exact-authority denials, five instrument corruptions. Those corruption controls are evidence/authority tests, not parser semantic mutants. Initial reviewer is incomplete at wrong guard dictionary selection, with exact first used source/combined shell error/initial reached control channels retained; distinct original stdout/stderr unavailable. Corrected reviewer changes only the selection source and reaches every control. Proposed/missing-status diagnostics authorize in both functions; no composed bypass claimed. P1 .3.1.3 owns immediate full-path diagnosis/repair; current accepted ADR is independently checked. Autonomous maintenance does not assert a new explicit director grant or unlimited reserve. No other controls/history bytes/production/test/book/CI/hook/checker/dependency changes. Exact staged canonical receipt and normal hooks govern admission independently; no new runtime/readiness claim. Necessary read-only OS/Perl/Python/Git inputs; project data repository-local/same-volume; other repositories remain read-only.',
 'rederive':{'status':'checked','command':'At clean47444428a activation run bash tools/run_python_project_data.sh '+PREFIX+'capacity-plan.py then '+PREFIX+'capacity-apply.py. At the published candidate/committed boundary run bash tools/run_python_project_data.sh '+PREFIX+'capacity-review.py and '+PREFIX+'capacity-instrument-review.py; original captures remain exact.','granularity':json.dumps(verification,sort_keys=True),'result':summary},
 'falsify':{'status':'checked','hypothesis':'Equal aggregate values or matching route markers alone prove lossless finite accepted admission.','oracle':'Independent original Git root/suffix/manifest/archive reconstruction, exact unchanged fields, actual full query and pressure channels; independently checked current accepted Status and actual unchanged authorization functions.','red_control':'Actual pressure255 before governed apply0;14 effective evidence corruptions,7 actual indexed-authority denials, independent18 threshold observations and5 instrument denials. Two additional status fixtures authorize in both actual functions and remain explicitly owned; they are not rejecting controls.'},
 'durability':{'status':'checked','mode':'live','inputs':inputs}}]}
(ROOT/('docs/claims/'+LEAF+'.json')).write_text(json.dumps(claim,indent=2)+'\n')
print(json.dumps({'prepared':LEAF,'bound_inputs':len(inputs),'canonical_pending':True,'accepted_state_repair_next':True}))
