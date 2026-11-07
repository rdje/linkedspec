"""Publish bounded Perl completion and the independent Rust frontier."""
import gzip
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
assert (BASE / 'readonly_review/exit.txt').read_text() == '0\n'
assert gzip.decompress((BASE / 'readonly_review/stderr.log.gz').read_bytes()) == b''
result = json.loads(gzip.decompress((BASE / 'readonly_review/stdout.log.gz').read_bytes()))
assert result['result'] == 'PASS' and len(result['controls']) == 7
LEAF = 'TYPE-REFERENCE-BOOK.1.2.23.3.78.1.1'
NEXT = 'TYPE-REFERENCE-BOOK.1.2.23.3.78.2'
summary = 'Perl Array result guards repair all19 original targets under unchanged37. The normal reaches212PASS from19RED/193 healthy; original123 plus52 own prefix/host/arity profiles stay exact. Direct composition/source/Hash normals pass490 groups. Exact old/current private images reproduce19RED/212PASS with matching212 module-handler pairs; first readonly0/empty stderr/seven effective corruptions passes. Source78.0 and first producer permission remain intact; independent Rust78.2 is next.'
task = Path('docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md')
text = task.read_text(); start = text.index('- ID: `' + LEAF + '`\n'); end = text.index('- ID:', start + 7)
node = text[start:end]
assert node.count('Status: `in_progress`') == 1
node = node.replace('Status: `in_progress`', 'Status: `completed` / bounded canonical Perl Array results focused-checked', 1)
node += '''  First acquisition: Current unchanged37/original123 plus independent52 literal Number/null/Hash-with, empty/main/outer host and missing/excluded-arity observations precede production. All24 Number3 host prefixes stay isolated. New212 normal reaches19 selected target RED/193 healthy; no policy or failure verdict is imported from a peer.
  Mechanism/fix: MethodLowering.pm omitted the selected Array result/source-prefix role from actual-kind and rejection dispatch. Canonical optional count/slice and exact concat2/1 forms now retain those roles through copy/logical/with. First receiver producer uses its original terminal lowering; prior constructor/copy/view/size/Hash owners retain their guard, and free Array results block initial Hash-helper permission. Direct flat roles, noncanonical concat, unknown/traversal/non-with trailing and unassessed receivers gain no role. All13 existing Number predicates stay intact.
  Result: Actual212 normal PASS; all193 before-healthy public projections/175 policy profiles exact with only eval serials normalized. Needed errors, source once/snapshots/order/nested kinds, valid empty with and earlier guards survive. Exact private old/current images at one controlled path reproduce19RED/212PASS; all212 corresponding module/handler pairs match public before/after. Direct three files490 PASS and every direct artifact/input is retained; source/Hash output folders are new and explicitly owned here, with previous proof files unchanged.
  Recovery: First readonly0/empty stderr validates all own activation Perl/three grammars, frozen inputs, material channels, exact private images, healthy/profile equality and seven specific corruptions. Tested physical candidate bytes are bound before review. Shared process/runtime and full native/cache/transitive/toolchain/mutation-command outer channels remain4.2/SESSION5; no full context/portable/registration/admission or peer-policy credit.
  Writer qualification: Original Python edit producer warns on embedded regex literal escapes but emits the tested correct Perl. Preserve original repair.py/source epochs and first observations. Separate repair_qualified.py adds only a raw-string prefix; actual compiler replay records old warnings, new zero warnings and identical Python AST. A changed helper constant distinguishes the oracle. No mutation rerun or original outer-channel completeness claim.
  Evidence: docs/checkpoints/array-transform-composition-perl-2026-11-07/REVIEW.md and default readonly review.py. Modules precede fresh load; native handlers follow public Get before invocation. Source78.0 proof and all frozen37 targets/contract remain unchanged.
  Next: Normal hooks/post-pointer/brief0/clean Git, then independently activate Rust78.2. Acquire own unchanged37/source/optional/excluded-arity/needed-error and prior-owner fences before production; retain first actual inputs/artifacts/channels and assess without importing Perl fallback policy. Full23.4 remains deferred after agreed feature coverage.
  Commit: TYPE-REFERENCE-BOOK.1.2.23.3.78.1.1 — guard Perl ordinary Array transform results.

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get/return_descriptor/call_spec_handler_subst/dump_parser_source/native/full emitted-fresh212 normal exposes19 original targets before production, with193 healthy controls.
  - [x] **ROOT CAUSE (WHY + WHERE)** — MethodLowering.pm's result/prefix/retained/copy/logical/with roles omit these eight Array producers; actual handlers show unguarded Hash copying and literal DSL despite ready metadata.
  - [x] **FIX** — retain selected canonical Array results with existing actual-kind/rejection dispatch and original first-producer permission, preserving prior guarded owners and source78.0.
  - [x] **ADDRESSED (verified)** — actual19RED to212PASS, direct490, exact old/current private inverse, first readonly0/seven corruptions and matching212 artifact pairs pass.
  - [x] **NO REGRESSION** — all193 healthy projections/175 profiles remain exact; needed errors, Number host isolation, optional/excluded arities, nested kinds, snapshots and earlier guards survive focused source/Hash normals.
  - [x] **LOCKSTEP** — book/worked examples/Knowledge, helper spine/task/index/frontier and change/engineering/live/MEMORY distinguish bounded Perl completion from independent Rust/full admission.

'''
text = text[:start] + node + text[end:]
text = text.replace('Status: `pending` / selected existing-contract ordinary Array transform result guards', 'Status: `active` / bounded Perl complete; independent peers remain', 1)
text = text.replace('Status: `active` / independently acquired; source prerequisite first', 'Status: `completed` / bounded Perl source and result implementation focused-checked; full admission separate', 1)
text = text.replace('Frontier: Bounded Perl source78.0 is repaired/focused-checked. Composition78.1.1 is next from unchanged37/own123/current source-isolation fences; qualified capacity4.16 retains the exact current task tail.', 'Frontier: Bounded Perl source78.0/result78.1.1 are repaired/focused-checked. Independent Rust78.2 is next under unchanged37 and own source/arity/error acquisition; full23.4 remains separate.')
task.write_text(text)

