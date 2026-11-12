"""Publish the actual bounded Dart proof and persistent director push steering."""
import gzip
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT).as_posix()
LEAF = 'TYPE-REFERENCE-BOOK.1.2.23.3.80.3'


def report(tag):
    folder = BASE / 'launches' / tag
    assert (folder / 'exit.txt').read_text() == '0\n'
    assert gzip.decompress((folder / 'stderr.log.gz').read_bytes()) == b''
    return json.loads(gzip.decompress((folder / 'stdout.log.gz').read_bytes()))


proof, current = report('review'), report('current')
assert proof['historical_recovery'] == current['current_inputs'] == 'PASS'
assert (proof['programs'], proof['supported'], proof['separate_compatibility'], proof['preserved'], proof['direct_named_groups']) == (508, 20, 4, 484, 1155)
controls, identities = len(proof['corruption_controls']), current['declared_inputs']
for tag in ('review-publication-query', 'review-catalog-query'):
    assert report(tag)['live_intersections'] == 0


def edit(name, old, new):
    path = ROOT / name; source = path.read_text()
    assert source.count(old) == 1, name + ': exact publication anchor'
    path.write_text(source.replace(old, new, 1))


review = f'''# Dart existing concat arities — bounded result guards

Owner: {LEAF}. Activation:1753884257bed7ce0b842bc406c665671403a828.

Independent source-only508 programs contain shared84 questions, own legacy312,
108 source questions and four exact older ordinary terminal/composed controls.
No Perl/Rust verdict is imported. Own native/restored/plan/fresh intake selects20
supported result continuations, four separately justified scalar-operand legacy
continuations and484 full preservation records. All80 initial-input policies and
eight invalid fixed/rest signatures remain exact. Dart's own Boolean receiver-null/
free-empty distinction and complete available class/error/error_json/field absence
remain. Fresh generated source identities are bound to each authored source, never
masked. The new nested-kinds question is scoped to its source origin.

The unchanged normal exits1 with exactly24RED/484PASS; all508 complete three-route
observations match the cold intake. Only the existing result-chain count guard in
dart/lib/src/runtime/interpreter.dart changes: concat_arrays count==2 to count>=1.
The original terminal producer, invocation/signature checks, parser, emitter and
serialized formats remain unchanged. Source S and additional Arrays T/U run once
in order; valid rest X effects survive. Later Hash rejection skips K/V; persistent
rejection skips D/W. Compatible last/uppercase, empty with, needed source/operand
errors, snapshots and nested Bool/Number/null values retain their own behavior.

All508/four-route outcomes match the frozen profiles. Four legacy continuations
retain terminal effects SX (old callable pair) or SA (old ordinary pair) before
rejecting the later Hash consumer. Scalar operand elements remain in the existing
terminal Array; these are compatibility controls without portable input authority.
Only four route records in each of those four old profile objects transfer; all
other objects and all source/metadata fields stay exact. Both kinds were acquired
before production, so no post-change operand policy is invented.

The exact same private SDK path yields24RED with the old interpreter and508PASS
with only the repaired interpreter. Direct508 new +312 old callable transform
+141 old ordinary transform +194 old callable pipeline =1155 named test groups
pass with one worker. These overlapping suites are not1155 unique DSL programs.
Fatal selected analysis and changed-surface format pass. The first independent
readonly reader0 rejects{controls} reason-sensitive corruptions; current{identities}
input identities pass at activation/pre-staging only. Native/fresh stderr and
outer controllers' stderr are empty; expected old normal failure channels remain.

Recovery verifies1016 retained parsed/module pairs across intake/after,2032 normal
parsed snapshots, exact SDK/source/fixture/wrapper/executed inputs and full modes,
with Git executable class checked separately. Parsed JSON is persisted/read back
before compile/restore; actual modules precede fresh analysis/use. The emitted
payload is normalized SpecFile source state, not complete lowered typed IR.
Historical review executes no current SDK, producer or repair.

Shared publication queries retain all206 accepted claim records with226 historical
intersections for handoff/flow/roadmaps plus the separate catalog query, zero live
bindings, and distinguishing injected live-binding RED controls. No earlier claim,
hash or revision is refreshed. Actual document producer/report/document inputs and
outputs are retained in publication/ and independently recovered by
review_publication.py. Reverify runtime history with review.py; check_current.py is
only the activation/pre-staging identity gate.

Director publication override: monitor after every leaf/before large growth and
publish around1,500,000,000 estimated outgoing bytes even mid-PNT/batch, with full
canonical CI and clean exact HEAD before every push. Committed HEAD1753884 is101
ahead of cached origin4683555e; the conservative local non-thin estimate is
1,233,210,937 bytes. This excludes uncommitted Dart and is not negotiated wire size.
The initial delta-base accounting hypothesis fails; one no-sparse counterfactual
proves sparse inclusion adds exactly five already-at-base blobs. The larger size
remains the monitor; raw packs/indexes stay ignored on this volume. Formal guard/
measurement-closure/discovery/publication owner23.4.30 is the next clean action.

Limits: finite authored controls/full available public error projections only.
Full native/in-memory/VM/cache/transitive/toolchain/OS4.2/SESSION5, source/context/
isolation/discovery4.1/historical4.24/raw-error4.28/launcher4.22/SESSION7/initial-
literal/excluded/declared Lua5.4/formatter/full23.4 remain separately owned. No
portable completeness, performance/population, physical Git/cache/toolchain or
future freshness claim follows. Rebuild Dart applications. Julia/Lua80.4-.5 follow
the clean publication-budget preparation; full CI is not an ordinary-slice check.
'''
(BASE / 'REVIEW.md').write_text(review)
card = f'''---
id: dart-open-arity-concat-result-guards
title: Dart concat results retain guards across existing one or more Array inputs
answers:
  - "why does Dart unary or three Array concat run rejected Hash operands"
  - "which Dart concat arity selector owns later result guards"
  - "where is own Dart family80 four route proof and historical recovery"
  - "which Dart concat scalar operand legacy continuations changed"
  - "does Dart concat preserve initial policies invalid signatures and full errors"
date: 2026-11-12
status: bounded implementation with focused checks; full admission separate
tags: [dart, arrays, concat, guards, functions, source, errors, custody]
evidence: "{LEAF}; {REL}/REVIEW.md;508/four routes/20 supported/four separate compatibility/484 preserved; old24-current508/direct1155/readonly{controls}/current{identities}."
reverify:
  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P {REL}/review.py"
  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P {REL}/review_publication.py"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter expanded --concurrency=1 test/array_concat_open_arity_result_guard_composition_test.dart"
---

The existing terminal concat producer accepts the recorded one/two/three Array
forms. _isOrdinaryArrayTransformArguments near interpreter.dart6614 recognizes
only count2 for result-chain ownership. One changed line admits count>=1 while
keeping terminal producers, function dispatch/signatures and formats exact.
Rebuild Dart applications. Source/additional Arrays and valid rest effects run
once in order; incompatible Hash rejection skips its operands and remains rejected
through copy/logical/with. Compatible consumers, empty Arrays, needed errors,
snapshots and nested kinds stay exact.

Own508/four routes have20 supported repairs/four separate legacy scalar-operand
continuations/484 full preservation records. All80 initial-input/eight invalid-
signature fences and the own Boolean receiver-null/free-empty distinction remain.
Legacy terminals include scalar elements; two callable continuations retain SX,
two ordinary continuations retain SA before later Hash rejection. Only their four
route fields transfer in old profiles; no portable scalar-input authority follows.
Complete class/error/error_json/presence and authored generated identities survive.

Original and same-path old normals yield24RED/484PASS; repaired508/direct1155 named
groups pass. First historical readonly{controls}/current{identities}, selected fatal
analysis and format pass.1016 parsed/module pairs and2032 normal inputs retain
before-use persistence/order and full modes. Emitted normalized source state is
not complete typed IR. Current identity is activation/pre-staging only; recovery
executes no SDK. Native/VM/cache/transitive/toolchain/OS4.2/SESSION5, full source/
context/admission23.4 and older custody/launcher/raw-error/declared-host owners stay
separate. No peer outcome, performance/population or future freshness claim.

Related: [[dart-callable-array-transform-result-guards]],
[[dart-array-transform-result-guards]], [[array-concat-open-arity-result-selection]].
'''
(ROOT / 'docs/knowledge/dart-open-arity-concat-result-guards.md').write_text(card)

