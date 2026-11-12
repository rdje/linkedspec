"""Publish the actual focused Julia outcome and preserve the size-driven frontier."""
import gzip
import json
from pathlib import Path
import re

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
LEAF = 'TYPE-REFERENCE-BOOK.1.2.23.3.80.4'


def report(tag):
    folder = BASE / 'launches' / tag
    assert (folder / 'exit.txt').read_text() == '0\n'
    assert gzip.decompress((folder / 'stderr.log.gz').read_bytes()) == b''
    return json.loads(gzip.decompress((folder / 'stdout.log.gz').read_bytes()))


proof, current, bindings = [report(tag) for tag in ('review', 'current', 'review-publication-query')]
assert proof['historical_recovery'] == current['current_inputs'] == 'PASS'
assert (proof['programs'], proof['supported'], proof['legacy_compatibility'], proof['preserved'], proof['direct_assertions']) == (508, 20, 4, 484, 4959)
assert bindings['live_intersections'] == 0
controls, identities = len(proof['reason_sensitive_controls']), current['declared_inputs']


def edit(name, old, new):
    path = Path(name)
    source = path.read_text()
    assert source.count(old) == 1, 'exact publication anchor:' + name
    path.write_text(source.replace(old, new, 1))


review = f'''# Julia existing concat arities — bounded result guards

Owner: {LEAF}. Activation:952f8a022c59a478614ba1413e0e36e49e7e14e8.

Independent source-only508 programs contain shared84 questions, own Julia
legacy312,108 new source questions and four exact older ordinary terminal/composed
controls. No peer outcome or compatibility verdict is imported. Own public
native/restored/plan/fresh acquisition establishes20 supported result-guard
targets, four separately qualified legacy scalar-operand continuations and484
full preservation records. All80 initial policies/eight invalid signatures stay
exact; source-once/additional Arrays T/U, valid rest X effects, needed complete
errors, field absence, snapshots and nested Bool/Number/null kinds remain.

The unchanged normal reproduces24 failing groups/96 route failures with1936PASS
of2032 assertions. Every full observation equals cold intake. One interpreter
line changes the existing concat result-arity selector from count==2 to count>=1;
one runtests include selects the new normal. Terminal producers, function
resolution/signatures, parser/emitter and formats stay unchanged. A produced
Array rejects incompatible Hash operands before K/V; rejection persists through
copy/logical/with and skips D/W. Compatible consumers and empty Arrays entering
with remain valid.

Own exact terminal/composed contrasts qualify two legacy callable continuations
with SX and two ordinary continuations with SA. Only these four old profile
objects' route results transfer; all source/metadata and other objects remain.
Their terminal Arrays retain scalar operand elements; this is compatibility,
without portable non-Array authority. Julia's independently acquired initial
policies and complete native/generated error JSON stay exact.

Repaired508/four routes pass2032 assertions. The same private SDK path yields
old24RED/current508PASS with compiled modules disabled and only the interpreter
image replaced. Direct new2032 + old callable-transform1248 + ordinary-transform903
+ callable-pipeline776 =4959 assertions pass. These overlapping suites are not
4959 unique DSL programs. First independent historical reader0/empty stderr
rejects{controls} reason-sensitive corruptions; current{identities} actual inputs
pass at activation/pre-staging only. Six508-pair epochs retain3048 parsed/emitted
pairs with byte equality. Parsed JSON persists/readbacks before compile/restore;
emitted modules precede fresh inclusion. All actual source/instruments/fixtures/
grammar/wrappers/channels/full modes survive. Private SDK copies share one path;
fresh Modules share the process/runtime. Successful root precompile output and
expected old Test stderr are retained; other successful SDK/outer stderr is empty.
Older direct normals' transient strings receive no new first-use custody credit.

Historical review.py executes no SDK, producer or repair. check_current.py is only
activation/pre-staging identity, not future freshness. Full native/cache/transitive/
toolchain/OS4.2/SESSION5, source/context/isolation/discovery4.1/historical4.24/raw-
error4.28/launcher4.22/SESSION7/literal/excluded/declared5.4/formatter/full23.4 stay
separately owned. Rebuild Julia applications/use the updated runtime.

The shared publication query retains{bindings['claim_records']} accepted records,
{bindings['historical_intersections']} historical intersections, zero live bindings
and five injected live-binding RED controls. Historical claim hashes/revisions
stay exact. Actual document producer/report/document input/output images and
independent recovery live in publication/ and review_publication.py.

Operational size telemetry is a separate three-leg record at docs/claims/{LEAF}.json:
the new reusable monitor0 at committed952f8a022/cached origin4683555e measures
1,269,685,903 bytes/103 commits/230,314,097-byte trigger margin, excluding this
uncommitted Julia slice. Before-use producer/policy/wrapper and actual channels
survive in push-monitor-current/. Independent validation at these new refs and
full physical/native/raw-pack/toolchain durability are explicit parent30/4.2 gaps.
No fresh remote or negotiated-wire/future-size claim follows. Prepare near1.4GB
and publish around1,500,000,000 bytes even mid-PNT/batch, with canonical discovery/
full CI/normal hooks/clean exact HEAD first. Remeasure after this commit; review
daily cleanup timing before the next long slice, then independent installed
Lua80.5 while margin permits. No full CI or push occurs in this focused slice.
'''
(BASE / 'REVIEW.md').write_text(review)
card = f'''---
id: julia-open-arity-concat-result-guards
title: Julia concat results retain guards across existing one or more Array inputs
answers:
  - "why does Julia unary or three Array concat run rejected Hash operands"
  - "which Julia concat result arity selector owns later guards"
  - "where is own Julia concat full error and source proof retained"
  - "which Julia legacy concat operand continuations transfer"
  - "does Julia concat preserve initial and invalid function signature policies"
date: 2026-11-12
status: bounded80.4 implemented with focused proof; full admission separate
tags: [julia, arrays, concat, guards, functions, errors, custody]
evidence: "{LEAF}; {BASE}/REVIEW.md;508/four routes/20 supported/four separate compatibility/484 preserved/80 initial/eight invalid signatures; old24-current508/direct4959 assertions/readonly{controls}/current{identities}."
reverify:
  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P {BASE}/review.py"
  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P {BASE}/review_publication.py"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia,JSON3,Test; include(ARGS[1])' julia/test/array_concat_open_arity_result_guard_composition_test.jl"
---

At activation952f8a022, Interpreter.jl6981 recognizes concat result ownership only
at count2 while existing terminal producers accept the recorded one/two/three
Array forms. One line admits count>=1 and one normal include selects the proof.
The existing persistent actual-kind guard then rejects Hash operands before K/V
and skips later D/W. First producers/signatures/function dispatch/formats remain.
User-function resolution near4343 rejects unmatched arity before entering the
argument evaluator; fixed/rest failure observations stay exact.

Own508/four routes establish20 supported targets/four separate legacy operand
continuations/484 preservation, with80 initial/eight invalid-signature fences.
Exact own legacy terminal contrasts retain SX or SA and scalar operand elements;
only their four old continuation route records transfer, with no portable input
authority. Complete errors/field absence, authored source identities, snapshots,
nested Bool/null/Number values and source/additional Array/rest order remain.

Old24-current508/private same-path/direct4959 assertions pass; first historical
readonly{controls}/current{identities} and3048 epoch pairs retain full channels,
input identities/modes and new parsed/module first-use order. Successful root
precompilation and old Test stderr remain. Older direct transient strings gain
no new custody credit. Current identity is point-in-time; historical recovery
uses no SDK. Full native/cache/transitive/toolchain/OS4.2/SESSION5 and wider
source/context/discovery/admission23.4 remain open. Rebuild Julia applications.

Related: [[julia-callable-array-transform-result-guards]],
[[julia-array-transform-result-guards]], [[array-concat-open-arity-result-selection]].
'''
Path('docs/knowledge/julia-open-arity-concat-result-guards.md').write_text(card)
flow = 'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md'
edit(flow, 'Perl, Rust and Dart guarded\n`concat_arrays` forms now retain', 'Perl, Rust, Dart and Julia guarded\n`concat_arrays` forms now retain')
edit(flow, 'bounded Julia/Lua proof here covers free-two/receiver-one.', 'bounded Lua proof here covers free-two/receiver-one.')
edit(flow, 'Perl, Rust and Dart additionally accept the single-Array terminal', 'Perl, Rust, Dart and Julia additionally accept the single-Array terminal')
edit(flow, 'recorded one/two/three-Array Perl, independent Rust and Dart controls, including empty Arrays entering with.', 'recorded one/two/three-Array Perl, independent Rust, Dart and Julia controls, including empty Arrays entering with.')
edit(flow, 'Perl80.1, Rust80.2 and Dart80.3 now retain result guards through these existing arities for', 'Perl80.1, Rust80.2, Dart80.3 and Julia80.4 retain result guards through these existing arities for')
edit(flow, 'null values are preserved. Rebuild Dart applications. Julia/Lua independently\nacquire their existing policies before implementation; full continuation/context\nadmission is separate.', '''null values are preserved. Rebuild Dart applications. Julia independently passes
508 four-route controls:20 supported result continuations/four separate legacy
operand continuations/484 preserved, with80 initial/eight invalid signatures exact.
Its callable SX and ordinary SA terminal effects remain before Hash rejection;
terminal scalar elements stay compatibility observations. Complete available
runtime/generated error JSON, source identities, source-once/additional Array/
rest order, snapshots and nested kinds remain. Rebuild Julia applications. Lua
acquires its own policies before implementation; full continuation/context
admission is separate.''')
edit(flow, 'Perl80.1, independent Rust80.2 and Dart80.3 have focused proof; Julia/Lua lanes remain pending.', 'Perl80.1, independent Rust80.2, Dart80.3 and Julia80.4 have focused proof; installed Lua80.5 remains pending.')
catalog = 'docs/linkedspec-book/src/appendix/helper-contract-catalog.md'
edit(catalog, 'Perl, Rust and Dart also accept a single Array:', 'Perl, Rust, Dart and Julia also accept a single Array:')
edit(catalog, 'bounded one/two/three-Array Perl, independent Rust and Dart intakes.', 'bounded one/two/three-Array Perl, independent Rust, Dart and Julia intakes.')
edit(catalog, 'Perl, Rust and Dart result guards now cover', 'Perl, Rust, Dart and Julia result guards now cover')
edit(catalog, 'The bounded Perl80.1, Rust80.2 and Dart80.3 checks preserve their own initial-input and', 'The bounded Perl80.1, Rust80.2, Dart80.3 and Julia80.4 checks preserve their own initial-input and')
edit(catalog, 'and Dart applications to use the corrected result guards. Independent Julia/Lua\nopen-arity assessments remain with family80; complete', '''and Dart applications to use the corrected result guards. Julia independently
passes508/four routes with20 supported/four separate legacy operand/484 preserved
records, all80 initial policies/eight invalid signatures exact. Its complete
error JSON and source/operand/rest effects survive; rebuild Julia applications.
Installed Lua80.5 remains with family80; complete''')
handoff = 'docs/linkedspec-book/src/appendix/backend-handoff.md'
edit(handoff, 'Remeasure after the monitor commit, then continue Julia/Lua while margin permits;', f'Independent Julia80.4 now has a one-line existing concat arity guard/one runner include:508/four routes/20 supported/four separate compatibility/484 preserved/80 initial/eight invalid signatures; old24-current508/direct4959 assertions/first readonly{controls}/current{identities}/3048 pairs pass. Complete errors/source effects remain; rebuild Julia applications. Evidence: {BASE}/REVIEW.md. New committed952f8a022/cached origin4683555e telemetry is1,269,685,903 bytes/103 ahead/230,314,097-byte trigger margin, excluding this Julia slice; its independent-current/native durability gaps stay30/4.2. Remeasure after Julia, then installed Lua while margin permits;')
frontier = f'November12 current fluent frontier: Perl80.1/Rust80.2/Dart80.3/Julia80.4 existing concat result guards have focused proof. Julia508/four routes/20 supported/four separate compatibility/484 preserved/80 initial/eight invalid signatures; same-path old24-current508/direct4959 assertions/first readonly{controls}/current{identities}/3048 pairs pass. Original producers/signatures/formats remain. At Julia activation committed952f8a022/cached origin4683555e estimates1,269,685,903 bytes/103 ahead/230,314,097-byte1.5GB margin; this excludes uncommitted Julia and has explicit independent-current/native custody gaps30/4.2. Remeasure after clean commit, review daily cleanup timing before another long slice, then independent installed Lua80.5 while margin permits. Prepare near1.4GB or earlier for next-slice/receipt growth; canonical discovery4.1/full CI/clean publication30.2 take priority around1,500,000,000 bytes regardless PNT/batch cadence. Full source/context/admission23.4 and existing historical/raw-error/launcher/declared-host/formatter owners remain. Evidence: {BASE}/REVIEW.md.'
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name)
    source, count = re.subn(r'^November12 current fluent frontier:.*$', lambda _: frontier, path.read_text(), count=1, flags=re.M)
    assert count == 1
    path.write_text(source)
