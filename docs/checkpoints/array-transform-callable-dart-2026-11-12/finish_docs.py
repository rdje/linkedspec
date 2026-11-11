"""Synchronize the completed Dart leaf and public examples before landing."""
import hashlib
import json
from pathlib import Path
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
    path = ROOT / name
    text = path.read_text()
    assert text.count(old) == 1, (name, old)
    path.write_text(text.replace(old, new))

frontier = ('Independent Dart78.6.3 is implemented with focused312/four routes,28 supported targets/'
    'three separate initial-source compatibility continuations/281 preserved and104 initial policies exact. '
    'Same-path31RED-current312/direct647/qualified readonly24/current510 pass; original reader1 and exact outer '
    'launcher notice remain retained. Perl/Rust callable-transform slices are committed. Independent Julia78.6.4 '
    'is next, then installed Lua; open concat42 follows bounded78.6. Full23.4/native/source/context/registration/'
    'SESSION7/formatter/declared5.4 stay separate.')
path = ROOT / 'ROADMAP_V2.md'
text = path.read_text(); start = text.index('Current fluent frontier: '); end = text.index('\n\n', start)
path.write_text(text[:start] + 'Current fluent frontier: ' + frontier + text[end:])
replace('ROADMAP.md', '# ROADMAP\n', '# ROADMAP\n\nNovember12 current fluent frontier: ' + frontier + '\n')
replace('docs/tasks/TYPE-REFERENCE-BOOK.md', 'independent Dart78.6.3 is next;',
    'independent Dart78.6.3 is focused-checked312/28 targets/three separate compatibility/281 preserved/private31-current312/direct647/qualified readonly24/current510; independent Julia78.6.4 is next;')
replace('docs/tasks/TYPE-REFERENCE-BOOK.md',
    '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.2` | `completed` | Independent312/20 targets/three compatibility/289 preserved; private23-current312/direct701/readonly23/current825; originals retained. |',
    '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.3` | `completed` | Independent312/28 targets/three compatibility/281 preserved; private31-current312/direct647/qualified readonly24/current510; original reader1/notice retained. |')
replace('docs/tasks/TYPE-REFERENCE-BOOK.md',
    '| 2 | `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.3` | `in_progress` | Acquire independent Dart source/optional/excluded/signature/error/order/snapshot policies; no Rust verdict or initial-policy import. |',
    '| 2 | `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.4` | `pending` | Acquire independent Julia source/optional/excluded/signature/error/order/snapshot policies from clean Dart; no peer outcome import. |')
