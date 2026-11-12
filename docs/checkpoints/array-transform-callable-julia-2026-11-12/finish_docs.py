"""Synchronize the completed Julia slice and its public compatibility boundaries."""
from pathlib import Path
import re
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
names = ['MEMORY.md', 'LIVE_ACHIEVEMENT_STATUS.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md',
    'ROADMAP.md', 'ROADMAP_V2.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md',
    'docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md', 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md',
    'docs/knowledge/array-transform-callable-result-selection.md',
    'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md',
    'docs/linkedspec-book/src/appendix/backend-handoff.md']
with tarfile.open(BASE / 'docs-before.tar.gz', 'x:gz') as archive:
    for name in names:
        archive.add(ROOT / name, arcname=name, recursive=False)

def replace(name, old, new):
    path = ROOT / name; text = path.read_text()
    assert text.count(old) == 1, (name, old)
    path.write_text(text.replace(old, new))

frontier = ('Independent Julia78.6.4 is implemented with focused312/four routes,28 supported targets/'
    'three separate initial-source compatibility/281 preserved and104 initial policies exact. '
    'Same-path31RED-current312/direct2927 assertions/first readonly24/current519 pass;1872 actual pairs/'
    'nine traces retain full available error maps and new first-use ordering. Classifier4/2 and one runner include '
    'only. Perl/Rust/Dart bounded slices are committed. Independent installed Lua78.6.5 is next; open concat42 '
    'follows bounded78.6. Full23.4/native/source/context/registration/historical4.24/SESSION7/formatter/declared5.4 stay separate.')
for name, label in (('ROADMAP_V2.md', 'Current fluent frontier: '), ('ROADMAP.md', 'November12 current fluent frontier: ')):
    path = ROOT / name; text = path.read_text(); start = text.index(label); end = text.index('\n\n', start)
    path.write_text(text[:start] + label + frontier + text[end:])
replace('docs/tasks/TYPE-REFERENCE-BOOK.md', 'independent Julia78.6.4 is next;',
    'independent Julia78.6.4 is focused-checked312/28 targets/three separate compatibility/281 preserved/private31-current312/direct2927 assertions/first readonly24/current519; installed Lua78.6.5 is next;')
replace('docs/tasks/TYPE-REFERENCE-BOOK.md',
    '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.3` | `completed` | Independent312/28 targets/three compatibility/281 preserved; private31-current312/direct647/qualified readonly24/current510; original reader1/notice retained. |',
    '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.4` | `completed` | Independent312/28 targets/three compatibility/281 preserved; private31-current312/direct2927 assertions/first readonly24/current519;1872 pairs/nine traces. |')
replace('docs/tasks/TYPE-REFERENCE-BOOK.md',
    '| 2 | `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.4` | `in_progress` | Acquire independent Julia source/optional/excluded/signature/error/order/snapshot policies from clean Dart; no peer outcome import. |',
    '| 2 | `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.5` | `pending` | Acquire installed Lua independently from clean Julia, on each actual host; preserve native input/error/source policies and safe-runner/formatter boundaries. |')
