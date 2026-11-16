"""Publish the bounded Rust source qualification without refreshing earlier proof."""
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
PARENT = OWNER.rsplit('.', 1)[0]
NEXT = PARENT + '.2'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'publication-bindings.json').exists(), 'one-shot publication'
result = json.loads(gzip.decompress((BASE / 'qualified2-stdout.gz').read_bytes()))
assert result['result'] == 'PASS' and result['current_inputs'] == 159 and len(result['controls']) == 11
assert len(result['historical']['matching']) == 61 and not result['historical']['changed'] and not result['historical']['absent']
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
log = Path('.linkedspec-data/julia-loader-commit.log')
raw = log.read_bytes()
assert b'doctrines: ALL 10 enforced doctrines PASS.' in raw and b'[memory-pointer] ok: post-commit' in raw
(BASE / 'preceding-normal.log.gz').write_bytes(gzip.compress(raw, mtime=0))
(BASE / 'preceding-normal.json').write_text(json.dumps(dict(source=str(log), commit=ACTIVATION,
    bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=log.stat().st_mode & 0o777,
    recording='after-use copy of the preceding completed commit'), indent=2) + '\n')
telemetry = Path('.linkedspec-data/push-monitor/20261116T225243.024321Z')
(BASE / 'telemetry').mkdir()
copies = []
for path in sorted(telemetry.iterdir()):
    if path.suffix in ('.pack', '.idx', '.log') or path.name.startswith(('objects-', 'object-metadata-')):
        continue
    target = BASE / 'telemetry' / path.name
    shutil.copy2(path, target)
    assert target.read_bytes() == path.read_bytes() and target.stat().st_mode == path.stat().st_mode
    copies.append(dict(source=str(path), target=str(target), bytes=path.stat().st_size,
        sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=path.stat().st_mode & 0o777))
(BASE / 'telemetry-copies.json').write_text(json.dumps(copies, indent=2) + '\n')
summary = ('Rust21 sources retain38 literal fixtures plus21 embedded grammar dependencies,59 bindings to39 targets,21 filesystem sites, '
    'five readbacks/six write-only exports/twelve env sites/seven emitted-string roles/three row selectors/two execution qualifications. '
    'Historical61/eleven victim-sensitive controls/current159 and two original reader refusals pass. No Cargo/SDK or admission.')
next_action = ('Remeasure committed outgoing size; qualify generated Rust manifest/corpus/host roles under ' + NEXT +
    ', then remaining Perl/transitive3. Separate generated Dart2/frozen-input3 and all other prerequisites precede registration4.1.2/publication30.2.')

path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n')
end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node = node.replace('Reader defect (owned; repair in this leaf):', 'Reader defect (owned/fixed):')
node = node.replace('Historical-reader defect (owned; repair in this leaf):', 'Historical-reader defect (owned/fixed):')
node += '\n  Outcome: ' + summary + '\n  Remaining: Generated Rust2/remaining Perl-transitive3 include unresolved Lua selection. Generated Dart2/frozen-input3/native4.2 and all other prerequisites remain open; actual old binary embedding and runtime outcomes are unclaimed.\n'
path.write_text(text[:start] + node + text[end:])
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(OWNER) + r'`.*$',
    '| 1 | `' + NEXT + '` | `pending` | Ordinary Rust source loaders focused-checked; generated Rust2/remaining Perl-transitive3, generated Dart2/frozen-input3 precede registration4.1.2. All other publication owners remain. |', path.read_text())
assert count == 1
path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name)
    text, count = re.subn(r'(?m)^November(?:16|17) current PNT frontier:.*$',
        'November17 current PNT frontier: Ordinary Rust21 source loaders ' + OWNER + ' are focused-checked with exact capture/plan roles and both reader corrections retained. Generated Rust2/remaining Perl-transitive3 and generated Dart2/frozen-input3 precede registration4.1.2/publication30.2; no SDK/admission claim.', path.read_text(), count=1)
    assert count == 1
    path.write_text(text)