for name in ('CHANGES.md', 'DEVELOPMENT_NOTES.md'):
    p = Path(name); text = p.read_text(); position = text.index('\n## ')
    p.write_text(text[:position] + '\n## 2026-11-07 — ' + LEAF + ' — Guard Perl ordinary Array transform results\n\n' + summary + '\n\nCompatible Array and selected String/Hash bridges, nested kinds, valid empty with and needed errors remain. Incompatible Hash consumers reject before operands and skip later copy/logical/with work. Canonical result arities and original input policies remain separate; no variadic/callback/public-format promotion. Original Python writer warning is preserved; separate raw-string spelling has identical AST and zero compile warnings. Regenerate affected emitted Perl. Evidence: docs/checkpoints/array-transform-composition-perl-2026-11-07/REVIEW.md.\n' + text[position:])

live = Path('LIVE_ACHIEVEMENT_STATUS.md'); text = live.read_text()
for heading, body in (('Current Activity', 'PNT proceeds to independent Rust Array-transform78.2 after bounded Perl78.1.1; remaining peers and full23.4 stay separately owned.'), ('Latest Completed Slice', LEAF + '. ' + summary), ('Next Action', 'From clean Perl78.1.1 landing activate ' + NEXT + '. Independently acquire unchanged37 on native/restored/generated-plan/full emitted-fresh routes and own initial Number/null/Hash, optional/excluded-arity, needed-error and earlier-owner fences before edits. Retain actual first SDK/grammar/instrument/artifact inputs/full channels; assess without importing Perl source policy. Smallest new/direct/inverse/recovery/book/Knowledge/commit; full verification after agreed feature coverage.')):
    start = text.index('## ' + heading + '\n'); end = text.index('\n## ', start + 4)
    text = text[:start] + '## ' + heading + '\n\n' + body + '\n' + text[end:]
start = text.index('## Recent Completions\n') + len('## Recent Completions\n'); end = text.index('\n## History', start)
rows = [line for line in text[start:end].splitlines() if line.startswith('- ')]
rows.insert(0, '- ' + LEAF + ' —212PASS/direct490/private19RED-restored212PASS/seven controls;175 profiles/193 healthy exact; independent Rust78.2 next.')
live.write_text(text[:start] + '\n' + '\n'.join(rows[:16]) + '\n' + text[end:])
Path('MEMORY.md').write_text('''# MEMORY

- activation_commit: `4bfe17f75c20851bc9a634c151071b6d196de57d` — clean Perl composition78.1.1 activation; derive current HEAD from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.23.3.78.1.1` — guard Perl ordinary Array transform results.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.23.3.78.1.1` (completed through landing); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md.
- next_action: From clean Perl78.1.1 landing independently activate TYPE-REFERENCE-BOOK.1.2.23.3.78.2. Acquire own unchanged37 on native/restored/generated-plan/full emitted-fresh routes plus own source/optional/excluded-arity/needed-error/prior-owner fences before production. Retain actual first SDK/grammar/instrument/artifact inputs/full channels; preserve first producer policy separately from result guards. Smallest new/direct/inverse/recovery/book/Knowledge/live/commit; no peer fallback import.
- in_flight_uncommitted: none.
- blockers: none requiring director input. Bounded Perl source78.0/result78.1.1 focused-checked; independent Rust/Dart/Julia/Lua remain. Generic task boundary/query4.17 is P2 after feature coverage, earlier on capacity block. Full native/cache/transitive custody4.2/SESSION5, RAM fallback/card4.14, registration4.1 and declared Lua5.4 remain separately owned.
- evidence: docs/checkpoints/array-transform-composition-perl-2026-11-07/REVIEW.md and default readonly review.py. Unchanged37/original123/own52 yields19RED/193 healthy to212PASS; direct3files490PASS, exact private old19RED/current212PASS and first readonly0/empty stderr/seven controls. All193 healthy projections/175 profiles and212 corresponding module-handler pairs exact. Source78.0 Number gates remain. Original Python writer warning retained; qualified raw-string spelling has identical AST/zero compile warnings, with no original mutation outer-channel completeness credit. No peer/full-domain/context/admission credit.
- publication: Exact canonical4683555e is the last published checkpoint. Later local focused commits require fresh final proof; full23.4/final clean push follows feature coverage.
- verification_policy: Smallest focused checks per slice, mandatory hooks. Same-volume data; other repositories/submodules read-only. Host24GiB; one intensive own job at a time. Cleanup2026-11-07T05:37:20.574917+00:00 remains within24h at activation; recheck next clean boundary. Director RAM policy overrides stale card until4.14.
''')