task = Path('docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md')
source = task.read_text()
start = source.index('- ID: `' + LEAF + '`')
end = source.index('\n- ID:', start + 1)
part = source[start:end].replace('Status: `active` / independent Julia acquisition before production', 'Status: `completed` / bounded focused proof; full admission separate', 1)
part += f'''
  Completion: One existing concat result-selector line and one normal include; producer/function/signature/parser/emitter/formats unchanged. Own508/four routes/20 supported/four separate legacy operand continuations/484 full preservation/80 initial/eight invalid signatures; old24 failing groups/96 route assertions move to2032PASS. Same-path private old24-current508/direct4959 assertions0; first historical readonly0/empty stderr/{controls} reason-sensitive controls/current{identities}. Six508 parsed/emitted pair epochs retain3048 pairs; new parsed/module first-use order and full available errors/source identities survive. Successful root precompile and expected old Test stderr remain; older direct transient strings gain no new custody credit. Four exact old profile route objects transfer only; no scalar-input authority.
  Publication:{bindings['claim_records']} accepted records/{bindings['historical_intersections']} historical intersections/zero live bindings/five injected REDs precede shared edits. Actual document producer/reports/documents/outputs retained; old claim/hash/revision fields unchanged. New operational telemetry separately declares checked rederive and independent-current/native durability gaps owned by30/4.2. Remeasure after clean commit; review daily cleanup timing then independent installed Lua80.5 while margin permits. Canonical discovery4.1/full CI/clean publication30.2 preempt cadence near the size budget.

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Independent508/four routes; original normal24 failing groups/96 route assertions, all full records equal cold intake.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Public terminal/continuation contrasts and retained products expose Interpreter.jl6981 count2 result selector despite existing open terminal arity.
  - [x] **FIX** — One selector line/one runner include; preserve first producer and function/signature/format contracts. Four separately acquired legacy continuation projections transfer exactly.
  - [x] **ADDRESSED (verified)** —2032 new assertions/private old24-current508/direct4959 assertions/first readonly{controls}/current{identities} pass.
  - [x] **NO REGRESSION** —484 full records/80 initial/eight invalid signatures and nested kinds/source/order/errors exact; all3048 epoch pairs remain byte-equal. Native/cache/toolchain/source/context/full23.4 separate.
  - [x] **DOCUMENTATION** — Book/catalog/backend/Knowledge/roadmaps/task/live/pointer synchronized, actual publication inputs/outputs retained; normal landing checks still govern commit.
  Commit: `{LEAF} - guard existing Julia concat arities`.
  Evidence: {BASE}/REVIEW.md; historical review.py/review_publication.py, current identity only before staging. Full23.4/native4.2/SESSION5/source/context/discovery4.1/historical4.24/raw-error4.28/launcher/SESSION7/literal/excluded/declared5.4/formatter remain owned.
'''
source = source[:start] + part + source[end:]
source = source.replace('Status: `in_progress` / Perl80.1/Rust80.2/Dart80.3 focused-complete; publication-budget30 then independent Julia80.4 next', 'Status: `in_progress` / Perl80.1/Rust80.2/Dart80.3/Julia80.4 focused-complete; installed Lua80.5 next while publication margin permits', 1)
task.write_text(source)
root = 'docs/tasks/TYPE-REFERENCE-BOOK.md'
edit(root, 'publication-budget30 then independent Julia80.4 next; raw-native observability4.28', f'Julia80.4 is focused-checked508/20 supported/four separate compatibility/484 preserved/old24-current508/direct4959 assertions/readonly{controls}/current{identities}; installed Lua80.5 next after fresh size/cleanup timing checks; raw-native observability4.28')
edit(root, '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.3.80.4` | `pending` | After clean monitor30.1, remeasure current outgoing bytes and acquire independent Julia concat policies; canonical publication takes priority near1.4-1.5GB. |', '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.3.80.5` | `pending` | After clean Julia80.4, remeasure outgoing bytes/review daily cleanup timing, then acquire independent installed Lua concat policies; canonical publication takes priority near1.4-1.5GB. |')
for name, heading, body in (
    ('CHANGES.md', f'2026-11-12 — {LEAF}: Julia existing concat result arities', f'One result-arity guard/one runner include preserve existing unary/multi-Array\nconcat continuations. Own508/four routes:20 supported/four separately qualified\nlegacy operand continuations/484 preserved;80 initial/eight invalid signatures\nexact. Old24-current508/direct4959 assertions/first readonly{controls}/current{identities}\npass with3048 retained epoch pairs/full available errors. Four old route-profile\nobjects transfer only; producer/signature/formats stay unchanged. Book/live/docs\nsynced. Remeasure after commit;1.5GB early publication overrides cadence, with\ncanonical proof first. Full native/source/context/admission stays separate.\nEvidence: {BASE}/REVIEW.md.'),
    ('DEVELOPMENT_NOTES.md', f'2026-11-12 — Julia concat result-arity ownership ({LEAF})', f'Own source-only508 intake precedes a one-line count2 to count>=1 result guard,\nwith fixed/rest invocation and terminal producers unchanged. Original24 failing\ngroups/96 route assertions match cold observations; repaired2032 and direct4959\nassertions pass, including same-path private old/current.20 supported targets,\nfour separate legacy continuations and484 full preservation records retain80\ninitial/eight invalid signatures, complete errors/absence and source identities.\nExact callable SX/ordinary SA terminal effects qualify only four old route-profile\nobjects, without scalar-input admission. Six508-pair epochs retain3048 parsed/\nemitted pairs; new first-use order is explicit and older transient direct strings\nreceive no new custody credit. First readonly{controls}/current{identities} pass;\nsuccessful root precompile and old Test stderr remain. Shared publication binds\n{bindings['claim_records']} accepted records/{bindings['historical_intersections']} historical intersections/zero live plus five injected REDs,\nwithout refreshing old claims. New committed952f8a022 telemetry1,269,685,903 bytes\nis separately disclosed with current-independent/native custody gaps30/4.2;\nrecheck after commit. Full native/cache/transitive/toolchain/OS4.2/SESSION5 and\nfull23.4 remain. Evidence: {BASE}/REVIEW.md.'),
):
    path = Path(name)
    source = path.read_text()
    anchor = re.search(r'^## ', source, re.M)
    assert anchor
    path.write_text(source[:anchor.start()] + '## ' + heading + '\n\n' + body + '\n\n' + source[anchor.start():])
