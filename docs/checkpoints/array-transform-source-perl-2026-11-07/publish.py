"""Publish the bounded verified source repair and its next owned composition leaf."""
import gzip
from pathlib import Path

BASE = Path(__file__).resolve().parent
for name in ('readonly_review', 'result_preservation_review'):
    assert (BASE / name / 'exit.txt').read_text() == '0\n'
    assert gzip.decompress((BASE / name / 'stderr.log.gz').read_bytes()) == b''
LEAF = 'TYPE-REFERENCE-BOOK.1.2.23.3.78.0'
NEXT = 'TYPE-REFERENCE-BOOK.1.2.23.3.78.1.1'
summary = 'Perl source78.0 reuses the existing Number-AST predicate at exactly eight named-Array shortcuts. The actual normal changes16 main-only host RED/173 healthy to189PASS; own123 policies and every healthy public projection remain exact. Exact private old/current images reproduce16RED/189PASS with matching module/handler pairs. Two readonly recoveries and six specific corruptions pass. Separate unchanged37 result projections and all37 artifact pairs still retain19 selected failures/18 healthy; composition78.1.1 is next.'
task = Path('docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md')
text = task.read_text()
start = text.index('- ID: `' + LEAF + '`\n'); end = text.index('- ID:', start + 7)
node = text[start:end].replace('Status: `in_progress`', 'Status: `completed` / bounded Number source isolation focused-checked', 1)
node = node.replace('eighteen healthy direct producer controls;', 'eighteen healthy direct producer controls and separate unchanged37 result preservation;')
node += '''  Result: Exactly eight local shortcuts now exclude Number ASTs via the existing _method_value_is_numeric_literal predicate. Number3 follows the original computed-source fallback and does not read @main::3; genuine Arrays keep their original shortcut. Global extractors, required callback bindings, arities, count/start coercion, sorting, snapshots, list splices, mutation and result roles are unchanged.
  Verification: Actual189 normal reaches all groups:16 main-only RED/173 healthy before,189PASS after. Exact private old/current owner images reproduce16RED/189PASS at one controlled load path while the checkout stays repaired. All173 healthy projections/123 policies and matching189 module/handler pairs agree. First readonly0/empty stderr/six reason-sensitive controls passes; separate composed readonly0 independently validates all activation own Perl/three grammar bytes and unchanged37 current result projections/artifact pairs with19 original defects/18 healthy. No result guard, full source/context/native-transitive or admission credit.
  Evidence: docs/checkpoints/array-transform-source-perl-2026-11-07/REVIEW.md; default readonly review_result_preservation.py. Actual SDK/grammar/instrument/cases/artifacts precede use; modules precede fresh loading and handlers follow public Get before execution. Original preflight/failed instruments and all historical evidence remain unchanged. Captured private owner identities precede each test; full native/cache/toolchain custody4.2/SESSION5 stays separate.
  Next: Normal hooks/post-pointer/brief0/clean Git, then activate composition78.1.1 and reacquire unchanged37/own123 plus source-isolation fences before any result-role edit. Keep producer permission separate from prior guarded results; no peer policy import or broad suite.
  Commit: TYPE-REFERENCE-BOOK.1.2.23.3.78.0 — isolate Perl Array-transform Number sources.

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get/return_descriptor/call_spec_handler_subst/dump_parser_source/native/full emitted-fresh189 normal exposes16 main-only host reads before production edits.
  - [x] **ROOT CAUSE (WHY + WHERE)** — literal Number3 reaches @3 at eight named-Array shortcuts in perl/LinkedSpec/ActionIR/MethodLowering.pm; empty/outer controls distinguish the actual host namespace.
  - [x] **FIX** — reuse the existing Number-AST fence at exactly eight shortcuts; preserve their computed fallback and genuine Array branch without a global extractor or result guard change.
  - [x] **ADDRESSED (verified)** — actual16RED to189PASS, exact old/current private inverse, both readonly0 recoveries/six effective controls and all actual artifact/source identities agree.
  - [x] **NO REGRESSION** — all173 healthy projections/123 policies stay exact; unchanged37 retains all prior values/errors and37 matching module/handler pairs; needed errors, snapshots, defaults and earlier guards survive.
  - [x] **LOCKSTEP** — book/Knowledge/helpers, task/index/frontier, change/engineering/live/MEMORY route clean handoff to composition78.1.1; full admission remains separate.

'''
text = text[:start] + node + text[end:]
text = text.replace('Frontier: Own Perl preflight78.1.0 demonstrates literal Number-to-host-Array reads. Source78.0 is immediate, then composition78.1.1; qualified capacity4.16 retains the exact current task tail.', 'Frontier: Bounded Perl source78.0 is repaired/focused-checked. Composition78.1.1 is next from unchanged37/own123/current source-isolation fences; qualified capacity4.16 retains the exact current task tail.')
task.write_text(text)

