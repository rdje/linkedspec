"""Publish bounded Dart loader qualification; preserve originals and declared gaps."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
ACTIVATION = '54f374727558365d616ce6a8539f9ddd02a8e88d'
PARENT = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1'
OWNER, NEXT = PARENT + '.0', PARENT + '.1'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'publication-bindings.json').exists(), 'one-shot publication'
result = json.loads(gzip.decompress((BASE / 'review-qualified-stdout.gz').read_bytes()))
assert result['result'] == 'PASS' and result['historical_bindings'] == 11 and len(result['controls']) == 9
assert result['qualification']['original_capture_exit'] == 1 and result['qualification']['capture_replayed'] is False
documents = [BOOK, 'MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md']
bindings = []
for path in sorted(Path('docs/claims').glob('*.json')):
    for claim in json.loads(path.read_bytes())['claims']:
        leg = claim['durability']
        for item in leg.get('inputs', []):
            if item['path'] in documents:
                assert leg['mode'] == 'historical', 'live binding requires qualified preservation'
                bindings.append(dict(record=str(path), claim=claim['name'], input=item, mode=leg['mode'], revision=leg['revision']))
(BASE / 'publication-bindings.json').write_text(json.dumps(bindings, indent=2, sort_keys=True) + '\n')
log = Path('.linkedspec-data/lua-loader-qualification-commit.log'); body = log.read_bytes()
assert b'doctrines: ALL 10 enforced doctrines PASS.' in body and b'[memory-pointer] ok: post-commit' in body
(BASE / 'preceding-normal.log.gz').write_bytes(gzip.compress(body, mtime=0))
(BASE / 'preceding-normal.json').write_text(json.dumps(dict(source=str(log), commit=ACTIVATION,
    bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=log.stat().st_mode & 0o777,
    recording='after-use copy of the preceding completed commit log'), indent=2) + '\n')
telemetry = Path('.linkedspec-data/push-monitor/20261116T200917.490374Z'); (BASE / 'telemetry').mkdir()
copies = []
for path in sorted(telemetry.iterdir()):
    if path.suffix in ('.pack', '.idx', '.log') or path.name.startswith(('objects-', 'object-metadata-')):
        continue
    target = BASE / 'telemetry' / path.name; shutil.copy2(path, target)
    assert target.read_bytes() == path.read_bytes() and target.stat().st_mode == path.stat().st_mode
    copies.append(dict(source=str(path), target=str(target), bytes=path.stat().st_size,
        sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=path.stat().st_mode & 0o777))
(BASE / 'telemetry-copies.json').write_text(json.dumps(copies, indent=2) + '\n')
summary = ('Three Dart Array normals have nine fixture/grammar edges, two support imports and two optional one-shot readbacks. '
    'Eleven older bindings to nine distinct targets agree; nine controls/current130 pass. The original export-reader refusal '
    'is retained; one qualified regex correction completes the ledger without capture or Dart replay.')
next_action = ('Remeasure committed outgoing size; continue remaining Perl/native loaders/support/dormancy/transitive discovery under ' + NEXT +
    ', with generated Dart package/corpus2 and final registration-input freeze3 separately owned before4.1.2; all push prerequisites remain.')
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md'); text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n'); end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node += '\n  Outcome: ' + summary + '\n  Remaining: Sibling1 owns remaining population/loaders/selection, sibling2 generated package/corpus interpretation, sibling3 registration-input freeze; native4.2 and all other prerequisites stay separate.\n'
path.write_text(text[:start] + node + text[end:])
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text, count = re.subn(r'(?m)^\| 1 \| `TYPE-REFERENCE-BOOK\.1\.2\.23\.4\.1\.1\.1\.1\.1\.1\.1`.*$',
    '| 1 | `' + NEXT + '` | `pending` | Recent Dart Array loaders focused-checked; finish remaining loaders/support/dormancy/transitive discovery, generated-source2 and frozen-input3 before registration4.1.2. Separate push owners remain. |', path.read_text())
assert count == 1; path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name); text, count = re.subn(r'(?m)^November16 current PNT frontier:.*$',
        'November16 current PNT frontier: Three recent Dart Array loaders ' + OWNER + ' are focused-checked with original reader refusal preserved. Remaining loader/population/transitive review, generated package/corpus2 and frozen-input3 precede registration4.1.2/publication30.2; no SDK execution/admission claim.', path.read_text(), count=1)
    assert count == 1; path.write_text(text)
path = Path('docs/TASK_TREE.md'); text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Bounded native/Lua/recent Dart loader qualification is focused-checked; remaining review precedes registration4.1.2/publication30.2.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — three Dart Array loader graphs and retained export-reader qualification; no SDK or admission.', text, count=1)
text, count = re.subn(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$',
    lambda match: match[1] + 'PNT: recent Dart Array loaders focused-checked; remaining loader/population/transitive review and generated-source/freeze before registration4.1.2. Publication30.2 retains all prerequisites.' + match[2], text)
assert count == 1; path.write_text(text)
for name, heading, body in [('CHANGES.md', '2026-11-16 — qualify recent Dart Array loaders', summary),
    ('DEVELOPMENT_NOTES.md', '2026-11-16 — retain Dart loader reader refusal and source epochs',
     'The captured source epoch stays exact after the original single-token return-type regex rejects valid Map<String, Object?> observation entrypoints. A separate reader derives exactly one export-regex replacement, retains its full source, reproduces the original pure-reader refusal and completes the first ledger without capture/SDK replay. Explicit grammar/fixture inputs differ from conditional parsed-output readbacks. Independent direct-run root ledgers agree on eleven bindings; older ordinary parsed-dump/error-field qualifications remain unchanged. Generated-package/corpus dependencies have their own pending owner.')]:
    path = Path(name); text = path.read_text(); offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## ' + heading + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md'); text = path.read_text()
for heading, body in {'Current Activity': 'PNT: recent Dart Array loaders complete; remaining population/loader/transitive review precedes registration.',
    'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': next_action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda match: match[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — Dart3/fixture-grammar9/support2/optional2/historical11-to9/current130/nine controls; original reader refusal retained, no SDK.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean Dart Array-loader activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — three recent Dart Array loader graphs.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + next_action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review_qualified.py/optional --current. Dart3/fixture-grammar9/support2/optional2/historical11-to9/nine controls/current130; three added qualification instruments checked separately. No Dart/SDK executed.\n' +
    '- findings: First export reader wrongly assumes a single-token return type; original capture/source/exit1 retained. Qualified reader changes one exact regex and finishes from the same archive. Capture serializes after parse, writes/reads before compile/restore; older ordinary timing/error-field scope remains4.24-owned. Generated-package/corpus interpretation has explicit sibling2 ownership.\n' +
    '- limits: Remaining Perl/native loader/population/support/dormancy/transitive review stays sibling1; frozen registration input stays3. Eleven Lua local selection routes remain unresolved. Default literal omission/two repeated ActionIR routes remain4.1.2. Native/per-read/source-origin/physical4.2/SESSION5 and declared5.4/formatter/context/shadowing/launcher/literal/excluded owners remain open.\n' +
    '- publication: Director1.5GB trigger governs. Activation/cached4683555e estimate1,478,068,720 bytes/117 ahead/21,931,280-byte margin is dated and excludes this slice. Selected telemetry retained; raw pack/full logical tables ignored, independent size falsification30/native4.2 gaps. Remeasure after landing;30.2 needs all prerequisites/exact canonical proof.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GB/director90-percent rising-trend policy. Daily cleanup current; nothing removed. Normal hooks are the mandatory global integrity boundary.\n')
path = Path(BOOK); text = path.read_text(); marker = '\nClosed-task commentary can use the existing explicit epoch interface'
assert text.count(marker) == 1
paragraph = ('\nDart guard normals can read cases, domain profiles and an explicitly supplied grammar from a declared package cwd. Optional one-shot captures have a different role: they require an allowed phase and an absent target, write parsed JSON, then read and check it before target compilation and restoration. Parsing precedes that write. Preserve those conditions and the original source epoch when qualifying the loader graph; matching historical file identities does not renew an earlier execution or custody claim.\n')
path.write_text(text.replace(marker, paragraph + marker, 1))
gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Retained/reused source bodies/modes, historical metadata, activation Git binding, original refusal, full derived reader and actual command channels are tracked. Complete native Python/Git/library/OS, outer-launcher first-use, per-read/source-origin and physical custody remains4.2/SESSION5. No Dart/SDK or canonical credit.')
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review_qualified.py') + ' --current'
claims = [dict(name='bounded-dart-array-loaders', statement=summary, scope=result['limits'],
    rederive=dict(status='checked', command=command, granularity='Three fixed case/profile/grammar source graphs, two selected observe imports and capture conditions/order;130 epoch source bodies/modes and separate qualification images.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='gap', repair_owner=PARENT, reason='Six source-ledger corruptions reject and eleven independent historical bindings agree, but complete independent semantic/transitive role adjudication remains parent qualification before registration. Source-expression consistency establishes no Dart or path-resolution result.'), durability=gap),
    dict(name='historical-dart-array-direct-input-comparison', statement='Three independently retained direct-run root ledgers agree on eleven selected bindings to nine distinct case/profile/grammar/support targets. Three body/mode/missing-record controls reject.',
    scope='Only the selected historical metadata-to-retained-body/mode comparison. No SDK replay, repaired original first-use, full historical native graph or renewed ordinary parsed-dump timing claim.',
    rederive=dict(status='checked', command=command, granularity='Each selected root-packet file identity from three historical direct/custody.json records compared with its retained body/mode.', result='historical_bindings=11; historical_unique_targets=9; healthy PASS; historical-body/mode/missing controls RED'),
    falsify=dict(status='checked', hypothesis='Changed grammar body/mode or a missing historical grammar record could pass the direct-input comparison.',
        oracle='Three independently captured older direct-run root-packet metadata ledgers, separate from the new source interpretation and archived current target bodies.',
        red_control='Grammar body, grammar mode and removed historical grammar record each reject; healthy eleven bindings agree.'), durability=gap)]
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
claims.append(dict(name='activation-outgoing-estimate', statement='Committed activation estimates1,478,068,720 non-thin serialized bytes against cached4683555e;21,931,280 bytes below the director1.5GB trigger.', scope=size['limits'],
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py',
        granularity='Actual committed activation/cached-origin range; selected original producer/ref/config/command channels copied without replay.', result=json.dumps(size, sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Producer stream/stat/footer agree; independent actual-file size falsification remains30. This slice does not infer it from copied metadata.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Selected producer/ref/config/command channels are tracked. Raw pack/full logical object tables remain ignored; complete native/physical/input custody stays4.2/SESSION5. No remote freshness or wire-size claim.')))
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
