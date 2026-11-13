"""Prepare the intended clean resource handoff; canonical receipt gates landing."""
import hashlib
import json
from pathlib import Path
import re
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'handoff'
OUT.mkdir()
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.14'
ACTIVATION = 'b370de8d31e3f38da6abf8ed4702a523aa3d6d97'
documents = ['CHANGES.md', 'DEVELOPMENT_NOTES.md', 'MEMORY.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'ROADMAP.md', 'ROADMAP_V2.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md',
    'git_message_brief.txt']
reports = [BASE / 'proofs/historical-review/stdout.gz', BASE / 'proofs/historical-review/exit.txt',
           BASE / 'push-monitor-current/result.json', BASE / 'claim-preservation/result.json']


def freeze(name, paths):
    rows = {}
    with tarfile.open(OUT / (name + '.tar.gz'), 'x:gz') as archive:
        for path in paths:
            path = Path(path)
            raw = path.read_bytes()
            rows[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=str(path), recursive=False)
    with tarfile.open(OUT / (name + '.tar.gz')) as archive:
        assert set(archive.getnames()) == rows.keys()
        for member in archive:
            raw = archive.extractfile(member).read()
            assert hashlib.sha256(raw).hexdigest() == rows[member.name]['sha256']
            assert member.mode & 0o777 == rows[member.name]['mode']
    (OUT / (name + '.json')).write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')


freeze('inputs-before-use', documents + reports + [Path(__file__).relative_to(ROOT)])
assert reports[1].read_text().strip() == '0'
pack = json.loads(reports[2].read_bytes())
buffers = {name: Path(name).read_text() for name in documents}
record = f'''## 2026-11-12 — {OWNER}: actual RAM capacity and one snapshot

RAM guard and canonical CI share tools/host_ram_usage.sh: validated sysctl capacity or actual memory_pressure fallback, one Darwin VM snapshot with its own page size, validated Linux snapshot, and clear refusal without invented capacity. Original denied native query and old-wrapper RED retain25-percent/admitted child/three VM reads for the known24GiB/12GiB-available fixture. Source-bound deterministic/native controls and independent historical recovery/eight corruptions pass. First repaired controls remain separately qualified without original before-use source custody; the test now allocates in verified managed scratch and has exact storage registrations. One live CI claim is preserved at b370 by mode/revision only; all original input hashes/other fields/claims stay exact. Current trend policy/book are aligned. Canonical admission for the exact staged candidate is required by normal hooks; focused proof is not full feature admission. Local b370/cached-origin outgoing estimate is1,376,459,879 bytes/107 commits, excluding this slice; independent-current30/native4.2 gaps remain. Fresh size/current discovery4.1/raw-error4.28 precede clean canonical publication around1.5GB. Evidence: {BASE}/REVIEW.md.

'''
notes = f'''## 2026-11-12 — {OWNER}: capacity and monitoring are separate

Denied sysctl cannot justify a16GiB constant on the director24GiB host. Both old direct producers combined three VM responses; a shared validated capacity/single-snapshot producer removes drift. The estimate counts free/inactive/speculative availability and rounds used upward; it differs from memory_pressure's free indicator and supplies no peak/trend safety guarantee. Conservative configurable88-percent admission is separate from the current director rule: intervene in our jobs when host usage exceeds90 and continues rising, resume with stable sufficient headroom, never stop other projects. Exact212-record pre-edit query correctly blocks the one live CI binding; preservation verifies every original input and changes only mode/revision. Keep its original refusal. Initial repaired controls0 have late direct-source retention only; the subsequent source-bound epoch and native recorder carry their own before-use evidence. Defaults recover historical proof without rerunning producers; canonical receipt is a separate landing requirement. Evidence: {BASE}/REVIEW.md.

'''
for name, text in [('CHANGES.md', record), ('DEVELOPMENT_NOTES.md', notes)]:
    at = buffers[name].index('\n## ') + 1
    buffers[name] = buffers[name][:at] + text + buffers[name][at:]
part = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
start = buffers[part].index('- ID: `' + OWNER + '`')
end = buffers[part].find('\n- ID:', start + 1)
end = len(buffers[part]) if end < 0 else end
node = buffers[part][start:end]
node = node.replace('  Status: `active` / P1 resource-control repair before memory-guarded full verification',
                    '  Status: `completed` / focused resource repair; exact canonical receipt required for landing', 1)