for name in ('CHANGES.md', 'DEVELOPMENT_NOTES.md'):
    p = Path(name); text = p.read_text(); position = text.index('\n## ')
    p.write_text(text[:position] + '\n## 2026-11-07 — ' + LEAF + ' — Isolate Perl Array-transform Number sources\n\n' + summary + '\n\nGenuine Arrays retain their existing producer paths; Number literals use the original computed-source fallback. Regenerate affected emitted Perl. Own Perl/three grammar inputs match activation Git before repair; source/artifact/channel custody remains scoped and full native/cache/transitive/context/registration/admission stays separately owned. Evidence: docs/checkpoints/array-transform-source-perl-2026-11-07/REVIEW.md.\n' + text[position:])

live = Path('LIVE_ACHIEVEMENT_STATUS.md'); text = live.read_text()
for heading, body in (('Current Activity', 'PNT resumes bounded Perl Array result composition78.1.1 after source-isolation78.0. Other backend78 assessments and full23.4 remain separate.'), ('Latest Completed Slice', LEAF + '. ' + summary), ('Next Action', 'From clean source78.0 landing activate ' + NEXT + '. Reacquire unchanged37/own123/source-isolation controls, then retain selected canonical Array result ownership through consumer/copy/logical/with links without changing producer permission, arities or earlier guarded owners. Own smallest new/direct/inverse/recovery/book/Knowledge/continuity commit.')):
    start = text.index('## ' + heading + '\n'); end = text.index('\n## ', start + 4)
    text = text[:start] + '## ' + heading + '\n\n' + body + '\n' + text[end:]
start = text.index('## Recent Completions\n') + len('## Recent Completions\n'); end = text.index('\n## History', start)
rows = [line for line in text[start:end].splitlines() if line.startswith('- ')]
rows.insert(0, '- ' + LEAF + ' — eight Number fences/189PASS, private16RED/restored189PASS/two readonly/six controls; original37 unchanged; composition78.1.1 next.')
live.write_text(text[:start] + '\n' + '\n'.join(rows[:16]) + '\n' + text[end:])
Path('MEMORY.md').write_text('''# MEMORY

- activation_commit: `df9dc784e368a66f16238caaa41142a649dde4dd` — clean source78.0 activation; derive current HEAD from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.23.3.78.0` — isolate Perl Array-transform Number sources.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.23.3.78.0` (completed through landing); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md.
- next_action: From clean source78.0 landing activate TYPE-REFERENCE-BOOK.1.2.23.3.78.1.1. Reacquire unchanged37/own123 and source-isolation fences before result-role edits. Add only selected canonical Array result ownership, preserving first producer permission separately from earlier guarded owners; own smallest new/direct/inverse/recovery/book/Knowledge/live/commit. No peer policy import or broad suite.
- in_flight_uncommitted: none.
- blockers: none requiring director input. Source78.0 is bounded/focused-checked; result78.1.1 remains pending. Generic task boundary/query4.17 is P2 after feature coverage, earlier on capacity block. Complete native/cache/transitive custody4.2/SESSION5, RAM fallback/card4.14, registration4.1 and declared Lua5.4 remain separately owned.
- evidence: docs/checkpoints/array-transform-source-perl-2026-11-07/REVIEW.md and readonly review_result_preservation.py. Eight existing Number-AST fences yield16RED/173 healthy to189PASS; exact private old/current16RED/189PASS, two readonly0/empty stderr/six controls PASS. All173 healthy projections/123 policies match; original37 projections/module-handler pairs still retain19 result defects/18 healthy. All captured own Perl/three grammar bytes agree with activation Git before source repair. No result/full-domain/admission credit.
- publication: Exact canonical4683555e is the last published boundary. Later focused commits need fresh final proof; full23.4/final clean push follows feature coverage.
- verification_policy: Smallest focused checks per slice and mandatory hooks. Same-volume data; other repositories/submodules read-only. Host24GiB; one intensive own job at a time. Latest cleanup2026-11-07T05:37:20.574917+00:00 remains within24h at this activation; recheck at clean boundaries. Director RAM policy overrides stale card until4.14.
''')