flow = 'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md'
edit(flow, 'Perl and Rust guarded\n`concat_arrays` forms now retain', 'Perl, Rust and Dart guarded\n`concat_arrays` forms now retain')
edit(flow, 'bounded Dart/Julia/Lua proof here covers free-two/receiver-one.', 'bounded Julia/Lua proof here covers free-two/receiver-one.')
edit(flow, 'Perl and Rust additionally accept the single-Array terminal', 'Perl, Rust and Dart additionally accept the single-Array terminal')
edit(flow, 'recorded one/two/three-Array Perl and independent Rust controls, including empty Arrays entering with.', 'recorded one/two/three-Array Perl, independent Rust and Dart controls, including empty Arrays entering with.')
edit(flow, 'Perl80.1 and Rust80.2 now retain result guards through these existing arities for', 'Perl80.1, Rust80.2 and Dart80.3 now retain result guards through these existing arities for')
edit(flow, 'unchanged. Rebuild Rust applications. Dart/Julia/Lua independently acquire their\nexisting policies before implementation; full continuation/context admission is separate.', '''unchanged. Rebuild Rust applications. Dart independently passes508 four-route
controls:20 supported result continuations/four separate legacy operand
continuations/484 exact records, with80 initial and eight invalid-signature fences.
Its old callable continuations retain SX, and old ordinary continuations retain
SA before Hash rejection. Their terminal Arrays still include the observed scalar
operand elements; this gives no portable scalar-input authority. Complete runtime/
generated error JSON and authored source identities stay exact. Source-once and
additional Array order, valid rest arguments, snapshots and nested Bool/Number/
null values are preserved. Rebuild Dart applications. Julia/Lua independently
acquire their existing policies before implementation; full continuation/context
admission is separate.''')
edit(flow, 'Perl80.1 and independent Rust80.2 have focused proof; Dart/Julia/Lua lanes remain pending.', 'Perl80.1, independent Rust80.2 and Dart80.3 have focused proof; Julia/Lua lanes remain pending.')
catalog = 'docs/linkedspec-book/src/appendix/helper-contract-catalog.md'
edit(catalog, 'Perl and Rust also accept a single Array:', 'Perl, Rust and Dart also accept a single Array:')
edit(catalog, 'bounded one/two/three-Array Perl and independent Rust intakes.', 'bounded one/two/three-Array Perl, independent Rust and Dart intakes.')
edit(catalog, 'Perl and Rust result guards now cover', 'Perl, Rust and Dart result guards now cover')
edit(catalog, 'The bounded Perl80.1 and Rust80.2 checks preserve their own initial-input and', 'The bounded Perl80.1, Rust80.2 and Dart80.3 checks preserve their own initial-input and')
edit(catalog, 'authority. Rebuild Rust applications to use the corrected result guards. Independent\nDart/Julia/Lua open-arity assessments remain with family80; complete', 'authority. Dart independently retains complete available error JSON and all80\ninitial/eight invalid-signature controls; its four legacy operand continuations\nretain their terminal SX or SA effects before later Hash rejection. Rebuild Rust\nand Dart applications to use the corrected result guards. Independent Julia/Lua\nopen-arity assessments remain with family80; complete')
# Keep the landing page bounded; detailed examples live in the linked reference.
handoff = 'docs/linkedspec-book/src/appendix/backend-handoff.md'
edit(handoff, 'Independent Dart80.3 is next. Evidence: docs/checkpoints/array-concat-open-arity-rust-2026-11-12/REVIEW.md.', f'Independent Dart80.3 is now focused-checked with a one-line result-arity guard:508/four routes/20 supported/four separate legacy operand continuations/484 exact records,80 initial/eight invalid signatures preserved; same-path old24-current508/direct1155/first readonly{controls}/current{identities}/format pass.1016 parsed/module pairs and2032 normal snapshots retain complete available error JSON and authored source identities. Rebuild Dart applications. Publication-budget preparation23.4.30 precedes independent Julia/Lua. Evidence: {REL}/REVIEW.md. Rust evidence: docs/checkpoints/array-concat-open-arity-rust-2026-11-12/REVIEW.md.')
frontier = f'November12 current fluent frontier: Existing concat family80 has independent Perl80.1, Rust80.2 and Dart80.3 focused proof. Dart changes one result-count guard and passes508/four routes:20 supported targets/four separate legacy scalar-operand continuations/484 preserved;80 initial policies/eight invalid signatures exact. Same-path old24-current508/direct1155 named test groups/first readonly{controls}/current{identities}/format pass.1016 parsed/module pairs and2032 normal inputs retain complete available errors/source identities. Original producers/signatures/formats remain. Next clean action: remeasure outgoing pack and activate publication-budget owner23.4.30 before further feature growth; director1,500,000,000-byte early-push trigger supersedes PNT/batch cadence, with canonical CI before every push. Then independent Julia80.4/installed Lua80.5. Full23.4/native4.2/SESSION5/source/context/discovery4.1/historical4.24/raw-error4.28/SESSION7/formatter/declared5.4 remain separate. Evidence: {REL}/REVIEW.md.'
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = ROOT / name; source = path.read_text()
    source, count = re.subn(r'^November12 current fluent frontier:.*$', lambda _: frontier, source, count=1, flags=re.M)
    assert count == 1; path.write_text(source)
