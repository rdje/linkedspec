"""Publish the intended clean handoff after complete private compatibility proof."""
import re
import common as c
import review4 as review
PATHS=['MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md','docs/tasks/TYPE-REFERENCE-BOOK.md',
 'docs/TASK_TREE.md','ROADMAP_V2.md','CHANGES.md','DEVELOPMENT_NOTES.md',
 'docs/knowledge/selected-consumer-proof-input-closure-gap.md',c.PREFIX+'README.md']
def replace(text,old,new):
 assert text.count(old)==1,(old,text.count(old))
 return text.replace(old,new,1)
def main():
 result=review.check()
 artifact=c.load('artifact5-run.json.gz');scope=c.load('scope5-runs.json.gz')
 assert artifact['restored'] and artifact['denials']==3 and scope['restored'] and len(scope['targets'])==3
 before={p:c.read(p) for p in PATHS}
 c.save('final-continuity4-before.json.gz',dict(before=before,producer=c.read(c.PREFIX+'finalize4.py')))
 old=c.load('finalization2.json.gz')['summary']
 summary=(f"{result['cases']} public cases/{result['accepted_red']} accepted-source RED/{result['accepted_controls']} controls; "
  f"{result['faults']} source-fault9 controls plus the actual private-consumer inverse; "
  f"{result['direct_suites']} suites/{result['direct_tap']} top-level TAP; "
  f"private {result['private_rows']} rows/{result['private_changed_rows']} deliberate consumer changes; "
  f"book {result['book_inputs']} inputs/{result['book_examples']} executed examples with heading/prose/URL denials; "
  f"three identity denials and {len(scope['targets'])} required-fixture omission/bypass/restoration controls")
 for path in ('CHANGES.md','DEVELOPMENT_NOTES.md','ROADMAP_V2.md','docs/tasks/TYPE-REFERENCE-BOOK.md'):
  text=(c.ROOT/path).read_text();assert old in text,path
  text=text.replace(old,summary).replace(c.PREFIX+'publish3.py',c.PREFIX+'publish4.py')
  (c.ROOT/path).write_text(text)
 path='docs/tasks/TYPE-REFERENCE-BOOK.md';text=(c.ROOT/path).read_text()
 text=replace(text,'- Status: `active` / deferred-write12 private-consumer compatibility repair',
  '- Status: `active` / signed-selector17 next after clean12 and due hygiene21')
 start=text.index('- ID: `'+c.OWNER+'`');end=text.index('- ID: ',start+6)
 node=text[start:end]
 node=replace(node,'  Status: `active` / canonical private-consumer compatibility repair',
  '  Status: `completed` / bounded deferred-write foundation; exact canonical receipt governs landing')
 declaration=next(line for line in node.splitlines() if line.startswith('  Claim verification:'))
 node=replace(node,declaration,'  Claim verification: `docs/claims/'+c.OWNER+'.json`')
 node=node.replace('Durability/limits: publish3 watches','Durability/limits: publish4 watches')
 node=node.replace('two independent named fixtures','three independent named fixtures')
 old_check=next(line for line in node.splitlines() if line.startswith('  - [ ] **NO REGRESSION**'))
 node=replace(node,old_check,'  - [x] **NO REGRESSION** — '+str(result['direct_suites'])+' source-bound suites pass, including the complete516-check private consumer. Exact staged canonical3 and normal hooks govern admission; both prior failures remain retained.')
 node+='  Private consumer completion: Complete296-row comparison isolates26 deliberate nested-consumer source changes and exactly one target conversion4->5; every other predicate/authority field stays exact. The original native JSON and probe match real clean Git. The test projects expected consumer source only, never observed rows. An actual syntax-valid old-result inverse rejects both this consumer and executable value/quietness assertions, then restores GREEN. Source9 is unchanged; earlier functional/fault/book observations retain their exact epochs. Focused10 adds the previously missed direct private consumer. Publication4/artifact5 independently require the original native fixture alongside the existing public/multiline fixtures. No distinct fault-family count is inflated by the extra inverse.\n\n'
 text=text[:start]+node+text[end:]
 start=text.index('## Current Frontier\n');end=text.index('## Decisions\n',start)
 lines=[];order=0
 for line in text[start:end].splitlines():
  if '`'+c.OWNER+'`' in line:continue
  if re.match(r'^\| \d+(?:\.\d+)? \|',line):
   order+=1;line=re.sub(r'^\| \d+(?:\.\d+)? \|','| '+str(order)+' |',line)
  lines.append(line)
 text=text[:start]+'\n'.join(lines)+'\n'+text[end:]
 (c.ROOT/path).write_text(text)
 (c.ROOT/'MEMORY.md').write_text('''# MEMORY

- activation_commit: `'''+c.BASE+'''` — clean deferred-write base; derive current HEAD from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.12`; subject `TYPE-REFERENCE-BOOK.1.2.12 - execute deferred indexed writes atomically`.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.12` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: From clean committed Git own overdue daily artifact review REPO-HYGIENE.21, commit it, then activate TYPE-REFERENCE-BOOK.1.2.17 and split bounded shared signed-index contract/backend/admission children before implementation.
- in_flight_uncommitted: none — intended clean post-landing handoff; exact staged canonical receipt and normal hooks govern admission.
- proof: docs/checkpoints/type-deferred-indexed-writes/publish4.py; immutable rejected/superseded captures retain their real inputs. Never rerun historical writers.
- steering: [-n] = [size-n] only when size-n >= 0; -1 is last and -size is first. Signed17 precedes last14, deferred with16, grouped19, raw-regex21, policy20 and complete inventory.
- limits: Bounded Perl deferred writes only. Source9 is unchanged after private expectation qualification; full296 rows preserve predicate/authority fields. Legacy raw-regex payload repair remains owned21. Other repositories/submodules are read-only black boxes; all data stays on-volume. No push until PNT exhausted.
- blockers: none established; signed-selector admission remains pending.
''')
 path='LIVE_ACHIEVEMENT_STATUS.md';text=(c.ROOT/path).read_text()
 sections={
 'Current Activity':'Deferred-write12 is complete subject to exact staged canonical3 admission. Overdue artifact review REPO-HYGIENE.21 follows clean landing, then director-priority signed selectors TYPE-REFERENCE-BOOK.1.2.17. No signed-selector admission yet.',
 'Latest Completed Slice':c.OWNER+': '+summary+'. Whole rejected canonical1/2 and publications remain retained. The private test qualifies only deliberate assignment emission, preserving original captures and all predicate fields. Exact canonical receipt and normal hooks govern landing.',
 'Next Action':'From clean committed Git own/commit overdue artifact review21, then split and implement signed17 across shared contracts/backends. Continue14/16/19/raw-regex21/policy20 before complete inventory/reference work.'}
 for heading,body in sections.items():
  text,n=re.subn(r'(?m)^## '+re.escape(heading)+r'\n.*?(?=^## )','## '+heading+'\n\n'+body+'\n\n',text,count=1,flags=re.S);assert n==1
 start=text.index('## Recent Completions\n');end=text.index('## History\n',start)
 rows=[line for line in text[start:end].splitlines() if line.startswith('- ') and '`'+c.OWNER+'`' not in line]
 rows=['- `'+c.OWNER+'` — '+summary+'; signed17 next feature.']+rows
 text=text[:start]+'## Recent Completions\n\n'+'\n'.join(rows[:16])+'\n\n'+text[end:]
 (c.ROOT/path).write_text(text)
 path='docs/TASK_TREE.md';text=(c.ROOT/path).read_text()
 text=re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: '+c.OWNER+' executes bounded Perl deferred typed writes with caller/parameter presence, atomic effects, exact diagnostics and compatible scalar results/raw fragments. '+summary+'. Exact canonical3/normal hooks govern admission. Due hygiene21 then director-priority signed17 follow clean Git; full references remain pending.',text,count=1)
 lines=text.splitlines()
 for index,line in enumerate(lines):
  if line.startswith('| `TYPE-REFERENCE-BOOK` |'):
   lines[index]='| `TYPE-REFERENCE-BOOK` | `active` / next .1.2.17 | `.spec documentation / per-type reference` | Deferred-write12: '+summary+'. Exact canonical admission, due hygiene21, then signed17; complete per-type references remain pending. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |'
 (c.ROOT/path).write_text('\n'.join(lines)+'\n')
 path='CHANGES.md';text=(c.ROOT/path).read_text();marker='Exact staged canonical receipt and normal hooks govern landing.'
 start=text.index('## 2026-10-23 — '+c.OWNER);end=text.index('\n## ',start+4)
 node=text[start:end]
 assert marker in node
 node=node.replace(marker,'Canonical2 rejects only26 private consumer expectations; the whole candidate/actual readonly/log survive. Full296-row comparison qualifies the scalar-result emission and one target4->5 without changing predicate/authority fields or original captures. An actual old-result inverse rejects both source and executable value oracles and restores GREEN. '+marker,1)
 text=text[:start]+node+text[end:];(c.ROOT/path).write_text(text)
 path='DEVELOPMENT_NOTES.md';text=(c.ROOT/path).read_text();start=text.index('## 2026-10-23 — '+c.OWNER);end=text.index('\n## ',start+4)
 node=text[start:end]
 node+='\n\nThe tracking-predicate fixture runs the real scalar-assignment consumer. Its frozen source text predates this result repair. Project only expected consumer emission and its extra identifier conversion; preserve every callback/authority field. Keep the original native JSON/probe byte-exact and pair this projection with the independent executable value/quietness oracle and actual source inverse. The missed consumer is now in focused selection.\n'
 (c.ROOT/path).write_text(text[:start]+node+text[end:])
 path='docs/knowledge/selected-consumer-proof-input-closure-gap.md';text=(c.ROOT/path).read_text().replace(c.PREFIX+'publish3.py',c.PREFIX+'publish4.py');(c.ROOT/path).write_text(text)
 (c.ROOT/(c.PREFIX+'README.md')).write_text('''# Deferred indexed writes

Owner: TYPE-REFERENCE-BOOK.1.2.12. Clean activation: '''+c.BASE+'''.
Current readonly proof: `bash tools/run_python_project_data.sh docs/checkpoints/type-deferred-indexed-writes/publish4.py`.

'''+summary+'''. Runtime source9 stays byte-exact after the private expectation repair. Compatibility3, faults9, attribution9 and book9 retain their actual source-bound observations; focused10 adds the direct tracking-predicate consumer to the prior21 suites. Every measurement keeps its real epoch; final continuity is later authored state.

Rejected canonical1 reached1035 and failed800/1034. Rejected canonical2 completes private91/32246 and fails only tracking predicate26/516. rejected-canonical1/2 retain complete actual logs, whole unpublished claim/publication/manifest, recoverable input epochs and actual readonly PASS before changes. No unpublished epoch is assigned an accepted Git revision. Whole accepted11 custody precedes all writes. Earlier failed adapters/instruments remain explicit and earn no successful-control credit.

The private comparison retains296 original loaded/cold rows. Only26 nested-consumer rows change assignment text; one target conversion rises4->5 because the result identifier is emitted again. Every predicate/authority field stays exact. The permanent consumer projects expected source only, preserving the original native fixture/probe. An actual old-result source inverse rejects both the projected consumer and independent executable value/quietness oracle, then restores GREEN. This extra inverse is not counted as a distinct source-fault9 family.

Book4 HTML reproduces exactly. The precise legacy raw-regex limitation paragraph is an explicit authored overlay before comparing the current reflow. Page tokens and complete search data then agree except body whitespace; native JSON.parse calibrates both datasets. Actual heading/prose/URL corruptions reject. The paragraph fixture retains its exact separator through a path-specific whitespace attribute; whole publication2/actual readonly PASS precedes that change.

Publication4/artifact5 retain actual identity denials and three independent required-fixture omissions: the public indexed-write plan, multiline consumer and original private native fixture. The probe is also an explicit producer. The manifest watches a conservative regular main-repository superset, not a minimal I/O graph. System tools/public dependency outputs stay read-only prerequisites; Gitlinks/symlinks/other repositories are excluded.

Two LF subjects expose existing assigned raw-regex semicolon corruption on accepted/current native/fresh routes against an independent literal oracle. TYPE-REFERENCE-BOOK.1.2.21 owns repair after19 and before20/inventory. General raw-host fidelity is not admitted here. Requested [-n] = [size-n] when nonnegative belongs to director-priority17 after clean12 and due hygiene21; last14 and deferred with16 remain pending. No other-backend, complete inventory/reference or wider historical-audit admission.

Capture/mutation writers are one-shot. Rerun only the current readonly publisher or permanent consumers. Exact staged canonical3 and normal commit hooks govern landing.
''')
 c.save('finalization4.json.gz',dict(result=result,summary=summary,before_capture='final-continuity4-before.json.gz',after={p:c.read(p) for p in PATHS},producer=c.read(c.PREFIX+'finalize4.py')))
 print('Clean handoff prepared:',summary)
if __name__=='__main__':main()