inventory = Path('docs/checkpoints/type-operation-inventory/helpers.md'); text = inventory.read_text()
start = text.index('Current finite frontier:'); end = text.index('\n', start)
inventory.write_text(text[:start] + 'Current finite frontier: Perl source78.0 isolates literal Number inputs at eight Array shortcuts; actual189PASS/private16RED-restored189PASS/two readonly/six controls and unchanged123 policies are focused-checked. All original37 result projections/artifact pairs retain19 defects/18 healthy. Composition78.1.1 is next before independent peers. Full source/context/native custody/registration/declared Lua5.4/full23.4 remain separate. Evidence: docs/checkpoints/array-transform-source-perl-2026-11-07/REVIEW.md.' + text[end:])

root = Path('docs/tasks/TYPE-REFERENCE-BOOK.md'); text = root.read_text()
text = text.replace('own Perl preflight78.1.0 freezes37/123 profiles and main-only host reads; source78.0 then composition78.1.1 next;', 'bounded source78.0 is focused-checked with189PASS/own123 policies and unchanged37 result defects; composition78.1.1 next;')
text = text.replace('| 1 | `TYPE-REFERENCE-BOOK.1.2.23.3.78.1.0` | `completed` | Own Perl Array preflight freezes37/123 profiles;16 main-only Number-to-host-Array reads require source78.0. |', '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.3.78.0` | `completed` | Eight local Number fences/189PASS/private inverse/two readonly; original37 result defects remain unchanged. |')
text = text.replace('| 2 | `TYPE-REFERENCE-BOOK.1.2.23.3.78.0` | `pending` | P1 literal Number source isolation at eight shortcuts, then composition78.1.1; full23.4 remains separate. |', '| 2 | `TYPE-REFERENCE-BOOK.1.2.23.3.78.1.1` | `pending` | Preserve source78.0 and own123 policies while adding bounded Array-result guards; full23.4 remains separate. |')
root.write_text(text)
for name in ('docs/TASK_TREE.md', 'ROADMAP_V2.md'):
    p = Path(name); lines = p.read_text().splitlines(True)
    for index, line in enumerate(lines):
        if line.startswith('Current Perl Array frontier:'):
            lines[index] = 'Current Perl Array frontier: source78.0 is repaired/focused-checked with189PASS/own123 policies, exact private inverse and unchanged37 result defects. Composition78.1.1 is next; independent peers/full23.4 remain separate.\n'
        elif line.startswith('Latest PNT slice:') and name == 'docs/TASK_TREE.md':
            lines[index] = 'Latest PNT slice: ' + LEAF + ' — eight Number-source fences/189PASS/private inverse/two readonly/six controls; original37 result projections and artifacts unchanged. Next composition78.1.1, full admission separate.\n'
        elif name == 'docs/TASK_TREE.md' and line.startswith('| `TYPE-REFERENCE-BOOK` |'):
            lines[index] = '| `TYPE-REFERENCE-BOOK` | `active` / fluent methods .1.2.23 | `.spec documentation / complete type and fluent reference` | Bounded Perl source78.0 is repaired/focused-checked. Composition78.1.1 is next from unchanged37/own123/source-isolation fences, then independent backend78 assessments. Earlier finite outcomes retain their exact task records and host/context qualifications; complete inventory/domain/context/native custody/registration/declared Lua5.4/full23.4 stay separately owned. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |\n'
    p.write_text(''.join(lines))
Path('git_message_brief.txt').write_text(LEAF + ' - isolate Perl Array-transform Number sources\n\nReuse the existing Number-AST predicate at exactly eight named-Array shortcuts.\nRetain producer policies, genuine Arrays and the original result defects.\nValidate189 focused groups, exact private inverse and current37 artifact preservation.\nUpdate book, Knowledge, task ownership and continuity before composition78.1.1.\n')
print('Verified source repair and clean composition handoff prepared')