task = ROOT / 'docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md'; text = task.read_text()
text = text.replace('bounded Perl/Rust/Dart focused-checked; independent Julia/Lua pending', 'bounded Perl/Rust/Dart/Julia focused-checked; installed Lua pending', 1)
start = text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.4`'); end = text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.5`', start)
node = text[start:end].replace('Status: `in_progress`', 'Status: `completed`', 1)
old = 'Focused checks: Own full four-route acquisition/public traces/error maps/policy freeze before production; new and direct-dependent normal, exact same-path old/current if repaired, historical recovery/corruptions/current identities/docs and normal hooks. Actual results follow before completion.'
assert old in node
node = node.replace(old, 'Focused checks: Independent312/four routes/full errors/nine public traces; original/private31RED-current312; direct1248+903+776=2927 assertions; rehearsal/apply0; first historical reader0/24 controls/current519; book/memory/history/normal hooks.')
node += '''  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Original312 full wires/312 pairs/nine public traces and normal1124PASS/124FAIL; before comparison0 exactly matches cold data.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Registered-source exclusion near6991 bypasses existing actual-kind guard; invocation already resolves fixed/minimum signatures before arguments, and first-producer policy remains.
  - [x] **FIX** — Classifier4 insertions/two deletions and one local runner include; unregistered free-helper identity, helper bodies/arity/formats/source scope remain.
  - [x] **ADDRESSED (verified)** —312/four-route1248 assertions; same-path old31RED-current312; first full historical reader0/empty stderr/24 effective controls/current519.
  - [x] **NO REGRESSION** —281 complete records/104 initial policies/1872 actual pairs/nine parsed trace inputs exact; unchanged direct normals give2927 assertions. Own Boolean receiver-null/free-empty and sorted/reversed SXKVW remain.
  - [x] **LOCKSTEP** — Book/backend/Knowledge/live/resume/task/index/scope/history align; focused doc gates and normal landing precede independent installed Lua78.6.5. Full23.4 remains separate.
  Outcome: docs/checkpoints/array-transform-callable-julia-2026-11-12/REVIEW.md. Only28 targets count as supported repair; three initial-source continuations are separate compatibility. First full readonly0 with24 reason-sensitive controls, with mutation preconditions outside rejection handlers; current519 is pre-staging. Eighteen exact plain trace/input duplicates retire after archive verification, retaining all proof. Expected old Test failure and successful root precompile stderr stay explicit; no new launcher notice in SDK proof. Older direct normals are semantic proof without new transient-generated/native-custody credit. Full4.2/SESSION5/historical4.24/source/context/isolation/registration4.1/safe-launcher4.22/SESSION7/shadowing32/declared5.4/formatter/full23.4 remain owned; no Julia policy is imported for Lua.

'''
task.write_text(text[:start] + node + text[end:])
replace('docs/tasks/TYPE-REFERENCE-BOOK.overview.md', '  Addition78.6.3:',
    '  Addition78.6.4: Check actual canonical discovery for julia/test/array_transform_callable_result_guard_composition_test.jl, its callable_array_transform_observation.jl include and array_transform_callable_result_guard_julia_cases.json/profiles.json fixtures before23.4/push. One local runner include and focused1248/direct2927 do not establish canonical selection. Preserve independent full error/producer fences and new first-use inputs; older direct transient strings gain no custody credit.\n  Addition78.6.3:')
replace('docs/knowledge/array-transform-callable-result-selection.md',
    'status: qualified selection41 frozen; bounded Perl/Rust/Dart focused-checked; independent Julia next',
    'status: qualified selection41 frozen; bounded Perl/Rust/Dart/Julia focused-checked; installed Lua next')
replace('docs/knowledge/array-transform-callable-result-selection.md',
    'Julia/installed Lua acquire their own policies next.',
    'Independent Julia78.6.4 is now focused-checked: [[julia-callable-array-transform-result-guards]] records28 targets/three separate initial-source compatibility/281 preserved/104 initial policies, private31-current312/direct2927 assertions/first readonly24/current519,1872 actual pairs/nine public traces. Installed Lua acquires its own policies next.')
book = 'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md'
replace(book, 'same result-kind guards on Perl, Rust and Dart.', 'same result-kind guards on Perl, Rust, Dart and Julia.')
replace(book, 'Dart independently passes the same four public route classes, its own old/current\ncontrols and focused regressions. Each remaining',
    'Dart and Julia independently pass the same four public route classes, their own\nold/current controls and focused regressions. Each remaining')
replace(book, 'do not grant a new input domain or imply a policy for Julia or Lua.',
    'do not grant a new input domain or imply a policy for Lua.\n\nJulia independently preserves all of its initial producer and immediate-`with`\nobservations, including `[null,""]` for Boolean receiver `take` and `[0,"W"]`\nfor the corresponding free helper. Its Number/null/Hash inputs retain empty Arrays\nfor the seven non-concat transforms, and `concat_arrays` retains an initial scalar\nor Hash as one element. Only the later rejected continuations change. These are\ncompatibility observations; portable programs supply Arrays.')
replace(book, 'their receiver forms evaluate it. Function fixed/rest arity checks and complete\navailable error fields remain intact. Wider open-arity',
    'their receiver forms evaluate it. Julia evaluates the extra operand in both\nfree and receiver forms: its observed order remains `SXKVW` for the excluded\nHash/with continuation. Function fixed/rest arity checks and complete available\nerror fields remain intact. Wider open-arity')
