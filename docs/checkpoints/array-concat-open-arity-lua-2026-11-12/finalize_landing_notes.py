"""Retain actual final focused-gate/pointer correction notes before their insertion."""
import gzip
import json
from pathlib import Path
BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
OUT = BASE / 'landing-notes'
OUT.mkdir()
paths = [Path('docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md'), Path('CHANGES.md'), Path('DEVELOPMENT_NOTES.md')]
for path in paths:
    body = path.read_bytes()
    target = OUT / (path.name + '.before.gz')
    target.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(target.read_bytes()) == body
for tag in ('review-selection-frontier', 'review-publication'):
    folder = BASE / 'launches' / tag
    assert (folder / 'exit.txt').read_text() == '0\n'
    assert gzip.decompress((folder / 'stderr.log.gz').read_bytes()) == b''
    (OUT / (tag + '.json')).write_bytes(gzip.decompress((folder / 'stdout.log.gz').read_bytes()))
note = '''

  Landing preparation and small owned pointer defect: Actual document publication0/independent recovery0-three controls retain27 inputs/15 outputs/full modes; current live view16/history exact. mdBook0 with known search-index18.2 warning, memory architecture0, Knowledge1753 facts/12491 keys and scope1955 members/17 pages pass. Changes302lines/44263bytes and notes203/34767 pass pressure checks; whitespace0. A read of the current selection card still says peers pending/Rust80.2 next, although all five bounded80 outcomes now exist. Impact: stale current retrieval could repeat completed work. Own80.5 fixes exactly its status/next prose, retaining original selection observations and complete before/after images. Separate actual query210 records/zero card bindings precedes that edit; independent recovery0 and injected live-binding RED pass. This separate reader also checks the current card, so its future execution is point-in-time, not a new default historical entrypoint. Existing review.py/review_publication.py stay unchanged. Host memory preflight67% system-wide free; normal hooks still govern landing and size is remeasured after commit. No full CI/push or broad-admission credit.
'''
p = paths[0]
body = p.read_text()
marker = '- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.80.5`'
start = body.index(marker)
end = body.find('\n- ID:', start + 1)
end = len(body) if end < 0 else end
p.write_text(body[:end] + note + body[end:])
for p, title, addition in (
    (paths[1], '## TYPE-REFERENCE-BOOK.1.2.23.3.80.5', ' A stale selection-card current pointer (peers pending/Rust next) is corrected with exact original evidence retained;210 accepted records/zero bindings/one live-binding RED independently recovered.'),
    (paths[2], '## 2026-11-12 — TYPE-REFERENCE-BOOK.1.2.23.3.80.5', ' The current selection card also needed two exact pointer replacements after all backend outcomes; its original selection evidence remains immutable in the correction packet, with independent query/recovery and a live-binding RED.'),
):
    body = p.read_text()
    start = body.index(title)
    end = body.find('\n## ', start + 1)
    end = len(body) if end < 0 else end
    section = body[start:end]
    section = section.rstrip() + addition + '\n\n'
    p.write_text(body[:start] + section + body[end:])
for path in paths:
    body = path.read_bytes()
    target = OUT / (path.name + '.after.gz')
    target.write_bytes(gzip.compress(body, mtime=0))
    assert gzip.decompress(target.read_bytes()) == body
print(json.dumps(dict(final_notes='PASS', documents=len(paths), current_pointer_defect='fixed with exact two replacements and independently recovered inputs', normal_hooks='pending')))
