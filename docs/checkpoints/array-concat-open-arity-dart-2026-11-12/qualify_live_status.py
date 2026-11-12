"""Preserve the failed landing, then rotate one bounded recent-status row."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
OUT = BASE / 'landing-pressure'
OUT.mkdir()
VIEW = ROOT / 'LIVE_ACHIEVEMENT_STATUS.md'
log = ROOT / '.linkedspec-data/array-concat-open-arity-dart-commit.log'
paths = [VIEW, log, Path(__file__), ROOT / 'docs/decisions/0066-bounded-live-document-store.md']
rows = {}
with tarfile.open(OUT / 'inputs-before-use.tar.gz', 'x:gz') as packed:
    for path in paths:
        body = path.read_bytes(); name = path.relative_to(ROOT).as_posix()
        rows[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        packed.add(path, arcname=name, recursive=False)
with tarfile.open(OUT / 'inputs-before-use.tar.gz') as packed:
    assert set(packed.getnames()) == rows.keys()
    for member in packed:
        body = packed.extractfile(member).read(); row = rows[member.name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
(OUT / 'input-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
failure = log.read_bytes()
assert failure.count(b'  PASS  ') == 8 and failure.count(b'  FAIL  ') == 2
assert b'live_status current view has more than sixteen recent rows' in failure
assert b'doctrines: one or more doctrines FAILED' in failure
policy = paths[-1].read_bytes()
assert b'Recent Completions` retains at most sixteen one-line' in policy
before = VIEW.read_bytes()
start = before.index(b'## Recent Completions\n\n') + len(b'## Recent Completions\n\n')
end = before.index(b'## History', start)
recent = before[start:end]
lines = recent.splitlines(keepends=True)
entries = [line for line in lines if line.startswith(b'- ')]
assert len(entries) == 17 and all(line.startswith(b'- ') or not line.strip() for line in lines)
rotated = entries[-1]
old_head = subprocess.check_output(['git', 'show', '1753884257bed7ce0b842bc406c665671403a828:LIVE_ACHIEVEMENT_STATUS.md'], cwd=ROOT)
assert rotated in old_head and before.count(rotated) == 1
after = before[:start] + b''.join(entries[:16]) + b'\n' + before[end:]
assert before.replace(rotated, b'', 1) == after
(OUT / 'before-live.md.gz').write_bytes(gzip.compress(before, mtime=0))
(OUT / 'after-live.md.gz').write_bytes(gzip.compress(after, mtime=0))
(OUT / 'rotated-row.md.gz').write_bytes(gzip.compress(rotated, mtime=0))
(OUT / 'accepted-HEAD-live.md.gz').write_bytes(gzip.compress(old_head, mtime=0))
(OUT / 'first-failed-commit-combined.log.gz').write_bytes(gzip.compress(failure, mtime=0))
(OUT / 'result.json').write_text(json.dumps(dict(original_recent_rows=17, corrected_recent_rows=16,
    rotated_row=rotated.decode().rstrip('\n'), original_observed_exec_exit=1,
    original_exec_session=65235, passed_doctrines=8, failed_doctrines=['DOCUMENT-HISTORY', 'README-STABILITY'],
    scope='Exact original combined commit log/full modes, views and oldest row retained. Original publisher and historical outputs are unchanged. Current view rotates one already accepted row under ADR0066; no SDK/fixture replay.'), indent=2, sort_keys=True) + '\n')
VIEW.write_bytes(after)
print('Retained original failed combined log/17-row view; rotated exactly one accepted row to restore16')