task = ROOT / 'docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md'
text = task.read_text(); start = text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.3`'); end = text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.4`', start)
node = text[start:end].replace('Status: `in_progress`', 'Status: `completed`', 1)
old = 'Focused checks: Fresh own public four-route acquisition and exact error JSON, new/direct-dependent normals, same-path old/current if repaired, historical recovery/corruptions/current identities and docs/normal hooks. Actual results follow before completion.'
assert old in node
node = node.replace(old, 'Focused checks: Independent312/four routes/full error JSON; original/private31RED-current312; direct647; rehearsal/apply/scoped format0; qualified readonly0/24 controls/current510; mdBook/memory/history/normal hooks.')
node += '''  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Original312/full wires/nine public traces; normal31RED/281PASS and parsed inputs match cold acquisition exactly.
  - [x] **ROOT CAUSE (WHY + WHERE)** — _isOrdinaryArrayTransformResultChain near6656 excludes registered sources from result ownership; existing signature-before-arguments/actual first producer remain.
  - [x] **FIX** — Only classifier4 insertions/four deletions; canonical first transforms reuse guards while unregistered free-helper identity survives.
  - [x] **ADDRESSED (verified)** — Four-route312/private31RED-current312; qualified historical reader0/empty stderr/24 distinguishing controls/current510.
  - [x] **NO REGRESSION** —281 complete records/104 initial policies exact; direct647/624 parsed-module pairs/1248 normal inputs/nine trace inputs. Boolean receiver-null/free-empty/excluded shapes/errors unchanged.
  - [x] **LOCKSTEP** — Book examples/backend/Knowledge/live/resume/task/index/scope/history align; focused doc gates and normal landing precede independent Julia78.6.4. Full23.4 remains separate.
  Outcome: docs/checkpoints/array-transform-callable-dart-2026-11-12/REVIEW.md. Only28 targets count as supported repair; three initial-source continuations are compatibility. Original sealed reader1 is retained; qualified reader fixes only raw-byte comparator control and passes24. Current510 is pre-staging;642 exact plain duplicates retired after archive verification. Known outer83-byte setpgid93882 notice retained/SESSION7-owned, actual Dart native/fresh stderr empty, final PGID uncaptured. Complete native4.2/SESSION5/historical4.24/source/context/isolation/registration4.1/safe-launcher4.22/declared5.4/formatter/full23.4 stay open. No imported Dart policy for Julia/Lua.

'''
task.write_text(text[:start] + node + text[end:])
replace('docs/tasks/TYPE-REFERENCE-BOOK.overview.md',
    '  Addition78.6.2:',
    '  Addition78.6.3: Check actual canonical discovery for dart/test/array_transform_callable_result_guard_composition_test.dart, tests/fixtures/array_transform_callable_result_guard_dart_profiles.json, its docs/checkpoints/array-transform-callable-dart-2026-11-12/cases.json input and probe/observation/trace tools before23.4/push. Focused312/private/direct647 are separate from canonical discovery; preserve full error wires/own policies and new parsed-before-compile custody, without upgrading historical4.24.\n  Addition78.6.2:')
replace('docs/knowledge/array-transform-callable-result-selection.md',
    'status: qualified selection41 frozen; bounded Perl/Rust focused-checked; independent Dart next',
    'status: qualified selection41 frozen; bounded Perl/Rust/Dart focused-checked; independent Julia next')
replace('docs/knowledge/array-transform-callable-result-selection.md',
    'Dart/Julia/installed Lua acquire their own policies next.',
    'Independent Dart78.6.3 is now focused-checked: [[dart-callable-array-transform-result-guards]] records28 targets/three separate initial-source compatibility/281 preserved/104 initial policies exact, private31-current312/direct647/qualified readonly24/current510, with original reader1 and launcher notice retained. Julia/installed Lua acquire their own policies next.')
book = 'docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md'
replace(book, 'same result-kind guards on Perl and Rust.', 'same result-kind guards on Perl, Rust and Dart.')
replace(book, 'applications with the updated runtime. The bounded Perl implementation',
    'applications with the updated runtime, and rebuild Dart applications. The bounded Perl implementation')
replace(book, 'controls, same-path old/current proof, direct regressions and historical recovery. Each other',
    'controls, same-path old/current proof, direct regressions and historical recovery. Dart independently passes the same four public route classes, its own old/current controls and focused regressions. Each remaining')
replace(book, 'Excluded argument shapes also keep their current behavior.', '''Dart preserves its independently observed Number/null/Hash empty-Array policies
for the seven non-concat transforms and retains a scalar or Hash as one element
for `concat_arrays`. Its three initial-source continuations are recorded separately
from supported Array-input fixes. Boolean source behavior differs between receiver
and free helper: this Dart compatibility program returns `[null,""]`, because
the receiver producer returns null and the block stays skipped:

```text
fn supply(seed) {return(seed)}

Value:: I {
 order="";
 out=supply(false).take(1).with(){order=cat(order,"W");return(value.count())};
 return([out,order]);
}
```

Replacing the prefix with `take(supply(false),1)` returns `[0,"W"]`: the free
helper produces an empty Array and the block runs. Both policies are unchanged
by result guarding. Portable programs supply Arrays; these compatibility examples
do not grant a new input domain or imply a policy for Julia or Lua.

Excluded argument shapes also keep their current behavior.''')
replace(book, 'transform shapes gain no new guarded-result authority. Wider open-arity',
    'transform shapes gain no new guarded-result authority. Dart also retains its own missing/excess shapes: free `sorted`/`reversed` skip an ignored extra operand, while their receiver forms evaluate it. Function fixed/rest arity checks and complete available error fields remain intact. Wider open-arity')
