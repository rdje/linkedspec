"""Publish only after the independent focused proof and current identity pass."""
import gzip
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(BASE.parents[2])
LEAF = 'TYPE-REFERENCE-BOOK.1.2.23.3.80.2'
NEXT = 'TYPE-REFERENCE-BOOK.1.2.23.3.80.3'
SUBJECT = LEAF + ' - guard existing Rust concat arities'
for tag in ('review-qualified', 'current-qualified', 'format', 'review-publication'):
    assert (BASE / 'launches' / tag / 'exit.txt').read_text() == '0\n', 'unverified publication:' + tag
    assert gzip.decompress((BASE / 'launches' / tag / 'stderr.log.gz').read_bytes()) == b''
review = json.loads(gzip.decompress((BASE / 'launches/review-qualified/stdout.log.gz').read_bytes()))
identity = json.loads(gzip.decompress((BASE / 'launches/current-qualified/stdout.log.gz').read_bytes()))
assert review['readonly'] == identity['current_inputs'] == 'PASS'
controls = len(review['corruption_controls'])
current = identity['declared_inputs']


def replace(path, before, after):
    path = Path(path); body = path.read_text()
    assert body.count(before) == 1, str(path) + ': publication anchor'
    path.write_text(body.replace(before, after, 1))


replace('docs/linkedspec-book/src/appendix/helper-contract-catalog.md',
    'Perl also accepts a single Array:', 'Perl and Rust also accept a single Array:')
replace('docs/linkedspec-book/src/appendix/helper-contract-catalog.md',
    'bounded one/two/three-Array Perl intake.', 'bounded one/two/three-Array Perl and independent Rust intakes.')
replace('docs/linkedspec-book/src/appendix/helper-contract-catalog.md',
    'Perl result guards now cover the existing one-or-more Array signature, including',
    'Perl and Rust result guards now cover the existing one-or-more Array signature, including')
replace('docs/linkedspec-book/src/appendix/helper-contract-catalog.md',
    'The bounded Perl80.1 checks preserve the existing initial-input and fixed/rest\nfunction policies. Independent Rust/Dart/Julia/Lua open-arity assessments remain\nwith family80; complete source/context/portable admission is separate.',
    'The bounded Perl80.1 and Rust80.2 checks preserve their own initial-input and\nfixed/rest function policies. Rust keeps scalar operand elements in its legacy\nterminal producer; those compatibility controls grant no portable non-Array input\nauthority. Rebuild Rust applications to use the corrected result guards. Independent\nDart/Julia/Lua open-arity assessments remain with family80; complete\nsource/context/portable admission is separate.')
page = 'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md'
replace(page, 'and `sorted`/`reversed` take no extra receiver operands. Perl guarded `concat_arrays`\nforms now retain the existing one-or-more Array signature; the bounded peer\nproof here covers free-two/receiver-one.',
    'and `sorted`/`reversed` take no extra receiver operands. Perl and Rust guarded\n`concat_arrays` forms now retain the existing one-or-more Array signature; the\nbounded Dart/Julia/Lua proof here covers free-two/receiver-one.')
replace(page, 'Perl additionally accepts the single-Array terminal', 'Perl and Rust additionally accept the single-Array terminal')
replace(page, 'recorded one/two/three-Array Perl controls, including empty Arrays entering with.',
    'recorded one/two/three-Array Perl and independent Rust controls, including empty Arrays entering with.')
replace(page, 'Perl80.1 now retains result guards/readiness through these existing arities for',
    'Perl80.1 and Rust80.2 now retain result guards through these existing arities for')
replace(page, 'Each remaining backend independently acquires its existing arity and producer\npolicies before implementation. Full continuation/context admission is separate.',
    'Rust independently retains all80 initial-input controls and eight invalid-signature\nrecords. Its legacy terminal concat includes scalar operand elements; two old\ncontinuations now reject a later Hash consumer after preserving their terminal SX\neffects. These are separate compatibility controls, with no non-Array admission.\nTwo additional older ordinary expectations at that same scalar-operand boundary\nare independently qualified by exact old/current terminal/composed probes; their\nterminal values/effects stay exact and their later Hash consumer now skips K/W.\nThe original failed direct run remains recorded. These controls sit outside504.\nIts16 supported repairs retain source-once S/T/U, valid rest-argument X effects,\nneeded complete error strings and snapshots through native/restored/plan/fresh\nexecution. The original producer, function dispatch and source formats are\nunchanged. Rebuild Rust applications. Dart/Julia/Lua independently acquire their\nexisting policies before implementation; full continuation/context admission is separate.')
