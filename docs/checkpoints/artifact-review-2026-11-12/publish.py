"""Publish the actual dated cleanup and preserve earlier observations and claims."""
import gzip
import json
from pathlib import Path
import re

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.31'


def report(tag):
    folder = BASE / 'launches' / tag
    assert (folder / 'exit.txt').read_text() == '0\n'
    assert gzip.decompress((folder / 'stderr.log.gz').read_bytes()) == b''
    return json.loads(gzip.decompress((folder / 'stdout.log.gz').read_bytes()))


proof, links, query = [report(tag) for tag in ('readonly', 'task-links', 'review-publication-query')]
retirement = json.loads((BASE / 'retirement.json').read_bytes())
observation = json.loads(gzip.decompress((BASE / 'observation.json.gz').read_bytes()))
monitor = json.loads((BASE / 'push-monitor-current/result.json').read_bytes())
assert (monitor['head'], monitor['cached_origin_main'], monitor['ahead'], monitor['estimated_non_thin_pack_bytes'], monitor['packed_objects'], monitor['remaining_to_trigger_bytes']) == ('a3faaf97292550ba1e3001604e1e379d478bcdd4', '4683555ec51f04b8977812ce4e984c5cc6e6f42c', 104, 1287859376, 46075, 212140624)
assert proof['result'] == retirement['result'] == 'PASS' and links['task_links'] == 'PASS'
assert proof['archived_files'] == retirement['removed_plain_files'] == 3
assert proof['archived_content_bytes'] == retirement['archived_content_bytes']
assert query['live_intersections'] == 0 and len(query['rejected_live_binding_controls']) == 6
rows, content, controls = proof['scoped_rows'], proof['archived_content_bytes'], len(proof['rejected_controls'])
assert (rows, content, controls, links['public_queries']) == (1316, 133480, 16, 3)


def edit(name, old, new):
    path = Path(name)
    source = path.read_text()
    assert source.count(old) == 1, 'exact publication anchor:' + name
    path.write_text(source.replace(old, new, 1))