handoff = 'docs/linkedspec-book/src/appendix/backend-handoff.md'
replace(handoff, 'Independent Dart78.6.3 is next; full23.4 and SESSION7/native/source/context/registration owners remain open.',
    'Independent Dart78.6.3 now has a classifier4/4 repair:312/four routes/28 supported targets/three separate initial-source compatibility/281 preserved and104 initial policies exact, including Boolean receiver-null/free-empty. Same-path31RED-current312/direct647/qualified readonly0 with24 controls/current510 pass;624 parsed-module pairs/1248 normal inputs/nine trace inputs remain. Original reader1 from JSON-comparing bytes is preserved; qualified reader changes only that raw-channel control. Exact outer83-byte launcher notice is retained under SESSION7; actual Dart native/fresh stderr empty, final PGID uncaptured. Complete available error maps and new parsed-before-compile/restore order survive; rebuild Dart applications. Independent Julia78.6.4 is next; full23.4/SESSION7/native/source/context/registration/historical4.24 stay open. Evidence: docs/checkpoints/array-transform-callable-dart-2026-11-12/REVIEW.md.')
assert len((ROOT / handoff).read_text().splitlines()) == 4999

for name, record in (
    ('CHANGES.md', '''## 2026-11-12 — TYPE-REFERENCE-BOOK.1.2.23.3.78.6.3 — Dart callable Array-transform result guards

- Four interpreter insertions/four deletions admit canonical first transforms from registered-function results to existing guards; invocation/producers/signatures/formats remain unchanged.
- Independent312/four routes freeze28 targets, three separate initial-source compatibility continuations and281 preserved records. All104 initial policies/full error maps remain exact. Original/private31RED-current312 and direct312+141+194=647 pass.
- Qualified historical reader0/empty stderr/24 controls/current510;624 parsed-module pairs/1248 normal inputs/nine trace inputs recover. Original reader1 (JSON comparator received bytes) and its separate one-control correction remain exact.642 archive-verified plain duplicates retired; no proof removed.
- Book examples/backend/Knowledge/task/live state align. Exact outer launcher83-byte notice remains SESSION7-owned; actual Dart native/fresh stderr empty, PGID uncaptured. Full23.4/native/historical4.24/registration remain separate; Julia next. Evidence: docs/checkpoints/array-transform-callable-dart-2026-11-12/REVIEW.md.

'''),
    ('DEVELOPMENT_NOTES.md', '''## 2026-11-12 — TYPE-REFERENCE-BOOK.1.2.23.3.78.6.3 — Preserve Dart producer policy independently of later guards

The registered-function exclusion in _isOrdinaryArrayTransformResultChain bypasses actual-kind result ownership. Canonical first-transform prefixes now reach existing guards while unregistered free-helper identity and signature-before-arguments invocation stay unchanged (4/4 source delta). Independent312 observations support28 repairs plus three separate initial-source continuation movements;281 complete records and104 initial policies remain exact. Dart Boolean receiver take yields null/skip-with, while free take yields[]/runs-with; peer input policies are not an oracle.

Full available class/error/error_json/source/stage fields survive across native/restored/plan/fresh routes. New parsed bytes precede compile/restore, and emitted bytes precede fresh use;624 pairs/1248 normal/nine traced inputs remain archived. The first sealed reader1 fails only because a raw-byte negative control calls the JSON comparator; a separate qualified reader changes that control to byte equality and passes24. Original instruments/channels remain. Current510 is activation/pre-staging only. Known after-comparator outer launcher83-byte warning is retained under SESSION7, without lifecycle/PGID credit; all Dart native/fresh stderr is empty. Direct647/private31-current312 pass. Full native4.2/SESSION5/historical4.24/registration/full23.4 remain separately owned. See the Dart packet REVIEW.md and new Knowledge card.

''')):
    path = ROOT / name; text = path.read_text(); at = text.index('## ')
    path.write_text(text[:at] + record + text[at:])

