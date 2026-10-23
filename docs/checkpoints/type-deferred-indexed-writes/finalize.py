"""Publish bounded continuity after successful current semantic and artifact proof."""
import re
import common as c
import review

def replace(text,old,new):
 assert text.count(old)==1,(old,text.count(old))
 return text.replace(old,new,1)

def prepend(path,record):
 text=(c.ROOT/path).read_text()
 match=re.search(r'^## ',text,re.M)
 assert match,path
 (c.ROOT/path).write_text(text[:match.start()]+record+'\n\n'+text[match.start():])

def main():
 result=review.check()
 artifact=c.load('artifact2-run.json.gz');scope=c.load('scope2-run.json.gz')
 assert artifact['restored'] and artifact['denials']==3 and scope['restored']
 summary=(f"{result['cases']} public cases/{result['accepted_red']} accepted RED/{result['accepted_controls']} controls;"
  f"{result['faults']} restored source faults;{result['direct_suites']}/{result['direct_tap']} top-level TAP;"
  f"book{result['book_inputs']}/{result['book_examples']} exact examples/heading and prose RED;artifact3 and actual fixture omission/bypass/restoration")
 path='docs/tasks/TYPE-REFERENCE-BOOK.md'
 text=(c.ROOT/path).read_text()
 text=text.replace('- Status: `active` / deferred indexed writes .1.2.12; before enumeration','- Status: `active` / next signed selectors .1.2.17; before enumeration',1)
 text=text.replace('- Last updated: `2026-10-22`','- Last updated: `2026-10-23`',1)
 start=text.index('- ID: `'+c.OWNER+'`');end=text.index('- ID: ',start+6)
 node=text[start:end]
 node=replace(node,'  Status: `active` / public contract reproduction','  Status: `completed` / bounded deferred-write foundation verified')
 node=replace(node,'  Claim verification: none: Active diagnosis; a source-bound record is required before measured completion.','  Claim verification: `docs/claims/'+c.OWNER+'.json`')
 node=node.replace('  Current work (October23; not admitted):','  Superseded pre-repair work (October23):').replace('  Remaining proof/landing:','  Superseded proof plan:').replace('This is owned by12 and blocks landing.','This blocked landing until the verified compatibility repair below.')
 node+='''  Completion: '''+summary+'''. Newly allocated slots retain supplied caller flag identity; compiled caller scalar inventories preserve null independently of deferred-body origin; standalone compatibility fragments keep their existing declaration requirements. Typed writes delegate to the existing atomic runtime; weak resolved-slot flags preserve dynamically introduced null across separately forwarded calls, while copied fixed/rest parameters restore caller slots/flags. Basic malformed carriers/operand headers reject before effects. Earlier wrapper collision, parenthesized-assignment/negative-error adapters, wrong ordinary fault selection, fact-budget drafts and superseded focus/attribution epochs remain explicit. No recursive ActionIR-carrier, other-backend, signed-selector17, deferred-with16, last14, complete inventory or wider historical-audit admission.
  Durability: Whole accepted pipeline11 claim/readonly baseline and all original live records precede writes. Pipeline11 is revision-bound to its actual clean Git source. Current publication watches the conservative regular main-repository superset with the full measured-input floor and independent required-fixture witness. Every earlier measured epoch keeps its actual inputs and source bodies; final authored continuity is a later boundary. System tools/public dependency outputs remain read-only prerequisites; Gitlinks/symlinks/other repositories are excluded. No fabricated historical input hashes or minimal I/O graph is claimed.
  Host diagnostic qualification: Some commands initially yielded without output. Read-only OS process-tree inspection later showed the actual Perl probe actively consuming CPU; system/Homebrew shell and Python/Perl version controls returned successfully. No execution-access blocker or performance cause was established. These necessary OS diagnostics wrote no project data outside the repository and changed no external repository, process or setting.
  Acceptance checklist:
  - [x] **REPRODUCE / ISSUE** — Public LinkedSpec::Get/return_descriptor/dump_parser_source/native/fresh emitted routes in attribution7.json.gz retain exact accepted-source RED and current GREEN; forwarded-presence.json.gz retains the separate null-loss counterexample.
  - [x] **ROOT CAUSE (WHY + WHERE)** — CodeblockRuntime::_eval_expr lacked assign_nested_access. Generated forwarded calls reused slots but supplied separate empty presence maps; weak slot identity now preserves dynamically introduced presence. operand-validation-before.json.gz shows an earlier key effect before a missing typed operand header failed.
  - [x] **FIX** — Reuse BindingRuntime::nested_write; validate basic carriers first, guard receiver identity before operands, evaluate keys then RHS once, snapshot afterward, publish once, and restore parameter slot/flag identities.
  - [x] **ADDRESSED (verified)** — Accepted rollback/current reapplication and exact source restoration pass; thirteen actual source faults and frozen structural/evaluation oracles distinguish dispatch, flags, kinds, snapshot, guard and detachment defects.
  - [x] **NO REGRESSION** — Twenty current direct suites and exact changed tests pass; complete canonical CI and normal hooks govern landing rather than inferring a full regression result from selected TAP.
  - [x] **LOCKSTEP** — Worked book/guide, existing canonical fact and derived map, current roadmap/index/live docs, complete proof producers and claim inputs agree. Signed-selector17 is first after clean Git.
  Commit: `TYPE-REFERENCE-BOOK.1.2.12 - execute deferred indexed writes atomically`

'''
 text=text[:start]+node+text[end:]
 text=replace(text,'| 10 | `TYPE-REFERENCE-BOOK.1.2.12` | `active` | Deferred indexed writes before inventory. |','| 10 | `TYPE-REFERENCE-BOOK.1.2.12` | `completed` | '+summary+'; signed17 next. |')
 start=text.index('## Current Frontier\n');end=text.index('## Decisions\n',start)
 rows=[line for line in text[start:end].splitlines() if line.startswith('| ') and '`done`' not in line and '`completed`' not in line]
 order=0
 for i,line in enumerate(rows):
  if re.match(r'^\| \d+ \|',line):
   order+=1;rows[i]=re.sub(r'^\| \d+ \|','| '+str(order)+' |',line)
 text=text[:start]+'## Current Frontier\n\n'+'\n'.join(rows)+'\n\n'+text[end:]
 text=re.sub(r'(?m)^No director input required\..*$', 'No director input required. Signed selectors17 follows the clean12 boundary, then14/16/19/policy20 before inventory. No dirty pivot.',text)
 text=text.replace('## Verification Log\n','## Verification Log\n\n- `2026-10-23` — `.1.2.12`: '+summary+'; actual compatibility RED/GREEN; exact canonical admission governs landing.\n',1)
 text=text.replace('## Commit Log\n','## Commit Log\n\nDeferred-write12 subject: `TYPE-REFERENCE-BOOK.1.2.12 - execute deferred indexed writes atomically`; derive accepted identity from Git.\n',1)
 text=text.replace('## Changelog\n','## Changelog\n\n- `2026-10-23`: Complete bounded deferred-write12, preserve caller presence and standalone compatibility; signed17 is next, then14/16/19/policy20 before inventory.\n',1)
 (c.ROOT/path).write_text(text)
 (c.ROOT/'MEMORY.md').write_text('''# MEMORY

- activation_commit: `'''+c.BASE+'''` — clean deferred-write base; Git owns current identity.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.12` — subject `TYPE-REFERENCE-BOOK.1.2.12 - execute deferred indexed writes atomically`.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.12` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.md.
- next_action: From clean committed Git own the overdue daily artifact review under REPO-HYGIENE.21, commit it, then activate TYPE-REFERENCE-BOOK.1.2.17 and split shared signed-index contract/backend/admission children before implementation.
- in_flight_uncommitted: none — intended clean post-landing state; exact staged canonical receipt and normal hooks govern admission.
- proof: docs/checkpoints/type-deferred-indexed-writes/publish.py; retained epochs keep original inputs, rejected/superseded candidates and actual controls. No historical writer is rerun.
- steering: [-n] = [size-n] only when size-n >= 0; -1 is last and -size is first. Signed selectors17 precede last14, deferred with16 and complete inventory.
- limits: Foundation12 admits bounded Perl deferred writes only. Other repositories/submodules remain read-only black boxes; all project data stays on-volume. No push until PNT is exhausted.
- blockers: none established; signed-selector contract/backend admission remains pending.
''')
 path='LIVE_ACHIEVEMENT_STATUS.md';text=(c.ROOT/path).read_text()
 sections={
  'Current Activity':'TYPE-REFERENCE-BOOK.1.2.17 is next after the clean deferred-write foundation: tail-relative array selectors across shared contracts and runtimes. The director rule is [-n] = [size-n] when size-n >= 0; no signed-selector admission yet.',
  'Latest Completed Slice':c.OWNER+': '+summary+'. Weak slot-presence retention fixes separately forwarded null assignments; malformed operand headers reject before effects. Whole accepted11 custody and all superseded epochs remain retained. Exact canonical receipt and normal hooks govern admission.',
  'Next Action':'After clean landing, own and commit the overdue daily artifact review under REPO-HYGIENE.21. Then activate TYPE-REFERENCE-BOOK.1.2.17, split bounded shared-contract/backend/admission children and reproduce ordinary/deferred native/fresh reads/writes. Complete this director feature priority before14/16/inventory.'}
 for heading,body in sections.items():
  text,count=re.subn(r'(?m)^## '+re.escape(heading)+r'\n.*?(?=^## )','## '+heading+'\n\n'+body+'\n\n',text,count=1,flags=re.S)
  assert count==1,heading
 start=text.index('## Recent Completions\n');end=text.index('## History\n',start)
 rows=[line for line in text[start:end].splitlines() if line.startswith('- ')]
 rows=['- `'+c.OWNER+'` — '+summary+'; signed17 next.']+rows
 text=text[:start]+'## Recent Completions\n\n'+'\n'.join(rows[:16])+'\n\n'+text[end:]
 (c.ROOT/path).write_text(text)
 path='docs/TASK_TREE.md';text=(c.ROOT/path).read_text()
 text,count=re.subn(r'^Latest PNT slice:.*$', 'Latest PNT slice: '+c.OWNER+' executes deferred typed writes atomically with caller/parameter presence, weak slot identity across forwarded calls, guarded effects and malformed headers. '+summary+'. Exact canonical admission governs landing. Director-priority signed selectors17 follows clean Git, then last14/with16/inventory; complete type references remain pending.',text,count=1,flags=re.M)
 assert count==1
 lines=text.splitlines()
 for index,line in enumerate(lines):
  if line.startswith('| `TYPE-REFERENCE-BOOK` |'):
   lines[index]='| `TYPE-REFERENCE-BOOK` | `active` / next .1.2.17 | `.spec documentation / per-type reference` | Deferred-write12: '+summary+'. Signed tail-relative selectors17 is first after clean landing, then14/16 before inventory/reference work. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |'
 (c.ROOT/path).write_text('\n'.join(lines)+'\n')
 path='ROADMAP_V2.md';text=(c.ROOT/path).read_text()
 text,count=re.subn(r'^October22 current PNT boundary:.*$', 'October23 current PNT boundary: '+c.OWNER+' executes bounded Perl deferred typed writes with atomic publication, weak slot presence across forwarded calls, copied parameter restoration, typed diagnostics and guarded effects: '+summary+'. Exact canonical receipt and normal hooks govern landing. Director-priority signed selectors17 follows clean Git;14/16 and complete inventory/reference work remain queued. No other-backend or wider historical-audit admission.',text,count=1,flags=re.M)
 assert count==1
 text=text.replace('October21 type-reference direction:', 'October23 type-reference direction:',1)
 text=text.replace('After11 landing, continue the owned12/14 repairs, then operation/spelling inventory1','After12 landing, implement director-priority signed selectors17, then14/16 before operation/spelling inventory1',1)
 (c.ROOT/path).write_text(text)
 prepend('CHANGES.md','''## 2026-10-23 — TYPE-REFERENCE-BOOK.1.2.12 — atomic deferred indexed writes

Perl callable bodies execute the existing typed nested-write contract through BindingRuntime. Every compiled caller scalar slot preserves presence independently of the callback source. Caller null presence survives separately forwarded callbacks through weak slot identity; fixed/rest parameter copies and original flags restore on every exit. Basic write carriers/operand headers validate before effects, receiver guards precede operands, keys then RHS evaluate once, and isolated publication returns detached roots. Worked book/guide and canonical retrieval stay aligned.

Validation: '''+summary+'''. Actual accepted-source rollback/reapplication, frozen success/failure/evaluation cases, malformed/parameter/guard controls and all retained producer epochs are source-bound. Whole accepted11 custody precedes writes; earlier intermediate proof is explicitly superseded. Exact staged canonical receipt and normal hooks govern landing. Readonly: docs/checkpoints/type-deferred-indexed-writes/publish.py. The director's tail-relative [-n] rule is owned by17 as the immediate next slice;16 deferred with and14 last remain pending. No shared signed-selector, other-backend, complete reference or wider historical-audit admission.''')
 prepend('DEVELOPMENT_NOTES.md','''## 2026-10-23 — TYPE-REFERENCE-BOOK.1.2.12 — presence belongs to the resolved slot

A compiled invocation can pass a fresh presence dictionary while reusing the same working slots. Separately forwarded callbacks then lose an explicit null marker: the next write incorrectly vivifies it. Generated Get/dump/native/fresh evidence isolates that mechanism. Weak slot identity now retains only presence, follows scalar-slot lifetime and captures no callable environment. Every compiled caller scalar slot supplies presence regardless of callback origin; standalone compatibility fragments preserve their earlier declaration boundary. Known lexical flags still pass by reference; copied parameters use separate flag/slot identities and restore both. Missing typed operand headers are checked before earlier key effects, while ordinary expression failures preserve completed effects and identity.

Validation: '''+summary+'''. Basic carrier validation does not imply general reconstructed ActionIR admission. The current conservative watchset covers measured epochs and independently requires the actual fixture; validator bypass/restoration separates scope/identity checks from mutually incomplete inventories. Superseded candidates and actual failed instruments remain retained. Foundation12 keeps the prior write boundary until director-priority signed selectors17 changes the shared contract and backends. Exact canonical proof governs landing.''')
 c.save('finalization.json.gz',dict(result=result,summary=summary,producer=c.read(c.PREFIX+'finalize.py')))
 print('Continuity prepared:',summary)
if __name__=='__main__':main()