handoff = 'docs/linkedspec-book/src/appendix/backend-handoff.md'
replace(handoff, 'Independent Julia78.6.4 is next; full23.4/SESSION7/native/source/context/registration/historical4.24 stay open.',
    'Independent Julia78.6.4 now has a classifier4/2 repair and one runner include:312/four-route1248 assertions,28 supported targets/three separate initial-source compatibility/281 preserved/104 initial policies exact. Boolean receiver-null/free-empty and both free/receiver sorted-reversed excess SXKVW remain. Same-path31RED-current312/direct2927 assertions/first full readonly0 with24 controls/current519 pass;1872 pairs/nine traced parsed inputs retain full public error maps and new first-use order. Actual successful root precompile and expected old Test stderr remain exact; older direct transient strings receive no new native/artifact-custody credit. Rebuild Julia applications. Installed Lua78.6.5 is next; full23.4/native4.2/SESSION5/historical4.24/source/context/isolation/registration/SESSION7/formatter/declared5.4 remain open. Evidence: docs/checkpoints/array-transform-callable-julia-2026-11-12/REVIEW.md.')
assert len((ROOT / handoff).read_text().splitlines()) == 4999
for name, record in (
    ('CHANGES.md', '''## 2026-11-12 — TYPE-REFERENCE-BOOK.1.2.23.3.78.6.4 — Julia callable Array-transform result guards

- Four interpreter insertions/two deletions and one runner include let canonical registered-function transforms reach existing actual-kind guards; invocation/signatures/first producers/formats remain.
- Independent312/four routes/nine traces freeze28 supported targets/three separate initial-source compatibility/281 preserved/104 initial policies exact. Original/private31RED-current312 and direct1248+903+776=2927 assertions pass, with complete available error maps and actual old/precompile channel roles retained.
- First full historical reader0/empty stderr/24 controls/current519;1872 actual pairs/nine parsed trace inputs recover. Eighteen verified trace/input duplicates retire without proof loss. Older direct transient generated strings gain no new custody credit; full4.2/SESSION5/registration/full23.4 remain separate.
- Book examples/backend/Knowledge/task/live/resume align; installed Lua78.6.5 follows clean landing. Evidence: docs/checkpoints/array-transform-callable-julia-2026-11-12/REVIEW.md.

'''),
    ('DEVELOPMENT_NOTES.md', '''## 2026-11-12 — TYPE-REFERENCE-BOOK.1.2.23.3.78.6.4 — Julia callable transform guards preserve own producer policies

The registered-source denial in _runtime_is_ordinary_array_transform_result_chain bypasses existing actual-kind ownership. Admit canonical first transforms, preserving unregistered free-helper identity and existing fixed/minimum signature-before-argument checks. Source4/2 plus one normal runner include; no producer, source scope or generated format change. Independent312/four routes establish28 supported fixes/three separate initial continuations/281 preserved records and104 unchanged initial policies. Julia Boolean receiver take stays null/skip-with and free take stays[]/runs-with; both free and receiver sorted/reversed extras retain X, independently of Dart.

Full available class/text/to_json maps, source identities/stages/absence and source/count/slice/concat order remain. Original/private31 failing groups move to312/1248 assertions passing; direct2927/first historical reader24/current519 pass.1872 actual pairs/nine trace inputs retain new parsed-before-compile/restore and emitted-before-include order. Fresh Modules share runtime/process; old direct transient strings receive no new custody credit. Expected old Test error and successful root precompile stderr stay exact. Full native4.2/SESSION5/historical4.24/source/context/isolation/registration/SESSION7/declared5.4/formatter/full23.4 remain separate. The new Julia Knowledge card and packet REVIEW.md own these facts.

''')):
    path = ROOT / name; text = path.read_text(); boundary = re.search(r'^## ', text, re.M)
    assert boundary is not None
    path.write_text(text[:boundary.start()] + record + text[boundary.start():])