summary = f'{rows} matching metadata rows/eight scopes retained; three exact completed own combined logs/{content} content bytes/full modes independently recovered before plain-copy retirement. Postdelete readonly0/empty stderr/{controls} corruption controls and three exact public task queries pass. All other proof/caches/native products/repositories remain retained; no physical reclamation claim.'
Path('docs/ARTIFACT_CLEANUP.md').write_text(f'# Latest artifact cleanup\n\n- Date: {retirement["at_utc"]}\n- Summary: {OWNER}: {summary} Evidence: {BASE}/; complete native/OS custody remains23.4.2/SESSION5.\n')
(BASE / 'REVIEW.md').write_text(f'''# November12 safe artifact cleanup

Owner: {OWNER}. Clean activation:a3faaf97292550ba1e3001604e1e379d478bcdd4.
Census:{observation['at_utc']}; exact duplicate retirement:{retirement['at_utc']}.

{summary}

The primary non-following scanner and independent scandir/lstat agree on every
dated path/suffix/byte row in eight named root/Rust/log scopes. Configured Cargo
target and Dart/Julia conventions are covered; this is not a whole-project file
population or disposal authority. Census candidates remain retained. Caches,
native products, managed Lua runs, other repositories and submodules are not
traversed for disposal.

Accepted November11 census/retire/reader templates and driver context precede
fresh composition with retained bytes/modes. The generic launcher comes from
the accepted Julia checkpoint's run_stage.py, with its actual modified body
retained before delegation; that source already exists at activation Git.
New source/channel handling and parent checks are
authored before first use. Launchers retain actual helpers before import. Shared
wrapper identities recover at accepted activation Git bytes, not future live
source. No previous writer or used instrument is replayed or rewritten.

Only Dart80.3/monitor30.1/Julia80.4 completed own combined normal-commit logs retire.
All{content} original content bytes/full modes/per-file identities and Git
commit/parent/subject markers survive in archive-manifest.json and combined-logs/.
Original stdout/stderr separation is unavailable. The complete tracked-file
reference query explicitly disables submodule recursion and uses one worker;
no reference to those exact names is found. See git-grep-contract.txt for the
public contract. This is no global process-liveness or arbitrary cache purge.

Compressed copy/readback precedes actual independent predelete0/empty stderr.
Its all10/post-pointer/commit checks and16 metadata/source/log/channel/parent
corruptions pass. The writer rechecks exact original identity/hash immediately
before unlinking only that duplicate. Three paths are absent. Separate default
postdelete readonly0/empty stderr verifies archives and residue. No physical
allocated/free-space or original native/kernel/OS/transitive input epoch is
measured; the remaining custody leg is owned by4.2/SESSION5.

Parent4's manual Children field ended at29 although indexed owner30 existed.
Full before/after images add30/31 exactly once, preserving every other byte.
Two lost/duplicate-link controls reject and three public parent/30/31 queries
return exact nodes. This is a current data repair, not whole-hierarchy prevention.

Before book/frontier publication,{query['claim_records']} accepted records and
{query['historical_intersections']} historical intersections have zero live
bindings; six injected live-binding controls reject. This follows the separately
captured owned task activation/child-link fix and is not called pre-query for
that earlier fix. Old claim/hash/revision fields remain unchanged. publication/
retains actual document producer/report/document inputs/outputs; its independent
recovery is review_publication.py. The live view keeps16 rows and its exact
History pointer; the rotated row remains in the input image and separate file.

Auxiliary operational telemetry at committed a3faaf972/cached origin4683555e is
1,287,859,376 bytes/104 ahead/46,075 logical/header objects/212,140,624-byte1.5GB
margin, excluding this maintenance. Before-use producer and actual metadata/
channels survive in push-monitor-current/; raw pack remains ignored/protected.
Current independent-size/native durability gaps remain30/4.2. No remote refresh,
wire/server or future-size guarantee. Prepare near1.4GB and publish around
1,500,000,000 bytes regardless cadence, with canonical discovery/full CI/normal
hooks/clean exact HEAD first. Remeasure after this commit, then independent
installed Lua80.5 while margin permits. No SDK/full CI/push here.

Default recovery is historical readonly. Do not replay completed capture,
retirement or publication writers:

```sh
bash tools/project_data_run.sh env PYTHONPATH= python3 -P {BASE}/review.py
```
''')
Path('docs/knowledge/daily-artifact-log-archival-2026-11-12.md').write_text(f'''---
id: daily-artifact-log-archival-2026-11-12
title: November12 cleanup retains three completed commit logs before retiring plain duplicates
answers:
  - "what did the November12 daily artifact cleanup remove"
  - "where are the Dart concat monitor and Julia concat commit logs retained"
  - "does the November12 census authorize deleting other artifacts or caches"
  - "why was publication owner30 missing from its parent task children"
  - "does a stable task lookup guarantee the manual parent Children list is complete"
date: 2026-11-12
status: dated focused maintenance verified; native custody and full admission separate
tags: [artifacts, cleanup, logs, evidence, tasks, custody]
evidence: "{OWNER};{BASE}/REVIEW.md;{rows} named-scope rows retained, three exact completed combined logs/{content} content bytes/modes independently used before plain retirement; readonly{controls}/three public task queries."
reverify: "bash tools/project_data_run.sh env PYTHONPATH= python3 -P {BASE}/review.py"
---

The dated primary/independent walks agree on{rows} matching rows in eight named
root/Rust/log scopes; all census candidates stay retained. Configured Cargo target
and Dart/Julia conventions are covered. Metadata gives no disposal authority.

Only three completed own normal logs retire after compressed readback and actual
independent predelete use: Dart102ec3446, monitor952f8a022 and Juliaa3faaf972.
All{content} original combined content bytes/full modes and actual Git completion
identities survive in combined-logs/ and archive-manifest.json. Original channel
separation is unavailable. Tracked-file reference search disables submodule
recursion and uses one worker; no reference to these exact names is found.
Postdelete readonly0/empty stderr verifies three absent paths and{controls} faults.

The manual parent4 Children list ended at29 while stable owner30 lookup worked.
The exact data repair adds30/31 once, preserving other bytes. Two corruptions and
three public queries retain that correction. Indexed lookup success alone did
not establish the manual list's completeness; no new checker rule is claimed.

Actual source/helper/template/channel custody precedes use. Historical wrappers
recover at accepted activation Git bytes; checkpoint instruments stay immutable.
Native/kernel/OS/transitive first-use custody remains4.2/SESSION5. Unselected
artifacts/caches/native/proof/other repositories remain protected. No whole-
project population, global liveness or physical reclamation claim. Latest-only
schedule: docs/ARTIFACT_CLEANUP.md. All writer modes are one-shot history.

Related: [[daily-artifact-log-archival-2026-11-11]],
[[repo-generated-artifact-cleanup-boundary]], [[github-size-safe-publication]].
''')
workflow = 'docs/linkedspec-book/src/development/documentation-workflow.md'
edit(workflow, 'A daily review can retain every candidate.', f'''The November12 review retains all{rows} matching metadata rows in eight named
scopes. Separately, three completed own normal-commit logs preserve{content}
content bytes/full modes in compressed evidence before independent recovery and
removal of only their plain copies. Postdelete recovery and{controls} metadata/
log/channel/task-link corruption controls pass. Caches, native products and other
proof remain retained; no physical reclamation claim follows. The latest-only
record is `docs/ARTIFACT_CLEANUP.md`. Review without rerunning capture/retirement:

```sh
bash tools/project_data_run.sh env PYTHONPATH= python3 -P {BASE}/review.py
```

A daily review can retain every candidate.''')
edit('docs/linkedspec-book/src/appendix/backend-handoff.md', 'Remeasure after Julia, then installed Lua while margin permits;', f'Daily31 retains{rows} named-scope rows and archives three completed own logs/{content} content bytes before independent use/plain-copy retirement; readonly{controls}/three public task queries pass, native custody stays4.2/SESSION5. Parent4 adds30/31 links exactly. Evidence: {BASE}/REVIEW.md. Remeasure after daily31, then installed Lua while margin permits;')
frontier = f'November12 current fluent frontier: Perl80.1/Rust80.2/Dart80.3/Julia80.4 existing concat result guards have focused proof; installed Lua80.5 remains independent. Daily31 retains{rows} metadata rows/eight scopes and independently recovers three completed own combined logs/{content} content bytes before plain-copy retirement; readonly{controls}/three public task queries pass and parent30/31 links are exact. Native custody remains4.2/SESSION5. Committed Juliaa3faaf972/cached origin4683555e monitor0 estimates1,287,859,376 bytes/104 ahead/212,140,624-byte1.5GB margin, excluding daily31; current-independent/native gaps remain30/4.2. Remeasure after clean maintenance commit, then Lua80.5 while margin permits. Prepare near1.4GB or earlier for growth; canonical discovery4.1/full CI/normal hooks/clean publication30.2 take priority around1,500,000,000 bytes regardless cadence. Full source/context/admission23.4 and historical/raw-error/launcher/declared-host/formatter owners remain. Evidence: {BASE}/REVIEW.md; Julia proof: docs/checkpoints/array-concat-open-arity-julia-2026-11-12/REVIEW.md.'
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name)
    source, count = re.subn(r'^November12 current fluent frontier:.*$', lambda _: frontier, path.read_text(), count=1, flags=re.M)
    assert count == 1
    path.write_text(source)