at = node.index('  Acceptance Checklist\n')
node = node[:at] + f'''  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Retained actual native sysctl1 and old-wrapper deterministic RED1: wrong25-percent/admitted child/three VM snapshots.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Original tools/ram_guard.sh39 and tools/run_ci_local.sh1325 used17179869184 fallback and separate VM queries; exact original sources remain in before/.
  - [x] **FIX** — Shared tools/host_ram_usage.sh validates real capacity and one snapshot, refuses unavailable data and preserves admitted child exit/77 skip behavior; canonical CI uses the same producer.
  - [x] **ADDRESSED (verified)** — Source-bound finite controls0, actual native recorder0/independent arithmetic, historical review0/eight corruptions; full staged canonical receipt is mandatory before normal commit can land.
  - [x] **NO REGRESSION** — Success/fallback/invalid snapshot/rounding/Linux-simulated/child-exit controls pass; exact storage inventories and bash syntax/locality are selected, git diff --check and normal doctrines govern landing.
  - [x] **LOCKSTEP** — Current RAM cards/book, task/index, roadmaps/live/pointer and bounded histories carry the same qualified behavior; canonical and feature-admission boundaries stay distinct.
  Outcome: {BASE}/REVIEW.md. Default review.py is historical. preserve_ci_claim.py default reviews original mode/revision-only preservation; current tool/candidate identities are separate point-in-time checks. Never replay one-shot capture/publish/seal producers.
  Verification boundary: Focused implementation proof is complete. This infrastructure commit requires the exact staged canonical receipt; the actual receipt/log, not this intended handoff text, establishes that gate. Current discovery4.1/raw-error4.28/declared5.4/formatter/full23.4 admission remain independent before-push owners. Fresh size then current discovery; the1.5GB trigger overrides cadence.
'''
buffers[part] = buffers[part][:start] + node + buffers[part][end:]
root = 'docs/tasks/TYPE-REFERENCE-BOOK.md'
old = next(line for line in buffers[root].splitlines() if line.startswith('| 1 |'))
buffers[root] = buffers[root].replace(old, '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.4.1` | `pending` | Fresh size, then current canonical discovery and raw-error4.28 before clean publication. |', 1)
old = 'fresh size then resource4.14/discovery4.1/raw-error4.28 before push;'
assert buffers[root].count(old) == 1
buffers[root] = buffers[root].replace(old, 'resource14 shares validated capacity/single-snapshot producer with focused/native/historical proof and canonical receipt required; fresh size then discovery4.1/raw-error4.28 before push;', 1)
frontier = f'November12 current fluent frontier: All five bounded concat80 implementations have focused outcomes. Headroom32 is committed at b370 with all10/post-pointer/brief0/clean. Resource14 repairs both RAM preflights through shared validated capacity/single-snapshot arithmetic, source-bound controls, actual native recorder and historical recovery/eight corruptions. Original wrong-admission RED and first-run custody qualification remain; one live CI claim is preserved by mode/revision only. Current RAM cards/book distinguish admission from live host-wide trend policy. Exact staged canonical receipt is required for this infrastructure landing; full feature admission remains separate. Local b370/cached origin4683555e outgoing estimate is1,376,459,879 bytes/107 commits/123,540,121-byte1.5GB margin, excluding14; current-falsification/native gaps30/4.2 remain. Fresh size then current discovery4.1/raw-error4.28 before admission AND push; clean exact-HEAD canonical publication preempts cadence near1.4-1.5GB. Evidence: {BASE}/REVIEW.md.'
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    old = next(line for line in buffers[name].splitlines() if line.startswith('November12 current fluent frontier:'))
    buffers[name] = buffers[name].replace(old, frontier, 1)
live = 'LIVE_ACHIEVEMENT_STATUS.md'
for heading, text in (
    ('Current Activity', 'Full PNT continues. Resource14 has focused/native/historical proof and requires canonical staged admission for landing. Fresh size then current discovery4.1/raw-error4.28 and publication preparation; broader source/context/admission remains.'),
    ('Latest Completed Slice', OWNER + '. Both RAM preflights share actual capacity and one validated snapshot. Original wrong-admission RED, source-bound controls/native arithmetic/historical recovery-eight controls pass. One live CI claim mode/revision-only preservation and current RAM docs are retained; canonical receipt governs landing.'),
    ('Next Action', 'Remeasure current committed outgoing bytes, then current canonical discovery4.1 and before-push raw-error4.28. Prepare near1.4GB and publish around1,500,000,000 bytes regardless cadence, with exact clean-HEAD canonical proof/normal hooks/fresh remote identity.'),
):
    buffers[live], count = re.subn(r'(## ' + re.escape(heading) + r'\n\n).*?(?=\n## )',
                                  lambda match: match[1] + text + '\n', buffers[live], flags=re.S)
    assert count == 1