replace(page, 'Perl80.1 has focused proof and independent peer lanes remain pending.',
    'Perl80.1 and independent Rust80.2 have focused proof; Dart/Julia/Lua lanes remain pending.')
replace('docs/linkedspec-book/src/appendix/backend-handoff.md', 'Independent Rust80.2 is next.',
    f'Independent Rust80.2 now has a two-line selector/comment repair:504 four-route records pass, with16 supported targets/two separate legacy operand continuations/486 fully preserved records. All80 initial policies/eight invalid signatures stay exact. Same-path old18RED-current504/combined direct1205/first independent readonly{controls}/current{current} pass;504 before-after parsed/compiled/emitted triples stay exact. Original producers/function dispatch/signatures/formats remain unchanged; rebuild Rust applications. Complete native/cache/toolchain/OS/transitive closure stays4.2/SESSION5. The first direct1/ordinary193+2 failure is retained; two extra ordinary expectations outside504 are qualified through exact terminal/composed old/current probes, and only missing508 checks then pass. Independent Dart80.3 is next. Evidence: {REL}/REVIEW.md.')

(BASE / 'REVIEW.md').write_text(f'''# Rust existing concat arities — bounded result guards

Owner: {LEAF}. Activation: b3b9795f5c983e4dfb7ffa353b8368657c06bb65.

Independent source-only504 programs contain shared84 questions, own legacy312 and
108 source questions with no imported Perl outcomes. Actual native/restored/plan/
fresh intake, own public parsed/compiled projections and terminal contrasts select
16 supported composition failures, two separate legacy scalar-operand continuations
and486 exact preservation records. All80 initial-input policies and eight invalid
fixed/rest signature records remain unchanged. Rust's original concat producer
keeps scalar operand elements; the legacy terminal is [["head","tail","tail",1],"SX"].
Neither those controls nor malformed calls grant portable input/signature authority.
The two additional ordinary-profile transfers are disclosed separately below.

The unchanged-engine normal actually exits101 with18RED/486PASS, and all504 full
native/restored/plan records match the independent intake. Public compiled snapshots
expose ordinary/function free and receiver arity distinctions before source diagnosis.
The existing result selector only recognizes count2 even though the existing producer
already accepts the observed one/two/three Array forms. Rehearsal/apply/scoped format0
changes only count==2 to count>=1 and its stale comment. The original terminal helper,
function evaluation, signatures, parser/serialized/emitted formats and other owners
remain exact. Source S/T/U and valid rest X effects survive; Hash rejection skips
K/V and persistent rejection skips D/W. Needed errors retain their entire published
String, including the plan wrapper prefix. Bool/Number/null and snapshots stay exact.

All504 repaired four-route records pass frozen expectations, with identical504 pairs
of parsed/compiled/emitted triples. Only the two independently acquired legacy
continuations transfer to the old312 profile; all other objects and source cases
stay exact. The same private source path/oracle fails18 with the exact original
owner and passes504 with only the repaired owner. The only private manifest edit
rebases the existing public RGX path. The first direct controller exits1: new504 pass and ordinary193 pass, while two
additional old ordinary profile projections fail with actual101. Exact source-only
four-program terminal/composed probes on the same private original/current SDK pass
all four routes: terminal [["b","a","z",1],"SX"] stays exact, while the later Hash
consumer now rejects before K/W. Only those two ordinary profile projections change;
they are outside main504 and grant no portable scalar-input authority. Their two
filtered normals pass, and the previously unexecuted callable312/pipeline194 pass.
Combined unique focused coverage is504+193+2+312+194=1205; the successful504/193
groups are not replayed and the original actual1/101 channels remain. Completion
retains1008 already-written original normal snapshots after the controller failure,
without claiming an earlier archive event. SDK remains only two changed lines.
Rustfmt passes.

The first full independent qualified readonly reader exits0 with empty stderr and rejects
{controls} reason-sensitive corruptions. Current{current} actual direct-run inputs pass
before staging. Recovery executes no SDK; it reads actual complete channels, before-use
root/source/parsed/compiled/emitted/executed-product capsules and full modes, with
Git executable class checked separately. All native/fresh stderr channels are empty;
expected old normal failures and compiler channels remain in full. Exactly archived
intake build-tree/executable duplicates retire only after archive recovery and use;
no cache or earlier evidence is deleted and no physical reclamation is claimed.

The publication query retains all206 accepted claim records,317 historical
intersections and zero live bindings before changing shared book pages. Independent
recovery and three injected live-binding controls pass; no earlier claim/hash/revision
is refreshed. Original one-shot instruments/results remain immutable. launch capsules
retain producers and separate stdout/stderr/exit; review_qualified.py is the historical reverify
entrypoint, check_current.py is activation/pre-staging identity only.

Limits: finite authored controls and public String diagnostics, without complete
operation/context/population or raw typed diagnostic authority. Native/in-memory/VM/
cache/transitive/toolchain/OS closure4.2/SESSION5, older direct transient inputs,
historical4.24/source/context/isolation/discovery4.1/raw-error4.28/launcher4.22/SESSION7,
initial-literal/excluded policies/declared Lua5.4/formatter/full23.4 stay separately
owned. Full verification follows feature coverage and the final clean push boundary.
''')

