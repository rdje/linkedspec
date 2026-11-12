"""Publish bounded operational monitoring with explicit measured and missing legs."""
import gzip
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT).as_posix()
LEAF = 'TYPE-REFERENCE-BOOK.1.2.23.4.30.1'


def report(tag):
    folder = BASE / 'launches' / tag
    assert (folder / 'exit.txt').read_text() == '0\n' and gzip.decompress((folder / 'stderr.log.gz').read_bytes()) == b''
    return json.loads(gzip.decompress((folder / 'stdout.log.gz').read_bytes()))


recovery, current, query = report('review'), report('current'), report('review-publication-query')
assert recovery['historical_metadata_recovery'] == current['current_monitor_inputs'] == 'PASS'
assert query['accepted_records'] == 207 and query['historical_intersections'] == 231 and query['live_intersections'] == 0
r = json.loads((BASE / 'measurement/result.json').read_bytes())
v = json.loads((BASE / 'validation-qualified/result.json').read_bytes())
claim = json.loads((ROOT / 'docs/claims' / (LEAF + '.json')).read_bytes())['claims'][0]
assert claim['rederive']['status'] == claim['falsify']['status'] == 'checked'
assert claim['durability']['status'] == 'gap' and claim['durability']['repair_owner'] == 'TYPE-REFERENCE-BOOK.1.2.23.4.2'
assert r['estimated_non_thin_pack_bytes'] == v['pack_bytes'] == 1_257_281_519
assert not r['trigger_reached'] and not r['preparation_due'] and len(v['corruption_controls']) == 12


def edit(name, old, new):
    path = ROOT / name; source = path.read_text()
    assert source.count(old) == 1, name + ': exact publication anchor'
    path.write_text(source.replace(old, new, 1))


