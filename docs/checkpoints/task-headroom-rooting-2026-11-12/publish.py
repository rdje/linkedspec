"""Publish retained headroom proof from frozen reports and document preimages."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
OWNER='TYPE-REFERENCE-BOOK.1.2.23.4.32'
ACTIVATION='9f11029e5af9d6168925f532d4c1911637421af3'
BOOK='docs/linkedspec-book/src/development/documentation-workflow.md'
PART='docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
OUT=BASE/'publication';OUT.mkdir()
documents=[BOOK,PART,'docs/tasks/TYPE-REFERENCE-BOOK.md','ROADMAP.md','ROADMAP_V2.md','CHANGES.md','DEVELOPMENT_NOTES.md','LIVE_ACHIEVEMENT_STATUS.md','MEMORY.md','git_message_brief.txt']
reports=[str(BASE/name) for name in ('review-result.json','candidate-result.json','preflight-result.json')]
for tag in ('review','current','review-refusal','review-publication-query'):
    reports += [str(BASE/'launches'/tag/name) for name in ('stdout.log.gz','stderr.log.gz','exit.txt')]
instruments=[str(BASE/name) for name in ('publish.py','review_publication.py','review.py','review_refusal.py','sealed-identities.json','outputs-before-reader-identities.json')]
instruments += ['tools/project_data_run.sh','tools/project_data_env.sh','docs/claims/'+OWNER+'.json','docs/tasks/PROJECT-DATA-SSD-ROOTING.md','docs/history/task-narrative-epochs/'+OWNER+'.json']
def freeze(tag,names):
    rows={};bodies={}
    with tarfile.open(OUT/(tag+'.tar.gz'),'x:gz') as archive:
        for name in sorted(set(names)):
            path=Path(name)
            assert not path.is_absolute() and '..' not in path.parts and path.is_file() and not path.is_symlink()
            assert path.stat().st_dev==Path.cwd().stat().st_dev
            raw=path.read_bytes();rows[name]=dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest(),mode=path.stat().st_mode&0o777)
            archive.add(path,arcname=name,recursive=False);bodies[name]=raw
    with tarfile.open(OUT/(tag+'.tar.gz')) as archive:
        assert len(archive.getnames())==len(rows) and set(archive.getnames())==rows.keys()
        for member in archive:
            raw=archive.extractfile(member).read();row=rows[member.name]
            assert raw==bodies[member.name] and len(raw)==row['bytes'] and hashlib.sha256(raw).hexdigest()==row['sha256'] and member.mode&0o777==row['mode']
    (OUT/(tag+'.json')).write_text(json.dumps(rows,indent=2,sort_keys=True)+'\n')
    return rows,bodies
rows,before=freeze('inputs-before-use',documents+reports+instruments)
def report(tag):
    prefix=str(BASE/'launches'/tag)+'/'
    assert before[prefix+'exit.txt']==b'0\n'
    assert gzip.decompress(before[prefix+'stderr.log.gz'])==b''
    return json.loads(gzip.decompress(before[prefix+'stdout.log.gz']))
proof=json.loads(before[str(BASE/'review-result.json')]);candidate=json.loads(before[str(BASE/'candidate-result.json')])
query=report('review-publication-query');refusal=report('review-refusal')
assert proof['preservation']==candidate['candidate']==refusal['refusal_recovery']=='PASS'
assert (proof['stable_ids'],proof['selected_closed'],proof['unchanged_short_bodies'],proof['original_bytes'],proof['current_bytes'],proof['current_text_bytes_renewed'],proof['current_tail_bytes'],proof['actual_public_queries'])==(22,17,5,98757,58170,40587,35225,23)
assert len(proof['effective_corruptions'])==10 and len(refusal['corruptions'])==3
assert query['claim_records']==211 and query['live_intersections']==0
buffers={name:before[name].decode() for name in documents}
def replace(name,old,new):
    assert buffers[name].count(old)==1,'publication anchor:'+name
    buffers[name]=buffers[name].replace(old,new,1)
record=f'''## 2026-11-12 — {OWNER}: closed task narrative capacity

Existing PROJECT-DATA-SSD-ROOTING epoch preserves22 ordered IDs/all CORE fields/five complete unselected bodies/prefix/full35225-byte tail.17 closed narratives gain exact source pointers;98757 becomes58170 current bytes, renewing40587 under unchanged limits. All23 actual public queries/independent readonly10/current source-manifest identity pass. Earlier terse capture1 is retained: all189 already have original Narrative pointers, so the writer refuses before mutation; independent refusal recovery/three controls pass. New preflight checks both pointer forms and actual shorter eligible bodies. Source/mode/producer/input/channel/Git proof survives; no SDK/cleanup execution or fresh parity/reclamation claim. Latest committed9f/cached origin4683555e monitor0 is1,352,197,517 bytes/106 ahead/147,802,483-byte trigger margin, excluding32; current-falsification/native gaps30/4.2 stay explicit. Fresh size then resource4.14/current discovery4.1/raw-error4.28 and canonical publication preempt cadence. Evidence: {BASE}/REVIEW.md.

'''
assert record.startswith('## 2026-11-12 — ')
for name,text in (('CHANGES.md',record),('DEVELOPMENT_NOTES.md',f'''## 2026-11-12 — {OWNER}: archive-pointer eligibility

The existing writer excludes both original Narrative and later Narrative epoch pointers. A vocabulary-only preflight cannot establish remaining capacity: terse189 already carry original pointers and actual capture1 correctly refuses before mutation. Keep its sealed original source/producer/channels and independently recover the guard; no extraction credit. A fresh rooting operation independently predicts17 eligible bodies, then preserves22 IDs/all CORE/five whole bodies/full35225-byte tail and23 exact public queries. First historical reader rejects10 preservation faults; source-manifest current identity is separate. All tools/limits/schemas and original storage/cache dates/contracts remain unchanged; no cleanup or native/SDK replay. Remeasure committed bytes, then resource4.14 must cover both RAM producers before current discovery/canonical publication. Evidence: {BASE}/REVIEW.md.

''')):
    position=buffers[name].index('\n## ')+1
    buffers[name]=buffers[name][:position]+text+buffers[name][position:]
book_add=f'''

The storage-locality epoch preserves all22 IDs/CORE fields, five complete unselected
bodies and the full35225-byte frontier/trailing section.17 closed narratives gain
source pointers; current text changes from98757 to58170 bytes, renewing40587 under
unchanged limits. Recover the exact original source with:

```bash
bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch {OWNER} --all
```

All23 source/node queries and independent recovery with ten corruption controls
pass. The first terse attempt is retained as a guarded refusal: its189 records
already had original archive pointers, so it supplied no new capacity. Readiness
checks must exclude both original and epoch pointers and confirm a shorter
eligible body. Original source/producer/command/mode evidence remains exact.
This data epoch preserves dated storage evidence; current deletion, SDK and parity authority stays with its existing owners.
'''
replace(BOOK,'This preserves task data, with no new cleanup, runtime or parity claim.','This preserves task data, with no new cleanup, runtime or parity claim.'+book_add)
marker='- ID: `'+OWNER+'`';start=buffers[PART].index(marker);end=buffers[PART].find('\n- ID:',start+1);end=len(buffers[PART]) if end<0 else end
block=buffers[PART][start:end]
assert block.count('  Status: `active`')==1
block=block.replace('  Status: `active`','  Status: `completed` / bounded existing data epoch with focused proof',1)
block+=f'''

  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Prior Lua normal task-cap failure and compact own-commentary routing leave little room;9f source/input identities retained.
  - [x] **ROOT CAUSE (WHY + WHERE)** — migrate_epoch132 skips original Narrative and epoch pointers; terse189 already compacted. Actual guarded1/unchanged source is independently recovered; rooting17 eligible preflight matches actual selection.
  - [x] **FIX** — Existing rooting epoch32 preserves22 ordered IDs/all CORE/five complete unselected bodies/prefix/full35225-byte tail;17 pointers renew40587 current-text bytes without changing limits/tools.
  - [x] **ADDRESSED (verified)** — Actual migration0/all23 public queries0-empty stderr, first historical readonly0-ten effective corruptions/current source-manifest identity0; prior refusal recovery0-three controls.
  - [x] **NO REGRESSION** — Exact before/after/Git/native command channels/full modes; all contracts/statuses/full tail survive. No original source/tool/claim hash rewrite, SDK/cleanup replay or new parity/physical-reclamation claim.
  - [x] **LOCKSTEP** — Book/Knowledge/roadmaps/task/index/live/pointer/scope/history align; normal hooks govern clean landing before resource4.14/current discovery/publication.
  Outcome: {BASE}/REVIEW.md; default review.py/review_refusal.py and public epoch queries. Current identity is pre-staging only. Earlier {str(Path('docs/checkpoints/task-headroom-terse-2026-11-12'))} stays immutable with no migration credit. Actual before-use producer/report/document images and publication recovery retained.
  Claim boundary: Finite named task/byte-preservation controls; separate operational telemetry record discloses actual9f pack1,352,197,517/106 and current-falsification30/native4.2 gaps.211 accepted records/207 historical intersections/zero live/eight injected REDs precede rooting/book edits after task activation. Original hashes/revisions remain. Full source/context/admission23.4/historical4.24/raw-error4.28/launcher/SESSION7/literal/excluded/declared5.4/formatter remain owned. Fresh size after commit; canonical publication preempts cadence near1.4-1.5GB.
'''
buffers[PART]=buffers[PART][:start]+block+buffers[PART][end:]
root='docs/tasks/TYPE-REFERENCE-BOOK.md'
oldrow=next(line for line in buffers[root].splitlines() if line.startswith('| 1 |'))
replace(root,oldrow,'| 1 | `TYPE-REFERENCE-BOOK.1.2.23.4.14` | `pending` | Fresh size, then repair both RAM preflights before current discovery/full CI/publication. |')
replace(root,'installed Lua80.5 is focused-checked; bounded80 outcomes recorded; fresh size then coverage/discovery4.1/raw-error4.28 before push;','installed Lua80.5 is focused-checked; bounded80 outcomes recorded; headroom32 preserves22 IDs/17 closed/five unchanged bodies/full35225-byte tail/23 queries/readonly10; fresh size then resource4.14/discovery4.1/raw-error4.28 before push;')
frontier=f'November12 current fluent frontier: All five bounded concat80 implementations have focused outcomes; Lua9f11029 is committed/all10/clean. Headroom32 preserves22 rooting IDs/all CORE/five whole bodies/full35225-byte tail;17 closed pointers renew40587 bytes,23 public queries/readonly10/current identity pass. Terse189 guarded refusal remains unchanged/recovered with three controls. No SDK/cleanup replay or new parity claim. Latest committed9f/cached origin4683555e monitor0 is1,352,197,517 bytes/106 ahead/147,802,483-byte1.5GB margin/47,802,483-byte1.4GB margin, excluding32. Current-falsification/native gaps30/4.2 remain. Fresh size then resource4.14 repairs both RAM producers before current discovery4.1/full CI; raw-error4.28 precedes admission AND push. Canonical clean publication30.2 preempts cadence near1.4-1.5GB. Evidence: {BASE}/REVIEW.md.'
for name in ('ROADMAP.md','ROADMAP_V2.md'):
    old=next(line for line in buffers[name].splitlines() if line.startswith('November12 current fluent frontier:'))
    replace(name,old,frontier)
live='LIVE_ACHIEVEMENT_STATUS.md'
for heading,text in (
    ('Current Activity','Full PNT continues. Bounded concat80 has five focused backend outcomes and headroom32 is complete. Remeasure committed size, then resource4.14/current discovery and canonical publication preparation; broader source/context/admission remains.'),
    ('Latest Completed Slice',OWNER+'. Existing rooting data epoch:22 IDs/all CORE/five unchanged bodies/full35225-byte tail,17 pointers/40587 current-text bytes renewed. Migration23 public queries/first independent readonly10/current identity pass. Terse refusal1 remains unchanged and independently recovered/three controls; no SDK, cleanup or parity claim.'),
    ('Next Action','Remeasure current committed outgoing bytes, then repair both RAM preflight producers under resource4.14 before current canonical discovery4.1/full CI. Raw-error4.28 precedes admission AND push. Prepare near1.4GB and publish around1,500,000,000 bytes regardless cadence, with exact clean-HEAD canonical proof/normal hooks/fresh remote identity.'),
):
    pattern=r'(## '+re.escape(heading)+r'\n\n).*?(?=\n## )'
    buffers[live],count=re.subn(pattern,lambda m:m[1]+text+'\n',buffers[live],flags=re.S);assert count==1
start=buffers[live].index('## Recent Completions\n\n')+len('## Recent Completions\n\n');end=buffers[live].index('\n## History',start)
recent=[line for line in buffers[live][start:end].splitlines() if line.startswith('- ')];assert len(recent)==16
rotated=recent[-1]+'\n'
newrow='- '+OWNER+' —22 rooting IDs/17 closed/five unchanged/full35225-byte tail/40587 bytes renewed/23 public queries/readonly10/current identity; terse refusal recovered-three controls; fresh size then RAM14.'
buffers[live]=buffers[live][:start]+'\n'.join([newrow]+recent[:15])+'\n\n'+buffers[live][end:]
buffers['MEMORY.md']=f'''# MEMORY

- activation_commit: `{ACTIVATION}` — clean headroom32 activation; derive current HEAD from Git.
- latest_completed_leaf: `{OWNER}` — bounded closed storage-locality task narrative capacity.
- active_work_unit: `{OWNER}` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.
- run_state: full PNT, no fixed batch count.
- next_action: Remeasure current committed outgoing bytes with docs/checkpoints/publication-size-monitor-2026-11-12/measure.py, then resource23.4.14 repairs both ram_guard and the embedded CI preflight before current canonical discovery4.1/full CI. Raw-error4.28 precedes admission AND push. Canonical publication30.2 preempts cadence near1.4-1.5GB or before large growth. Never replay completed migration/SDK/publication writers.
- in_flight_uncommitted: none; headroom32 data/proof/docs committed; no required background job.
- evidence: {BASE}/REVIEW.md; existing PROJECT-DATA-SSD-ROOTING epoch preserves22 ordered IDs/all CORE/five complete unselected bodies/metadata/full35225-byte tail;17 closed pointers,98757 to58170 current bytes/40587 renewed. Actual migration/all23 public source-node queries0/empty stderr, first independent readonly0/ten effective corruptions/current source-manifest identity0. All actual producers/inputs/Git bodies/channels/full modes retained before use, outputs before queries; default review.py and public epoch reader historical. Current target identity is pre-staging only; no SDK/cleanup/parity or physical-reclamation claim.
- qualification: Earlier terse capture1 is sealed under docs/checkpoints/task-headroom-terse-2026-11-12;189 original Narrative pointers trigger the correct no-capacity guard before mutation. Source/Git/mode unchanged and32 manifest absent then; no extraction credit. New independent preflight excludes both pointer forms and checks actual shorter eligibility; its17 IDs match the new actual selection. review_refusal.py0/three reason-sensitive controls recovers that original failure without replay/current absence assertions.
- shared_docs:211 exact accepted records/207 historical intersections/zero live/eight injected binding controls precede rooting/book edits after owned activation. Actual producer/reports/documents/full modes before-after are retained in publication/; original claims/hashes/revisions unchanged. New Knowledge rooting-closed-task-narrative-headroom records source/eligibility/recovery boundaries.
- publication: Director1,500,000,000-byte early trigger overrides cadence; advisory preparation1,400,000,000. Fresh actual monitor0 at committed9f11029e5/cached origin4683555e:1,352,197,517 bytes/106 ahead/46,757 objects/147,802,483 trigger margin/47,802,483 advisory margin, excluding32. Actual metadata/source/channels in this checkpoint push-monitor-current/; raw pack ignored/protected. New record docs/claims/{OWNER}.json discloses current-independent30/native4.2 gaps. No remote freshness/wire/future-size guarantee. Full canonical/current discovery4.1/before-push raw-error4.28/normal hooks/clean exact HEAD/fresh remote identity precede push; no push yet.
- continuity: Lua80.5/9f11029e5/all10/post-pointer/brief0/clean verified before activation. Its default historical reader is review_qualified.py after exact oracle compression, with11 original+two added controls; original reader/first0/seal remain immutable and standalone original expects retired plain source. Own per-host508/20 targets/four separate compatibility/484 preserved/80 initial/eight signatures/direct6987/3048 pairs remain focused. Full23.4/native4.2/SESSION5/source/context/historical4.24/launcher4.22/SESSION7/literal/excluded/shadowing32/declared5.4/formatter stay open.
- verification_policy: Focused ordinary data slices/normal hooks; canonical designated admission/publication boundaries. Same-volume/serial intensive jobs/shared24GiB/RAM90 trend policy. Resource4.14 covers the CI copy of the denied-sysctl16GiB fallback too; see canonical-ci-ram-fallback-prerequisite. Only this repository writable; submodules black boxes. Latest cleanup2026-11-12T15:32:21.895461+00:00 remains current; old retired logs recover from artifact-review-2026-11-12. No native PID/PGID inference from denied pgrep.
'''
buffers['git_message_brief.txt']=OWNER+' - renew closed task narrative headroom\n\nPreserve22 rooting task IDs and all CORE/full trailing data while17 closed\nnarratives gain exact source pointers. Retain the guarded terse refusal and\nindependent recovery; use existing tools and unchanged document controls.\n\nFocused23 public queries/readonly10/current identities and synchronized book/docs.\n'
newdocs={str(BASE/'REVIEW.md'):f'''# Closed storage-locality narrative headroom

Owner: {OWNER}. Clean activation: {ACTIVATION} after Lua80.5/all10/post-pointer/
empty brief/clean; all five bounded concat backends have focused outcomes.

The existing unpartitioned PROJECT-DATA-SSD-ROOTING epoch preserves22 ordered
IDs/all declared CORE fields, five complete unselected bodies, metadata and the
full35225-byte Current Frontier/trailing section.17 closed commentary bodies gain
immutable source pointers. Original98757 becomes58170 current bytes, renewing
40587 under unchanged limits. All23 actual public whole-source/every-ID queries
return the complete original bytes with0/empty stderr. Original source/tool/Git
body/template/command/channel/full filesystem modes survive; outputs precede
queries. First independent historical recovery0/ten effective corruptions and
separate source-manifest current identity0 pass. The exact independent preflight
selected set matches actual selection. No tool/reader/schema/registry/limit/SDK
changes, cleanup replay, runtime/parity or physical disk-reclamation claim follows.
Current identity is pre-staging; original metadata/cache dates remain historical.

An earlier source choice, SPEC-FORMAT-TERSE, produced actual capture1 with the
published no-closed-narrative-capacity guard before mutation. All189 records
already have original Narrative pointers. Those are a separate exclusion from
later Narrative epoch pointers. Vocabulary-only preflight supplied no capacity
credit; the old source and all actual outcomes/instruments remain unchanged and
sealed under docs/checkpoints/task-headroom-terse-2026-11-12. Refusal recovery0
checks exact Git/source/capsule/producer bytes, actual channels and the exclusion;
three reason-sensitive pointer/failure/state controls reject. It makes no current
manifest-absence assertion after the fresh rooting operation. Only the same
headroom maintenance source selection changes; no unfinished work is abandoned.
The new preflight rejects either pointer form and verifies strictly shorter
eligible bodies before its fresh operation. Default review.py/review_refusal.py
are readonly; never rerun migration, capture or publication writers.

Before rooting/book edits, the retained binding query recovers211 accepted records,
207 historical intersections/zero live bindings/eight injected live REDs. It
follows own task activation. Original claim hashes/revisions stay unchanged.
Actual document producer/reports/source-manifest/claim/document before-after
images are retained in publication/; review_publication.py recovers them without
SDK execution. Finite named source/byte-preservation controls do not establish
complete project reading, modern native admission or fresh historical SDK results.

Separate operational telemetry at committed9f/cached origin4683555e reports
1,352,197,517 serialized non-thin bytes/106 commits/46,757 objects,147,802,483 bytes
below1.5GB and47,802,483 below advisory1.4GB, excluding this slice. Retained actual
source/policy/wrappers/channels are under push-monitor-current/. The new claim
record explicitly leaves independent-current actual-file falsification30 and
native/physical/raw-pack/cache/compressor/toolchain/OS4.2/SESSION5 open; no remote
freshness/negotiated-wire/future-size guarantee follows. No full CI or push occurs
in this focused data slice. Remeasure after commit, then resource4.14 repairs both
RAM producers before current discovery4.1/full CI. Raw-error4.28 precedes admission
AND push; canonical clean publication30.2 preempts cadence around1,500,000,000 bytes.
Full source/context/admission23.4/historical4.24/launcher/SESSION7/literal/excluded/
declared5.4/formatter owners remain separate.
''', 'docs/knowledge/rooting-closed-task-narrative-headroom.md':f'''---
id: rooting-closed-task-narrative-headroom
title: Closed storage-locality task commentary retains exact source through a data epoch
answers:
  - "where are original PROJECT DATA SSD ROOTING task narratives"
  - "how do I recover storage locality tasks before headroom32"
  - "why does SPEC FORMAT TERSE have no closed narrative capacity"
  - "does the epoch writer exclude original Narrative pointers as well as epoch pointers"
  - "does closed storage task headroom authorize cache deletion or new runtime admission"
date: 2026-11-12
status: bounded existing data epoch focused-checked; normal landing governs clean handoff
tags: [tasks, narrative, headroom, storage, preservation, history]
evidence: "{OWNER};22 ordered IDs/all CORE/five unchanged bodies/full35225-byte tail;17 pointers/98757 to58170/40587 current bytes renewed;23 exact public queries/readonly10/current identity. Terse189 already archived; guarded1/unchanged source/refusal recovery-three controls. {BASE}/REVIEW.md."
reverify:
  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P {BASE}/review.py"
  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P {BASE}/review_refusal.py"
  - "bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PROJECT-DATA-SSD-ROOTING --epoch {OWNER} --all"
---

Existing ADR0139 data interface preserves the exact9f source,22 ordered IDs/all
CORE fields, five full unselected bodies/metadata/full35225-byte tail.17 closed
commentary bodies gain pointers to the retained ancestor. Original98757 becomes
58170 current bytes/40587 renewed; all23 public source/node queries return exact
original bytes with0/empty stderr. No tool/limit/schema/runtime movement follows.

The writer excludes both original Narrative and later Narrative epoch markers.
A large closed tree can therefore have no eligible capacity: terse189 already
have original pointers, and actual capture1 correctly refuses before mutation.
Original source/producer/channels remain sealed. Separate refusal recovery0/three
controls supplies no extraction or old archive/SDK re-admission credit. New
preflight must check both pointer kinds and actual shorter eligible bodies.

Before-use source/instrument/fixture/Git bodies/full modes and actual command
channels are retained; outputs precede public queries. First independent readonly
0/ten corruptions/current target-manifest identity0 pass. Current identity is
point-in-time; default historical readers run no writer or SDK. All legacy source
labels, original dates and cleanup evidence remain recoverable in complete source.
This is no new deletion, physical-space, parity or whole-project reading authority.

Source/context/portable/native4.2/SESSION5/current discovery4.1/raw-error4.28/
historical4.24/launcher/declared5.4/formatter/full23.4 stay separate. Remeasure
committed packed bytes then repair resource4.14 before full canonical publication.
Related: [[normal-hook-archive-reference-contracts]],
[[hygiene-closed-task-narrative-headroom]], [[github-size-safe-publication]].
''', str(OUT/'rotated-live-row.txt'):rotated}
for name,text in buffers.items():
    assert Path(name).read_bytes()==before[name],'document changed during publication:'+name
    Path(name).write_text(text)
for name,text in newdocs.items():
    path=Path(name);assert not path.exists();path.write_text(text)
for name in reports+instruments:
    if name in documents:continue
    assert Path(name).read_bytes()==before[name] and Path(name).stat().st_mode&0o777==rows[name]['mode'],'consumed input changed'
freeze('outputs-after-use',documents+list(newdocs))
print(json.dumps(dict(publication='PASS',stable_ids=22,selected_closed=17,public_queries=23,corruptions=10,prior_refusal_controls=3,claim_records=query['claim_records'],old_claims_unchanged=True,next='Fresh size then resource4.14/current discovery/full canonical publication as budget requires')))
