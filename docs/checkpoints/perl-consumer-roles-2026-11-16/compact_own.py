"""Route only this unlanded slice's task commentary; preserve every older byte."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import stat
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
TASK = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
PARENT = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1'
OWNER = PARENT + '.0'
NEXT = PARENT + '.1'
assert not (BASE / 'pressure.json').exists(), 'one-shot own-commentary routing'
before = TASK.read_bytes()
assert subprocess.check_output(['git', 'show', ':' + str(TASK)]) == before
old = subprocess.check_output(['git', 'show', 'HEAD:' + str(TASK)])
mode = stat.S_IMODE(TASK.stat().st_mode)
for name, body in [('task-before', before), ('task-activation', old),
                   ('first-normal', Path('.linkedspec-data/perl-roles-normal-20261116.log').read_bytes()),
                   ('compact-source', Path(__file__).read_bytes())]:
    (BASE / (name + '.gz')).write_bytes(gzip.compress(body, mtime=0))
text = old.decode()
start = text.index('- ID: `' + PARENT + '`\n')
end = text.index('\n- ID:', start + 1)
parent = text[start:end].replace('Status: `pending`', 'Status: `active`', 1)
parent = parent.replace('  Status: `active`\n', '  Status: `active`\n  Children: `.0`, `.1` (ID suffixes).\n', 1)
node = ('\n- ID: `' + OWNER + '`\n'
        '  Status: `completed`\n'
        '  Goal: Qualify Perl roles.\n'
        '  Acceptance: Per Evidence.\n'
        '  Verification tier: `focused`\n'
        '  Focused checks: Qualified review; book; normal hooks.\n'
        '  Canonical trigger: Registration4.1.2/push30.2.\n'
        '  Claim verification: `docs/claims/' + OWNER + '.json`\n'
        '  Evidence: docs/checkpoints/perl-consumer-roles-2026-11-16/REVIEW.md.\n')
pending = ('\n- ID: `' + NEXT + '`\n'
           '  Status: `pending`\n'
           '  Goal: Complete parent qualification.\n'
           '  Acceptance: Parent contract.\n')
after = (text[:start] + parent + '\n' + node + pending + text[end:]).encode()
assert len(after) - len(old) <= 700, 'bounded current task delta before mutation'
TASK.write_bytes(after)
(BASE / 'task-after.gz').write_bytes(gzip.compress(after, mtime=0))
result = dict(task=str(TASK), mode=mode,
              activation_sha256=hashlib.sha256(old).hexdigest(),
              before_sha256=hashlib.sha256(before).hexdigest(),
              after_sha256=hashlib.sha256(after).hexdigest(),
              original_parent=parent.encode().hex(), new_node=node.encode().hex(),
              pending_node=pending.encode().hex(), start=start, end=end,
              added_task_bytes=len(after) - len(old),
              limit='Only new own commentary/child records condensed. Original parent contract and all other activation bytes remain; full rejected own text and hook are retained. No limit, checker, claim hash, original measurement or old task body changed.')
(BASE / 'pressure.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(added_task_bytes=result['added_task_bytes'], older_bytes_preserved=True)))
