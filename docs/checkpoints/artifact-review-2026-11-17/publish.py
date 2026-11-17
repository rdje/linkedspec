"""Publish the dated retention review and a durable pending-priority handoff."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
ACTIVATION = '36428fa1288d9da3fe00628ca0ab734b940bc023'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.37'
SOURCE = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.3.1.1.2.1'
PUBLICATION = 'TYPE-REFERENCE-BOOK.1.2.23.4.30.2'
PART = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
QUESTION = str(BASE / 'PUBLICATION_QUESTION.md')
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
result = json.loads((BASE / 'result.json').read_bytes())
assert result == json.loads((BASE / 'capture-result.json').read_bytes())
assert result['result'] == 'PASS' and result['removed'] == 0
with tarfile.open(BASE / 'publication-before.tar.gz', 'x:gz') as archive:
    for path in (Path(__file__).relative_to(Path.cwd()), Path(PART)):
        archive.add(path, arcname=str(path), recursive=False)
names = [BOOK, 'MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md', PART,
    'docs/ARTIFACT_CLEANUP.md', 'docs/knowledge/github-size-safe-publication.md',
    'docs/checkpoints/perl-helper-path-plan-2026-11-17/review.py',
    'docs/checkpoints/perl-helper-path-plan-2026-11-17/REVIEW.md']
inputs = {}
for name in names:
    raw = subprocess.check_output(['git', 'ls-tree', '-z', ACTIVATION, '--', name]).split(b'\0')[0]
    header, encoded = raw.split(b'\t', 1); mode, kind, blob = header.decode().split()
    assert kind == 'blob' and encoded.decode() == name
    body = subprocess.check_output(['git', 'cat-file', 'blob', blob])
    assert name == PART or Path(name).read_bytes() == body
    inputs[name] = dict(revision=ACTIVATION, blob=blob, mode=mode, bytes=len(body), sha256=hashlib.sha256(body).hexdigest())
(BASE / 'git-inputs.json').write_text(json.dumps(inputs, indent=2, sort_keys=True) + '\n')
telemetry = Path('.linkedspec-data/push-monitor/20261117T102230.796772Z')
(BASE / 'telemetry').mkdir()
for path in telemetry.iterdir():
    if path.suffix in ('.pack', '.idx', '.log') or path.name.startswith(('objects-', 'object-metadata-')):
        continue
    shutil.copy2(path, BASE / 'telemetry' / path.name)
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
assert size['head'] == ACTIVATION
log = Path('.linkedspec-data/perl-helper-path-plan-commit.log').read_bytes()
assert b'doctrines: ALL 10 enforced doctrines PASS.' in log and b'[memory-pointer] ok: post-commit' in log
(BASE / 'preceding-normal.log.gz').write_bytes(gzip.compress(log, mtime=0))
question = '''# Publication priority — director decision pending

Owner: TYPE-REFERENCE-BOOK.1.2.23.4.30.2; intake/handoff: TYPE-REFERENCE-BOOK.1.2.23.4.37.
Raised through the live user-input request on2026-11-17; no answer or approval received.

The director's early-push rule in `docs/knowledge/github-size-safe-publication.md`
requires preparation with margin and publication around1.5GB, independently of
batch cadence. The publication parent's Dependencies/Schedule and leaf30.2 in
`docs/tasks/TYPE-REFERENCE-BOOK.overview.md` also require unfinished canonical
discovery/registration and existing before-push prerequisites. Neither requirement
is silently waived. The current task scope remains the complete inherited source
population and every semantic/native/generated/registration owner.

The actual retained activation telemetry is in `telemetry/result.json`: committed
36428fa1 against cached4683555e, excluding this handoff slice. It is a serialized
estimate, not fresh remote or negotiated wire size. Continuing the broad source
work needs a priority decision before consuming the remaining preparation margin.

Choose one:

1. Allow a checkpoint push after full exact-candidate canonical CI and normal
   hooks, keeping discovery/registration explicitly open. This authorizes a
   checkpoint only; it does not admit unregistered tests or close source/native
   provenance gaps. Resume source work after successful publication.
2. Finish discovery/registration first, allowing the outgoing estimate to grow
   beyond the1.5GB target while still monitoring and staying safely below the
   GitHub hard limit. Resume nonadjacent literals and all subsequent owners.

The first option is recommended but is not approval. No push has been attempted.
The source frontier is held; completed work and the dated retention review are
committed before stopping. Full CI remains mandatory before any push in either
case. A fresh session reads `MEMORY.md` and this file, obtains the director's
choice, records it, then activates the corresponding task from clean Git.
'''
Path(QUESTION).write_text(question)
summary = (str(result['scoped_rows']) + ' dated metadata rows agree across the eight published scopes; '
    'six evidence controls and a stage-byte source RED pass. All artifacts/caches/proof remain retained; nothing removed. '
    'The actual logical Git-index input exactly matches its clean-base tree inverse, avoiding a duplicate large index packet. '
    'Publication-priority decision remains pending; source growth is held.')
action = 'Obtain the director publication-priority choice in ' + QUESTION + '; then prepare an authorized checkpoint with full CI or resume nonadjacent source binding with explicit growth authority.'
path = Path(PART); text = path.read_text()


def change_node(text, owner, transform):
    start = text.index('- ID: `' + owner + '`\n'); end = text.find('\n- ID:', start + 1)
    assert end >= 0
    return text[:start] + transform(text[start:end]) + text[end:]


text = change_node(text, SOURCE, lambda node: node.replace('Status: `pending`', 'Status: `blocked`', 1) +
    '  Blocker: Director priority is required before more source-evidence growth near the early-push trigger; see docs/checkpoints/artifact-review-2026-11-17/PUBLICATION_QUESTION.md. Unblock by authorizing the checkpoint exception or prerequisite-first growth. No implementation started.\n')
text = change_node(text, PUBLICATION, lambda node: node.replace('Status: `pending`', 'Status: `blocked`', 1) +
    '  Priority blocker: Early-push margin and unfinished discovery/registration prerequisites now require a director choice; see docs/checkpoints/artifact-review-2026-11-17/PUBLICATION_QUESTION.md. Full CI stays mandatory. A checkpoint exception cannot close the original admission prerequisites.\n')
text = change_node(text, OWNER, lambda node: node.replace('Status: `active`', 'Status: `completed`', 1) +
    '  Outcome: Metadata1322/eight scopes/controls6 plus actual stage-byte RED/separate readonly recovery PASS; zero removals. Exact clean-base index inverse replaces duplicate raw input storage. Publication-priority question is durable; historical plan-reader qualification must pass before landing. Evidence: docs/checkpoints/artifact-review-2026-11-17/REVIEW.md.\n')
path.write_text(text)
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md'); text = path.read_text()
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(SOURCE) + r'`.*$', '| 1 | `' + PUBLICATION + '` | `blocked` | Director must choose checkpoint publication or prerequisite-first growth near the1.5GB trigger; full CI remains mandatory. |', text)
assert count == 1; path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name); text, count = re.subn(r'(?m)^November17 current PNT frontier:.*$', 'November17 current PNT frontier: Director publication-priority choice pending near the early-push trigger. Daily metadata1322/eight scopes/controls6 plus source RED/zero removals is focused-checked; helper plan is committed. Discovery/registration, all source/native/generated prerequisites and full before-push CI remain open; no waiver or runtime admission.', path.read_text(), count=1)
    assert count == 1; path.write_text(text)
path = Path('docs/TASK_TREE.md'); text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Director publication-priority decision pending; completed source/plan/retention units are committed before further growth. Original discovery/registration and all semantic/native/generated prerequisites remain open.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — retention metadata1322/eight scopes/six controls plus source RED/zero removals; pending publication priority is durable.', text, count=1)
text = re.sub(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$', lambda match: match[1] + 'Blocked on director early-push versus discovery/registration priority; source qualification and helper plan committed, daily retention complete. No admission or prerequisite waiver.' + match[2], text)
path.write_text(text)
for name, title, body in [('CHANGES.md', 'retain the dated artifact review and publication-priority handoff', summary),
    ('DEVELOPMENT_NOTES.md', 'reuse the exact clean-base index input without copying its full packet', 'Two public Git commands independently supply the actual index stream and the retained clean-base tree. Sorted mode/object/path rows reconstruct the exact stage0 input; bytes/SHA256 agree before the scanner interprets it. An actual stage-byte input alteration is RED, and six evidence controls reject. Historical source inputs remain recoverable through Git; physical index/native/library/kernel closure remains4.2/SESSION5. No artifacts removed. The source frontier and original publication leaf are explicitly blocked on the director priority choice, without waiving canonical CI or registration.')]:
    path = Path(name); text = path.read_text(); offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## 2026-11-17 — ' + title + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
Path('docs/ARTIFACT_CLEANUP.md').write_text('# Latest artifact cleanup\n\n- Date: ' + result['date'] + '\n- Summary: ' + OWNER + ': ' + summary + ' Evidence: docs/checkpoints/artifact-review-2026-11-17/. Full native/OS custody remains23.4.2/SESSION5.\n')
path = Path('LIVE_ACHIEVEMENT_STATUS.md'); text = path.read_text()
for heading, body in {'Current Activity': 'PNT held on the explicit publication-priority decision; dated retention review complete.', 'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda match: match[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — retention1322/eight scopes/six controls/source RED/zero removals; publication-priority question recorded.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean retention/handoff activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — dated retention review and priority handoff.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; blocked on the director priority decision, not voluntarily paused.\n- next_action: ' + action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- blockers: Director must resolve early-push versus unfinished discovery/registration priority; source1 and publication30.2 are blocked. No answer/approval received; default UI choice is not authorization.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; dated metadata1322/eight scopes/six controls/stage-source RED/zero removals. Historical plan recovery uses accepted36428fa1; current-boundary mode remains distinct.\n' +
    '- limits: Full159-source/helper/generated/semantic/native/physical4.2/SESSION5 and registration prerequisites remain open. A checkpoint exception, if authorized, changes no admission claim. Full exact-candidate CI before any push.\n' +
    '- publication: Activation/cached4683555e estimates1,498,646,045 bytes/132 ahead/1,353,955-byte margin, excluding this slice. Selected telemetry retained; independent size30/native4.2 and fresh-remote/wire/future gaps remain. Remeasure after landing.\n' +
    '- preceding_normal: .linkedspec-data/perl-helper-path-plan-commit.log completes all10/post-pointer for36428fa1; message brief cleared before activation.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial/shared24GB. Latest retention review ' + result['date'] + '; nothing removed. Normal hooks mandatory.\n')
path = Path(BOOK); text = path.read_text(); marker = '\nA closed-tree epoch can renew current text capacity'
assert text.count(marker) == 1
path.write_text(text.replace(marker, '\nA dated retention review can also reuse a clean Git input without copying its full packet. Compare the actual index stream with the exact mode/object/path inverse of the retained base tree before interpreting it, and preserve byte identity plus an altered-input RED control. This proves logical input recovery; it does not establish physical index, native-tool or filesystem custody, and a metadata census grants no deletion authority.\n' + marker, 1))
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review.py')
native = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Actual project producers/bytes/modes precede helper import and scanning; full capture/recovery channels and dated observations retained. The actual logical Git-index stream is hash/byte-gated against its clean-base tree inverse before use, with retained before-input reference and source RED. Full external Python/Git/library/filesystem/kernel/physical/outer-first-use/per-read/source-origin custody remains4.2/SESSION5. No content-ownership, liveness, deletion or reclamation claim.')
claims = [dict(name='november17-scoped-retention-metadata', statement=summary, scope='Dated path/suffix/byte metadata in the eight published scopes only; all artifacts/caches/proof retained. No whole-project, native, liveness, disposal or space-reclamation admission.',
    rederive=dict(status='checked', command=command, granularity='Every dated row in both independent walks, source packet, exact logical index input and source/evidence control.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='checked', hypothesis='A missing/changed/duplicate/outside metadata row, changed producer or index identity could be accepted; a stage1-altered source stream could equal the stage0 tree inverse.', oracle='Published non-following scanner versus independent scandir/lstat; actual ls-files stream versus retained Git-tree inverse.', red_control='Six distinct metadata/source/index evidence corruptions reject, and altering the first stage0 byte to stage1 in the actual source stream is RED without changing the real index.'), durability=native),
    dict(name='retention-activation-outgoing-estimate', statement='Committed activation estimates1,498,646,045 non-thin bytes against cached4683555e, leaving1,353,955 before the director1.5GB trigger.', scope=size['limits'],
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py', granularity='Committed activation/cached-origin serialized range; selected actual metadata copied after use.', result=json.dumps(size, sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Stream/stat/footer agreement retained; complete independent actual-file falsification remains30.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Selected producer/ref/config/command/channels retained after use; raw pack/full tables stay ignored on this volume. Full native/physical/outer-first-use/per-read/source-origin/toolchain closure remains4.2/SESSION5. No fresh-remote, wire-size or future-growth promise.'))]
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