task = ROOT / 'docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md'
source = task.read_text(); start = source.index('- ID: `' + LEAF + '`'); end = source.index('\n- ID:', start + 1)
part = source[start:end].replace('Status: `in_progress`', 'Status: `completed` / bounded focused proof; full admission separate', 1)
part = part.replace('Serial one-shot intake is running with a shared24GiB headroom preflight; no interpreter/normal/profile change.', 'Serial one-shot intake and inspection both complete0 before production, with a shared24GiB headroom preflight and complete retained channels.')
part += f'''\n  Completed repair: One interpreter line changes existing concat result ownership count==2 to count>=1; producer/function/signature/parser/emitter/formats unchanged. Frozen own508 profiles select20 supported targets/four separately qualified legacy operand continuations/484 exact records;80 initial policies/eight invalid signatures remain. Original normal24RED/484PASS matches all own native/restored/plan records; after508/four routes exact. All four compatibility controls were acquired before production; only four old profile objects' route fields transfer, source/metadata and all other objects unchanged. No portable scalar-input authority.
  Focused verification: Same-path private old24RED-current508; direct508+312+141+194=1155 named groups0, selected fatal analysis/format0; first independent readonly0/empty stderr/{controls} reason-sensitive corruptions/current{identities} inputs.1016 parsed/module pairs/2032 normal inputs and full source/fixture/wrapper/actual channels/modes recover; parsed before compile/restore, modules before fresh use. Native/fresh/outer stderr empty; expected old test failures retained. Normalized emitted source state is not full lowered typed IR.
  Publication:206 exact accepted claim records/226 historical handoff-flow-roadmap intersections plus separate catalog intersections/zero live bindings and reason-sensitive injected live-binding controls before shared edits. Actual document producer/report/document inputs/outputs retained; independent publication recovery follows. No earlier claim/hash/revision refresh.
  Remaining: Full23.4/native4.2/SESSION5/source/context/discovery4.1/historical4.24/raw-error4.28/launcher4.22/SESSION7/literal/excluded/declared5.4/formatter stay owned. Clean next action remeasures committed outgoing pack and activates23.4.30 publication-budget preparation; no dirty pivot. Julia80.4 then Lua80.5 follow the clean publication boundary. Evidence: {REL}/REVIEW.md.
'''
source = source[:start] + part + source[end:]
source = source.replace('Status: `in_progress` / Perl80.1/Rust80.2 focused-complete; independent Dart80.3 next', 'Status: `in_progress` / Perl80.1/Rust80.2/Dart80.3 focused-complete; publication-budget30 then independent Julia80.4 next', 1)
task.write_text(source)
root = 'docs/tasks/TYPE-REFERENCE-BOOK.md'
edit(root, 'independent Dart80.3 is next; raw-native observability4.28', f'Dart80.3 is focused-checked508/20 supported/four separate compatibility/484 preserved/old24-current508/direct1155/readonly{controls}/current{identities}; publication-budget30 then independent Julia80.4 next; raw-native observability4.28')
edit(root, '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.3.80.3` | `in_progress` | Independent Dart existing-signature concat acquisition/repair after clean Rust80.2; own arity/initial/signature/error/native/source fences before production. |', '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.4.30` | `pending` | After clean Dart80.3, remeasure outgoing pack and prepare1.5GB early-push monitoring/discovery/canonical publication; then Julia80.4. |')

