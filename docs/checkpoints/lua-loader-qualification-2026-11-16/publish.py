"""Publish a bounded loader companion, preserving existing historical claim values."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
ACTIVATION = '341f488d36b15cb39069db32a74e3dc5d82a70d8'
PARENT = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1'
OWNER, NEXT = PARENT + '.0', PARENT + '.1'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'publication-bindings.json').exists(), 'one-shot publication'
result = json.loads(gzip.decompress((BASE / 'review-stdout.gz').read_bytes()))
assert result['result'] == 'PASS' and result['historical_inputs'] == 6 and len(result['controls']) == 10
documents = [BOOK, 'MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md']
bindings = []
for path in sorted(Path('docs/claims').glob('*.json')):
    for claim in json.loads(path.read_bytes())['claims']:
        leg = claim['durability']
        for item in leg.get('inputs', []):
            if item['path'] in documents:
                assert leg['mode'] == 'historical', 'live binding requires preservation before publication'
                bindings.append(dict(record=str(path), claim=claim['name'], input=item, mode=leg['mode'], revision=leg['revision']))
(BASE / 'publication-bindings.json').write_text(json.dumps(bindings, indent=2, sort_keys=True) + '\n')
log = Path('.linkedspec-data/native-consumer-routes-commit.log'); body = log.read_bytes()
assert b'doctrines: ALL 10 enforced doctrines PASS.' in body and b'[memory-pointer] ok: post-commit' in body
(BASE / 'preceding-normal.log.gz').write_bytes(gzip.compress(body, mtime=0))
(BASE / 'preceding-normal.json').write_text(json.dumps(dict(source=str(log), commit=ACTIVATION,
    sha256=hashlib.sha256(body).hexdigest(), bytes=len(body), mode=log.stat().st_mode & 0o777,
    recording='after-use copy; this log belongs to the preceding completed commit'), indent=2) + '\n')
telemetry = Path('.linkedspec-data/push-monitor/20261116T194006.431077Z'); (BASE / 'telemetry').mkdir()
copies = []
for path in sorted(telemetry.iterdir()):
    if path.suffix in ('.pack', '.idx', '.log') or path.name.startswith(('objects-', 'object-metadata-')):
        continue
    target = BASE / 'telemetry' / path.name; shutil.copy2(path, target)
    assert target.read_bytes() == path.read_bytes() and target.stat().st_mode == path.stat().st_mode
    copies.append(dict(source=str(path), target=str(target), bytes=path.stat().st_size,
        sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=path.stat().st_mode & 0o777))
(BASE / 'telemetry-copies.json').write_text(json.dumps(copies, indent=2) + '\n')
summary = ('Eleven Lua direct-loader sources have24 fixture/grammar edges to14 distinct targets, two returned support modules '
    'and two optional write/readback families. The older raw-error ledger agrees on six inputs; ten controls reject. '
    'All134 retained source bodies/modes match current inputs, reusing113 and adding21. No SDK execution or transitive selection claim.')
next_action = ('Remeasure committed outgoing size; complete remaining Perl/native loaders, support/dormancy and transitive discovery under ' + NEXT +
    ' before freezing registration4.1.2 input; all separate before-push owners remain.')
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md'); text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n'); end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node += '\n  Outcome: ' + summary + '\n  Remaining: All eleven local Lua selection routes and broader independent semantic/population review remain with sibling1; registration4.1.2 and native4.2 stay separate.\n'
path.write_text(text[:start] + node + text[end:])
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text, count = re.subn(r'(?m)^\| 1 \| `TYPE-REFERENCE-BOOK\.1\.2\.23\.4\.1\.1\.1\.1\.1\.1`.*$',
    '| 1 | `' + NEXT + '` | `pending` | Bounded native routes and eleven Lua direct loaders are focused-checked; finish remaining loaders/support/dormancy/transitive discovery, then freeze registration4.1.2. Separate push owners remain. |', path.read_text())
assert count == 1; path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name); text, count = re.subn(r'(?m)^November16 current PNT frontier:.*$',
        'November16 current PNT frontier: Eleven Lua direct loaders ' + OWNER + ' are focused-checked using the retained native epoch. Remaining loaders/support/dormancy/transitive routes precede registration4.1.2 and publication30.2; no SDK execution/full population/admission claim.', path.read_text(), count=1)
    assert count == 1; path.write_text(text)
path = Path('docs/TASK_TREE.md'); text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Bounded native routes and eleven Lua direct loaders are focused-checked; remaining qualification precedes registration4.1.2/publication30.2.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — direct Lua fixture/grammar/support/output-readback roles; no SDK or admission.', text, count=1)
text, count = re.subn(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$',
    lambda match: match[1] + 'PNT: Lua direct loaders focused-checked; remaining loaders/support/transitive discovery then registration4.1.2. Publication30.2 retains all prerequisites.' + match[2], text)
assert count == 1; path.write_text(text)
for name, heading, body in [('CHANGES.md', '2026-11-16 — qualify eleven Lua candidates direct loaders', summary),
    ('DEVELOPMENT_NOTES.md', '2026-11-16 — reuse source epochs and separate Lua read roles',
     'The unchanged native archive supplies suite sources; only additional direct inputs are archived. Fixed/list reads, cached/default versus explicit grammar, returned support modules and optional output readbacks have separate source expressions. The raw-error persist helper writes before two readbacks; support exports are not standalone suites. The older independent six-input ledger agrees; nullable phase authority remains excluded. No prior claim or result is refreshed.')]:
    path = Path(name); text = path.read_text(); offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## ' + heading + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md'); text = path.read_text()
for heading, body in {'Current Activity': 'PNT: bounded Lua direct loaders complete; remaining loader/support/transitive qualification precedes registration.',
    'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': next_action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda match: match[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — Lua11/direct24/targets14/support2/optional2/historical6/current134/ten controls; no SDK.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean Lua direct-loader activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — eleven Lua direct input/support roles.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + next_action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review.py/optional --current. Lua11/direct24/targets14/support2/optional2; old raw-error6 identities/ten controls/current134. Reuses113 source images, adds21; no SDK executed.\n' +
    '- findings: Eleven Lua local selection routes still need transitive qualification. Returned observation helpers are support; optional parsed/emitted capture reads its own output after writing. Cached default grammar is module-relative, actual runtime resolution unobserved. Prior Perl/Dart/native route evidence remains dated/static.\n' +
    '- limits: Remaining Perl/native loaders/support/dormancy/transitive/independent semantic population review stays with sibling1. Default literal omission/two repeated ActionIR routes remain4.1.2-owned. Full native/per-read/source-origin/physical closure stays4.2/SESSION5; declared5.4/formatter/context/shadowing/launcher/literal/excluded owners stay open.\n' +
    '- publication: Director1.5GB trigger governs. Activation/cached4683555e estimate1,477,999,832 bytes/116 ahead/22,000,168-byte margin is dated and excludes this slice. Selected telemetry retained; raw pack/full logical tables ignored, independent size falsification30/native4.2 gaps. Remeasure after landing;30.2 needs all prerequisites/exact canonical proof.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GB/director90-percent rising-trend policy. Daily cleanup current; nothing removed. Normal hooks are the mandatory global integrity boundary.\n')
path = Path(BOOK); text = path.read_text(); marker = '\nClosed-task commentary can use the existing explicit epoch interface'
assert text.count(marker) == 1
paragraph = ('\nLua direct input review separates immutable fixtures from generated capture outputs. A suite may iterate literal fixture paths, obtain a cached module-relative function grammar, or explicitly supply that grammar. A `dofile` returning observation functions is a support input. Optional capture helpers may write parsed JSON or emitted source before reading those bytes back; those paths are outputs with readback dependencies. Retain the source expressions and conditions, then compare earlier input ledgers without assigning new execution or canonical-selection credit.\n')
path.write_text(text.replace(marker, paragraph + marker, 1))
gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Reused and additional logical source bodies/modes, activation Git binding, instruments and command channels are retained. Complete native Python/Git/library/OS, outer-launcher first-use, per-read/source-origin and physical custody remain4.2/SESSION5. No SDK or canonical credit.')
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review.py') + ' --current'
claims = [dict(name='bounded-lua-direct-loaders', statement=summary, scope=result['limits'],
    rederive=dict(status='checked', command=command, granularity='Each named suite/input expression, returned support export, optional write/readback condition; all134 reused/additional bodies and modes.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='gap', repair_owner=PARENT, reason='Seven source-ledger corruptions reject and the independent historical six-input subset agrees, but full independent semantic/transitive adjudication of every edge remains parent1. Static expression agreement establishes no SDK lookup or execution.'), durability=gap),
    dict(name='historical-raw-error-direct-input-comparison', statement='All six named raw-error suite/helper/fixture/grammar byte and mode identities agree with its older independent normal input ledger. Three body/mode/missing-record controls reject.',
    scope='Exactly the six named historical direct inputs. No new normal/SDK run, earlier first-use repair, complete native input graph or broader history verdict.',
    rederive=dict(status='checked', command=command, granularity='Six actual archived bodies and modes versus the independently retained older normal input-identities.json.', result='historical_inputs=6; body/mode/missing-record controls RED; healthy comparison PASS'),
    falsify=dict(status='checked', hypothesis='A substituted grammar body/mode or absent historical grammar record could still pass.',
        oracle='The prior raw-error normal input ledger is an independently captured historical list of exact bytes/modes, separate from the new loader reconstruction.',
        red_control='Changed grammar body, changed grammar mode and removed historical grammar record each reject; all six healthy identities agree.'), durability=gap)]
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
claims.append(dict(name='activation-outgoing-estimate', statement='Committed activation estimates1,477,999,832 non-thin serialized bytes against cached4683555e;22,000,168 bytes below the director1.5GB trigger.', scope=size['limits'],
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py',
        granularity='Actual committed activation/cached-origin range; selected original producer/ref/config/command channels copied without replay.', result=json.dumps(size, sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='The producer stream/stat/footer agree; independent actual-file size falsification remains30. This companion does not infer it from metadata.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Selected actual producer/ref/config/command channels are tracked. Raw pack and complete logical object tables remain ignored; full native/physical/input custody stays4.2/SESSION5. No remote freshness or wire-size claim.')))
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