path = ROOT / 'LIVE_ACHIEVEMENT_STATUS.md'; text = path.read_text()
history = text[text.index('## History'):]
recent = text[text.index('## Recent Completions') + len('## Recent Completions'):text.index('## History')].strip().splitlines()
recent = ['- TYPE-REFERENCE-BOOK.1.2.23.3.78.6.3 —312/four routes/28 targets+three compatibility/281 preserved/104 initial policies; private31-current312/direct647/qualified readonly24/current510; original reader1/launcher notice retained, Julia next.'] + recent[:15]
path.write_text('# LIVE ACHIEVEMENT STATUS\n\n## Current Activity\n\nFull PNT continues. Bounded Perl/Rust/Dart callable Array-transform implementations are focused-checked; independent Julia78.6.4 is next. Complete source/context/portable admission remains full23.4.\n\n## Latest Completed Slice\n\nTYPE-REFERENCE-BOOK.1.2.23.3.78.6.3. Independent312/four routes,28 supported targets/three separate initial-source compatibility/281 preserved and104 initial policies exact. Original/private31RED-current312/direct647/qualified readonly24/current510 pass; source4/4 only. Original reader1 and exact outer launcher notice stay retained.\n\n## Next Action\n\nActivate independent Julia78.6.4 from clean Dart, reading its public integration and own transform/pipeline/function contracts. Acquire source-only shared45 plus own initial/optional/excluded/signature/error/order/snapshot/terminal observations before repair. No peer policy/verdict. Installed Lua and open concat42 follow; full23.4/native/registration/historical4.24/formatter/declared5.4 stay open.\n\n## Recent Completions\n\n' + '\n'.join(recent) + '\n\n' + history)
(ROOT / 'MEMORY.md').write_text('''# MEMORY

- activation_commit: `5ac1fac5eb7126cd8f952858f8df194914884830` — clean Rust predecessor; derive current HEAD from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.3` — bounded Dart callable Array-transform guards with focused proof.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.3` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md.
- run_state: full PNT, no fixed batch count.
- next_action: Activate independent Julia78.6.4 from clean Dart; read own public integration/function/transform contracts, acquire own source-only questions/terminal contrasts/full errors and first-use inputs before production. Installed Lua follows, then open concat23.1.42 before coverage exhaustion.
- in_flight_uncommitted: none.
- blockers: No director input required for bounded78.6. Full23.4/native4.2/SESSION5/registration4.1/historical4.24/formatter/declared5.4 stay open; SESSION7 owns exact outer launcher recurrence, final PGID uncaptured.
- evidence: docs/checkpoints/array-transform-callable-dart-2026-11-12/REVIEW.md:312/four routes/28 supported targets/three separate initial-source compatibility/281 preserved/104 initial policies exact; old31RED-current312/direct647/qualified readonly0-empty stderr/24 controls/current510. Only interpreter classifier4/4 changes.624 parsed-module pairs/1248 normal/nine trace inputs recover;642 exact duplicates retired after archive verification. Original reader1 from JSON-comparing bytes and exact outer83-byte notice remain retained; all actual Dart native/fresh stderr empty. Qualified reader changes only raw-byte control.
- open_scope: Independent Julia78.6.4 then installed Lua78.6.5, concat23.1.42; initial literal1.2.1.3.1/excluded inventory1.2.1.4.3, historical4.24/safe-launcher4.22/query4.17/routing18.2 remain owned after coverage/before admission. Perl/Rust bounded outcomes remain committed.
- publication: Exact canonical4683555e is last recorded published checkpoint; final clean push follows agreed coverage and fresh canonical proof.
- verification_policy: Focused ordinary slices/mandatory hooks/canonical final push. Same-volume project data; other repositories/submodules read-only. Shared24GiB, one intensive own job with actual memory checks; director RAM90 overrides stale4.14. Latest cleanup2026-11-11T15:29:23.870616+00:00.
''')
print('Synchronized completed Dart task, canonical-registration follow-up, book examples, bounded live docs and clean post-landing pointer')