review = f'''# Committed outgoing-pack monitoring — bounded operational proof

Owner: {LEAF}. Activation:102ec3446407543c5ef64f3222bd0fffb5eb3064.

The director1,500,000,000-byte early-push trigger overrides PNT/batch cadence.
Measure after every leaf and before large growth; prepare around1,400,000,000
bytes or earlier when the next slice/receipt needs more headroom. The100MB reserve
is advisory, not a bound on future output. Every actual push still requires exact
current canonical discovery23.4.1, full CI, normal hooks and a clean exact HEAD.
No Git/CI/hook, dependency, storage/path policy or runtime behavior changes here.

The checkpoint-only reusable command is:

```sh
bash tools/project_data_run.sh env PYTHONPATH= python3 -P {REL}/measure.py
```

It reads committed HEAD and cached origin/main, retains source/policy/wrapper/
selected non-secret pack configuration/ref/object metadata before pack use, and
writes a unique ignored same-volume diagnostic. Git runs one worker with64m
window memory and explicit no-sparse/non-thin output. A memory preflight, streamed
byte/stat/PACK/footer checks, empty-range control and unchanged ref/config checks
precede the JSON result. Uncommitted changes are excluded. Repeated future calls
measure their actual refs; historical recovery never replays the writer.

Actual HEAD102ec3446407543c5ef64f3222bd0fffb5eb3064 versus cached base
4683555ec51f04b8977812ce4e984c5cc6e6f42c has102 outgoing commits. The estimate is
1,257,281,519 bytes, with242,718,481 bytes below the trigger and142,718,481 below
the preparation warning. All45,549 logical objects occur in the45,549 packed
objects, with zero extras. The largest outgoing blob remains31,374,498 bytes;
the empty standalone pack is32 bytes. These are scopes of this exact local
artifact, not a negotiated wire/server size or future-size promise. Remote
freshness has not been checked; it must be checked before publication.

The first independent validator exits1: native index creation succeeds0, but
verify1 looks for independent.pack from independent.idx while the real pack is
outgoing-estimate.pack. Full original source/commands/stdout/stderr/exit remain.
Git's public verify-pack contract pairs an index with its corresponding pack:
https://git-scm.com/docs/git-verify-pack. The separate qualified validator reuses
that completed original index under outgoing-estimate.idx, checks current memory,
and passes actual verify0/full-file stream/stat/SHA/footer/object coverage and12
reason-sensitive receipt/fact corruptions. No new pack or repeated index creation
is used. The incomplete validation file read is repeated; the successful index is
reused. The failed original is never relabeled PASS.

The separate readonly historical reader0 verifies sealed metadata/source/channel/
full-mode archives, actual before-use input handoffs, the original failure and
qualified outcomes, required-object sets, source flags, historical Git range and
three own corruptions. It reads retained evidence and does not call the pack
producer, live-file validator or SDK. check_current.py separately verifies five
producer/policy/wrapper inputs plus current config/refs at activation/pre-staging;
that current check makes no future freshness claim.

The measured claim record is docs/claims/{LEAF}.json.
Re-derivation and actual falsification are checked. Full physical/native Git/
cache/compressor/toolchain/OS and ignored raw pack/index artifact custody remain
an explicit durability gap owned by23.4.2/SESSION5. Retaining logical metadata and
Git-addressed bodies does not close it. The earlier Dart operational claim keeps
its own two gaps and parent30 ownership; no earlier hash/revision/claim is refreshed.

Before shared edits, the narrow query retains207 accepted claim records,231
historical intersections and zero live bindings; four injected live-binding
controls reject. Actual publication producers/reports/document inputs/outputs are
retained in publication/ and recovered by review_publication.py. No diagnostic
pack/index is added to Git. The old one-off backlog publisher remains retired.

This measurement excludes the monitor's own uncommitted documentation/evidence.
After its clean commit, remeasure before independent Julia80.4. Continue feature
PNT while actual margin permits; canonical discovery/verification/publication
preempts cadence as the budget approaches. Parent30/publication30.2 and wider
source/context/native/full23.4/declared-host/formatter owners remain open.
'''
(BASE / 'REVIEW.md').write_text(review)
card = 'docs/knowledge/github-size-safe-publication.md'
edit(card, '  - "how does sparse Git pack walking add already remote objects"\n', '''  - "how does sparse Git pack walking add already remote objects"
  - "where is the reusable current outgoing pack estimate producer"
  - "why does verify pack look for a differently named missing pack"
''')
anchor = 'The November4 workflow below is dated historical evidence.\n'
extra = f'''The bounded reusable monitor30.1 is now retained at {REL}/measure.py.
Run it after every committed leaf and before large growth; it prints actual refs,
packed bytes, trigger margin and advisory1.4GB preparation state. At committed
HEAD102ec3446/cached base4683555e,102 commits estimate1,257,281,519 bytes, leaving
242,718,481 before1.5GB. Explicit no-sparse output contains exactly45,549 required
objects. The original validator1 is an index/pack stem error; its native index0
is reused under the matching stem and qualified verify0/12 controls pass. Git
pairs the index with its corresponding pack (https://git-scm.com/docs/git-verify-pack).
Historical reverify: bash tools/project_data_run.sh env PYTHONPATH= python3 -P
{REL}/review.py. Current identity is separate; full native/physical/raw-artifact
durability remains a disclosed23.4.2/SESSION5 gap. Remote freshness and wire size
remain unassessed. Current normal source/case/proof is in {REL}/REVIEW.md.

'''
edit(card, anchor, extra + anchor)
chapter = 'docs/linkedspec-book/src/development/local-ci-and-regression.md'
anchor = 'This means a normal batch pays for focused proof on each commit and full proof once before push. Local Git hooks remain bypassable, and hosted CI remains disabled, so this is strong normal-workflow enforcement rather than a claim of literal impossibility.\n'
section = f'''
### Outgoing publication byte budget

The director1,500,000,000-byte early-push trigger takes precedence over the batch
or PNT cadence. Measure after each committed leaf and before large growth:

```sh
bash tools/project_data_run.sh env PYTHONPATH= python3 -P {REL}/measure.py
```

The command prints the actual committed HEAD/cached origin refs, non-thin pack
estimate, byte margin and preparation state. It keeps raw diagnostics on the
repository volume outside Git, with one pack worker and64m window memory. All
uncommitted changes are excluded. Start canonical discovery/publication preparation
around1,400,000,000 bytes or earlier if the next slice or CI receipts need more
margin; this100MB reserve is advisory. Publish around1.5GB even before the batch
ends. GitHub's [single-push limit](https://docs.github.com/en/get-started/using-git/troubleshooting-the-2-gb-push-limit)
is2GiB. Every push still requires current canonical test discovery, full CI and a
clean exact HEAD through normal hooks. Check fresh remote identity before transfer.

The estimate concerns a local serialized artifact; remote negotiation and wire
bytes can differ. Source/config/ref/object metadata and independent validation are
retained, while full native/physical/cache/toolchain custody remains separately
owned. The canonical record at `docs/knowledge/github-size-safe-publication.md`
links the scoped proof and preserved index-stem failure. The historical one-off
backlog publisher remains retired. Parent30/publication30.2 owns actual publication.
'''
edit(chapter, anchor, anchor + section)
handoff = 'docs/linkedspec-book/src/appendix/backend-handoff.md'
edit(handoff, 'Publication-budget preparation23.4.30 precedes independent Julia/Lua.', 'Bounded monitor23.4.30.1 now records HEAD102ec3446/cached origin4683555e at1,257,281,519 bytes,242,718,481 below trigger; actual native index/qualified verify and12 corruption controls pass, with original filename failure retained. Full native/raw/toolchain durability remains4.2/SESSION5. Remeasure after the monitor commit, then independent Julia/Lua while margin permits; canonical publication preempts cadence near the budget.')
frontier = f'November12 current fluent frontier: Perl80.1/Rust80.2/Dart80.3 existing concat result guards remain focused-complete. Publication monitor30.1 now captures committed HEAD102ec3446 versus cached origin4683555e:102 commits/1,257,281,519 packed bytes/45,549 logical and packed objects/242,718,481-byte1.5GB trigger margin. Source before pack use, independent native index/qualified verify,12 falsification controls and historical reader/three controls pass; original index-stem validator1 stays retained. Full native/physical/toolchain durability remains4.2/SESSION5. Remeasure after the monitor commit, then independent Julia80.4/Lua80.5 while margin permits. Prepare near1.4GB or earlier for next-slice/receipt growth; canonical discovery4.1/full CI/clean publication30.2 supersede PNT/batch cadence around1.5GB. Full source/context/admission23.4 and existing historical/raw-error/launcher/declared-host/formatter owners stay separate. Evidence: {REL}/REVIEW.md.'
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = ROOT / name; source = path.read_text()
    source, count = re.subn(r'^November12 current fluent frontier:.*$', lambda _: frontier, source, count=1, flags=re.M)
    assert count == 1; path.write_text(source)