start = buffers[live].index('## Recent Completions\n\n') + len('## Recent Completions\n\n')
end = buffers[live].index('\n## History', start)
recent = [line for line in buffers[live][start:end].splitlines() if line.startswith('- ')]
assert len(recent) == 16
(OUT / 'rotated-live-row.txt').write_text(recent[-1] + '\n')
row = '- ' + OWNER + ' — shared actual capacity/single VM snapshot; old wrong-admission RED/source-bound controls/native arithmetic/readonly eight controls; exact CI-claim preservation/current trend docs; canonical receipt required, fresh size then discovery.'
buffers[live] = buffers[live][:start] + '\n'.join([row] + recent[:15]) + '\n\n' + buffers[live][end:]
buffers['MEMORY.md'] = f'''# MEMORY

- activation_commit: `{ACTIVATION}` — clean resource14 activation; derive current HEAD from Git.
- latest_completed_leaf: `{OWNER}` — shared actual-capacity/single-snapshot RAM preflight repair.
- active_work_unit: `{OWNER}` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.
- run_state: full PNT, no fixed batch count; no pause requested.
- session_health: Long context; use targeted committed recovery before current CI-discovery work.
- next_action: Remeasure current committed outgoing bytes with docs/checkpoints/publication-size-monitor-2026-11-12/measure.py, then current canonical discovery4.1 and before-push raw-error4.28. Canonical publication30.2 preempts cadence near1.4-1.5GB or before large growth. Never replay completed capture/publish/seal writers.
- in_flight_uncommitted: none; resource14 implementation/proof/docs committed; no required background job.
- evidence: {BASE}/REVIEW.md; source-bound deterministic controls0, actual native recorder0/independent arithmetic and historical review0/eight corruptions. Original denied native query and wrong-admission RED1 remain distinct. First repaired controls0 have no original before-use direct-source custody credit; new qualified epoch captures actual sources before use. Default review.py is historical; current identity is point-in-time.
- shared_docs: Original212-record query correctly refused one live CI binding; preserve_ci_claim.py changes only that claim mode/revision at b370, verifies every original input and rejects six faults. Original hashes/other fields/claims remain exact. Additional storage binding query has no remaining live intersection after that qualification; exact new test entrypoint/temporary owner is registered. RAM cards/book carry current trend policy.
- publication: Director1,500,000,000-byte trigger overrides cadence; advisory preparation1,400,000,000. Actual b370/cached origin4683555e monitor0 is1,376,459,879 bytes/107 ahead/47,042 objects/123,540,121-byte trigger margin/23,540,121-byte advisory margin, excluding14. Metadata/source/channels under this checkpoint push-monitor-current/; raw pack ignored/protected. Claim14 discloses current-independent30/native4.2 gaps. No remote freshness/wire/future-size guarantee. Exact clean-HEAD canonical/current discovery4.1/raw-error4.28/normal hooks/fresh remote precede push; no push yet.
- verification_policy: This infrastructure leaf requires exact staged canonical admission enforced by normal hooks; the actual receipt/log establishes that gate. Full feature admission23.4/current discovery4.1/raw-error4.28/native4.2/SESSION5/source/context/historical4.24/launcher/SESSION7/literal/excluded/shadowing32/declared5.4/formatter remain separate. All five bounded concat80 implementations have focused outcomes.
- locality: Same-volume/serial intensive jobs/shared24GiB/current90-percent trend policy; only this repository writable, submodules black boxes. Latest cleanup2026-11-12T15:32:21.895461+00:00 remains current. No native PID/PGID inference from denied pgrep.
'''
buffers['git_message_brief.txt'] = f'''{OWNER} - validate actual host RAM capacity

Share one validated RAM snapshot producer across command guard and canonical CI.
Retain original wrong-admission RED, source-bound controls and native arithmetic.
Preserve the accepted live CI claim by mode/revision only, align trend guidance,
and require canonical staged admission before landing this infrastructure slice.
'''
for name, text in buffers.items():
    Path(name).write_text(text)
freeze('outputs-after-use', documents + [OUT / 'rotated-live-row.txt'])
print('Intended resource handoff prepared; exact canonical receipt remains required')