for name, title, text in (
    ('CHANGES.md', f'2026-11-12 — {LEAF}: Dart existing concat result arities', f'One result-count guard retains existing unary/multi-Array concat continuations.\nOwn508/four routes:20 supported/four separate legacy operand compatibility/484\npreserved;80 initial/eight invalid signatures exact. Old24-current508/direct1155\nnamed groups/first readonly{controls}/current{identities}/fatal analysis/format pass.\nComplete errors/source identities,1016 parsed/module pairs and2032 normal inputs\nremain. Four old continuation profile objects transfer without producer/signature/\nformat changes. Book/Knowledge/live/task docs synced. Director1.5GB outgoing push\ntrigger overrides batch cadence; canonical CI still precedes pushes. Full23.4/\nnative closure stays separate. Evidence: {REL}/REVIEW.md.'),
    ('DEVELOPMENT_NOTES.md', f'Dart concat selector preserves its producer arity ({LEAF})', f'Own cold508 source-only programs precede the one-line count==2 to count>=1\nresult guard. Normal24RED/484PASS exactly matches intake. Repaired four routes\nmatch20 supported/four separate compatibility/484 preservation records;80 initial\nand eight invalid-signature records stay exact. Exact older callable SX and\nordinary SA terminal/composed controls were included upfront, and only their four\nroute objects transfer. Same-path private old24-current508/direct1155/first\nreadonly{controls}/current{identities}/fatal analysis/format pass. Complete available\nerror maps/field absence and actual source identities remain. Normalized emitted\nsource state is not lowered typed IR. New parsed inputs precede compile/restore;\n1016 parsed/module pairs and2032 normal snapshots retain full modes. Full native/\nVM/cache/transitive/toolchain/OS closure stays4.2/SESSION5. Shared publication queries\nretain206 claims with zero live bindings; actual documentation producer and input/\noutput chain is recoverable. Operational push estimate1,233,210,937 bytes excludes\nthis uncommitted slice; sparse walking explains five extra base-reachable objects,\nand the original delta-base hypothesis failure remains. New director1,500,000,000-\nbyte early trigger is durable; clean23.4.30 preparation/discovery/full CI governs\npublication before further growth. Evidence: {REL}/REVIEW.md.'),
):
    path = ROOT / name; source = path.read_text(); anchor = re.search(r'^## ', source, re.M)
    assert anchor; source = source[:anchor.start()] + '## ' + title + '\n\n' + text + '\n\n' + source[anchor.start():]; path.write_text(source)
