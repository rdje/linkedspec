"""Preserve the rejected candidate and route only this leaf's new progress prose."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
OUT = BASE / 'landing-pressure'
OUT.mkdir()
part = Path('docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md')
raw = part.read_bytes()
text = raw.decode()
marker = '- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.78.6.1.2`'
assert text.count(marker) == 1
start = text.index(marker)
original = text[start:]
contract = original.splitlines()[:5]
assert contract[1] == '  Status: `completed`'
assert all(contract[i].startswith('  ' + name + ':') for i, name in ((2, 'Goal'), (3, 'Dependencies'), (4, 'Acceptance')))
tail = '''  Verification tier: `focused`
  Focused checks: LinkedSpec Get/descriptor/dump/native/fresh312; old/current; direct400/syntax; readonly17/current165; REVIEW.md.
  Canonical trigger: Full23.4/final clean push after coverage; policy/infrastructure separately owned.
  Claim verification: none: Finite authored controls; no completeness/performance/portable-domain measurement.
  Activation: Clean09bad87aa/all10/brief0; complete progression and scope retained in REVIEW.md.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Get probes; complete312/43 supported RED.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Get retains DSL; MethodLowering5762 excludes functions.
  - [x] **FIX** —15/two signature-valid terminal-producer/result guards.
  - [x] **ADDRESSED (verified)** — Qualified312; old46 (43+three metadata)/current312.
  - [x] **NO REGRESSION** —266 exact/three readiness; direct400; full errors/source policies.
  - [x] **LOCKSTEP** — Book/Knowledge/live/resume/index/history/scope; normal hooks before Rust.
  Outcome:1872 pairs/2008 API artifacts, qualified recovery17/current165; original after3/reader1 preserved. Native4.2/full23.4 remain open.
  Narrative: docs/checkpoints/array-transform-callable-result-perl-2026-11-11/REVIEW.md; exact pre-route task/log/patch in landing-pressure/.
'''
compact = '\n'.join(contract) + '\n' + tail
assert len(compact.encode()) <= 2500, len(compact.encode())
paths = [part, Path('docs/tasks/TYPE-REFERENCE-BOOK.index.jsonl'), Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md'), Path('MEMORY.md')]
records = {}
for path in paths:
    body = path.read_bytes()
    alias = OUT / (path.name + '.gz')
    alias.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(alias.read_bytes()) == body
    records[str(path)] = dict(alias=alias.name, bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
patch = subprocess.check_output(['git', 'diff', '--cached', '--full-index', '--binary', '--', 'docs/tasks'])
(OUT / 'staged-task-candidate.patch.gz').write_bytes(gzip.compress(patch, mtime=0))
log = Path('.linkedspec-data/array-transform-callable-result-perl-commit.log').read_bytes()
(OUT / 'stopped-hook.log.gz').write_bytes(gzip.compress(log, mtime=0))
(OUT / 'route-producer.py.gz').write_bytes(gzip.compress(Path(__file__).read_bytes(), mtime=0))
failure = dict(surface='task_evidence', actual_bytes=12588381, limit_bytes=12582912,
    excess_bytes=5469, outer_exit=1, complete_hook_PASS=False,
    scope='Only new current-leaf activation/progress/checklist explanation routed; Goal/Dependencies/Acceptance and all prior nodes stay exact. No cap/source/test/proof changes.',
    inputs=records, original_leaf_bytes=len(original.encode()), compact_leaf_bytes=len(compact.encode()),
    bytes_routed=len(original.encode())-len(compact.encode()), activation='09bad87aa19304486f836cf6dff44b499a8ea5ec')
(OUT / 'failure.json').write_text(json.dumps(failure, indent=2) + '\n')
new = (text[:start] + compact).encode()
assert new[:start] == raw[:start]
assert compact.splitlines()[:5] == contract
mode = part.stat().st_mode & 0o777
part.write_bytes(new)
assert part.stat().st_mode & 0o777 == mode
print(json.dumps(dict(result='PASS', bytes_routed=failure['bytes_routed'], compact_leaf_bytes=len(compact.encode()), original_contract_unchanged=True, whole_draft_retained=True), sort_keys=True))