path = Path('docs/TASK_TREE.md')
text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Ordinary Rust loaders focused-checked; generated Rust, remaining Perl/transitive and generated Dart/population work precede registration4.1.2/publication30.2.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — Rust21 direct loaders and qualified plan/archive interpretations; no SDK/admission.', text, count=1)
text, count = re.subn(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$',
    lambda match: match[1] + 'PNT: Rust21 loaders focused-checked; generated Rust/Perl-transitive/generated Dart/frozen-input work then registration4.1.2. Publication30.2 retains all prerequisites.' + match[2], text)
assert count == 1
path.write_text(text)
notes = ('Compile-time fixture/grammar dependencies do not establish actual binary embedding. Two parsed snapshots are equality-only; three compiled readbacks feed restoration, with retained plan arguments in concat/transform and serialized in callable pipeline. Six intake exports remain write-only with failure assertions intact; emitted strings and row selectors gain no fresh-host/all-row execution credit. First reader overgeneralizes a plan argument; first qualifier assumes a tag field absent from Rust archive/files packets. Separate derived sources retain both failures and complete the same source epoch without capture/SDK replay. Victim-bearing controls now expose their actual selected role.')
for name, title, body in [('CHANGES.md', 'qualify ordinary Rust source loaders', summary),
                          ('DEVELOPMENT_NOTES.md', 'bind Rust capture roles to actual arguments and packet schema', notes)]:
    path = Path(name)
    text = path.read_text()
    offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## 2026-11-17 — ' + title + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md')
