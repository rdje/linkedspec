"""Land the bounded source qualification, preserving original historical scopes."""
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
PLAN = json.loads((BASE / 'publication-plan.json').read_bytes())
OWNER, ACTIVATION = PLAN['owner'], PLAN['activation']
NEXT = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.3.1.1.1.1'
TARGET = 'docs/tasks/STAGED-LINKED-PARSING.md'
MANIFEST = 'docs/history/task-narrative-epochs/' + OWNER + '.json'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'publication-bindings.json').exists(), 'one-shot publication'
result = json.loads(gzip.decompress((BASE / 'commands/review-stdout.gz').read_bytes()))
assert result['result'] == 'PASS' and result['saved_bytes'] == 11972 and result['public_queries'] == 16 and result['current_target_and_manifest'] == 'PASS'
assert len(result['controls']) == 10 and all(row['result'] == 'RED' for row in result['controls'].values())
documents = [TARGET, MANIFEST, BOOK, 'MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md']
bindings = []
for path in sorted(Path('docs/claims').glob('*.json')):
    for claim in json.loads(path.read_bytes())['claims']:
        leg = claim['durability']
        for item in leg.get('inputs', []):
            if item['path'] in documents:
                assert leg['mode'] == 'historical', 'live binding requires separate preservation'
                bindings.append(dict(record=str(path), claim=claim['name'], input=item, mode=leg['mode'], revision=leg['revision']))
(BASE / 'publication-bindings.json').write_text(json.dumps(bindings, indent=2, sort_keys=True) + '\n')
identities = {}
with tarfile.open(BASE / 'publication-before.tar.gz', 'x:gz') as archive:
    for name in sorted(set(documents) | {str(BASE / n) for n in ('publish.py', 'prepare_publication.py', 'review_publication.py', 'publication-plan.json', 'scan.json', 'commands/review-stdout.gz', 'parent-review.json')}):
        path = Path(name)
        body = path.read_bytes()
        identities[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
        archive.add(path, arcname=name, recursive=False)
(BASE / 'publication-before-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
copies = []
for label, source in [('preceding-normal', '.linkedspec-data/perl-literal-open-commit-retry.log'),
    ('capture-outer', '.linkedspec-data/task-headroom-staged-capture.log'), ('parent-outer', '.linkedspec-data/task-headroom-staged-parent-review.log')]:
    path = Path(source)
    body = path.read_bytes()
    if label == 'preceding-normal':
        assert b'doctrines: ALL 10 enforced doctrines PASS.' in body and b'[memory-pointer] ok: post-commit' in body
    target = BASE / (label + '.log.gz')
    target.write_bytes(gzip.compress(body, mtime=0))
    copies.append(dict(source=source, target=str(target), bytes=len(body), sha256=hashlib.sha256(body).hexdigest(),
        mode=stat.S_IMODE(path.stat().st_mode), recording='after-use copy; no original first-use credit'))
(BASE / 'log-copies.json').write_text(json.dumps(copies, indent=2) + '\n')
telemetry = Path('.linkedspec-data/push-monitor/20261117T053734.081477Z')
(BASE / 'telemetry').mkdir()
copies = []
for path in sorted(telemetry.iterdir()):
    if path.suffix in ('.pack', '.idx', '.log') or path.name.startswith(('objects-', 'object-metadata-')):
        continue
    target = BASE / 'telemetry' / path.name
    shutil.copy2(path, target)
    assert target.read_bytes() == path.read_bytes() and target.stat().st_mode == path.stat().st_mode
    copies.append(dict(source=str(path), target=str(target), bytes=path.stat().st_size,
        sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode)))
(BASE / 'telemetry-copies.json').write_text(json.dumps(copies, indent=2) + '\n')
summary = ('The existing staged-task epoch preserves15 ordered IDs/all CORE fields, two full unselected bodies and the19108-byte frontier/tail. '
    'Thirteen closed pointers reduce current text43523 to31551 bytes, renewing11972 bytes under unchanged limits. '
    'All16 public queries/ten corruption controls/current target-manifest identities pass. Parent links35/36 pass three public queries/two controls. No SDK or new runtime/admission credit.')
action = 'Remeasure committed outgoing size; resume direct literal-variable IO under ' + NEXT + ', then other literal IO/helper/support/generated roles and all broader semantic/native/registration/publication prerequisites.'
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n')
end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node += '  Outcome: Staged epoch15 IDs/13 pointers/two unchanged bodies/tail19108 exact;43523 to31551/11972 renewed;16 queries/ten controls/current identity PASS. Parent links35/36: three public queries/two REDs; original35 node existed without its parent link. Full proof/limits in Evidence.\n'
path.write_text(text[:start] + node + text[end:])
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(OWNER) + r'`.*$', '| 1 | `' + NEXT + '` | `pending` | Task capacity renewed; resume literal variable bindings, then other IO/helper/support/generated and all admission prerequisites. |', path.read_text())
assert count == 1
path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name)
    text, count = re.subn(r'(?m)^November17 current PNT frontier:.*$', 'November17 current PNT frontier: Existing staged-task epoch36 is focused-checked:15 IDs/13 pointers/two bodies/full tail/11972 text bytes renewed; parent links35/36 repaired. Perl variable literals1/other IO2 and constructed/helper/support/generated roles precede broader reconciliation, generated Dart/frozen-input, registration4.1.2/publication30.2. No runtime admission.', path.read_text(), count=1)
    assert count == 1
    path.write_text(text)