inventory = Path('docs/checkpoints/type-operation-inventory/helpers.md'); text = inventory.read_text(); start = text.index('Current finite frontier:'); end = text.index('\n', start)
inventory.write_text(text[:start] + 'Current finite frontier: Bounded Perl source78.0/result78.1.1 are focused-checked. Unchanged37/original123/own52 gives212PASS/direct490, exact private19RED-restored212PASS/first readonly/seven controls;193 healthy projections/175 policies stay exact. Independent Rust78.2 is next before peers; no imported source policy. Full source/context/native custody/registration/declared Lua5.4/full23.4 remain separate. Evidence: docs/checkpoints/array-transform-composition-perl-2026-11-07/REVIEW.md.' + text[end:])
root = Path('docs/tasks/TYPE-REFERENCE-BOOK.md'); text = root.read_text()
text = text.replace('bounded source78.0 is focused-checked with189PASS/own123 policies and unchanged37 result defects; composition78.1.1 next;', 'bounded Perl source78.0/result78.1.1 are focused-checked with212PASS/direct490/own175 policies; independent Rust78.2 next;')
text = text.replace('| 1 | `TYPE-REFERENCE-BOOK.1.2.23.3.78.0` | `completed` | Eight local Number fences/189PASS/private inverse/two readonly; original37 result defects remain unchanged. |', '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.3.78.1.1` | `completed` | Bounded Perl Array guards212PASS/direct490/private inverse/readonly/seven controls; source78.0 and175 policies preserved. |')
text = text.replace('| 2 | `TYPE-REFERENCE-BOOK.1.2.23.3.78.1.1` | `pending` | Preserve source78.0 and own123 policies while adding bounded Array-result guards; full23.4 remains separate. |', '| 2 | `TYPE-REFERENCE-BOOK.1.2.23.3.78.2` | `pending` | Independently assess Rust unchanged37/own source/arity/errors before edits; full23.4 remains separate. |')
root.write_text(text)
for name in ('docs/TASK_TREE.md', 'ROADMAP_V2.md'):
    p = Path(name); lines = p.read_text().splitlines(True)
    for index, line in enumerate(lines):
        if line.startswith('Current Perl Array frontier:'):
            lines[index] = 'Current Array frontier: bounded Perl78.1.1 is focused-checked with212PASS/direct490/private inverse/readonly/seven controls. Independent Rust78.2 next under own source/arity/error acquisition; peers/full23.4 remain separate.\n'
        elif line.startswith('Latest PNT slice:') and name == 'docs/TASK_TREE.md':
            lines[index] = 'Latest PNT slice: ' + LEAF + ' — bounded Perl Array212PASS/direct490/private19RED-restored212PASS/readonly/seven controls;175 policies and source78.0 preserved. Next independent Rust78.2, full admission separate.\n'
        elif name == 'docs/TASK_TREE.md' and line.startswith('| `TYPE-REFERENCE-BOOK` |'):
            lines[index] = '| `TYPE-REFERENCE-BOOK` | `active` / fluent methods .1.2.23 | `.spec documentation / complete type and fluent reference` | Bounded Perl Array78.1.1 is repaired/focused-checked with source78.0 intact. Independent Rust78.2 is next from unchanged37/own source/arity/error acquisition, then independent peers. Earlier finite outcomes retain exact task records and host/context qualifications; full source/context/native custody/registration/declared Lua5.4/full23.4 remain separate. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |\n'
    p.write_text(''.join(lines))
Path('git_message_brief.txt').write_text(LEAF + ' - guard Perl ordinary Array transform results\n\nRetain selected Array result/source-prefix roles through kind and rejection dispatch.\nPreserve source78.0, original first-producer permission and prior guarded owners.\nValidate212 groups/direct490, exact private inverse, frozen policies and readonly recovery.\nUpdate worked book examples, Knowledge and task continuity for independent Rust78.2.\n')
print('Bounded Perl completion and independent Rust handoff prepared')