edit('docs/tasks/TYPE-REFERENCE-BOOK.md', 'installed Lua80.5 next after fresh size/cleanup timing checks; raw-native observability4.28', f'daily31 is focused-checked{rows} rows/three completed logs/{content} content bytes/readonly{controls}/three public queries and exact parent30/31 links; installed Lua80.5 next after fresh size; raw-native observability4.28')
edit('docs/tasks/TYPE-REFERENCE-BOOK.md', 'After clean Julia80.4, remeasure outgoing bytes/review daily cleanup timing, then acquire independent installed Lua concat policies; canonical publication takes priority near1.4-1.5GB.', 'After clean daily31, remeasure outgoing bytes then acquire independent installed Lua concat policies; canonical publication takes priority near1.4-1.5GB.')
task = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
source = task.read_text()
start = source.index('- ID: `' + OWNER + '`')
part = source[start:].replace('Status: `active` / daily artifact review before the next long backend slice', 'Status: `completed` / dated focused maintenance; full native custody separate', 1)
part += f'''
  Completion: {summary} Retirement timestamp{retirement['at_utc']}. Parent adds only30/31 links with every other source byte exact; three public queries0. Shared book/frontier query{query['claim_records']} accepted records/{query['historical_intersections']} historical/zero live and six injected REDs follows the earlier separately captured task activation/parent data fix. All old claim/hash/revision fields remain unchanged. Actual document producer/reports/documents/modes retained; latest-only cleanup record and16-row live view synchronized. New claims disclose native4.2/SESSION5 and auxiliary telemetry30/4.2 gaps. Remeasure after clean commit, then independent Lua80.5 while margin permits.

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Due daily record and exact public parent omission30 recovered; no whole-project disposal inference.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Existing policy defines eight scoped metadata walks and exact own completed logs; manual parent Children was not updated for30.
  - [x] **FIX** — Archive/full-mode recovery and independent use precede only three plain duplicate removals; add parent30/31 with other bytes exact.
  - [x] **ADDRESSED (verified)** — Census/replay/predelete/retire/postdelete readonly0-empty stderr/{controls} effective controls and three public queries pass.
  - [x] **NO REGRESSION** — Census candidates/caches/native/unselected proof/other repositories retained; no shared tool/checker/limit/policy/runtime change or physical-reclamation claim. Full native custody remains4.2/SESSION5.
  - [x] **DOCUMENTATION** — Latest cleanup/book/Knowledge/roadmaps/task/live/pointer synchronized; actual publication images retained, normal checks still govern landing.
  Commit: `{OWNER} - review daily artifacts and retain log proof`.
  Evidence: {BASE}/REVIEW.md; default review.py/historical review_publication.py. All writer modes are completed one-shot; no SDK/full CI/push here.
'''
task.write_text(source[:start] + part)
for name, title, text in (
    ('CHANGES.md', f'2026-11-12 — {OWNER}: daily artifact review and exact log retention', f'{summary}\nParent30/31 links preserve every other byte. Book/Knowledge/latest cleanup/live\ndocs synced; native4.2/SESSION5 and auxiliary telemetry30/4.2 gaps remain.\nFresh size then independent Lua80.5; no SDK/full CI/push in this focused slice.\nEvidence: {BASE}/REVIEW.md.'),
    ('DEVELOPMENT_NOTES.md', f'2026-11-12 — Exact daily log retirement ({OWNER})', f'Fresh{rows} metadata rows/eight scopes remain retention-only. Three exact own\nDart102ec3446/monitor952f8a022/Juliaa3faaf972 combined normal logs retain{content}\ncontent bytes/full modes/Git markers before actual independent predelete use.\nFinal identity/hash and three-path residue checks0; postdelete readonly{controls}\nrejects metadata/source/log/channel/parent faults. Shared wrappers recover at\naccepted activation Git bytes, without future live-source freshness claims.\nParent Children ended at29 despite indexed30; exact data adds30/31, two faults\nreject and three public queries pass. Shared publication{query['claim_records']} accepted/{query['historical_intersections']}\nhistorical/zero live precedes book/frontier edits, not the earlier captured task\ndata fix. Old claims/hashes/revisions stay exact. Full native/kernel/OS/transitive\ncustody4.2/SESSION5 and auxiliary pack gaps30/4.2 remain. Remeasure after commit.\nEvidence: {BASE}/REVIEW.md.'),
):
    path = Path(name)
    source = path.read_text()
    anchor = re.search(r'^## ', source, re.M)
    assert anchor
    path.write_text(source[:anchor.start()] + '## ' + title + '\n\n' + text + '\n\n' + source[anchor.start():])