card = Path('docs/knowledge/rust-open-arity-concat-result-guards.md')
assert not card.exists()
card.write_text(f'''---
id: rust-open-arity-concat-result-guards
title: Rust concat results retain guards across their existing open arity
answers:
  - "why does Rust one or three Array concat run rejected Hash operands"
  - "how do Rust open arity concat result guards work"
  - "which Rust concat scalar operand compatibility profiles changed in family80"
  - "does Rust concat preserve source and additional Array operand effects"
  - "where is independent Rust concat four route proof and historical recovery"
  - "were Rust concat initial policies and invalid function signatures preserved"
date: 2026-11-12
status: bounded implementation with focused checks; full admission separate
tags: [rust, arrays, concat, guards, functions, source, errors, custody]
evidence: "{LEAF}; {REL}/REVIEW.md;504/four routes/16 supported/two separate compatibility/486 preserved; old18-current504/combined direct1205/first readonly{controls}/current{current}."
reverify:
  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P {REL}/review_qualified.py"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -j 1 -p linkedspec-runtime --test array_concat_open_arity_result_guard_composition -- --test-threads=1"
---

The terminal concat producer already accepts the recorded one/two/three Array
forms. The result classifier near engine.rs9255 restricted ownership to exactly
two effective operands. Native/restored/plan/fresh terminal and compiled-source
observations isolate16 supported later-consumer failures. Two changed lines
including the comment admit the existing min-one result shape. Producers,
function dispatch/signatures and formats stay unchanged; rebuild Rust applications.

All504 complete route records pass.486 records, all80 initial policies and eight
invalid function calls remain exact. Source S/T/U and valid rest X effects run
once/in order; a wrong Hash consumer skips K/V, and rejection survives copy/logical/
with without D/W. Complete published error Strings, snapshots and nested Bool/
Number/null kinds stay exact. Rust's legacy terminal includes scalar operand
elements; two later continuations now retain SX before Hash rejection. They are
separate compatibility changes, without supported non-Array admission. Only those
two old312 profile objects transfer; every other old object/case stays exact.

The first direct controller1 retains new504PASS plus ordinary193PASS/two older
expectation failures. Exact four-route same-path old/current probes preserve their
terminal Array/SX and qualify only two outside504 ordinary projections. Filtered
two plus previously unexecuted callable312/pipeline194 pass; combined unique
coverage is504+193+2+312+194=1205 without replaying completed groups. Original
failure channels and1008 completed normal snapshots remain recoverable.

Same-path old18RED-current504/combined direct1205 and first readonly{controls}/current{current}
pass.504 before-after source triples and before-use executed copies survive;
recovery runs no current SDK. Current identity is activation/pre-staging only.
All SDK native/fresh stderr is empty; original expected test/compiler channels
remain. Full native/cache/transitive/toolchain/OS4.2/SESSION5, source/context/
isolation/discovery4.1/historical4.24/launcher/SESSION7/raw-error4.28/declared5.4/
formatter/full23.4 stay owned. No portable completeness or earlier transient-input
custody claim follows. Independent Dart/Julia/Lua80.3-.5 follow clean Rust80.2.

Related: [[rust-callable-array-transform-result-guards]],
[[rust-array-transform-result-guards]], [[array-concat-open-arity-result-selection]].
''')

