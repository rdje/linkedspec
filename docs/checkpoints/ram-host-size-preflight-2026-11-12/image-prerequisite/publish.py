"""Publish the completed bounded prerequisite and intended canonical handoff."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile

ROOT=Path.cwd().resolve()
BASE=Path(__file__).resolve().parent.relative_to(ROOT)
OUT=BASE/'publication'
OUT.mkdir()
OWNER='TYPE-REFERENCE-BOOK.1.2.23.4.14'
ACTIVATION='b370de8d31e3f38da6abf8ed4702a523aa3d6d97'
CARD='docs/knowledge/three-objective-language-readiness.md'
BOOK='docs/linkedspec-book/src/development/documentation-workflow.md'
PART='docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
RECORD='docs/claims/'+OWNER+'.json'
PRIMARY=BASE.parent
documents=[CARD,BOOK,PART,'docs/tasks/TYPE-REFERENCE-BOOK.md',RECORD,'CHANGES.md','DEVELOPMENT_NOTES.md',
           'MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md','ROADMAP.md','ROADMAP_V2.md','git_message_brief.txt',
           str(PRIMARY/'REVIEW.md'),str(PRIMARY/'LANDING.md')]
reports=[BASE/'isolated-recovery/stdout.gz',BASE/'isolated-recovery/stderr.gz',BASE/'isolated-recovery/exit.txt',
         BASE/'proofs/historical-recovery-review/stdout.gz',BASE/'proofs/historical-recovery-review/exit.txt',
         BASE/'proofs/population-review/stdout.gz',BASE/'proofs/population-review/exit.txt']


def freeze(name,paths):
    rows={}
    with tarfile.open(OUT/(name+'.tar.gz'),'x:gz') as archive:
        for item in sorted(set(map(str,paths))):
            path=Path(item);raw=path.read_bytes()
            assert path.is_file() and not path.is_symlink() and path.stat().st_dev==ROOT.stat().st_dev
            rows[item]=dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest(),mode=path.stat().st_mode&0o777)
            archive.add(path,arcname=item,recursive=False)
    with tarfile.open(OUT/(name+'.tar.gz')) as archive:
        assert set(archive.getnames())==rows.keys()
        for member in archive:
            assert hashlib.sha256(archive.extractfile(member).read()).hexdigest()==rows[member.name]['sha256']
            assert member.mode&0o777==rows[member.name]['mode']
    (OUT/(name+'.json')).write_text(json.dumps(rows,indent=2,sort_keys=True)+'\n')


freeze('inputs-before-use',documents+reports+[Path(__file__).relative_to(ROOT)])
assert all(path.read_text().strip()=='0' for path in reports if path.name=='exit.txt')
assert gzip.decompress((BASE/'isolated-recovery/stderr.gz').read_bytes())==b''
actual=json.loads(gzip.decompress((BASE/'isolated-recovery/stdout.gz').read_bytes()))
review=json.loads(gzip.decompress((BASE/'proofs/historical-recovery-review/stdout.gz').read_bytes()))
population=json.loads(gzip.decompress((BASE/'proofs/population-review/stdout.gz').read_bytes()))
assert review['result']==population['result']=='PASS'
buffers={name:Path(name).read_text() for name in documents}
old_claim=json.loads(buffers[RECORD]);assert len(old_claim['claims'])==2
(OUT/'prior-resource-claim.json.gz').write_bytes(gzip.compress(buffers[RECORD].encode(),mtime=0))
claim=copy.deepcopy(old_claim)
claim['claims'].append(dict(name='exact-later-images-and-ram-ci-historical-inverse',
    statement='The complete149-source historical population has four later committed runtime images at b370 and one exact owned RAM CI inverse. Original source-image tables, protected Phase0 fixture and predecessor stages remain; isolated historical recovery preserves the original134 inputs and every prior control field, including714 governance mutations. Source identity admission is separate from fresh runtime/objective/feature admission.',
    scope='Actual source-bound intake, nested-report RED/GREEN, current and prior19-image controls, exact owned candidate-to-committed-precursor inverse and isolated historical consumer. The old comparison packet predates the existing Phase0-value field; its unchanged producer still passes12 controls. Nine RAM CI source/input denials are new. No runtime SDK body changes are made by this prerequisite.',
    rederive=dict(status='checked',
        command='bash tools/run_python_project_data.sh docs/checkpoints/ram-host-size-preflight-2026-11-12/image-prerequisite/review.py; bash tools/run_python_project_data.sh docs/checkpoints/ram-host-size-preflight-2026-11-12/image-prerequisite/review_population.py',
        granularity='Every named historical source, effective committed image and predecessor, actual retained consumer/input/channel/mode and specific original/new corruption control.',
        result=f'Actual isolated consumer0/empty stderr, {len(actual["tracked_inputs"])} declared/{len(actual["observed_artifact_inputs"])} observed inputs within213 before-use bodies. Historical review0/six corruptions and population review0/three corruptions; all old recovery/control fields match. Original nested report1 is retained; repaired full image/RAM unit0 and focused exact predecessor/current controls0.'),
    falsify=dict(status='checked',
        hypothesis='A generic hash refresh can admit later images without preserving intermediate stages, the old report already names a nested latest image, or accepting the RAM registration permits unrelated historical drift.',
        oracle='Exact accepted b370 and728 Git images/modes, original closed tables and independent previous complete recovery report, original-stage and current19-image denials, strict two-hunk candidate inverse and retained actual channel comparison.',
        red_control='Canonical-first.log.gz refuses current Dart before admission. Actual nested-report-red exits1 on incorrect intermediate report; repaired unit passes. Every earlier714 governance control still rejects at its original precursor stage, nine new RAM source/input controls reject, and independent six recovery/three membership corruptions reject.'),
    durability=dict(status='gap',repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2',
        reason='All direct own source/producer/table bodies, before-use213-input epoch, separate actual channels, full modes, failed candidate and independent recovery instruments survive under image-prerequisite/. Complete physical/native Git/Python/cache/toolchain/OS implementation closure remains4.2/SESSION5; source-only retention is not full native custody.')))
assert claim['claims'][:2]==old_claim['claims']
buffers[RECORD]=json.dumps(claim,indent=2)+'\n'

assert '## November12 later image and RAM CI stages' not in buffers[CARD]
buffers[CARD]=buffers[CARD].replace('date: 2026-11-02\n','date: 2026-11-12\n',1)
anchor='  - "where is the frozen objective input epoch replayed"\n'
assert buffers[CARD].count(anchor)==1
buffers[CARD]=buffers[CARD].replace(anchor,anchor+'  - "why can nested successor verification report an intermediate image"\n  - "which exact RAM CI inverse preserves earlier objective controls"\n',1)
buffers[CARD]+='''

## November12 later image and RAM CI stages

Resource23.4.14's first canonical gate refuses the later Dart image. The complete
149-source/19-image inventory isolates four accepted runtime successors at b370
and the owned uncommitted RAM CI change. A second closed successor table retains
the original18 table,728 successor layer, first-image entry and Phase0 activation.
Nested reports now use effective successor reports and retain intermediate
lineage; an actual old-report RED precedes the correction.

The RAM CI stage has two exact hunks and closed support identities. It restores
the actual b370 precursor before every older CI inverse/falsifier, without
describing the owned candidate as a committed historical image. New source/data
controls remain separate from the original714 governance mutations. Every old
recovery/control field and134 recovered inputs match the previous capture;
the existing Phase0-value predicate/source is unchanged and its12 controls pass.
The actual current consumer has210 declared/199 observed inputs within213
before-use retained bodies. Native/toolchain/OS closure remains4.2/SESSION5.

Historical default recovery is image-prerequisite/review.py and
review_population.py under docs/checkpoints/ram-host-size-preflight-2026-11-12/.
The primary source/guard evidence remains separate. This admits exact source
identities and historical integrity; current runtime/objective/feature admission
does not follow. Later CI edits require a reviewed exact stage before these
earlier inverses, preserving all old tables and denials.
'''
buffers[BOOK]+='''

### Later source images and exact CI inverses

Historical objective recovery checks source identities separately from fresh
runtime results. A later accepted runtime image needs a closed successor entry:
retain the original image and intermediate committed predecessor, then bind the
latest path, commit, regular mode and full digest. Keep the original Phase0
activation and calibration. Nested reports must identify the effective latest
image while exposing the intermediate lineage.

An owned CI change can instead have an exact source inverse. The RAM preflight
stage restores its two reviewed hunks to committed b370 bytes before exercising
every older CI falsifier. Current candidate bytes are distinct from a committed
historical image. Missing registration, unrelated edits and changed support
inputs reject; old tables, recovered logs and runtime observations stay intact.

```sh
bash tools/run_python_project_data.sh tools/test_historical_objective_images.py
bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py
```

The first command checks source-admission/inverse mechanics. The second performs
actual isolated historical recovery under original-log/tracked-write denial.
Neither reruns the historical runtime objectives or promotes feature coverage.
Source/data integrity, current runtime proof and the exact canonical receipt
remain separate. New CI stages must preserve the earlier inverses and controls.
'''

def record(name,text):
    heading='## 2026-11-12 — '+OWNER+':'
    at=buffers[name].index(heading);end=buffers[name].find('\n## ',at+1)
    end=len(buffers[name]) if end<0 else end+1
    buffers[name]=buffers[name][:at]+text+'\n\n'+buffers[name][end:]


record('CHANGES.md',f'''## 2026-11-12 — {OWNER}: RAM and historical CI admission

RAM guard and canonical CI share actual-capacity/single-snapshot arithmetic with clear unknown-data refusal. Original wrong-admission RED, source-bound controls/native arithmetic and independent recovery pass. Current trend guidance and exact storage registrations align. First canonical1 passes all10 doctrines but refuses later source images; retain the failed267-file candidate. Complete149-source inventory isolates four b370 runtime successors and the RAM CI change. A closed nested successor layer preserves all prior images/Phase0; corrected reports expose latest and intermediate identities. A two-hunk inverse restores the committed CI precursor before every earlier falsifier. Actual isolated recovery0 preserves134 inputs/every old control field/714 governance mutations, with existing Phase0-value12 and new RAM9 controls;210 declared/199 observed bodies are retained before use. Independent evidence/membership controls pass; no runtime SDK body or old claim observation changes. Canonical staged receipt remains mandatory. Fresh pack then raw-error4.28 before final discovery4.1/clean publication around1.5GB. Evidence: {BASE}/REVIEW.md.''')
record('DEVELOPMENT_NOTES.md',f'''## 2026-11-12 — {OWNER}: original stages survive newer sources

Denied sysctl cannot justify a16GiB capacity constant; shared snapshot admission is separate from the director's live90-percent trend rule. Its canonical gate also exposes the expected strict source-image boundary. Inventory all149 historical sources before admission: four accepted later runtime images are distinct from the uncommitted RAM CI candidate. Nested successor verification already checks latest bytes, but report() formerly read raw intermediate rows/data; actual RED/qualified GREEN and preserved nested lineage fix that report. Keep original tables and Phase0 activation. The exact CI inverse restores b370 before every older governance control, with new RAM source/support denials separate. Source-bound actual isolated recovery and independent reports retain every old field and direct input; native closure remains4.2/SESSION5. Do raw-field coverage4.28 before final discovery4.1 so its new consumers enter one final canonical publication boundary. Evidence: {BASE}/REVIEW.md.''')

start=buffers[PART].index('- ID: `'+OWNER+'`');end=buffers[PART].find('\n- ID:',start+1)
end=len(buffers[PART]) if end<0 else end
node=buffers[PART][start:end]
node=node.replace('  Status: `active` / RAM repair focused-verified; mandatory canonical prerequisite owned',
                  '  Status: `completed` / RAM/source-stage prerequisites focused-verified; exact canonical receipt governs landing',1)
node+='''
  Historical prerequisite outcome: Complete actual intake149/19 isolates four acceptedb370 runtime images and the RAM CI change; all other executable paths retain their registered inverses. No live prospective helper/auditor/table/card bindings. Nested-report original RED1/final unit0; new reports retain effective b370 and intermediate728 lineage. Original three image tables and protected Phase0 bytes remain exact. Current and prior19 source denials both pass. Two exact RAM CI hunks restore committedb370; old pure governance predicate is byte-exact apart from its name, and all714 original controls run at that precursor. New RAM CI nine controls remain separate. Actual isolated consumer0/empty stderr has210 declared/199 observed bodies inside213 before-use sources; every old recovery/control field matches. Independent historical review0/six corruptions and exact-population review0/three controls pass. Existing Phase0-value12 predicate is unchanged; no runtime SDK body, old observation/hash or broad feature admission changes. First full canonical1 has no receipt credit; complete new staged canonical is still required.
  Handoff order: After clean commit and fresh size, do focused raw-error4.28 before final current discovery4.1 so its added consumers can share the final canonical publication boundary. Both remain required before push; no owner is waived. Image-prerequisite/review.py and review_population.py are historical defaults; all old capture/publish/seal writers remain one-shot. Prior check_candidate.py is the first-attempt point-in-time check, not the new candidate check.
'''
buffers[PART]=buffers[PART][:start]+node+buffers[PART][end:]
root='docs/tasks/TYPE-REFERENCE-BOOK.md'
old=next(line for line in buffers[root].splitlines() if line.startswith('| 1 |'))
buffers[root]=buffers[root].replace(old,'| 1 | `TYPE-REFERENCE-BOOK.1.2.23.4.28` | `pending` | Fresh size, then raw-field coverage before final current discovery4.1 and clean canonical publication. |',1)
old='resource14 shares validated capacity/single-snapshot producer with focused/native/historical proof and canonical receipt required; fresh size then discovery4.1/raw-error4.28 before push;'
assert buffers[root].count(old)==1
buffers[root]=buffers[root].replace(old,'resource14 shares validated RAM preflight and exact historical source/CI stages with focused/native/recovery proof; canonical receipt required; fresh size then raw-error4.28/final discovery4.1 before push;',1)
frontier=f'November12 current fluent frontier: All five bounded concat80 outcomes remain focused. Resource14 shares validated actual-capacity/single-snapshot RAM admission and current trend guidance. First canonical1 passes all10 doctrines, then strict historical recovery refuses later images. Complete149-source/19-image intake, four acceptedb370 successors, nested-report RED/GREEN and exact two-hunk RAM CI inverse preserve original tables/Phase0/every old recovery-control field. Actual isolated recovery0 has210 declared/199 observed inputs within213 before-use bodies, retaining714 old governance plus existingPhase012/newRAM9 controls; independent evidence/population corruptions pass. No runtime SDK body or old claim observation changes; native4.2/SESSION5 and broad feature admission stay separate. Complete staged canonical receipt still governs landing. Latest b370/cached origin4683555e pack is1,376,459,879 bytes/107 ahead, excluding14. Fresh size then raw-error4.28 before final discovery4.1 and clean canonical publication around1.5GB regardless cadence. Evidence: {BASE}/REVIEW.md.'
for name in ('ROADMAP.md','ROADMAP_V2.md'):
    old=next(line for line in buffers[name].splitlines() if line.startswith('November12 current fluent frontier:'))
    buffers[name]=buffers[name].replace(old,frontier,1)
live='LIVE_ACHIEVEMENT_STATUS.md'
for heading,text in (
    ('Current Activity','Full PNT continues. Resource14 has focused RAM and historical-source prerequisite proof; exact staged canonical admission governs landing. Fresh size, raw-error4.28 then final discovery4.1/publication; wider source/context/admission remains.'),
    ('Latest Completed Slice',OWNER+'. Shared actual RAM capacity/single snapshot; original RED/source-bound/native recovery, exact CI-claim preservation and trend docs. First canonical1 remains nonpassing; four accepted runtime successors/nested report/exact RAM CI inverse now pass isolated recovery with all old controls preserved. New full canonical receipt is required.'),
    ('Next Action','Remeasure committed outgoing bytes, then focused raw-error4.28 before final current discovery4.1. Publish around1,500,000,000 bytes regardless cadence with clean exact-HEAD canonical proof/normal hooks/fresh remote identity; prepare near1.4GB or earlier for growth.'),
):
    buffers[live],count=re.subn(r'(## '+re.escape(heading)+r'\n\n).*?(?=\n## )',lambda m:m[1]+text+'\n',buffers[live],flags=re.S)
    assert count==1
rows=buffers[live].splitlines();selected=[i for i,line in enumerate(rows) if line.startswith('- '+OWNER+' ')]
assert len(selected)==1
rows[selected[0]]='- '+OWNER+' — shared RAM snapshot/actual capacity; first canonical1 retained;149-source/four-successor/exact RAM CI inverse and isolated recovery preserve all old fields/714 controls; new canonical required, fresh size then raw28/final discovery.'
buffers[live]='\n'.join(rows)+'\n'
buffers['MEMORY.md']=f'''# MEMORY

- activation_commit: `{ACTIVATION}` — clean resource14 activation; derive current HEAD from Git.
- latest_completed_leaf: `{OWNER}` — RAM preflight and bounded historical-source canonical prerequisites.
- active_work_unit: `{OWNER}` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.
- run_state: full PNT, no fixed batch count; no pause requested.
- session_health: Long context; recover from committed source pointers before larger raw-field/current-discovery work.
- next_action: Remeasure current committed outgoing bytes with docs/checkpoints/publication-size-monitor-2026-11-12/measure.py, then focused raw-error4.28 before final current canonical discovery4.1. Include its new consumers in that final receipt. Clean canonical publication30.2 preempts cadence near1.4-1.5GB or before large growth; no before-push owner is waived.
- in_flight_uncommitted: none; resource14 code/proof/docs committed; no required background job.
- evidence: {PRIMARY}/REVIEW.md and {BASE}/REVIEW.md. Primary RAM source-bound/native/historical-eight controls pass; original first-use limitation/publication predicate1 remain qualified. New149-source/19-image inventory isolates four acceptedb370 successors and owned CI inverse. Source-bound isolated recovery0 preserves134 inputs/every old control field/714 governance controls, with existingPhase012/newRAM9;210 declared/199 observed bodies within213 before-use inputs. Independent historical six/population three corruptions pass; no fresh runtime/feature admission.
- source_stages: Original three image tables/protected Phase0/old governance predicate and runtime SDK bodies remain exact. Nested reports identify effective latest and retain intermediate lineage; actual old report1/final unit0. RAM CI two-hunk inverse restores committedb370 before older falsifiers. New checked observations keep native4.2/SESSION5 gaps explicit. Default historical image review.py/review_population.py execute no producer; capture/prepare/publish/seal writers are one-shot. Old check_candidate.py is the first-attempt point only.
- canonical_boundary: First approved-host6889 exits1 on unreviewed Dart after all10 doctrines; no receipt credit. The complete repaired staged candidate requires fresh canonical receipt and normal hooks before landing; the actual receipt/log establishes admission. This is separate from full23.4/current discovery4.1/raw-error4.28/declared5.4/formatter/source/context/native/historical4.24/launcher/SESSION7/literal/excluded/shadowing32 owners.
- publication: Director1,500,000,000-byte trigger overrides cadence; advisory1,400,000,000. Actual b370/cached origin4683555e monitor0 is1,376,459,879 bytes/107 ahead/47,042 objects/123,540,121 trigger margin, excluding14. Metadata/source/channels in primary push-monitor-current/; raw pack ignored/protected. Current-independent30/native4.2 gaps remain. No remote freshness/wire/future-size guarantee; fresh remote/exact-HEAD canonical/normal hooks/clean tree precede push.
- locality: Same-volume/serial intensive jobs/shared24GiB/current90-percent trend policy; only this repository writable, submodules black boxes. Latest cleanup2026-11-12T15:32:21.895461+00:00 remains current. No native PID/PGID inference from denied pgrep.
'''
buffers['git_message_brief.txt']=f'''{OWNER} - repair RAM and preserve historical CI stages

Share validated actual RAM capacity and one snapshot across guard and CI.
Preserve the accepted live claim, later committed source lineage, original
Phase0 and every earlier historical falsifier through exact new stages.
Retain original failures and complete direct-source recovery evidence;
require the fresh exact canonical receipt before landing.
'''
buffers[str(PRIMARY/'REVIEW.md')]+='''

The first mandatory canonical attempt exits1 after all10 doctrines, at the
existing historical current-image boundary. The bounded prerequisite and its
actual source-only recovery are in image-prerequisite/REVIEW.md. Its historical
review.py and review_population.py are additional defaults. Original image
tables/Phase0/runtime bodies and every prior control field survive. The original
primary check_candidate.py is an earlier point-in-time observation; the final
candidate has its own check. First canonical1 is retained without receipt credit;
complete repaired staged canonical CI and normal hooks still govern landing.
'''
buffers[str(PRIMARY/'LANDING.md')]+='''

The first canonical attempt stops1 on the later Dart image after all10 doctrines.
Its complete candidate/log are retained. The new bounded image/CI prerequisite
passes unit, source/current/prior-image, exact inverse, isolated recovery and
independent evidence/population checks. Original714 governance controls and all
other old fields remain; existing Phase0-value12/newRAM9 stay separate. New full
canonical receipt is required after final restaging; first-attempt pass/identity
checks are not represented as a receipt for this repaired candidate.
'''
for name,text in buffers.items():
    Path(name).write_text(text)
freeze('outputs-after-use',documents+[OUT/'prior-resource-claim.json.gz'])
print(json.dumps(dict(publication='PASS',original_two_resource_claims_unchanged=True,
    new_source_claim=claim['claims'][-1]['name'],next='Fresh size, raw-error4.28, final discovery4.1, clean canonical publication')))