text = path.read_text()
for heading, body in {'Current Activity': 'PNT: ordinary Rust loaders complete; generated Rust/Perl-transitive/generated Dart qualification remains.',
    'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': next_action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda match: match[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — Rust21/bindings59/targets39/filesystem21/readbacks5/exports6/current159/historical61/eleven controls/two refusals; no SDK.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean Rust-loader activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — ordinary Rust21 loaders and two qualified reader corrections.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + next_action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review_qualified2.py/optional --current. Rust21/bindings59/targets39/filesystem21/readbacks5/exports6/env12/emission7/selectors3/qualifications2/historical61/controls11/current159; native113 reused,46 extras. Original capture=1/first qualifier=1/qualified2=0 remain exact. No Cargo/SDK.\n' +
    '- findings: Parsed readback is equality-only; compiled readbacks feed restoration, with exact per-consumer plan arguments. Observation exports do not feed producers; emitted strings/row selectors do not establish host/all-row execution. Rust root packet uses archive locator. Both reader defects are fixed in separate qualified sources.\n' +
    '- limits: Generated Rust2/remaining Perl-transitive3 include eleven unresolved Lua routes. Generated Dart2/frozen-input3/default-literal/repeated ActionIR registration and every native/per-read/source-origin/physical4.2/SESSION5 or other prerequisite remain open. Actual binary embedded bytes/manifest anchor are unobserved.\n' +
    '- publication: Director1.5GB trigger governs. Activation/cached4683555e estimate1,478,764,914 bytes/121 ahead/21,235,086-byte margin excludes this slice. Selected telemetry retained; raw pack/full logical tables ignored; independent size falsification30/native4.2 gaps. Remeasure after landing;30.2 needs all prerequisites/exact canonical proof.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GB/director90-percent rising-trend policy. Last cleanup November16 10:59UTC remains under24h; nothing removed. Normal hooks are mandatory integrity.\n')
path = Path(BOOK)
text = path.read_text()
marker = '\nClosed-task commentary can use the existing explicit epoch interface'
assert text.count(marker) == 1
paragraph = ('\nRust `include_str!` supplies compile-time source dependencies; verifying the current file is separate from proving bytes embedded in an older binary. An optional readback can check equality without replacing the object passed to compilation. Follow the actual next argument: restoring from `retained` and calling a plan with `serialized` have distinct provenance even when their values agree. Keep observation-only exports and emitted source strings in their actual roles. Historical packet selection must use that producer’s documented schema, such as an exact archive locator.\n')
path.write_text(text.replace(marker, paragraph + marker, 1))

gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Reused113/additional46 original logical bodies/modes, activation Git bindings, both failed sources/actual channels and separate qualification instruments/derived bodies/success channels are recoverable. Full native/Python/Git/Rust/toolchain/OS, outer-launcher first-use, later qualification-instrument gating, per-read/source-origin and physical custody stays4.2/SESSION5; no Cargo/SDK or canonical admission.')
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review_qualified2.py') + ' --current'
claims = [dict(name='ordinary-rust-loader-source-graphs', statement=summary, scope=result['limits'],
    rederive=dict(status='checked', command=command, granularity='Each of21 consumers/38 fixture macros/21 grammar dependencies/21 filesystem sites and exact conditional readback/output/plan roles;159 original current bodies/modes.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='gap', repair_owner=PARENT + '.3', reason='Eight victim-bearing source graph controls and three historical inverses reject;61 older identities and two original reader refusals distinguish bounded aspects. Complete independent semantic/transitive/selection classification remains remaining3; no actual binary/source-origin proof.'), durability=gap),
    dict(name='historical-rust-loader-identities', statement='All61 distinct selected consumer/target/parser-source identities match the independent older qualified-direct root ledger; absent0/changed0 and three grammar body/mode/record inverses reject.',
    scope='Logical metadata/body/mode comparison only; membership does not establish old test execution, actual binary embedding or per-file reads.',
    rederive=dict(status='checked', command=command, granularity='Each selected consumer, direct target and grammar-owner source versus the dated exact root archive packet.', result=json.dumps(result['historical'], sort_keys=True)),
    falsify=dict(status='checked', hypothesis='Altered grammar body/mode or falsified old digest could retain bundled grammar agreement.', oracle='Independent dated qualified-direct root-packet identities, selected by its actual archive locator, compared with archived current bodies/modes.', red_control='Appended grammar byte, changed grammar mode and zeroed old digest each reject; healthy61 agree.'), durability=gap),
    dict(name='rust-reader-refusal-and-qualification', statement='The original reader rejects retained plan input, then the first qualifier rejects Rust archive/files metadata lacking tag. Both failures remain exact; separately derived source interprets per-consumer arguments and exact root archive selectors.',
    scope='Only these retained reader assumptions, source/packet vocabulary, exact six substitutions across two stages and readonly refusal/success reproduction. No product behavior repair or original capture replay.',
    rederive=dict(status='checked', command=command, granularity='Original AssertionError consumer/line/argument, first qualified KeyError/schema/root packet, full derived bytes and final same-graph proof.', result=json.dumps(dict(original=result['original_reader_refusal'], first_qualified=result['first_qualified_refusal'], qualification=result['qualification']), sort_keys=True)),
    falsify=dict(status='checked', hypothesis='Every captured Rust plan uses serialized, or these Rust packets expose a tag field.', oracle='Actual retained concat/transform/pipeline source call arguments and independent dated archive/files packet keys/root archive locator.', red_control='Original pure reader reproduces AssertionError at concat retained; first historical reader reproduces KeyError tag on four archive/files packets. Qualified argument/schema interpretation passes without changing the source graph or old metadata.'), durability=gap)]
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
claims.append(dict(name='activation-outgoing-estimate', statement='Committed activation estimates1,478,764,914 non-thin serialized bytes against cached4683555e;21,235,086 bytes below the director1.5GB trigger.', scope=size['limits'],
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py', granularity='Actual committed activation/cached-origin range; selected original producer/ref/config/command channels copied without replay.', result=json.dumps(size, sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Producer stream/stat/footer agree; independent actual-file size falsification remains30.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Selected producer/ref/config/command channels retained; raw pack/full logical tables stay ignored. Full native/physical/input custody remains4.2/SESSION5; no fresh-remote/wire claim.')))
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