task = Path('docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md')
s = task.read_text(); start = s.index('- ID: `' + LEAF + '`'); end = s.index('\n- ID: `' + NEXT + '`', start)
leaf = s[start:end].replace('  Status: `in_progress`', '  Status: `completed` / bounded focused proof; full admission separate', 1)
leaf = re.sub(r'^  Planned (?:verification tier|focused checks|canonical trigger|claim verification):.*\n', '', leaf, flags=re.M)
leaf += f'''
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Independent504/four routes; exact unchanged normal18RED/486PASS, with16 supported terminal contrasts/two separate legacy operand continuations.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Public compiled snapshots then engine.rs9255 show count2 result selector despite existing terminal arity; no producer/signature/format movement.
  - [x] **FIX** — Two changed lines including comment admit existing min-one concat result ownership, preserving source/operand effects and needed errors.
  - [x] **ADDRESSED (verified)** —504/four routes/private old18-current504/combined direct1205/first independent readonly0-empty stderr/{controls} controls/current{current}/format0.
  - [x] **NO REGRESSION** —486 full records/all80 initial policies/eight invalid signatures exact; nested Bool/Number/null/source snapshots and all504 source triples retained. Two own scalar-operand continuations transfer separately with SX, no input authority.
  - [x] **DOCUMENTATION** — Book/catalog/backend/card/live docs synced; publication206/317 historical/zero-live/three injected controls; no earlier claim binding refresh.
  Commit: `{SUBJECT}`.
  Narrative: {REL}/REVIEW.md; first-use capsules/full modes/separate actual channels/{controls} reason-sensitive controls; recovery executes no SDK, current identity is pre-staging only.
  Remaining: Full23.4/native4.2/SESSION5/source/context/discovery4.1/historical4.24/raw-error4.28/launcher4.22/SESSION7/literal/excluded/declared5.4/formatter remain owned. Independent Dart80.3 next; canonical discovery4.1 includes the new Rust normal before admission/push.
'''
s = s[:start] + leaf + s[end:]
s = s.replace('Perl80.1 focused-complete; independent Rust80.2 next', 'Perl80.1/Rust80.2 focused-complete; independent Dart80.3 next')
task.write_text(s)
replace('docs/tasks/TYPE-REFERENCE-BOOK.md', LEAF + '` | `in_progress`', NEXT + '` | `pending`')
replace('docs/tasks/TYPE-REFERENCE-BOOK.md',
    'Independent Rust existing-signature concat acquisition/repair after clean headroom29; own arity/initial/signature/error/native/source fences before production.',
    'Independent Dart existing-signature concat acquisition/repair after clean Rust80.2; own arity/initial/signature/error/native/source fences before production.')
replace('docs/tasks/TYPE-REFERENCE-BOOK.md', 'independent Rust80.2 is next;',
    f'Rust80.2 is focused-checked504/16 supported/two separate compatibility/486 preserved/old18-current504/combined direct1205/first readonly{controls}/current{current}; independent Dart80.3 is next;')


def prepend(path, record):
    path = Path(path); body = path.read_text(); match = re.search(r'^## ', body, re.M)
    assert match
    path.write_text(body[:match.start()] + record + '\n\n' + body[match.start():])


