"""Prepare this owned epoch once, preserving its original document/templates."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION = 'b370de8d31e3f38da6abf8ed4702a523aa3d6d97'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
OUT = BASE / 'activation'
OUT.mkdir()
TEMPLATE = Path('docs/checkpoints/task-headroom-rooting-2026-11-12')
names = ['check_publication_inputs.py', 'review_publication_inputs.py', 'run_stage.py']
paths = [TEMPLATE / name for name in names]
paths += [Path('MEMORY.md'), Path(__file__).relative_to(ROOT), BASE / 'PLAN.md',
          Path('tools/ram_guard.sh'), Path('tools/run_ci_local.sh')]
identities = {}
with tarfile.open(OUT / 'inputs-before-use.tar.gz', 'x:gz') as archive:
    for path in paths:
        raw = path.read_bytes()
        identities[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'inputs-before-use.tar.gz') as archive:
    assert set(archive.getnames()) == identities.keys()
    for member in archive:
        raw = archive.extractfile(member).read()
        assert hashlib.sha256(raw).hexdigest() == identities[member.name]['sha256']
        assert member.mode & 0o777 == identities[member.name]['mode']
(OUT / 'input-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
targets = ['tools/ram_guard.sh', 'tools/run_ci_local.sh', 'tools/host_ram_usage.sh', 'tools/test_ram_guard.py',
           'docs/knowledge/restricted-macos-ram-host-size-fallback.md',
           'docs/knowledge/canonical-ci-ram-fallback-prerequisite.md', 'docs/knowledge/shared-host-ram-budget.md',
           'docs/linkedspec-book/src/development/documentation-workflow.md',
           'docs/tasks/TYPE-REFERENCE-BOOK.overview.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md',
           'ROADMAP.md', 'ROADMAP_V2.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md',
           'LIVE_ACHIEVEMENT_STATUS.md', 'MEMORY.md']
for name in names:
    raw = (TEMPLATE / name).read_text()
    if name == 'check_publication_inputs.py':
        raw = raw.replace('9f11029e5af9d6168925f532d4c1911637421af3', ACTIVATION)
        lines = raw.splitlines()
        original = next(line for line in lines if line.startswith('targets = '))
        raw = raw.replace(original, 'targets = ' + repr(targets))
        raw = raw.replace('new headroom operational record', 'new resource operational record')
    (BASE / name).write_text(raw)
Path('MEMORY.md').write_text('''# MEMORY

- activation_commit: `b370de8d31e3f38da6abf8ed4702a523aa3d6d97` — clean resource14 activation; derive current HEAD from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.23.4.32` — rooting narrative headroom; all10/post-pointer/brief0/clean verified.
- active_work_unit: `TYPE-REFERENCE-BOOK.1.2.23.4.14`; task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.
- run_state: full PNT, no fixed batch count; no pause requested.
- session_health: Long context; preserve qualified producers/results and use targeted recovery before larger CI changes.
- next_action: Retain original RAM producers/OS channels and distinguishing denial RED, then repair both preflights with one validated snapshot, focused controls and exact staged canonical admission. Current discovery4.1/raw-error4.28 remain required before push.
- in_flight_uncommitted: resource14 activation; implementation/proof/docs and canonical receipt remain to finish. Headroom32 and its failed terse attempt are committed; never replay their writers.
- evidence: docs/checkpoints/ram-host-size-preflight-2026-11-12/PLAN.md; original RAM observations remain dated in the two prerequisite cards. Headroom32 historical recovery remains under its original checkpoint.
- publication: Director1,500,000,000-byte trigger overrides cadence; advisory preparation1,400,000,000. Fresh b370 measurement is retained under .linkedspec-data/push-monitor/20261112T194221.101324Z; preserve metadata/source/channels here before publishing measured values. Raw pack stays ignored/protected. No remote freshness/wire/future-size guarantee. Exact clean-HEAD canonical/current discovery4.1/raw-error4.28/normal hooks/fresh remote precede push.
- continuity: All five bounded concat80 backends have focused outcomes; full23.4/native4.2/SESSION5/source/context/historical4.24/launcher4.22/SESSION7/literal/excluded/shadowing32/declared5.4/formatter remain owned. Lua80.5 historical default is review_qualified.py; original standalone reader expects retired plain oracle.
- verification_policy: This infrastructure leaf is canonical. Same-volume/serial intensive jobs/shared24GiB/current90-percent trend policy; only this repository writable, submodules black boxes. Latest cleanup2026-11-12T15:32:21.895461+00:00 remains current. No native PID/PGID inference from denied pgrep.
''')
print(json.dumps(dict(prepared=str(BASE), activation=ACTIVATION, source_inputs=len(identities))))