task = ROOT / 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'; source = task.read_text(); start = source.index('- ID: `' + LEAF + '`'); end = source.index('\n- ID:', start + 1)
part = source[start:end].replace('Status: `in_progress`', 'Status: `completed` / bounded operational proof; native durability gap explicit', 1)
part += f'''\n  Completion: Reusable checkpoint-only producer0 records1,257,281,519 bytes/102 commits/all45,549 logical and packed objects/zero extras/242,718,481 trigger margin. Qualified native verify0 and12 falsification controls; first readonly historical recovery0/three controls/current five producer inputs. Original validator1/native index0/verify1/source/channels remain, with successful index reused under matching stem and no new pack. Full physical/native/raw/toolchain durability gap remains4.2/SESSION5; cached remote only, no wire/future guarantee.
  Publication:207 accepted records/231 historical/zero live bindings and four injected live-binding REDs precede shared edits; no old claim/hash/revision refresh. Book/Knowledge/frontiers/live/pointer and actual publication inputs/outputs retained. Full CI not run for this measurement-only leaf; no Git/CI/hook/runtime/storage-policy change or push. Remeasure after clean commit; independent Julia80.4 while margin permits. Canonical discovery4.1/publication30.2 remain before the size-driven push.
'''
task.write_text(source[:start] + part + source[end:])
edit('docs/tasks/TYPE-REFERENCE-BOOK.md', '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.4.30.1` | `in_progress` | Reusable read-only outgoing-pack telemetry from clean Dart102ec3446; validate byte budget before more feature growth or canonical publication. |', '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.3.80.4` | `pending` | After clean monitor30.1, remeasure current outgoing bytes and acquire independent Julia concat policies; canonical publication takes priority near1.4-1.5GB. |')
for name, title, text in (
    ('CHANGES.md', LEAF + ': monitor outgoing push size', f'Reusable one-worker measurement captures source/config/refs before pack use.\nHEAD102ec3446/cached origin4683555e:1,257,281,519 bytes/102 commits/45,549 objects;\n242,718,481 below1.5GB. Qualified native verify/12 RED controls and historical\nrecovery/three controls pass. Original index-stem failure remains; successful\nindex reused. Trigger overrides PNT/batch cadence, with advisory1.4GB preparation\nand full canonical CI before every push. Native/raw/toolchain durability remains\nexplicitly open. Book/Knowledge/live/docs synced. Evidence: {REL}/REVIEW.md.'),
    ('DEVELOPMENT_NOTES.md', 'Bounded outgoing-pack monitoring (' + LEAF + ')', f'Measure committed refs rather than commit count/store size; source/policy/config\nprecede one-worker/no-sparse packing. Actual1,257,281,519-byte artifact covers\n45,549 objects; independent index/qualified verify and12 metadata faults pass.\nOriginal index0/verify1 is a basename mismatch; reuse matching-stem index without\nrepacking. Historical reader0/three controls and five current inputs pass. Full\nphysical/native/toolchain/raw custody stays4.2/SESSION5. Advisory1.4GB preparation\nprotects director1.5GB early publication; canonical discovery/full CI remain\nmandatory. Evidence: {REL}/REVIEW.md.'),
):
    path = ROOT / name; source = path.read_text(); anchor = re.search(r'^## ', source, re.M); assert anchor
    path.write_text(source[:anchor.start()] + '## 2026-11-12 — ' + title + '\n\n' + text + '\n\n' + source[anchor.start():])