live = Path('LIVE_ACHIEVEMENT_STATUS.md')
source = live.read_text()
for title, text in (
    ('Current Activity', 'Full PNT continues. Perl/Rust/Dart/Julia concat family80 has focused proof and daily31 is complete. Remeasure committed outgoing bytes, then independent installed Lua80.5 while margin permits; canonical publication preempts cadence near1.4-1.5GB.'),
    ('Latest Completed Slice', OWNER + '. ' + summary + ' Parent30/31 links exact; native custody4.2/SESSION5 remains.'),
    ('Next Action', 'After clean daily31 commit, remeasure current committed outgoing bytes then acquire independent installed Lua80.5 concat policies while margin permits. Prepare near1.4GB; canonical discovery4.1/full CI/normal hooks/clean exact HEAD precede publication around1,500,000,000 bytes regardless cadence.'),
):
    source, count = re.subn(r'(## ' + title + r'\n\n).*?(?=\n\n## )', lambda match: match[1] + text, source, count=1, flags=re.S)
    assert count == 1
start = source.index('## Recent Completions\n\n') + len('## Recent Completions\n\n')
end = source.index('\n## History', start)
old_rows = source[start:end].strip().splitlines()
assert len(old_rows) == 16 and all(row.startswith('- ') for row in old_rows)
(BASE / 'publication/rotated-live-row.txt').write_text(old_rows[-1] + '\n')
new_row = f'- {OWNER} —{rows} rows/eight scopes retained; three exact own completed logs/{content} combined bytes/modes independently used before plain retirement; readonly{controls}/three public queries/parent30-31 exact; fresh size then Lua80.5.'
live.write_text(source[:start] + '\n'.join([new_row] + old_rows[:15]) + '\n\n' + source[end:])
Path('MEMORY.md').write_text(f'''# MEMORY

- activation_commit: `a3faaf97292550ba1e3001604e1e379d478bcdd4` — clean daily31 activation; derive current HEAD from Git.
- latest_completed_leaf: `{OWNER}` — dated focused artifact review and exact completed-log retention.
- active_work_unit: `{OWNER}` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.
- run_state: full PNT, no fixed batch count.
- next_action: Remeasure current committed outgoing bytes with docs/checkpoints/publication-size-monitor-2026-11-12/measure.py, then acquire independent installed Lua80.5 concat policies while margin permits. Canonical discovery4.1/full CI/publication30.2 preempt cadence near1.4-1.5GB or before large growth. Never replay completed capture/retirement/publication writers.
- in_flight_uncommitted: none; daily31 artifact proof/hierarchy data/docs committed; no required background job.
- evidence: {BASE}/REVIEW.md;{summary} Parent30/31 links preserve every other byte; three public queries pass. Default review.py is readonly and checks shared wrappers at accepted activation Git bytes. Full native/kernel/OS/transitive4.2/SESSION5 and auxiliary telemetry30/4.2 gaps remain explicit.
- publication: Director1,500,000,000-byte early trigger overrides PNT/batch cadence; preparation1,400,000,000 is advisory. Measure after each committed leaf/before large growth. At a3faaf972/cached origin4683555e, actual monitor0 is1,287,859,376 bytes/104 ahead/46,075 logical-header objects/212,140,624-byte margin, excluding daily31. Metadata/source/channels in this checkpoint push-monitor-current/, raw pack ignored/protected; current independent-size/native gaps30/4.2. No fresh remote/wire/future guarantee. Remeasure now. Full canonical/current discovery/normal hooks/clean exact HEAD/fresh remote identity precede every push; no push yet.
- qualifications: Claim docs/claims/{OWNER}.json discloses remaining native and telemetry legs.209 accepted/249 historical/zero live plus six injected controls precede shared book/frontier publication, after separately captured task activation/child-link data fix. Old claims/hashes/revisions unchanged. Full23.4/source/context/discovery4.1/historical4.24/raw-error4.28/launcher4.22/SESSION7/literal/excluded/declared5.4/formatter stay owned.
- continuity: Juliaa3faaf972/all10/post-pointer/brief0/clean verified before activation;508/four routes/20 supported/four compatibility/484 preserved/old24-current508/direct4959 assertions/readonly10 plus two patch controls/current516/3048 pairs stay focused. Its default historical reader is review_qualified.py after exact diff compression; original reader/seal/first0 stay immutable. Retired Dart/monitor/Julia successful commit logs are now in this checkpoint combined-logs/ with archive-manifest.json. Lua80.5 imports source questions only and acquires own policy.
- verification_policy: Focused ordinary slices plus normal hooks; canonical publication/mechanical boundaries. Latest cleanup{retirement['at_utc']}; latest-only record docs/ARTIFACT_CLEANUP.md. Only this repo writable; submodules black boxes. Same-volume data/shared24GiB/serial intensive jobs/RAM90 policy. External policy hashes unchanged at startup.
''')
Path('git_message_brief.txt').write_text(f'''{OWNER} - review daily artifacts and retain log proof

Retain all1316 named-scope rows. Archive three exact completed own combined
commit logs/133480 content bytes/full modes and independently consume them before
retiring only plain copies; verify exact residue.

Readonly16 controls/three public queries pass. Add only missing30/new31 parent
links; sync book/Knowledge/latest cleanup/live docs and disclose native/telemetry
gaps. Fresh size then independent Lua80.5. Canonical publication preempts cadence
near1.5GB; no SDK/full CI/push here.
''')
print(json.dumps(dict(publication='PASS', scoped_rows=rows, archived_files=3, content_bytes=content,
    controls=controls, public_queries=3, accepted_claims=query['claim_records'], historical_intersections=query['historical_intersections'], live_intersections=0)))
