"""Retain the over-cap draft; keep examples exact and fit existing prose budget."""
import gzip
import hashlib
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
TARGET = Path('docs/linkedspec-book/src/development/local-ci-and-regression.md')
before = TARGET.read_bytes()
saved = BASE / 'book-before-containment.md.gz'
assert not saved.exists()
saved.write_bytes(gzip.compress(before, mtime=0))
text = before.decode()
start = text.index('The later Lua narrative epoch preserves')
end = text.index('Canonical decisions, Knowledge cards and public references stay directly browsable.', start)
old = text[start:end]
replacement = ('The later Lua narrative epoch preserves the dated accepted source and current contracts with unchanged limits. '
    'Use `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree LUA-BACKEND-PARITY '
    '--epoch TYPE-REFERENCE-BOOK.1.2.23.4.16 --all` for exact source. Its qualified migration keeps all 157 IDs, '
    '149 closed contracts, eight unchanged short bodies and the entire current/trailing section, renewing 115,343 '
    'current-text bytes. The first generic migration passed metadata checks but swallowed the lowercase '
    '`Current frontier` boundary into its last archived node. That unsafe intermediate and its producer remain '
    'retained; separate restoration keeps the exact 232,154-byte tail directly browsable. The legacy last-node '
    'query still includes chronology; generic boundary/query repair belongs to4.17. Full-source recovery is exact. '
    'This is task-data preservation, with runtime and Lua5.4 admission unchanged; current IDs/statuses still '
    'satisfy Unicode/capability/language-closure consumers.\n\n')
text = text[:start] + replacement + text[end:]
for marker in ('### Current document-pressure restoration', 'Knowledge generation now renders'):
    needle = '\n\n\n' + marker
    assert text.count(needle) == 1
    text = text.replace(needle, '\n\n' + marker, 1)
after = text.encode()


def fenced(raw):
    found, current, marker = [], [], None
    for line in raw.splitlines(keepends=True):
        opening = re.match(rb'^ {0,3}(`{3,}|~{3,})', line)
        if marker is None and opening:
            marker = opening[1][0:1]
            current = [line]
        elif marker is not None:
            current.append(line)
            if opening and opening[1][0:1] == marker:
                found.append(b''.join(current))
                current, marker = [], None
    assert marker is None
    return found


removed = fenced(old.encode())
assert len(removed) == 1 and b'--epoch TYPE-REFERENCE-BOOK.1.2.23.4.16' in removed[0]
old_examples = fenced(before)
assert old_examples.count(removed[0]) == 1
old_examples.remove(removed[0])
assert fenced(after) == old_examples, 'all pre-existing code examples remain byte-exact'
assert before.count(b'\n') == 2063 and after.count(b'\n') <= 2048
TARGET.write_bytes(after)
(BASE / 'book-budget-record.json').write_text(json.dumps(dict(
    owner='TYPE-REFERENCE-BOOK.1.2.23.4.16',
    failure='first4.16 commit: diagnostics chapter2063/2048 lines; remaining claim verifier interrupted, not passed',
    before=dict(lines=before.count(b'\n'), bytes=len(before), sha256=hashlib.sha256(before).hexdigest()),
    after=dict(lines=after.count(b'\n'), bytes=len(after), sha256=hashlib.sha256(after).hexdigest()),
    preservation='All pre-existing fenced examples byte-exact; only own new example becomes an inline command and two outside-example redundant blank lines are removed.'
), indent=2) + '\n')
print('Book fits existing line cap; retained draft and all prior fenced examples unchanged')
