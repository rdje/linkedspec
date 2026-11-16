"""Preserve the incomplete failed landing attempt and correct its dated heading."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
OUT = BASE / 'landing-repair'
OUT.mkdir()
changes = Path('CHANGES.md')
before = changes.read_bytes()
assert before == subprocess.check_output(['git', 'show', ':CHANGES.md'])
log = Path('.linkedspec-data/logs/artifact-review-2026-11-16-commit.log').read_bytes()
assert b'change_history current hot shard has a non-dated change heading' in log
assert b'ALL 10 enforced doctrines PASS' not in log
(OUT / 'first-normal.log.gz').write_bytes(gzip.compress(log, mtime=0))
(OUT / 'changes-before.md.gz').write_bytes(gzip.compress(before, mtime=0))
(OUT / 'context.json').write_text(json.dumps(dict(
    observed_outer_exit=1, interrupted=True,
    limit='Known dated-heading failure preceded agent termination of the remaining hook group; no completed all-doctrine report or claim-verification pass is credited. Redundant standalone claim check also canceled143 with no pass credit.',
    log_sha256=hashlib.sha256(log).hexdigest(),
    changes_sha256=hashlib.sha256(before).hexdigest()), indent=2) + '\n')
old = b'## November16 bounded artifact retention review\n'
new = '## 2026-11-16 — bounded artifact retention review\n'.encode()
assert before.count(old) == 1
after = before.replace(old, new, 1)
changes.write_bytes(after)
(OUT / 'changes-after.md.gz').write_bytes(gzip.compress(after, mtime=0))
task = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
source = task.read_text()
anchor = '  Outcome: 1316 dated metadata rows agree in eight named scopes;'
assert source.count(anchor) == 1
source = source.replace(anchor, '  Landing correction: Initial CHANGES heading lacked the required ISO date; scripts/check_document_history.pl387-390 reports the exact defect. Preserve the partial failed normal log and before/after source in landing-repair/. Remaining first hooks and the redundant standalone claim check were canceled; no all-doctrine credit. Only the heading changes; normal retry must complete every required hook.\n' + anchor, 1)
task.write_text(source)
print('retained incomplete failed landing; corrected only the ISO heading')