live = ROOT / 'LIVE_ACHIEVEMENT_STATUS.md'; old_live = live.read_text(); history = old_live[old_live.index('## History'):]
recent = old_live[old_live.index('- TYPE-REFERENCE-BOOK.1.2.23.3.80.2'):old_live.index('## History')]
live.write_text(f'''# LIVE ACHIEVEMENT STATUS

## Current Activity

Full PNT continues. Perl80.1/Rust80.2/Dart80.3 existing concat result guards are focused-complete. Publication-budget30 is next at the clean boundary, followed by independent Julia80.4/Lua80.5. Full source/context/portable admission remains23.4.

## Latest Completed Slice

{LEAF}. One result-count line;508/four routes/20 supported/four separate compatibility/484 exact records;80 initial/eight invalid signatures exact. Old24-current508/direct1155 named groups/first readonly{controls}/current{identities}/format pass.1016 parsed/module pairs/2032 normal inputs retained.

## Next Action

After clean Dart80.3, remeasure outgoing pack and activate23.4.30. Monitor after each leaf/before large growth and push around1,500,000,000 estimated bytes even mid-PNT/batch, with clean exact-HEAD canonical CI first. Then resume independent Julia80.4; no peer verdict import. Broader owners remain separate.

## Recent Completions

- {LEAF} —508/four routes/20 supported/four separate compatibility/484 preserved/80 initial/eight invalid signatures; old24-current508/direct1155/readonly{controls}/current{identities}; publication-budget30 next.
''' + recent + history)
memory = f'''# MEMORY

- activation_commit: `1753884257bed7ce0b842bc406c665671403a828` — clean Dart80.3 activation; derive current HEAD from Git.
- latest_completed_leaf: `{LEAF}` — guard existing Dart concat arities with one result-count line and focused proof.
- active_work_unit: `{LEAF}` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md.
- run_state: full PNT, no fixed batch count.
- next_action: After the clean Dart commit, remeasure committed outgoing pack, then activate23.4.30 publication-budget preparation/discovery before further feature growth; exact clean-HEAD canonical CI before any early push. Independent Julia80.4 follows the publication boundary.
- in_flight_uncommitted: none; focused Dart proof and durable director steering committed; no required background job.
- blockers: No director decision needed. Full23.4/native4.2/SESSION5/source/context/isolation/discovery4.1/historical4.24/raw-error4.28/launcher4.22/SESSION7/literal/excluded/declared5.4/formatter remain owned.
- evidence: {REL}/REVIEW.md;508/four routes/20 supported/four separate legacy operand compatibility/484 exact/80 initial/eight invalid signatures. Old24-current508/direct1155 named groups/first readonly{controls}/current{identities}/fatal analysis/format pass.1016 parsed/module pairs/2032 normal inputs retain full available error JSON/source identities and full modes. One interpreter line only; four old profile objects' routes transfer, no producer/function/signature/format change.
- qualifications: Finite own Dart controls, no peer verdict or scalar-input/invalid-signature authority. Boolean receiver-null/free-empty and all initial policies stay exact. Normalized emitted source state is not full typed IR. Native/VM/cache/transitive/toolchain/OS closure remains4.2/SESSION5; current identities are activation/pre-staging only. Shared claim bindings remain historical; no original hash/revision refresh.
- publication: Director override2026-11-12 requires monitoring after each leaf/before large growth and early push around1,500,000,000 estimated bytes even mid-PNT/batch. Full canonical CI/clean exact HEAD remain mandatory. At HEAD1753884/base cached origin4683555e,101 commits estimated1,233,210,937 bytes,266,789,063 below trigger; this excludes Dart's new commit. Remeasure before selecting more work. Raw packs/indexes ignored same-volume; push-monitor-current/ retains operational metadata. No-sparse control proves five extra old blobs arise from sparse walking; original delta-base hypothesis failure retained. Formal measurement closure/guard/discovery/publication belongs23.4.30, not a negotiated-wire/physical Git/cache/toolchain claim.
- verification_policy: Focused ordinary slices/mandatory hooks/canonical publication. Only this repository writable; submodules black boxes. Same-volume data, shared24GiB/serial intensive jobs/director RAM90 policy. Latest cleanup2026-11-11T15:29:23.870616+00:00; supplied policy hashes unchanged at startup.
'''
(ROOT / 'MEMORY.md').write_text(memory)
(ROOT / 'git_message_brief.txt').write_text(f'''{LEAF} - guard existing Dart concat arities

Preserve unary and multi-Array result continuations with one count guard.
Own508/four routes:20 supported/four compatibility/484 preserved; initial and
invalid signatures exact. Old24-current508/direct1155/readonly{controls}/current{identities}.
Sync book, Knowledge and continuity; retain the director1.5GB early-push override.
Focused proof only; broader admission/native closure and canonical push stay owned.
''')
print(json.dumps(dict(publication='PASS', programs=508, readonly_controls=controls, current_inputs=identities)))