live = Path('LIVE_ACHIEVEMENT_STATUS.md')
source = live.read_text()
sections = {
    'Current Activity': 'Full PNT continues. Perl/Rust/Dart/Julia existing concat family80 guards have focused proof; installed Lua80.5 follows fresh size and daily cleanup timing checks. Full source/context/admission remains23.4; canonical publication preempts cadence near1.4-1.5GB.',
    'Latest Completed Slice': f'{LEAF}. One result-arity guard/one runner include;508/four routes/20 supported/four separate compatibility/484 preserved/80 initial/eight invalid signatures. Same-path old24-current508/direct4959 assertions/first readonly{controls}/current{identities}/3048 epoch pairs pass. Full native/cache/toolchain closure remains4.2/SESSION5.',
    'Next Action': 'After clean Julia commit, remeasure current committed outgoing bytes, review daily cleanup timing before another long slice, then independent installed Lua80.5 while margin permits. Prepare near1.4GB; canonical discovery4.1/full CI/normal hooks/clean exact HEAD precede the around1,500,000,000-byte push regardless PNT/batch cadence.',
}
for title, body in sections.items():
    source, count = re.subn(r'(## ' + title + r'\n\n).*?(?=\n\n## )', lambda match: match[1] + body, source, count=1, flags=re.S)
    assert count == 1
