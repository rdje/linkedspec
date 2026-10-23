"""Prepare a clean handoff after the final semantic and publisher controls pass."""
import re
import common as c
import review3 as review
PATHS=['docs/tasks/TYPE-REFERENCE-BOOK.md','MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md',
 'CHANGES.md','DEVELOPMENT_NOTES.md','docs/TASK_TREE.md','ROADMAP_V2.md',
 'docs/knowledge/selected-consumer-proof-input-closure-gap.md',
 'docs/knowledge/write-vivification-perl-reference.md',c.PREFIX+'README.md']
def replace(text,old,new):
 assert text.count(old)==1,(old,text.count(old))
 return text.replace(old,new,1)
def replace_record(path,heading,body):
 text=(c.ROOT/path).read_text()
 start=text.index(heading)
 end=text.index('\n## ',start+len(heading))
 (c.ROOT/path).write_text(text[:start]+heading+'\n\n'+body.rstrip()+'\n'+text[end:])
def main():
 result=review.check()
 artifact=c.load('artifact3-run.json.gz');scope=c.load('scope3-runs.json.gz')
 assert artifact['restored'] and artifact['denials']==3 and scope['restored']
 before={p:c.read(p) for p in PATHS}
 c.save('final-continuity-before.json.gz',dict(before=before,producer=c.read(c.PREFIX+'finalize2.py')))
 summary=(f"{result['cases']} public cases/{result['accepted_red']} accepted-source RED/{result['accepted_controls']} controls; "
  f"{result['faults']} restored source faults; {result['direct_suites']} suites/{result['direct_tap']} top-level TAP; "
  f"book {result['book_inputs']} inputs/{result['book_examples']} executed examples with heading/prose/URL denials; "
  'three identity denials and two required-fixture omission/bypass/restoration controls')
 path=PATHS[0];text=(c.ROOT/path).read_text()
 text=replace(text,'- Status: `active` / deferred-write .1.2.12 canonical regression repair',
  '- Status: `active` / signed-selector .1.2.17 next after clean12 and due hygiene21')
 start=text.index('- ID: `'+c.OWNER+'`');end=text.index('- ID: ',start+6)
 node='''- ID: `TYPE-REFERENCE-BOOK.1.2.12`
  Status: `completed` / bounded deferred-write foundation; exact canonical receipt governs landing
  Goal: Execute typed indexed writes inside deferred codeblocks.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.11`
  Verification tier: `canonical`
  Focused checks: Public LinkedSpec::Get/return_descriptor/dump_parser_source/native/fresh indexed-write cases; frozen write fixtures; copied parameters/alias/null/effect/guard/malformed controls; permanent callable/multiline and direct dependents; complete mdBook; source faults and input/scope denials.
  Canonical trigger: Public deferred typed-write availability; exact staged canonical CI and normal hooks required.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.12.json`
  Activation: Clean '''+c.BASE+'''. Whole accepted11 readonly replay and original live claims precede writes in prior-accepted.json.gz. Pipeline11 is frozen at this actual accepted Git revision with observations unchanged.
  Completion: '''+summary+'''. Readonly: bash tools/run_python_project_data.sh docs/checkpoints/type-deferred-indexed-writes/publish2.py.
  Mechanism: CodeblockRuntime delegates assign_nested_access to BindingRuntime. Basic write/operand headers validate before effects; receiver guard precedes keys then RHS, each once; root snapshot follows their effects and publication is atomic with detached results. Caller scalar inventories pass presence independently of callback origin. Weak resolved-slot identity retains presence across separately forwarded callbacks. New slots reuse supplied flags. Copied fixed/rest parameters restore caller slots/flags on every exit. Standalone ordinary fragments keep their existing declaration contract.
  Canonical compatibility repairs: The first exact staged candidate reached1035 and failed only800/1034. Broader tracking exposed a statement result replaced by flag=1; return scalar(value) while preserving presence and quiet void/value/list use. The legacy splitter passes incomplete naked regex fragments; leave those fragments intact instead of wrapping an unfinished pattern. Ten permanent lifecycle/value controls and independently emitted LF/CRLF escaped-brace controls preserve prior behavior. The final direct set includes the unchanged multiline consumer. Exact staged canonical proof remains a separate admission requirement.
  Retained rejected epochs: rejected-canonical1.json.gz keeps the complete actual combined log, original unpublished claim/publication/manifest, exact source epoch, index/fingerprint and actual readonly PASS. It was never an accepted Git state. Every earlier attribution/fault/book/focused capture remains immutable; final9 sources earn current proof. First wrappers, fixture parentheses, negative-error adapter, wrong ordinary fault target, failed CODE serialization, allocation-fault marker, publication-preparation failure and mis-scoped fixture edit retain actual observations without successful-control credit. final-continuity-before.json.gz keeps the full preceding task narrative.
  Instrument qualifications: The first raw-host probe required quietness without initializing Perl's default subject; actual accepted replay has the same warning. Explicit subject calibration passes both epochs without suppression. focused7 failed a fixture-adapter edit in the wrong similar loop; the scoped correction is retained. Its two new void warnings led to assignment-result-context-before.json.gz and the permanent scalar-context regression, not diagnostic filtering. Unsaved first fact-budget draft channels remain unavailable.
  Additional defect owned: Two LF source/subject pairs on accepted and final current native/fresh routes match an inserted-semicolon raw regex rather than the authored pattern. An independent direct literal oracle distinguishes them. compatibility3 retains source/subjects/oracle and exact accepted rollback/restoration. P2 child21 owns payload repair after19 and before20/inventory. The book documents the bounded legacy limitation; general raw-regex fidelity is not admitted here.
  Render evidence: Original book4 HTML reproduces exactly. The sole authored limitation paragraph is an explicit retained overlay before comparing the current reflowed page. After that overlay, all page/code/script/style/link tokens and complete search data agree except body whitespace; native JSON.parse calibrates both payloads. Actual heading/prose-source/URL corruptions reject. Existing Accepted7 retrieval was missed before re-derivation; it is reconciled with the original rule, not claimed as a novel result.
  Durability/limits: publish2 watches the conservative complete regular main-repository superset, including the measured epoch floor and two independent named fixtures. Every capture retains its actual producer, sources and changing artifacts; final continuity is later authored state. No minimal I/O graph, recursive ActionIR-carrier admission, other-backend, signed17, last14, deferred-with16, complete inventory or broader historical-audit completion. System tools/public dependency outputs are read-only prerequisites; Gitlinks/symlinks/other repositories are excluded. Host process inspection was read-only and established active probes, not a performance cause.
  Acceptance checklist:
  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get/return_descriptor/dump_parser_source native/fresh observations in attribution9 retain actual accepted-source typed-write failures; forwarded/caller/missing-slot and compatibility REDs remain separately retained.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Missing runtime dispatch, caller/forwarded/allocation presence loss, late operand validation, and statement/raw-fragment wrapping are isolated through public probes and actual source controls.
  - [x] **FIX** — Atomic BindingRuntime delegation, pre-effect guard/headers, ordered operands, slot flags/parameter restoration, scalar assignment results and unfinished-pattern preservation.
  - [x] **ADDRESSED (verified)** — Actual accepted rollback/reapplication, frozen independent write/error/evaluation controls and '''+str(result['faults'])+''' syntax-valid restored source faults distinguish faulty implementations.
  - [x] **NO REGRESSION** — '''+str(result['direct_suites'])+''' source-bound direct suites pass. Exact staged canonical receipt and normal hooks govern landing; prior canonical failure is retained without admission credit.
  - [x] **LOCKSTEP** — Worked book/guide, canonical facts/derived map, roadmap/index/live docs, source-bound claim and queued21 agree. Due hygiene21 then director-priority signed17 follow clean12.
  Commit: `TYPE-REFERENCE-BOOK.1.2.12 - execute deferred indexed writes atomically`

'''
 text=text[:start]+node+text[end:]
 start=text.index('## Current Frontier\n');end=text.index('## Decisions\n',start)
 rows=text[start:end].splitlines();order=0;new=[]
 for line in rows:
  if '`'+c.OWNER+'`' in line:continue
  if re.match(r'^\| \d+(?:\.\d+)? \|',line):
   order+=1;line=re.sub(r'^\| \d+(?:\.\d+)? \|','| '+str(order)+' |',line)
  line=line.replace('Shared containment policy update reconciliation after19.', 'Shared containment policy update reconciliation after raw-regex21.')
  new.append(line)
 text=text[:start]+'\n'.join(new)+'\n'+text[end:]
 text=text.replace('then14/16/19/policy20 before inventory','then14/16/19/raw-regex21/policy20 before inventory')
 text=text.replace('Schedule: After19 and before inventory1.', 'Schedule: After21 and before inventory1.')
 # Replace this uncommitted leaf's first completion line; preserve committed predecessors.
 text=re.sub(r'(?m)^- `2026-10-23` — `\.1\.2\.12`:.*$', '- `2026-10-23` — `.1.2.12`: '+summary+'; exact canonical receipt governs admission.',text,count=1)
 (c.ROOT/path).write_text(text)
 (c.ROOT/'MEMORY.md').write_text('''# MEMORY

- activation_commit: `'''+c.BASE+'''` — clean deferred-write base; derive current HEAD from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.12`; subject `TYPE-REFERENCE-BOOK.1.2.12 - execute deferred indexed writes atomically`.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.12` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: From clean committed Git own overdue daily artifact review REPO-HYGIENE.21, commit it, then activate TYPE-REFERENCE-BOOK.1.2.17 and split bounded shared signed-index contract/backend/admission children before implementation.
- in_flight_uncommitted: none — intended clean post-landing handoff; exact staged canonical receipt and normal hooks govern admission.
- proof: docs/checkpoints/type-deferred-indexed-writes/publish2.py; immutable earlier captures retain actual rejected/superseded sources and controls. Never rerun historical writers.
- steering: [-n] = [size-n] only when size-n >= 0; -1 is last and -size is first. Signed17 precedes last14, deferred with16, grouped19, raw-regex21, policy20 and complete inventory.
- limits: Bounded Perl deferred writes only; explicit legacy raw-regex payload limitation is owned21. Other repositories/submodules are read-only black boxes. All project data stays on-volume. No push until PNT exhausted.
- blockers: none established. Signed-selector admission remains pending.
''')
 path='LIVE_ACHIEVEMENT_STATUS.md';text=(c.ROOT/path).read_text()
 sections={
 'Current Activity':'Deferred-write12 is complete subject to exact staged canonical admission. Overdue artifact review REPO-HYGIENE.21 follows clean landing, then director-priority signed selectors TYPE-REFERENCE-BOOK.1.2.17. No signed-selector admission yet.',
 'Latest Completed Slice':c.OWNER+': '+summary+'. Caller/parameter presence, atomic effects and statement/regex-fragment compatibility are verified. First failed canonical and all superseded epochs remain retained; exact canonical receipt and normal hooks govern landing.',
 'Next Action':'From clean committed Git own/commit overdue artifact review21, then split and implement signed17 across shared contracts/backends. Continue14/16/19/raw-regex21/policy20 before complete inventory/reference work.'}
 for heading,body in sections.items():
  text,n=re.subn(r'(?m)^## '+re.escape(heading)+r'\n.*?(?=^## )','## '+heading+'\n\n'+body+'\n\n',text,count=1,flags=re.S);assert n==1
 start=text.index('## Recent Completions\n');end=text.index('## History\n',start)
 rows=[line for line in text[start:end].splitlines() if line.startswith('- ') and '`'+c.OWNER+'`' not in line]
 rows=['- `'+c.OWNER+'` — '+summary+'; signed17 next feature.']+rows
 text=text[:start]+'## Recent Completions\n\n'+'\n'.join(rows[:16])+'\n\n'+text[end:]
 (c.ROOT/path).write_text(text)
 old='74 public cases/54 accepted RED/20 controls;13 restored source faults;20/2567 top-level TAP;book89/4 exact examples/heading and prose RED;artifact3 and actual fixture omission/bypass/restoration'
 for path in ('ROADMAP_V2.md','docs/TASK_TREE.md','CHANGES.md','DEVELOPMENT_NOTES.md'):
  text=(c.ROOT/path).read_text();assert old in text,path;text=text.replace(old,summary)
  text=text.replace(c.PREFIX+'publish.py',c.PREFIX+'publish2.py')
  (c.ROOT/path).write_text(text)
 path='CHANGES.md';text=(c.ROOT/path).read_text()
 marker='Worked book/guide and canonical retrieval stay aligned.'
 text=replace(text,marker,marker+' Tracked scalar statements preserve assigned values without void warnings; unfinished raw-regex compatibility fragments retain their boundary. The rejected first canonical800/1034 and actual repair controls are retained; raw payload fidelity is separately owned21 and documented.')
 (c.ROOT/path).write_text(text)
 path='DEVELOPMENT_NOTES.md';text=(c.ROOT/path).read_text()
 marker='Basic carrier validation does not imply general reconstructed ActionIR admission.'
 text=replace(text,marker,'A presence write must not replace the value of a statement-shaped assignment. Explicit scalar(value) retains its value and avoids a bare-variable void warning; unfinished naked regex fragments cannot be wrapped across the compatibility splitter boundary. '+marker)
 (c.ROOT/path).write_text(text)
 path='docs/knowledge/selected-consumer-proof-input-closure-gap.md';text=(c.ROOT/path).read_text()
 text=text.replace('date: 2026-10-22','date: 2026-10-23',1).replace(c.PREFIX+'publish.py',c.PREFIX+'publish2.py')
 (c.ROOT/path).write_text(text)
 path='docs/knowledge/write-vivification-perl-reference.md';text=(c.ROOT/path).read_text()
 text=replace(text,'Complete tracked scalar statements still yield their assigned value; a presence flag must not replace it.',
 'Tracked statements yield scalar(value), retaining assignment results and quiet void/value/list use; a presence flag must not replace the result.')
 (c.ROOT/path).write_text(text)
 (c.ROOT/(c.PREFIX+'README.md')).write_text('''# Deferred indexed writes

Owner: TYPE-REFERENCE-BOOK.1.2.12. Clean activation: '''+c.BASE+'''.
Current readonly proof: `bash tools/run_python_project_data.sh docs/checkpoints/type-deferred-indexed-writes/publish2.py`.

'''+summary+'''. `compatibility3`, `faults9`, `attribution9`, `focused9` and `book9` are the final source epoch; native-search-json3 calibrates complete payloads. Permanent callable/multiline consumers retain frozen write/error/evaluation, malformed headers, caller/parameter/alias/effect/guard, lifecycle result and explicit-host regex compatibility controls.

The first exact staged canonical gate failed800/1034 after reaching1035. rejected-canonical1 keeps its complete actual log, original unpublished claim/publication/manifest, source epoch and readonly PASS. Every earlier capture keeps its actual source and observations, including failed adapters/instruments; no unpublished epoch is assigned an accepted Git revision. final-continuity-before retains the detailed preceding task narrative. Whole accepted11 custody precedes writes and its observations remain unchanged at its real Git revision.

Book4 HTML reproduces exactly. The exact new legacy raw-regex limitation note is an explicit authored overlay before the current reflow comparison. Page tokens and complete search data then agree except body whitespace. Native JSON.parse calibrates both datasets; actual heading/prose/URL mutations reject. System tools/public dependency outputs stay read-only prerequisites; the manifest watches a conservative regular main-repository superset, not a minimal I/O graph. Gitlinks/symlinks/other repositories are excluded.

Two LF subjects expose existing assigned raw-regex semicolon corruption on accepted/current native/fresh routes against an independent direct literal oracle. TYPE-REFERENCE-BOOK.1.2.21 owns repair after19 and before20/inventory. General raw-host fidelity is not admitted here. Requested [-n] = [size-n] when nonnegative belongs to director-priority17 after clean12 and due hygiene21; last14 and deferred with16 remain pending. No other-backend, complete inventory/reference or wider historical-audit admission.

Capture/mutation writers are one-shot. Rerun only the readonly publisher or permanent consumers. Exact staged canonical receipt and normal commit hooks govern landing.
''')
 c.save('finalization2.json.gz',dict(result=result,summary=summary,before_capture='final-continuity-before.json.gz',
  after={p:c.read(p) for p in PATHS},producer=c.read(c.PREFIX+'finalize2.py')))
 print('Clean handoff prepared:',summary)
if __name__=='__main__':main()
