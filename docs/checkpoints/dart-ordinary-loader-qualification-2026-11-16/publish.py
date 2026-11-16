"""Publish source-only ordinary Dart loader qualification without refreshing history."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PLAN = json.loads((BASE / 'plan.json').read_bytes())
OWNER, ACTIVATION = PLAN['owner'], PLAN['activation']
PARENT = OWNER.rsplit('.', 1)[0]; NEXT = PARENT + '.1'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'publication-bindings.json').exists(), 'one-shot publication'
result = json.loads(gzip.decompress((BASE / 'review-stdout.gz').read_bytes()))
assert result['result'] == 'PASS' and len(result['controls']) == 12 and result['historical_bindings'] == result['input_edges']
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
log = Path('.linkedspec-data/dart-array-loader-commit.log'); raw = log.read_bytes()
assert b'doctrines: ALL 10 enforced doctrines PASS.' in raw and b'[memory-pointer] ok: post-commit' in raw
(BASE / 'preceding-normal.log.gz').write_bytes(gzip.compress(raw, mtime=0))
(BASE / 'preceding-normal.json').write_text(json.dumps(dict(source=str(log), commit=ACTIVATION,
    bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=log.stat().st_mode & 0o777,
    recording='after-use copy of the preceding completed commit'), indent=2) + '\n')
telemetry = Path('.linkedspec-data/push-monitor/20261116T204051.758633Z'); (BASE / 'telemetry').mkdir()
copies = []
for path in sorted(telemetry.iterdir()):
    if path.suffix in ('.pack', '.idx', '.log') or path.name.startswith(('objects-', 'object-metadata-')): continue
    target = BASE / 'telemetry' / path.name; shutil.copy2(path, target)
    assert target.read_bytes() == path.read_bytes() and target.stat().st_mode == path.stat().st_mode
    copies.append(dict(source=str(path), target=str(target), bytes=path.stat().st_size,
        sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=path.stat().st_mode & 0o777))
(BASE / 'telemetry-copies.json').write_text(json.dumps(copies, indent=2) + '\n')
summary = (f"Ordinary Dart{result['consumers']} sources account for all{result['read_sites']} explicit string-read sites, "
    f"{result['input_edges']} fixture/grammar bindings to{result['unique_targets']} targets and matching historical identities. "
    f"Four source qualifications/two inline policy rows remain explicit; twelve controls/current{result['current_inputs']} pass. No Dart/SDK or admission credit.")
next_action = ('Remeasure committed outgoing size; continue remaining Perl/Rust/Julia/Lua loaders/support/dormancy/transitive qualification under ' + NEXT +
    '; generated Dart package/corpus2 and frozen-input3 remain separate before registration4.1.2, alongside every other push prerequisite.')
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md'); text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n'); end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node += '\n  Outcome: ' + summary + '\n  Remaining: Sibling1 owns remaining backends/Perl and population/selection; generated Dart source2/frozen-input3/native4.2 and all other prerequisites stay open.39.8.1 exclusions are unchanged.\n'
path.write_text(text[:start] + node + text[end:])
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(PARENT) + r'`.*$',
    '| 1 | `' + NEXT + '` | `pending` | Ordinary Dart loader graphs focused-checked; remaining Perl/Rust/Julia/Lua qualification, generated-source2 and frozen-input3 precede registration4.1.2. Separate push owners remain. |', path.read_text())
assert count == 1; path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name); text, count = re.subn(r'(?m)^November16 current PNT frontier:.*$',
        'November16 current PNT frontier: Sixteen ordinary Dart loader graphs ' + OWNER + ' are focused-checked with source exclusions preserved. Remaining Perl/native qualification, generated Dart package/corpus2 and frozen-input3 precede registration4.1.2/publication30.2; no SDK/admission claim.', path.read_text(), count=1)
    assert count == 1; path.write_text(text)
path = Path('docs/TASK_TREE.md'); text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Ordinary Dart loader/exclusion qualification is focused-checked; remaining Perl/native/generated-source/population work precedes registration4.1.2/publication30.2.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — sixteen ordinary Dart loader/exclusion graphs; no SDK or admission.', text, count=1)
text, count = re.subn(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$',
    lambda m: m[1] + 'PNT: ordinary Dart loaders focused-checked; remaining Perl/native/population/generated-source work then registration4.1.2. Publication30.2 retains all prerequisites.' + m[2], text)
assert count == 1; path.write_text(text)
for name, heading, body in [('CHANGES.md', '2026-11-16 — qualify ordinary Dart fixture loaders', summary),
    ('DEVELOPMENT_NOTES.md', '2026-11-16 — account for constructed Dart reads without erasing exclusions',
     'Remaining population comes from the native ledger minus earlier Dart manifests and generated-source owner. Every explicit readAsStringSync site maps to a fixed/list/stem/suffix expansion; consumer-level grammar remains explicit or cached/default without runtime-resolution credit. Three referenced runtime exclusions, an accumulator override, compile-only negatives and inline copied-null policy observations retain their scopes. The older root packet matches all file identities but captured more than its selected tests; no execution follows from membership. No original claim hash/result or consumer code changes.')]:
    path = Path(name); text = path.read_text(); offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## ' + heading + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md'); text = path.read_text()
for heading, body in {'Current Activity': 'PNT: ordinary Dart loader graphs complete; remaining Perl/native qualification precedes registration.',
    'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': next_action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda m: m[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — Dart16/read-sites23/bindings46/targets30/qualifications4/inline2/current152/twelve controls; no SDK.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean ordinary Dart-loader activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — sixteen ordinary Dart loader/exclusion graphs.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + next_action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review.py/optional --current. Dart16/read-sites23/fixture-grammar46/targets30/historical46/four qualifications/two inline rows/twelve controls/current152; native113 reused,39 additional inputs. No SDK run.\n' +
    '- findings: Captured-root membership supplies identity, not old test execution.39.8.1 retains three referenced runtime exclusions and accumulator override; compile-only negatives and AST/inline policy roles remain explicit. Earlier Dart six/recent3 and native/Lua/Perl ledgers remain dated/static; generated source remains separately owned2.\n' +
    '- limits: Remaining Perl/Rust/Julia/Lua loader/population/support/dormancy/transitive review stays sibling1; frozen-input3 remains separate. Eleven Lua local routes/default literal omission/repeated ActionIR routes remain4.1.2-owned. Native/per-read/source-origin/physical4.2/SESSION5, declared5.4/formatter/context/shadowing/launcher/literal/excluded owners stay open.\n' +
    '- publication: Director1.5GB trigger governs. Activation/cached4683555e estimate1,478,295,277 bytes/118 ahead/21,704,723-byte margin is dated and excludes this slice. Selected telemetry retained; raw pack/full logical tables ignored, independent size falsification30/native4.2 gaps. Remeasure after landing;30.2 needs all prerequisites/exact canonical proof.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GB/director90-percent rising-trend policy. Daily cleanup current; nothing removed. Normal hooks are the mandatory global integrity boundary.\n')
path = Path(BOOK); text = path.read_text(); marker = '\nClosed-task commentary can use the existing explicit epoch interface'
assert text.count(marker) == 1
paragraph = ('\nA constructed fixture path needs its caller vocabulary as well as its read expression. For example, a `fixture(extension)` helper called with `spec` and `json` reads two files; a stem helper or literal loop may expand one read site into several targets. Keep inline observations and AST/domain snapshots in their actual roles. Registering a suite that skips named runtime cases or preserves a backend-specific expected value does not close those independently owned qualifications. An older broad root snapshot can corroborate file identities without proving that every captured test ran.\n')
path.write_text(text.replace(marker, paragraph + marker, 1))
gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Reused/additional logical source bodies/modes, actual Git binding, instruments and command channels are retained. Complete Python/Git/toolchain/library/OS, outer-launcher first-use, per-read/source-origin and physical custody remains4.2/SESSION5. No SDK or canonical admission.')
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review.py') + ' --current'
claims = [dict(name='ordinary-dart-loader-source-graphs', statement=summary, scope=result['limits'],
    rederive=dict(status='checked', command=command, granularity='Each of16 source consumers, all23 explicit string-read sites, finite path expansions/grammar edges, source qualifications/inline rows and152 retained bodies/modes.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='gap', repair_owner=PARENT, reason='Nine graph corruptions reject and all46 older metadata bindings agree. Full independent semantic/transitive classification remains with remaining qualification; source consistency and read-site accounting supply no actual SDK/cache/module resolution.'), durability=gap),
    dict(name='historical-ordinary-dart-file-identity-comparison', statement='All46 graph bindings to30 distinct targets match an independently captured older root-packet file ledger; three body/mode/missing-record controls reject.',
    scope='Only selected historical metadata versus retained file bodies/modes. The broad root image captured more than its command selected; no claim that these16 consumers ran or read each file in that older SDK execution.',
    rederive=dict(status='checked', command=command, granularity='Every expanded fixture/grammar binding versus the older direct/custody.json root packet file identity.', result='historical_bindings=46; unique_targets=30; healthy PASS; historical body/mode/missing-record RED'),
    falsify=dict(status='checked', hypothesis='A changed grammar body/mode or absent older identity could pass.',
        oracle='Independently retained older root-packet identity metadata, separate from the new source read-site graph and archived target bodies.',
        red_control='Changed grammar body, changed grammar mode and removed root-packet grammar record each reject; healthy46 bindings agree.'), durability=gap)]
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
claims.append(dict(name='activation-outgoing-estimate', statement='Committed activation estimates1,478,295,277 non-thin serialized bytes against cached4683555e;21,704,723 bytes below the director1.5GB trigger.', scope=size['limits'],
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py',
        granularity='Actual committed activation/cached-origin range; selected original producer/ref/config/command channels copied without replay.', result=json.dumps(size, sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Producer stream/stat/footer agree; independent actual-file size falsification remains30, not inferred from metadata.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Selected producer/ref/config/command channels retained; raw pack/full logical tables remain ignored. Full native/physical/input custody remains4.2/SESSION5. No remote freshness/wire claim.')))
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