prepend('CHANGES.md', f'''## 2026-11-12 — {LEAF}: Rust existing concat result arities

Two selector/comment lines retain existing one-or-more Array concat result guards,
without producer/function/signature/format changes. Independent504/four routes:
16 supported targets/two separate legacy scalar-operand continuations/486 full
preservation;80 initial/eight invalid-signature records exact. Original18RED,
same-path old18-current504/combined direct1205/first readonly{controls}/current{current} and
format pass. Source triples/channels/executed copies remain recoverable. Book,
Knowledge and live docs synced; full23.4/native closure stays separate. Evidence:
{REL}/REVIEW.md.''')
prepend('DEVELOPMENT_NOTES.md', f'''## 2026-11-12 — Rust concat selector retains producer arity ({LEAF})

Public terminal/compiled observations precede diagnosis: count==2 in the result
selector excludes existing unary/three-Array results. count>=1 plus one comment
retains current producer/source effects while guarding later Hash consumers and
persistent rejection. Rust keeps scalar operand elements, unlike Perl: two legacy
continuations preserve SX and transfer separately;80 initial policies/eight invalid
function calls stay exact. Full published String errors/Bool versus Number/source
snapshots are compared strictly. All504 source triples and actual pre-use execution
products remain; first readonly{controls}/current{current}/same-path18-current504/
combined direct1205 pass. Publication query206/317 historical/zero live leaves original
claim revisions untouched. Complete native/cache/transitive/toolchain/OS closure
and full23.4 remain deferred. Evidence: {REL}/REVIEW.md.''')
live = Path('LIVE_ACHIEVEMENT_STATUS.md'); body = live.read_text()
history = body[body.index('## History'):]
recent = re.findall(r'^- TYPE-REFERENCE-BOOK[^\n]*', body, re.M)
recent = [f'- {LEAF} —504/four routes/16 supported/two separate compatibility/486 preserved/80 initial/eight invalid signatures; old18-current504/combined direct1205/first readonly{controls}/current{current}; Dart80.3 next.'] + recent[:15]
live.write_text(f'''# LIVE ACHIEVEMENT STATUS

## Current Activity

Full PNT continues. Perl80.1 and independent Rust80.2 existing concat result guards are focused-complete; independent Dart80.3 is next. Full source/context/portable admission remains23.4.

## Latest Completed Slice

{LEAF}. Two selector/comment lines;504/four routes/16 supported targets/two separate legacy operand continuations/486 exact records. All80 initial policies/eight invalid signatures stay exact. Same-path old18-current504/combined direct1205/first readonly{controls}/current{current}/format pass, with504 exact before-after source triples and retained execution products/channels.

## Next Action

Activate independent Dart80.3 from clean Rust80.2; read frozen80 and own public contracts, acquire source-only questions and own terminal/initial/arity/signature/error policies before production. No Rust/Perl verdict import; canonical discovery/native/source/context/historical/raw-error/formatter/declared-host owners remain separate.

## Recent Completions

''' + '\n'.join(recent) + '\n\n' + history)
Path('MEMORY.md').write_text(f'''# MEMORY

- activation_commit: `b3b9795f5c983e4dfb7ffa353b8368657c06bb65` — clean Rust80.2 base; derive current HEAD from Git.
- latest_completed_leaf: `{LEAF}` — `{SUBJECT}`.
- active_work_unit: `{LEAF}` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md.
- run_state: full PNT, no fixed batch count.
- next_action: Activate independent Dart80.3 from clean Rust80.2, read frozen80 and own public contracts, acquire source-only questions and own terminal/initial/arity/signature/error policies before production. Import no Rust/Perl outcomes.
- in_flight_uncommitted: none; intended clean post-landing handoff, no background proof pending.
- blockers: No director decision needed. Full23.4/native4.2/SESSION5/source/context/isolation/discovery4.1/historical4.24/raw-error4.28/launcher4.22/SESSION7/literal/excluded/declared5.4/formatter stay owned; discovery4.1 includes both new concat normals before admission/push.
- evidence: {REL}/REVIEW.md;504/four routes/16 supported/two separate legacy operand continuations/486 exact records/80 initial/eight invalid signatures; unchanged original18RED/486PASS, private old18-current504/combined direct1205/first independent readonly{controls}/current{current}/format0.504 before-after source triples/full channels/executed products remain.
- qualifications: Finite own authored controls and complete published Rust String diagnostics, no portable completeness or scalar/invalid-function admission. Existing terminal preserves scalar elements; only two legacy composed profiles transfer with SX. No SDK producer/signature/format change or native/cache/transitive/toolchain/OS closure; older direct transient custody stays open. Publication206/317 historical/zero live/three controls preserves original claim records.
- open_scope: Independent Dart/Julia/Lua80.3-.5 next; broader verification and defect owners remain task-tree scheduled. Task headroom29 retained25 IDs/22 closed/three unchanged/full22339-byte tail,48937 renewed bytes under unchanged tools/limits.
- publication: Exact canonical4683555e is last recorded published checkpoint; final clean push follows agreed coverage and fresh canonical proof.
- verification_policy: Focused ordinary slices/mandatory hooks/canonical final push. Same-volume data; other repositories/submodules read-only. Shared24GiB/serial intensive jobs/memory checks, director RAM90 policy. Latest cleanup2026-11-11T15:29:23.870616+00:00; supplied policy hashes unchanged at startup.
''')
Path('git_message_brief.txt').write_text(SUBJECT + '\n\nRetain existing concat result guards with original producers and signatures.\n\nValidate independent504/four routes, exact old18-current504/combined direct1205,\nfull historical recovery/corruptions/current identities and synchronized book.\n')
print(json.dumps(dict(publication='prepared', owner=LEAF, next=NEXT, controls=controls, current_inputs=current)))
