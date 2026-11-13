"""Retain the stopped normal attempt and exact lexical-checklist cause."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'normal-attempt-one'
OUT.mkdir()
task = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
command = ['git', 'show', ':' + task]
(OUT / 'task-command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
body = subprocess.check_output(command)
assert body == Path(task).read_bytes()
lines = [line for line in body.splitlines() if b'**LOCKSTEP**' in line and b'pending' in line]
assert len(lines) == 1 and b'current discovery4.1 and before-push owners stay pending.' in lines[0]
log = Path('.linkedspec-data/lua-raw-error-commit-20261113.log').read_bytes()
assert b'governed staged changes need one staged' in log
for name, raw in (('staged-task.md.gz', body), ('combined-log.gz', log),
        ('diagnosis-gate.sh.gz', Path('scripts/check_diagnosis_evidence.sh').read_bytes())):
    path = OUT / name
    path.write_bytes(gzip.compress(raw, mtime=0))
    assert gzip.decompress(path.read_bytes()) == raw
(OUT / 'cached-raw.txt').write_bytes(subprocess.check_output(['git', 'diff', '--cached', '--raw']))
(OUT / 'result.json').write_text(json.dumps(dict(head=subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip(),
    task_sha256=hashlib.sha256(body).hexdigest(), log_sha256=hashlib.sha256(log).hexdigest(),
    observed_session_exit=1, stopped_by_agent=True, cause=lines[0].decode(),
    scope='The normal attempt is stopped after confirmed diagnosis-evidence rejection; no completed all-doctrine outcome or new commit is claimed. Current leaf is complete; the wording referred to separate future owners.'), indent=2) + '\n')
print('Preserved the stopped normal attempt and exact single lexical checklist cause')