path = ROOT / 'LIVE_ACHIEVEMENT_STATUS.md'; text = path.read_text()
history = text[text.index('## History'):]
recent = text[text.index('## Recent Completions') + len('## Recent Completions'):text.index('## History')].strip().splitlines()
recent = ['- TYPE-REFERENCE-BOOK.1.2.23.3.78.6.4 —312/four routes/28 targets+three compatibility/281 preserved/104 initial policies; private31-current312/direct2927 assertions/first readonly24/current519/1872 pairs/nine traces; installed Lua next.'] + recent[:15]
path.write_text('# LIVE ACHIEVEMENT STATUS\n\n## Current Activity\n\nFull PNT continues. Bounded Perl/Rust/Dart/Julia callable Array-transform implementations are focused-checked; independent installed Lua78.6.5 is next. Complete source/context/portable admission remains full23.4.\n\n## Latest Completed Slice\n\nTYPE-REFERENCE-BOOK.1.2.23.3.78.6.4. Independent312/four routes,28 supported targets/three separate initial-source compatibility/281 preserved/104 initial policies exact. Original/private31RED-current312/direct2927 assertions/first readonly24/current519/1872 pairs/nine traces pass. Only classifier4/2 and one runner include; successful precompile/old Test channels remain explicit.\n\n## Next Action\n\nActivate independent installed Lua78.6.5 from clean Julia; read own public integration/function/transform/native/error/storage contracts and acquire own source-only shared45/initial/optional/excluded/signature/order/snapshot/terminal observations on each actual host before repair. No peer policy or declared5.4 inference. Open concat42 follows bounded78.6; native/source/context/registration/historical4.24/formatter/full23.4 stay open.\n\n## Recent Completions\n\n' + '\n'.join(recent) + '\n\n' + history)
(ROOT / 'MEMORY.md').write_text('''# MEMORY

- activation_commit: `3767c87c7167bdcb29b0092be35bc139520e3509` — clean Dart predecessor; derive current HEAD from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.4` — bounded Julia callable Array-transform guards with focused proof.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.4` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md.
- run_state: full PNT, no fixed batch count.
- next_action: Activate independent installed Lua78.6.5 from clean Julia; read own public integration/function/transform/native/error/storage contracts, acquire source-only questions/terminal contrasts and native/parsed/emitted inputs before use on each actual host. Open concat23.1.42 follows bounded78.6 before coverage exhaustion.
- in_flight_uncommitted: none.
- blockers: No director input required for bounded78.6. Full23.4/native4.2/SESSION5/registration4.1/historical4.24/formatter/declared5.4 stay open; SESSION7 owns known launcher/denied-liveness repair with no new lifecycle credit.
- evidence: docs/checkpoints/array-transform-callable-julia-2026-11-12/REVIEW.md:312/four routes/28 supported targets/three separate initial-source compatibility/281 preserved/104 initial policies exact; old31RED-current312/direct2927 assertions/first readonly0-empty stderr/24 controls/current519. Only classifier4/2 plus one runner include.1872 actual pairs/nine parsed trace inputs recover;18 exact duplicates retired after archive verification. Full error maps/own Boolean receiver-null/free-empty/sorted-reversed excess SXKVW remain. Successful root precompile and expected old Test stderr are retained; older direct transient strings gain no new native/artifact-custody credit.
- open_scope: Installed Lua78.6.5 then concat23.1.42; initial literal1.2.1.3.1/excluded inventory1.2.1.4.3, historical4.24/safe-launcher4.22/query4.17/routing18.2 remain owned after coverage/before admission. Perl/Rust/Dart bounded outcomes remain committed; never replay completed one-shot acquisitions.
- publication: Exact canonical4683555e is last recorded published checkpoint; final clean push follows agreed coverage and fresh canonical proof.
- verification_policy: Focused ordinary slices/mandatory hooks/canonical final push. Same-volume project data; other repositories/submodules read-only. Shared24GiB, one intensive own job with actual memory checks; director RAM90 overrides stale4.14. Latest cleanup2026-11-11T15:29:23.870616+00:00. Supplied three read-only policy hashes unchanged at startup.
''')
print('Synchronized completed Julia task, canonical-registration follow-up, book boundaries, live docs and clean post-landing pointer')