live = ROOT / 'LIVE_ACHIEVEMENT_STATUS.md'; source = live.read_text()
history = source[source.index('## History'):]
recent = source.split('## Recent Completions\n\n', 1)[1].split('## History', 1)[0]
rows = [line for line in recent.splitlines() if line.startswith('- ')]
assert len(rows) == 16
new_row = f'- {LEAF} —HEAD102ec3446/cached base4683555e:1,257,281,519 bytes/102 commits/45,549 objects; qualified verify/12 REDs/historical recovery/three controls; native durability gap explicit, remeasure then Julia.'
live.write_text(f'''# LIVE ACHIEVEMENT STATUS

## Current Activity

Full PNT continues. Monitor30.1 is focused-complete; Perl80.1/Rust80.2/Dart80.3 concat proof remains. Remeasure current committed bytes before Julia80.4; canonical publication preempts cadence near1.4-1.5GB. Full source/context/admission remains23.4.

## Latest Completed Slice

{LEAF}. HEAD102ec3446 versus cached origin4683555e:1,257,281,519 bytes/102 commits/45,549 required and packed objects,242,718,481 below1.5GB. Qualified native verify/12 controls/historical recovery/three controls/five current inputs pass. Original index-stem failure retained. Native/raw/toolchain durability remains4.2/SESSION5.

## Next Action

After clean monitor commit, remeasure before independent Julia80.4. Prepare canonical discovery/full CI/publication near1.4GB or earlier for next-slice/receipt growth; push around1,500,000,000 bytes even mid-PNT/batch with clean exact HEAD and normal hooks. Cached estimates are not fresh remote or wire-size promises.

## Recent Completions

''' + '\n'.join([new_row] + rows[:15]) + '\n\n' + history)
assert len([line for line in live.read_text().split('## Recent Completions\n\n', 1)[1].split('## History', 1)[0].splitlines() if line.startswith('- ')]) == 16
memory = f'''# MEMORY

- activation_commit: `102ec3446407543c5ef64f3222bd0fffb5eb3064` — clean monitor30.1 activation; derive current HEAD from Git.
- latest_completed_leaf: `{LEAF}` — bounded reusable outgoing-pack monitor and independently qualified telemetry.
- active_work_unit: `{LEAF}` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.
- run_state: full PNT, no fixed batch count.
- next_action: After clean monitor commit, remeasure current committed HEAD with {REL}/measure.py before independent Julia80.4. Continue PNT while actual margin permits; canonical discovery4.1/full CI/publication30.2 take priority approaching1.4-1.5GB or before large growth. Never replay historical capture/failed validators.
- in_flight_uncommitted: none; monitor source/policy/actual evidence/qualified failure/docs committed; no required background job.
- blockers: No director decision needed. Full23.4/native4.2/SESSION5/source/context/discovery4.1/historical4.24/raw-error4.28/launcher4.22/SESSION7/literal/excluded/declared5.4/formatter remain owned.
- evidence: {REL}/REVIEW.md; current historical snapshot HEAD102ec3446/base cached origin4683555e,102 ahead/1,257,281,519 bytes/45,549 logical and packed objects/zero extras/242,718,481-byte trigger margin. Source before pack use; stream/stat/footer/empty-range/ref/config0. Original index0/verify1 retained; qualified matching-stem index reuse/verify0/12 RED controls/historical recovery0-three controls/current five inputs pass. No SDK or new pack replay.
- qualifications: Local committed-range estimate excludes monitor's own then-uncommitted changes, not a negotiated wire/server/future-size guarantee. Native/physical Git/cache/compressor/toolchain/OS/raw-pack/index durability remains explicit4.2/SESSION5 gap; earlier Dart operational record keeps two gaps/parent30 ownership. Old claim/hash/revision data unchanged. Historical review.py uses retained evidence; check_current.py is activation/pre-staging only.
- publication: Director1,500,000,000-byte early trigger supersedes PNT/batch cadence. Measure after each committed leaf/before large growth; advisory1,400,000,000 preparation threshold reserves100MB but does not bound future slice/receipt growth. Full canonical CI/current discovery/clean exact HEAD/normal hooks/fresh remote identity precede every push. No push yet. Raw diagnostics stay ignored on this volume; old one-off uploader is retired. Repeat actual measurement after this commit before selecting further feature work.
- continuity: Dart102ec3446 all10/post-pointer/brief0/clean verified before monitor. Dart508/four routes/20 supported/four compatibility/484 preserved; old24-current508/direct1155/readonly9/current521 remains focused proof. Julia80.4 then Lua80.5 acquire own policies; no peer verdict import.
- verification_policy: Focused measurement/ordinary slices plus mandatory hooks; canonical publication/mechanical infrastructure boundaries. Only this repository writable; submodules black boxes. Same-volume data/shared24GiB/serial intensive jobs/RAM90 policy. Latest cleanup2026-11-11T15:29:23.870616+00:00; external policy hashes unchanged at startup.
'''
(ROOT / 'MEMORY.md').write_text(memory)
(ROOT / 'git_message_brief.txt').write_text(f'''{LEAF} - monitor outgoing publication size

Retain ref-bound one-worker/non-thin telemetry and independent validation.
HEAD102ec3446 estimate1,257,281,519 bytes;1.5GB early trigger/1.4GB advisory prep.
Qualified native verify/12 RED controls and historical recovery pass; preserve
the original index-stem failure and reuse its completed index without repacking.
Sync book/Knowledge/live/task/pointer; native/raw/toolchain durability stays open.
Focused measurement only; canonical discovery/full CI still precede every push.
''')
print(json.dumps(dict(publication='PASS', measured_bytes=r['estimated_non_thin_pack_bytes'], live_recent_rows=16,
    actual_falsification_controls=12, historical_recovery_controls=3, current_producer_inputs=5)))
