"""Publish source-only Julia loader qualification without refreshing history."""
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
result = json.loads(gzip.decompress((BASE / 'qualified-stdout.gz').read_bytes()))
assert result['result'] == 'PASS' and len(result['controls']) == 13 and len(result['historical']['matching']) == 69 and not result['historical']['absent']
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
log = Path('.linkedspec-data/lua-ordinary-loader-commit.log'); raw = log.read_bytes()
assert b'doctrines: ALL 10 enforced doctrines PASS.' in raw and b'[memory-pointer] ok: post-commit' in raw
(BASE / 'preceding-normal.log.gz').write_bytes(gzip.compress(raw, mtime=0))
(BASE / 'preceding-normal.json').write_text(json.dumps(dict(source=str(log), commit=ACTIVATION,
    bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=log.stat().st_mode & 0o777,
    recording='after-use copy of the preceding completed commit'), indent=2) + '\n')
telemetry = Path('.linkedspec-data/push-monitor/20261116T222311.531391Z'); (BASE / 'telemetry').mkdir()
copies = []
for path in sorted(telemetry.iterdir()):
    if path.suffix in ('.pack', '.idx', '.log') or path.name.startswith(('objects-', 'object-metadata-')): continue
    target = BASE / 'telemetry' / path.name; shutil.copy2(path, target)
    assert target.read_bytes() == path.read_bytes() and target.stat().st_mode == path.stat().st_mode
    copies.append(dict(source=str(path), target=str(target), bytes=path.stat().st_size,
        sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=path.stat().st_mode & 0o777))
(BASE / 'telemetry-copies.json').write_text(json.dumps(copies, indent=2) + '\n')
summary = ('Julia20 sources account for all52 file-read sites,69 fixture/grammar/support bindings to49 targets,14 same-process generated Modules and12 optional capture conditions. '
    'Three execution qualifications,69 older identities,13 corrected controls and current169 pass; a separate victim oracle exposes the original positional-control defect. No Julia/SDK execution or admission.')
next_action = ('Remeasure committed outgoing size; continue ordinary Rust21 under ' + NEXT +
    ', then generated Rust2 and remaining Perl/transitive3. Separate generated Dart2/frozen-input3 precede registration4.1.2 alongside every other push prerequisite.')
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md'); text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n'); end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node = node.replace('Control defect (owned; repair in this leaf):', 'Control defect (owned/fixed):')
node += '\n  Outcome: ' + summary + '\n  Remaining: Ordinary Rust1/generated Rust2/remaining Perl-transitive3, including eleven unresolved Lua local routes, remain open; generated Dart2/frozen-input3/native4.2 and every other prerequisite stay separate. Source exclusions and host expectation fallbacks are unchanged.\n'
path.write_text(text[:start] + node + text[end:])
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(PARENT) + r'`.*$',
    '| 1 | `' + NEXT + '` | `pending` | Julia loader graphs focused-checked; ordinary Rust1/generated Rust2/remaining Perl-transitive3, generated Dart2 and frozen-input3 precede registration4.1.2. Separate push owners remain. |', path.read_text())
assert count == 1; path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name); text, count = re.subn(r'(?m)^November16 current PNT frontier:.*$',
        'November16 current PNT frontier: Twenty Julia loader graphs ' + OWNER + ' are focused-checked with source exclusions preserved. Ordinary/generated Rust and remaining Perl/transitive qualification, generated Dart package/corpus2 and frozen-input3 precede registration4.1.2/publication30.2; no SDK/admission claim.', path.read_text(), count=1)
    assert count == 1; path.write_text(text)
path = Path('docs/TASK_TREE.md'); text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Julia loader/exclusion qualification is focused-checked; remaining Perl/native/generated-source/population work precedes registration4.1.2/publication30.2.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — twenty Julia loader roles; no SDK or admission.', text, count=1)
text, count = re.subn(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$',
    lambda m: m[1] + 'PNT: Julia loaders focused-checked; remaining Perl/native/population/generated-source work then registration4.1.2. Publication30.2 retains all prerequisites.' + m[2], text)
assert count == 1; path.write_text(text)
for name, heading, body in [('CHANGES.md', '2026-11-16 — qualify Julia direct loader roles', summary),
    ('DEVELOPMENT_NOTES.md', '2026-11-16 — keep Julia file reads, generated Modules and capture timing separate',
     'All20 named native Julia consumers map each direct read to source-derived root aliases and fixed/literal-loop expansions; explicit8/default12 grammar routes remain distinct. Three support includes and14 include_string Modules are classified without Julia execution or fresh-process credit. Three equal-byte capture/readback families precede AST restoration/target compilation and generated inclusion; eight write-only captures follow parsed-AST restoration, with restored compilation occurring later on its route; Count-guard emits stdout/trace only. Original control pop(0) removed Count fallback rather than runtime exclusions. A separate one-branch qualified reader and independent victim-role RED preserve the original epoch while fixing that test. Historical69 identities supply no execution evidence. Native/source-origin and independent full semantic/transitive closure remain open.')]:
    path = Path(name); text = path.read_text(); offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## ' + heading + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md'); text = path.read_text()