start = source.index('## Recent Completions\n\n') + len('## Recent Completions\n\n')
end = source.index('\n## History', start)
rows = source[start:end].strip().splitlines()
assert len(rows) == 16 and all(row.startswith('- ') for row in rows)
(BASE / 'publication/rotated-live-row.txt').write_text(rows[-1] + '\n')
row = f'- {LEAF} —508/four routes/20 supported/four separate compatibility/484 preserved/80 initial/eight invalid signatures; old24-current508/direct4959 assertions/readonly{controls}/current{identities}/3048 pairs; fresh size/cleanup then Lua80.5.'
source = source[:start] + '\n'.join([row] + rows[:15]) + '\n\n' + source[end:]
live.write_text(source)
Path('MEMORY.md').write_text(f'''# MEMORY

- activation_commit: `952f8a022c59a478614ba1413e0e36e49e7e14e8` — clean Julia80.4 activation; derive current HEAD from Git.
- latest_completed_leaf: `{LEAF}` — bounded existing concat result guards with focused proof.
- active_work_unit: `{LEAF}` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md.
- run_state: full PNT, no fixed batch count.
- next_action: Remeasure current committed outgoing bytes with docs/checkpoints/publication-size-monitor-2026-11-12/measure.py. Review daily cleanup timing before the next long slice, then independent installed Lua80.5 while margin permits; canonical discovery4.1/full CI/publication30.2 preempt cadence near1.4-1.5GB or before large growth. Never replay historical one-shot writers.
- in_flight_uncommitted: none; Julia80.4 source/proof/docs committed; no required background job.
- evidence: {BASE}/REVIEW.md;508/four routes/20 supported/four separate compatibility/484 preserved/80 initial/eight invalid signatures. Same-path old24-current508/direct4959 assertions/first readonly{controls}/current{identities}/3048 epoch pairs. One SDK guard line/one runner include; exact four legacy route transfers; producers/signatures/formats unchanged. Successful precompile and old Test stderr remain; old direct transient strings gain no new custody credit.
- publication: Director1,500,000,000-byte early trigger overrides PNT/batch cadence; preparation1,400,000,000 is advisory. Measure after each committed leaf/before large growth. At activation952f8a022/cached origin4683555e, monitor0 measures1,269,685,903 bytes/103 ahead/230,314,097-byte margin, excluding Julia. Metadata/source/channels retained under this checkpoint push-monitor-current/. New record discloses current independent-size/native durability gaps30/4.2; no remote freshness/wire/future guarantee. Remeasure now. Full canonical/current discovery/normal hooks/clean exact HEAD/fresh remote identity precede every push; no push yet.
- qualifications: Finite own authored controls, no peer verdict or scalar-input authority. Historical review.py/review_publication.py recover retained images without SDK/producer replay; check_current.py is activation/pre-staging only. Full23.4/native4.2/SESSION5/source/context/discovery4.1/historical4.24/raw-error4.28/launcher4.22/SESSION7/literal/excluded/declared5.4/formatter remain owned.208 accepted claims/333 historical/zero live and five injected controls protect shared publication; no old claim/hash/revision refresh.
- continuity: Monitor952f8a022/all10/post-pointer/brief0/clean verified before activation. Lua80.5 acquires own policies. Only this repository writable; submodules black boxes. Same-volume data/shared24GiB/serial intensive jobs/RAM90 policy.
- verification_policy: Focused ordinary slices plus mandatory hooks; canonical at publication/mechanical infrastructure boundaries. Latest cleanup2026-11-11T15:29:23.870616+00:00; check actual time before the next long slice and run daily owned cleanup when due. External policy hashes unchanged at startup.
''')
Path('git_message_brief.txt').write_text(f'''{LEAF} - guard existing Julia concat arities

Retain result-kind guards for existing one-or-more Array concat forms with one
selector line and one normal include. Preserve own source/initial/signature/error
policies and qualify only four legacy continuation route records.

Own508/four routes; private old24-current508; direct4959 assertions; first
historical readonly{controls}/current{identities};3048 retained epoch pairs. Book/live/
Knowledge/tasks synced. Full admission/native custody remain separately owned.
Monitor outgoing bytes after this commit; publish around1.5GB regardless cadence
after canonical proof. No full CI or push on this ordinary slice.
''')
print(json.dumps(dict(publication='PASS', historical_controls=controls, current_inputs=identities,
    accepted_claims=bindings['claim_records'], historical_intersections=bindings['historical_intersections'],
    live_intersections=0, next='fresh pack estimate, daily cleanup timing, independent Lua80.5')))