path = Path('docs/TASK_TREE.md')
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Staged closed-task capacity renewed; Perl variable literals1/other IO2 and constructed/helper/support/generated roles precede remaining semantic/native/registration/publication prerequisites.', path.read_text(), count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — staged epoch15 IDs/13 pointers/16 queries/ten controls/11972 bytes; parent links35/36 repaired.', text, count=1)
text, count = re.subn(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$', lambda hit: hit[1] + 'PNT: existing staged-task epoch36 complete; Perl variable/other/helper/support/generated roles and all admission/publication prerequisites remain.' + hit[2], text)
assert count == 1
path.write_text(text)
notes = 'Independent source planning and actual epoch output agree on13 closed narratives. All CORE fields,15 ordered IDs, two unselected bodies and the complete19108-byte frontier/tail remain exact; all16 original-source public queries and ten effective mutations pass. One prior historical target binding remains unchanged. The current parent field omitted already completed35; links35/36 now match three actual public queries and reject two missing-link controls. Previous literal-open failed/partial and successful normal attempts remain distinct; only the complete retry is reused. No tools, limits, source behavior or original SDK verdicts change.'
for name, title, body in [('CHANGES.md', 'renew staged closed-task narrative capacity', summary), ('DEVELOPMENT_NOTES.md', 'preserve closed staged contracts and parent routing', notes)]:
    path = Path(name)
    text = path.read_text()
    offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## 2026-11-17 — ' + title + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md')
text = path.read_text()
for heading, body in {'Current Activity': 'PNT: staged closed-task capacity renewed; Perl literal variable IO resumes.', 'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda hit: hit[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — staged epoch15/13 pointers/two bodies/16 queries/ten controls/11972 text bytes; parent links35/36 repaired.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean staged-task epoch activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — closed staged-task capacity and parent-link repair.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review.py/optional --current, parent_links.py and public epoch reader. All15 IDs/CORE/two bodies/tail19108/13 pointers/16 queries/ten controls/current identity;43523 to31551 bytes.\n' +
    '- findings: 11972 current text bytes renewed under unchanged tools/limits. Parent35 link was absent despite its existing completed node;35/36 now pass three public queries/two controls. Old source/SDK facts remain historical; no new runtime/admission proof.\n' +
    '- limits: Full145 variable literals1/other IO2, constructed/helper/support/generated-inline, excluded/computed/transitive/independent semantics, generated Dart/frozen-input and registration remain open. Native/PPI/Perl/outer-first-use/per-read/source-origin/physical4.2/SESSION5 and original Lua reader gap remain.\n' +
    '- publication: Activation/cached4683555e estimate1,491,724,655 bytes/128 ahead/8,275,345-byte margin to director1.5GB excludes this slice. Selected telemetry retained; raw pack/full tables ignored; independent size30/native4.2 gaps. Remeasure after landing; all prerequisites/exact canonical proof remain.\n' +
    '- preceding_normal: .linkedspec-data/perl-literal-open-commit-retry.log is complete all10/post-pointer PASS; first commit.log remains the failed/interrupted attempt.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GB/director90-percent rising trend policy. Last cleanup November16 10:59UTC remains under24h; nothing removed. Normal hooks mandatory.\n')
path = Path(BOOK)
text = path.read_text()
marker = '\nClosed-task commentary can use the existing explicit epoch interface'
assert text.count(marker) == 1
paragraph = '\nThe closed staged-parsing tree uses the same source-retaining interface:15 ordered IDs and all CORE fields, two full unselected bodies and the19108-byte frontier/tail remain current. Thirteen commentary pointers renew11972 text bytes. The whole-source query and every node query reproduce the original bytes. For this dated source, run `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree STAGED-LINKED-PARSING --epoch TYPE-REFERENCE-BOOK.1.2.23.4.36 --all`. This changes task text capacity, with original runtime observations still historical.\n'
path.write_text(text.replace(marker, paragraph + marker, 1))
gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Original/current task and manifest bodies/modes, source-bound planner, actual capture/reviewer/composition sources and command/query channels are retained. The migrator internally checks before the separate after-image; original outer/internal first-use and full Python/Perl/Git/toolchain/OS/native/per-read/source-origin/physical custody remain4.2/SESSION5. Parent proof has bounded project inputs, not full library/native closure. No SDK or fresh runtime admission.')
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review.py') + ' --current'
claims = [dict(name='staged-closed-task-narrative-preservation', statement=summary, scope=result['limits'], rederive=dict(status='checked', command=command, granularity='Every ordered ID/CORE field, exact unselected body, prefix/frontier/tail/mode and all16 actual public query outputs with independent preflight/renderer comparison.', result=json.dumps(result, sort_keys=True)), falsify=dict(status='checked', hypothesis='An epoch could lose a contract, source byte, node, unselected body or exact pointer while preservation still passed.', oracle='Independent field-state parser and full source/current byte comparison, separately checked through actual public whole-source/every-ID outputs.', red_control='Ten actual prefix/tail/status/goal/node/unselected/pointer/source/selection/mode corruptions reject with recorded reasons; healthy finite preservation passes.'), durability=gap)]
parent = json.loads((BASE / 'parent-review.json').read_bytes())
claims.append(dict(name='current-parent-links35-36', statement='Completed35 existed without its parent child link; current links35/36 pass three public node queries and two effective missing-link controls.', scope=parent['limits'], rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + str(BASE / 'parent_links.py'), granularity='Exact source at activation, captured current parent/part/index/root, three actual public API outputs and both altered link victims.', result=json.dumps(parent, sort_keys=True)), falsify=dict(status='checked', hypothesis='Either required link could be omitted while the parent-link oracle still passed.', oracle='Original committed parent/source node and actual current public-reader block compared with retained current source.', red_control='Removing35 fails required parent link.35; removing36 fails required parent link.36; healthy current parent and both child queries pass.'), durability=gap))
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
claims.append(dict(name='activation-outgoing-estimate', statement='Activation estimates1,491,724,655 non-thin bytes against cached4683555e;8,275,345 below director1.5GB.', scope=size['limits'], rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py', granularity='Actual committed activation/cached-origin estimate and selected original metadata copied after use.', result=json.dumps(size, sort_keys=True)), falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Stream/stat/footer agree; independent actual-file falsification remains30.'), durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Selected telemetry retained; ignored raw pack/full tables and full native/physical/producer closure remain4.2/SESSION5. No fresh-remote/wire/future guarantee.')))
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