for heading, body in {'Current Activity': 'PNT: Julia loader graphs complete; remaining Perl/native qualification precedes registration.',
    'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': next_action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda m: m[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — Julia20/read-sites52/bindings69/targets49/modules14/captures12/qualifications3/current169/thirteen corrected controls and victim oracle; no SDK.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean Julia-loader activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — twenty Julia loader roles and corrected exclusion control.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + next_action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review_qualified.py/optional --current. Julia20/read52/bindings69/targets49/modules14/captures12/qualifications3/historical69/controls13/current169; native113 reused,56 extras. Original control victim RED; one derived branch qualified. No Julia run.\n' +
    '- findings: Fresh Module shares the process; AST restoration and restored compilation have different capture timing. Existing parent/coordinator runtime exclusions and accumulator/non-Perl expectation fallbacks remain explicit. Earlier Julia graph/first result stays exact; qualified control selects its intended role.\n' +
    '- limits: Ordinary Rust1/generated Rust2/remaining Perl-transitive3 include eleven unresolved Lua local routes. Generated Dart2/frozen-input3 and default-literal/repeated ActionIR registration4.1.2 remain separate. Full native/per-read/source-origin/physical4.2/SESSION5 and other prerequisites stay open.\n' +
    '- publication: Director1.5GB trigger governs. Activation/cached4683555e estimate1,478,665,088 bytes/120 ahead/21,334,912-byte margin excludes this slice. Selected telemetry retained; raw pack/full logical tables ignored; independent size falsification30/native4.2 gaps. Remeasure after landing;30.2 needs all prerequisites/exact canonical proof.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GB/director90-percent rising-trend policy. Daily cleanup current; nothing removed. Normal hooks are the mandatory global integrity boundary.\n')
path = Path(BOOK); text = path.read_text(); marker = '\nClosed-task commentary can use the existing explicit epoch interface'
assert text.count(marker) == 1
paragraph = ('\nA Julia generated parser included with `Base.include_string(Module(...), emitted)` gets a new module in the same process. Keep that role separate from file reads and fresh-process execution. Also distinguish restoring parsed JSON into an AST from compiling that restored AST: an optional write after AST restoration can still precede the restored compilation. Capture timing must name the exact operation. For evidence controls, verify which semantic row was removed; deleting the first row can reject a ledger while testing a different qualification from the label.\n')
path.write_text(text.replace(marker, paragraph + marker, 1))
gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Reused113/additional56 original logical bodies/modes, activation Git records, exact first capture/reader/channels and separately retained qualification instruments/derived source/new channels are recoverable. Full Python/Git/Julia/toolchain/library/OS, outer-launcher first-use, qualification-instrument gating, per-read/source-origin and physical custody stays4.2/SESSION5. No Julia/SDK execution or canonical admission.')
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review_qualified.py') + ' --current'
assert result['control_qualification']['original_result'].startswith('RED:')
claims = [dict(name='julia-direct-loader-source-graphs', statement=summary, scope=result['limits'],
    rederive=dict(status='checked', command=command, granularity='Each of20 consumers/all52 filesystem read sites/69 finite fixture-grammar-support bindings,14 generated Module roles,12 capture conditions,three execution qualifications and169 original current bodies/modes.', result=json.dumps(result,sort_keys=True)),
    falsify=dict(status='gap', repair_owner=PARENT+'.3', reason='Ten corrected ledger corruptions reject,69 independent older identities agree and a separate victim oracle distinguishes the original control defect. Complete independent semantic/transitive/selection classification remains remaining3; no Julia/module/cache/path/native resolution follows.'), durability=gap),
    dict(name='historical-julia-loader-identities', statement='All69 distinct selected consumer/target identities match the independent older root ledger; three body/mode/record corruptions reject.',
    scope='Selected logical source/direct-target identities only. Membership supplies no proof of old test execution or per-file read/first-use custody.',
    rederive=dict(status='checked', command=command, granularity='Every selected consumer and distinct direct target versus the dated direct/custody.json root packet files.', result=json.dumps(result['historical'],sort_keys=True)),
    falsify=dict(status='checked', hypothesis='Changed grammar body/mode or falsified older grammar digest could still agree.',
        oracle='Independent dated root-packet metadata compared with archived current bodies and modes, apart from the new source call interpretation.',
        red_control='Appended grammar byte, changed grammar mode and zeroed older grammar digest each reject; healthy69/absent0 agree.'), durability=gap),
    dict(name='julia-exclusion-control-victim-qualification', statement='Original positional runtime-exclusion control removes Count fallback and leaves runtime exclusions; the qualified branch removes exactly the intended role while preserving both expectation qualifications.',
    scope='Only the original control victim versus source-derived role/consumer identities and one retained branch replacement. Original source/result remain exact; no product behavior repair or whole-graph semantic oracle.',
    rederive=dict(status='checked', command=command, granularity='Actual original pop(0) victim, remaining runtime role, exact one-branch derived source and corrected control with two preserved expectation rows.', result=json.dumps(result['control_qualification'],sort_keys=True)),
    falsify=dict(status='checked', hypothesis='A generic ledger rejection means the positional control tested its claimed runtime exclusion.',
        oracle='Separate victim-role/consumer identity check: Count-source fallback is distinct from referenced-blind runtime exclusions, which the original mutation retains.',
        red_control='Original victim is Count fallback and one runtime-exclusion row remains: observed RED for its label. Qualified role removal retains both fallback rows and the graph rejects that actual runtime corruption.'), durability=gap)]
size=json.loads((BASE/'telemetry/result.json').read_bytes())
claims.append(dict(name='activation-outgoing-estimate', statement='Committed activation estimates1,478,665,088 non-thin serialized bytes against cached4683555e;21,334,912 bytes below the director1.5GB trigger.', scope=size['limits'],
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py',
        granularity='Actual committed activation/cached-origin range; selected original producer/ref/config/command channels copied without replay.', result=json.dumps(size,sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Producer stream/stat/footer agree; independent actual-file size falsification remains30.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Selected producer/ref/config/command channels retained; raw pack/full logical tables remain ignored. Full native/physical/input custody stays4.2/SESSION5; no remote freshness/wire claim.')))
Path('docs/claims/'+OWNER+'.json').write_text(json.dumps(dict(version=1,owner=OWNER,claims=claims),indent=2)+'\n')
print(summary)
