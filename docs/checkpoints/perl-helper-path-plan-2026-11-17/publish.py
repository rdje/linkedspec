"""Retain the clean-base plan inputs and publish bounded helper/path owners."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import shutil
import stat
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
ACTIVATION = '7354d156f40c492e84c7992578a699e2e77ad7ba'
PARENT = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.3.1.1.2'
OWNER, NEXT = PARENT + '.0', PARENT + '.1'
PART = 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'before.tar.gz').exists()
with tarfile.open(BASE / 'before.tar.gz', 'x:gz') as archive:
    for path in (Path(__file__).relative_to(Path.cwd()) if Path(__file__).is_absolute() else Path(__file__), Path(PART)):
        archive.add(path, arcname=str(path), recursive=False)
names = [BOOK, 'MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md', PART,
    'tools/project_data_run.sh', 'tools/project_data_env.sh', 'tools/run_python_project_data.sh',
    'tools/update_reference_scope.py', 'tools/reference_scope.py', 'tools/update_task_tree_index.pl']
inputs = {}
original = {}
for name in names:
    row = subprocess.check_output(['git', 'ls-tree', '-z', ACTIVATION, '--', name]).split(b'\0')[0]
    header, encoded = row.split(b'\t', 1)
    mode, kind, blob = header.decode().split()
    assert kind == 'blob' and encoded.decode() == name
    body = subprocess.check_output(['git', 'cat-file', 'blob', blob])
    assert name == PART or Path(name).read_bytes() == body, 'clean-base document/input identity'
    inputs[name] = dict(revision=ACTIVATION, blob=blob, mode=mode, bytes=len(body), sha256=hashlib.sha256(body).hexdigest())
    original[name] = body
(BASE / 'git-inputs.json').write_text(json.dumps(inputs, indent=2, sort_keys=True) + '\n')


def node(text, owner):
    matches = list(re.finditer(r'(?m)^- ID: `' + re.escape(owner) + r'`\n', text))
    assert len(matches) == 1
    start = matches[0].start(); end = text.find('\n- ID:', matches[0].end())
    return text[start:end if end >= 0 else None]


old_parent = node(original[PART].decode(), PARENT)
path = Path(PART); text = path.read_text()
for field in ('Goal', 'Acceptance', 'Continuation'):
    pattern = r'(?m)^  ' + field + r': (.*)$'
    assert re.findall(pattern, old_parent) == re.findall(pattern, node(text, PARENT)), 'parent obligation preserved'
old = node(text, OWNER)
new = old.replace('Status: `active`', 'Status: `completed`', 1)
new += '  Outcome: Parent contract and full inherited cohort preserved; nonadjacent1, helper/caller2, library/process/non-open3 and reconciliation4 are ordered. No source classification, runtime or admission promoted. Evidence: docs/checkpoints/perl-helper-path-plan-2026-11-17/.\n'
path.write_text(text.replace(old, new, 1))
telemetry = Path('.linkedspec-data/push-monitor/20261117T095703.973397Z')
(BASE / 'telemetry').mkdir()
for path in telemetry.iterdir():
    if path.suffix in ('.pack', '.idx', '.log') or path.name.startswith(('objects-', 'object-metadata-')):
        continue
    shutil.copy2(path, BASE / 'telemetry' / path.name)
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
assert size['head'] == ACTIVATION
log = Path('.linkedspec-data/perl-other-io-commit-retry.log').read_bytes()
assert b'doctrines: ALL 10 enforced doctrines PASS.' in log and b'[memory-pointer] ok: post-commit' in log
(BASE / 'preceding-normal.log.gz').write_bytes(gzip.compress(log, mtime=0))
summary = 'Split the helper/path obligation into nonadjacent literal bindings, helper/caller targets, library/process/non-open origins and final reconciliation. Parent Goal/Acceptance/Continuation and the full inherited159-source cohort remain binding; generated/inline, independent semantics and native/publication prerequisites stay separate.'
action = 'Qualify nonadjacent fixed literal open bindings under ' + NEXT + '; remeasure after each leaf and preserve every unresolved helper/library/generated and admission owner.'
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md'); text = path.read_text()
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(PARENT) + r'`.*$', '| 1 | `' + NEXT + '` | `pending` | Helper/path plan committed; qualify nonadjacent literal bindings, then helper/caller, library/process/non-open and reconciliation leaves. |', text)
assert count == 1; path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name); text, count = re.subn(r'(?m)^November17 current PNT frontier:.*$', 'November17 current PNT frontier: Helper/path plan committed; nonadjacent literals precede helper/caller targets, library/process/non-open origins and source reconciliation. All prior159-source qualifications and semantic/native/generated/registration/publication limits remain. No runtime admission.', path.read_text(), count=1)
    assert count == 1; path.write_text(text)
path = Path('docs/TASK_TREE.md'); text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Helper/path plan complete; nonadjacent literal bindings precede helper/caller, library/process/non-open and source reconciliation, then remaining admission/publication prerequisites.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — bounded helper/path plan; inherited source scope and parent contracts preserved.', text, count=1)
text = re.sub(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$', lambda m: m[1] + 'PNT: nonadjacent literals, helper/caller, library/process/non-open and reconciliation leaves precede all remaining semantic/native/generated/registration/publication prerequisites.' + m[2], text)
path.write_text(text)
for name, title, body in [('CHANGES.md', 'bound the remaining Perl helper and path work', summary),
    ('DEVELOPMENT_NOTES.md', 'preserve the full helper-path obligation while splitting work', 'The parent remains active and its Goal/Acceptance/Continuation are preserved byte-for-byte as field values. Child source grammars must retain every unqualified site, source condition and target identity; they do not establish evaluated Perl values or callee/alias/phase semantics. Committed inputs are reused through Git revision/blob/SHA256 identities rather than duplicate source archives. Only the newly activated task image and producer need new before-images.')]:
    path = Path(name); text = path.read_text(); offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## 2026-11-17 — ' + title + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md'); text = path.read_text()
for heading, body in {'Current Activity': 'PNT: helper/path obligation split; nonadjacent literal bindings next.', 'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda m: m[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — helper/path work split with full parent/source scope preserved; no new runtime verdict.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean helper-plan activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — bounded helper/path plan.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; inherited source proof: docs/checkpoints/perl-other-io-2026-11-17/REVIEW.md. No new source/runtime classification.\n' +
    '- limits: Full159-source/122 unresolved file operands/130 non-open sites and process role remain. Generated/inline, independent semantics, native/PPI/Perl/outer-first-use/per-read/source-origin/physical4.2/SESSION5 and all registration/publication prerequisites remain.\n' +
    '- publication: Activation/cached4683555e estimates1,498,460,705 bytes/131 ahead/1,539,295-byte trigger margin, excluding this slice. Selected actual telemetry retained; ignored raw pack and independent size/native gaps remain30/4.2. Remeasure after landing.\n' +
    '- preceding_normal: .linkedspec-data/perl-other-io-commit-retry.log completes all10/post-pointer for7354d156; first failed/canceled attempt remains distinct.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial/shared24GB. Last cleanup November16 10:59UTC; run due maintenance at the next clean boundary if24h elapses. Normal hooks mandatory.\n')
path = Path(BOOK); text = path.read_text(); marker = '\nA closed-tree epoch can renew current text capacity'
assert text.count(marker) == 1
path.write_text(text.replace(marker, '\nResolve an unresolved input cohort in bounded stages: fixed variable declarations, helper formal/caller bindings, then library, process and handle origins. Each stage preserves the complete source population and its unresolved sites; a successful lexical stage does not close independent semantic or native-input verification.\n' + marker, 1))
claim = dict(name='helper-plan-activation-outgoing-estimate', statement='Committed activation estimates1,498,460,705 non-thin bytes against cached4683555e, leaving1,539,295 before the director1.5GB trigger.', scope=size['limits'],
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py', granularity='Committed activation/cached-origin serialized range; actual retained selected source/ref/config/command/channels copied after use.', result=json.dumps(size, sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Stream/stat/footer agreement is retained; complete independent actual-file falsification remains30.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='New plan producer/active task before-images and Git-addressed committed inputs retained, with selected actual telemetry. Raw diagnostic pack/full object tables remain ignored on this volume. Full native/physical/outer-first-use/per-read/source-origin/toolchain/OS closure remains4.2/SESSION5. No fresh remote, wire-size or future-growth guarantee.'))
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=[claim]), indent=2) + '\n')
print(summary)
