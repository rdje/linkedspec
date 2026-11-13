"""Publish the bounded resource repair and measured observations once."""
import gzip
import hashlib
import json
from pathlib import Path
import shutil
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'publication'
OUT.mkdir()
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.14'
cards = [Path('docs/knowledge') / name for name in (
    'restricted-macos-ram-host-size-fallback.md', 'canonical-ci-ram-fallback-prerequisite.md', 'shared-host-ram-budget.md')]
book = Path('docs/linkedspec-book/src/development/documentation-workflow.md')
monitor = Path('.linkedspec-data/push-monitor/20261112T194221.101324Z')
inputs = cards + [book, BASE / 'native-usage/result.json', BASE / 'sealed-identities.json',
    BASE / 'proofs/historical-review/stdout.gz', BASE / 'proofs/historical-review/exit.txt',
    Path('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.32.json'), Path(__file__).relative_to(ROOT)]
inputs += [path for path in monitor.iterdir() if path.is_file() and path.suffix not in ('.pack', '.idx')]


def freeze(name, paths):
    rows = {}
    with tarfile.open(OUT / (name + '.tar.gz'), 'x:gz') as archive:
        for path in sorted(set(paths)):
            raw = path.read_bytes()
            assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
            rows[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=str(path), recursive=False)
    with tarfile.open(OUT / (name + '.tar.gz')) as archive:
        assert set(archive.getnames()) == rows.keys()
        for member in archive:
            raw = archive.extractfile(member).read()
            assert hashlib.sha256(raw).hexdigest() == rows[member.name]['sha256']
            assert member.mode & 0o777 == rows[member.name]['mode']
    (OUT / (name + '.json')).write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')


freeze('inputs-before-use', inputs)
assert (BASE / 'proofs/historical-review/exit.txt').read_text().strip() == '0'
actual = json.loads((BASE / 'native-usage/result.json').read_bytes())
pack = json.loads((monitor / 'result.json').read_bytes())
retained = BASE / 'push-monitor-current'
retained.mkdir()
for path in monitor.iterdir():
    if path.is_file() and path.suffix not in ('.pack', '.idx'):
        shutil.copy2(path, retained / path.name)
        assert path.read_bytes() == (retained / path.name).read_bytes()
        assert path.stat().st_mode & 0o777 == (retained / path.name).stat().st_mode & 0o777

budget = cards[2]
budget.write_text('''---
id: shared-host-ram-budget
title: Shared host RAM uses snapshot admission and director trend monitoring
answers:
  - "how much RAM is available on the shared macOS host"
  - "are the86 and90 percent memory limits per process or host wide"
  - "when must an agent request a quiet time window"
  - "may an agent stop another project's jobs for RAM"
  - "does tools ram_guard monitor memory during a running job"
  - "why should RAM guard admission use danger pct86"
  - "how do RAM guard and canonical CI acquire host capacity"
date: 2026-11-12
status: current director trend policy; resource14 focused repair with canonical admission required
tags: [host, memory, ram, resources, locality, operations]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.4.14; retained original/native/source-bound controls and historical recovery in docs/checkpoints/ram-host-size-preflight-2026-11-12/. The prior November5 hard86/90 card is retained at b370de8d3 and in the before-edit proof capsules."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/ram-host-size-preflight-2026-11-12/review.py"
  - "bash tools/run_python_project_data.sh tools/test_ram_guard.py"
---

The director identifies this macOS host as24GB shared across projects and agents.
Thresholds concern total host usage. Before intensive work, check enough headroom
for the expected peak, use conservative workers/batches and run at most one
intensive job of our own. Observe the trend while it runs. If usage exceeds90%
and keeps increasing, tell the director and reduce or stop our driving jobs.
Otherwise, stable high80s alone do not require intervention. After a pressure
stop, resume only with stable sufficient headroom, aiming for80% or less and
using lower concurrency or smaller batches. Never stop another project's jobs.
If other projects keep usage above90%, defer our intensive work and report why.

Request a quiet window when the job needs unavailable headroom or background
activity could skew a measurement. State purpose, proposed start/duration and
required free memory or background limit; wait for confirmation, verify readiness
and announce when the window is no longer needed. Adequate headroom does not
require an unsolicited quiet-window pause.

tools/host_ram_usage.sh supplies the shared snapshot producer. On Darwin it uses
positive sysctl capacity, falling back to actual memory_pressure -Q capacity when
the first query fails or is invalid. It parses page size and free/inactive/
speculative pages from one vm_stat response. On Linux it uses one /proc/meminfo
response. Missing/invalid capacity or snapshots fail clearly. The upward-rounded
used estimate is100 minus the available-byte percentage rounded down; it is not
memory_pressure's free indicator, a peak bound or continuous trend monitoring.

tools/ram_guard.sh and canonical CI use that same producer. Their configurable88%
default is conservative job admission, not the superseded director86% global
rule. The wrapper refuses unknown usage or a reached threshold with77, preserves
the admitted child's exit code and attempts a virtual-memory ceiling; it does not
guarantee an RSS ceiling or monitor the child. The agent remains responsible for
current headroom and live host trends. Keep project logs and scratch in managed
repository storage. Historical November5 measurements and evidence stay unchanged.
''')

