"""Prepare the exact canonical checkpoint; publication observations follow afterward."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
ACTIVATION = '9b54456a4bf2588526943a2208094de428ef4e28'
PARENT = 'TYPE-REFERENCE-BOOK.1.2.23.4.30.2'
OWNER, NEXT = PARENT + '.0', PARENT + '.1'
PART = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
with tarfile.open(BASE / 'before.tar.gz', 'x:gz') as archive:
    for path in (Path(__file__).relative_to(Path.cwd()), Path(PART)):
        archive.add(path, arcname=str(path), recursive=False)
names = [BOOK, 'MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md',
    'tools/run_ci_local.sh', 'tools/verification_receipt.sh', '.githooks/pre-push', '.githooks/post-commit',
    'docs/checkpoints/artifact-review-2026-11-17/PUBLICATION_QUESTION.md']
inputs = {}
for name in names:
    raw = subprocess.check_output(['git', 'ls-tree', '-z', ACTIVATION, '--', name]).split(b'\0')[0]
    header, encoded = raw.split(b'\t', 1); mode, kind, blob = header.decode().split()
    assert kind == 'blob' and encoded.decode() == name
    body = subprocess.check_output(['git', 'cat-file', 'blob', blob])
    assert Path(name).read_bytes() == body
    inputs[name] = dict(revision=ACTIVATION, blob=blob, mode=mode, bytes=len(body), sha256=hashlib.sha256(body).hexdigest())
(BASE / 'git-inputs.json').write_text(json.dumps(inputs, indent=2, sort_keys=True) + '\n')
bindings = []
for path in sorted(Path('docs/claims').glob('*.json')):
    for claim in json.loads(path.read_bytes())['claims']:
        leg = claim['durability']
        for item in leg.get('inputs', []):
            if item['path'] == BOOK:
                assert leg['mode'] == 'historical'
                bindings.append(dict(record=str(path), claim=claim['name'], input=item, mode=leg['mode'], revision=leg['revision']))
(BASE / 'book-bindings.json').write_text(json.dumps(bindings, indent=2, sort_keys=True) + '\n')
path = Path(BOOK); text = path.read_text()
old = 'is 2 GiB. Every push still requires current canonical test discovery, full CI and a\nclean exact HEAD through normal hooks. Check fresh remote identity before transfer.'
new = '''is 2 GiB. Full CI and a clean exact HEAD through normal hooks remain required for
every push. Current canonical test discovery remains the normal admission prerequisite.
For the November17 checkpoint, the director clarifies that1.5GB is approximate:
a little below or above is fine. Finish the current leaf, run full canonical CI
and normal workflow, then publish the checkpoint while discovery/registration
and native-admission work remain open. Those owners are not closed by the push;
resume PNT afterward. Check fresh remote identity before transfer.'''
assert text.count(old) == 1
path.write_text(text.replace(old, new, 1))
path = Path(PART); text = path.read_text(); start = text.index('- ID: `' + OWNER + '`\n'); end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node += '  Outcome: Preparation only; exact canonical receipt is required before landing. Push/outcome1 remains pending.\n'
path.write_text(text[:start] + node + text[end:])
summary = 'Prepare the exact staged checkpoint and align the public budget paragraph with the received director clarification. Full canonical CI and normal hooks remain mandatory; original discovery/registration/native-admission owners stay open. No push or new test/coverage/wire metric is claimed by preparation.'
action = 'After the exact canonical preparation lands, publish the clean checkpoint through normal hooks under ' + NEXT + ', verify remote/local refs and record the receipt/outcome; then resume PNT.'
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md'); text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(PARENT) + r'`.*$', '| 1 | `' + NEXT + '` | `pending` | Canonical preparation requires its exact receipt; then normal clean checkpoint push/read-back, keeping admission owners open. |', path.read_text())
assert count == 1; path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name); text, count = re.subn(r'(?m)^November17 current PNT frontier:.*$', 'November17 current PNT frontier: Canonical checkpoint preparation aligns the public budget note with the director approximate1.5GB clarification. Full exact-candidate CI/normal workflow precedes push and remote read-back; discovery/registration/native admission remains open. Resume PNT after publication.', path.read_text(), count=1)
    assert count == 1; path.write_text(text)
path = Path('docs/TASK_TREE.md'); text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Exact canonical checkpoint preparation, then normal clean push/read-back and scoped outcome. Director approximate-budget clarification is adopted; discovery/registration/native admission remains open.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — exact canonical preparation; public budget note aligned, publication and its observed outcome remain separate.', text, count=1)
text = re.sub(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$', lambda match: match[1] + 'PNT: canonical checkpoint preparation then authorized normal push/read-back; source/registration/native admission stays open.' + match[2], text)
path.write_text(text)
for name, title in [('CHANGES.md', 'prepare the director-authorized canonical checkpoint'), ('DEVELOPMENT_NOTES.md', 'keep checkpoint publication separate from admission closeout')]:
    path = Path(name); text = path.read_text(); offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## 2026-11-17 — ' + title + '\n\n' + OWNER + ': ' + summary + ' Exact staged-candidate receipt and normal hooks gate this canonical leaf. Actual publication observations belong to push/outcome1. Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md'); text = path.read_text()
for heading, body in {'Current Activity': 'PNT: exact canonical checkpoint preparation, then authorized publication.', 'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda match: match[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — canonical preparation and scoped budget note; actual push/outcome remains separate.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean canonical checkpoint activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — receipt-bound canonical checkpoint preparation.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; director prioritizes this checkpoint, then source work resumes.\n- next_action: ' + action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- blockers: none requiring user input. Exact director reply: docs/checkpoints/artifact-review-2026-11-17/PUBLICATION_QUESTION.md. No further approval needed.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; tools/verification_receipt.sh binds exact staged candidate and promotes only its matching commit. Publication observations belong to outcome1.\n' +
    '- limits: Checkpoint preparation is not discovery/registration/native admission. All original source/helper/generated/semantic/native4.2/SESSION5 owners remain open. No new coverage, performance or wire-size claim.\n' +
    '- publication: Approximate1.5GB permits a little below or above. Full exact-candidate canonical CI, normal commit, clean root-only push and fresh remote read-back remain required.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial/shared24GB; use conservative workers. Latest retention review2026-11-17T10:26:54.898807+00:00 removed nothing.\n')
print(summary)