for path in cards[:2]:
    text = path.read_text()
    text = text.replace('status: source defect owned P1 by TYPE-REFERENCE-BOOK.1.2.23.4.14; product work uses independent monitoring',
                        'status: dated defect repaired under TYPE-REFERENCE-BOOK.1.2.23.4.14; focused proof passes, canonical admission required')
    text = text.replace('status: source-policy prerequisite owned by TYPE-REFERENCE-BOOK.1.2.23.4.14; no infrastructure change here',
                        'status: both preflight producers repaired under TYPE-REFERENCE-BOOK.1.2.23.4.14; canonical admission required')
    header, body = text.split('---\n', 2)[1:]
    path.write_text('---\n' + header + '---\n\nCurrent repair, November12: both RAM guard and canonical CI share the validated\n'
        'tools/host_ram_usage.sh producer. The original denied query, wrong admission\n'
        'and three-snapshot mechanism remain retained. Source-bound deterministic and\n'
        'actual native single-snapshot arithmetic controls pass; default historical\n'
        'recovery is docs/checkpoints/ram-host-size-preflight-2026-11-12/review.py.\n'
        'Canonical staged admission is required for this infrastructure landing.\n'
        'Use [[shared-host-ram-budget]] for current trend policy; the following dated\n'
        'diagnosis describes the original source, not the repaired current code.\n\n'
        '## Original diagnosis (historical)\n' + body)

text = book.read_text()
assert '### Host RAM admission and trend monitoring' not in text
book.write_text(text + '''

### Host RAM admission and trend monitoring

RAM guard and canonical CI share tools/host_ram_usage.sh. On macOS, a denied or
invalid sysctl query falls back to actual capacity from memory_pressure -Q.
Page size and available free/inactive/speculative pages come from one vm_stat
response. Linux uses one /proc/meminfo response. Missing or invalid data refuses
admission rather than substituting an invented host size.

```sh
bash tools/host_ram_usage.sh
bash tools/ram_guard.sh --ceiling-mb 4096 --danger-pct 88 -- bash tools/run_python_project_data.sh tools/test_ram_guard.py
```

The first command prints the upward-rounded availability-based used percentage.
The wrapper's configured threshold defaults to88%; it exits77 without starting
the child when usage is unknown or reaches that threshold, otherwise preserves
the child's exit code. Its attempted virtual-memory ceiling is not an RSS bound.
Canonical CI runs the capacity/arithmetic/admission controls before its heavy
suite and uses the same producer with LINKEDSPEC_TEST_DANGER_PCT.

These are snapshot admission checks. Check headroom for the expected peak, use
conservative concurrency and run at most one intensive job of our own. Observe
host-wide trends while it runs. If usage exceeds90% and keeps increasing, tell
the director and reduce or stop our driving jobs; stable high80s alone do not
require intervention. After a pressure stop, aim for stable80% or less before
resuming with lower concurrency or smaller batches. Never stop another project's
jobs. If other projects keep usage above90%, defer our intensive work.

Request a confirmed quiet window only when required headroom is unavailable or
background activity could skew a measurement. State purpose, proposed start and
duration, and required free memory/background limit; verify readiness and announce
when the window ends. Keep all monitoring data in managed repository storage.
The current operating authority is docs/knowledge/shared-host-ram-budget.md.
''')

claim = json.loads(Path('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.32.json').read_bytes())
claim['owner'] = OWNER
operational = claim['claims'][0]
operational['statement'] = (f"At committed HEAD{pack['head']} excluding cached origin/main{pack['cached_origin_main']}, "
    f"the one-worker explicit no-sparse non-thin pack is{pack['estimated_non_thin_pack_bytes']} bytes for{pack['ahead']} outgoing commits. "
    f"The director1500000000-byte trigger has{pack['remaining_to_trigger_bytes']} bytes remaining; advisory1400000000 has"
    f"{1400000000-pack['estimated_non_thin_pack_bytes']} bytes. All uncommitted resource14 work is excluded; this is not negotiated upload size.")
operational['scope'] = f"One actual ref-bound operational measurement. Actual before-use source/policy/wrapper, commands/channels, configuration and metadata are retained under {retained}/. No remote freshness, future-size or full physical/native closure follows."
operational['rederive']['result'] = (f"Actual0 at{pack['head']}/base{pack['cached_origin_main']}: {pack['estimated_non_thin_pack_bytes']} bytes, "
    f"{pack['packed_objects']} logical/header objects, {pack['ahead']} commits, {pack['remaining_to_trigger_bytes']}-byte trigger margin. "
    "Stream/stat/header/footer/ref/config/source/empty32 checks pass; preparation/trigger false. Actual receipts are under push-monitor-current/.")
operational['falsify']['reason'] = f"The prior independent native validation/twelve REDs at102ec3446 do not qualify this new{pack['head']} raw artifact. Parent30 owns separate actual-file falsification before publication; old controls are not refreshed."
claim['claims'].append(dict(name='actual-macos-availability-snapshot-arithmetic',
    statement=f"One retained actual restricted-shell observation obtains{actual['capacity_bytes']} capacity bytes through the native fallback and reports{actual['observed_used_percent']} percent used from one vm_stat snapshot. This is availability-based arithmetic, not live memory pressure or a peak/admission guarantee.",
    scope="The retained native responses forwarded to the helper, shared source and finite deterministic cases only. Original-wrapper denied-query RED and current single-snapshot controls remain distinct; initial repaired controls have no original before-use source custody credit. Linux controls are simulated on this macOS host. Full canonical admission is separately receipt-bound.",
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/ram-host-size-preflight-2026-11-12/review.py',
        granularity='Each retained actual native response, single snapshot arithmetic and finite named admission/exit controls.',
        result='Actual source-bound controls0, native recorder0 and independent historical recovery0/eight effective corruptions. Original wrapper control1 retains25-percent/admitted child/three snapshots for the known24GiB/12GiB-available fixture; repaired fixture reports50-percent/refuses at40-percent with one snapshot.'),
    falsify=dict(status='checked', hypothesis='The16GiB denied-query fallback or multiple VM reads already satisfies the declared capacity/single-snapshot admission contract.',
        oracle='Independent known24GiB/12GiB-available fixture, actual old-wrapper behavior and independently parsed retained native capacity/page/count bytes; historical reader does not call the RAM producer.',
        red_control='before/original-denial-red-exit.txt is1 with old actual child admission/code0/25-percent/three snapshots. Source-bound repaired controls pass. Historical recovery rejects changed native arithmetic/routing, erased original admission, omitted/accepted-denial/repeated-snapshot controls and wrong historical claim revision.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2',
        reason='Direct source bodies, wrappers, deterministic fixture generators, actual native responses before forwarding, separate channels and full modes are retained. Complete physical/native executable/interpreter/cache/toolchain/OS closure is not; broader4.2/SESSION5 owns that gap. No late archive is described as original first-use custody.')))
target = Path('docs/claims') / (OWNER + '.json')
assert not target.exists()
target.write_text(json.dumps(claim, indent=2) + '\n')
freeze('outputs-after-use', cards + [book, target] + list(retained.iterdir()))
print(json.dumps(dict(publication='PASS', cards=len(cards), book=str(book), claims=str(target))))
