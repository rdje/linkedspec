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
PLAN = json.loads((BASE / 'plan.json').read_bytes())
OWNER, ACTIVATION = PLAN['owner'], PLAN['activation']
NEXT = OWNER.rsplit('.', 1)[0] + '.1'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'publication-bindings.json').exists(), 'one-shot publication'
result = json.loads(gzip.decompress((BASE / 'commands/review-stdout.gz').read_bytes()))
assert result['result'] == 'PASS' and result['current_inputs'] == 31 and result['include_sites'] == 14
assert len(result['controls']) == 8 and set(result['controls'].values()) == {'RED'}
documents = [BOOK, 'MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
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
    for name in sorted(set(documents) | {str(BASE / n) for n in ('publish.py', 'review_publication.py', 'plan.json', 'roles.json', 'commands/review-stdout.gz')}):
        path = Path(name)
        body = path.read_bytes()
        identities[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
        archive.add(path, arcname=name, recursive=False)
(BASE / 'publication-before-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
copies = []
for label, source in [('preceding-normal', '.linkedspec-data/perl-token-census-commit.log'),
    ('capture-outer', '.linkedspec-data/perl-named-includes-capture.log'), ('review-outer', '.linkedspec-data/perl-named-includes-review.log'),
    ('plan-outer', '.linkedspec-data/perl-named-includes-plan.log')]:
    path = Path(source)
    body = path.read_bytes()
    if label == 'preceding-normal':
        assert b'doctrines: ALL 10 enforced doctrines PASS.' in body and b'[memory-pointer] ok: post-commit' in body
    target = BASE / (label + '.log.gz')
    target.write_bytes(gzip.compress(body, mtime=0))
    copies.append(dict(source=source, target=str(target), bytes=len(body), sha256=hashlib.sha256(body).hexdigest(),
        mode=stat.S_IMODE(path.stat().st_mode), recording='after-use copy; no original first-use credit'))
(BASE / 'log-copies.json').write_text(json.dumps(copies, indent=2) + '\n')
telemetry = Path('.linkedspec-data/push-monitor/20261117T040019.533023Z')
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
summary = ('Fourteen named Perl includes across three parents resolve to twelve suite sources and two probe libraries; one nested cold-child source is retained separately. '
    'All fifteen target/context documents round-trip under PPI1.270; current31 bodies/modes, earlier eleven callable edges and eight corruption controls pass. '
    'Caller-guarded plans, helper standalone guards, truth/defined load checks and parent source-selection multiplicities2/2/1 remain explicit. No application test or cold child runs.')
action = 'Remeasure committed size, then resolve the full145-source remaining literal fixture/source IO under ' + NEXT + '; constructed/helper sibling2, generated-inline roles and broader reconciliation precede registration and publication prerequisites.'
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n')
end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node += '  Outcome: Named14/parents3: suites12/libraries2/cold context1; PPI15/current31/old callable11/eight controls PASS. Caller plans/source selections2/2/1 preserved. Three added primary bodies were absent from the old callable-only epoch; prospective capture closes this slice, historical4.2 remains.\n'
text = text[:start] + node + text[end:]
marker = '\n- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.1`\n'
assert text.count(marker) == 1
addition = ('  Added ownership Perl-named includes: The earlier callable-only164-source identities omit assigned_raw_regex_payload.t and both receiver/legacy probe.pl targets; the new perl-named-includes-2026-11-17 captures all three plus nested cold context prospectively. Original archive/results remain unchanged. Audit their actual earlier consumer epochs and repair provenance before admission/push with SESSION5; no retroactive custody or changed runtime verdict.\n')
text = text.replace(marker, addition + marker, 1)
path.write_text(text)
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(OWNER) + r'`.*$',
    '| 1 | `' + NEXT + '` | `pending` | Named includes qualified; resolve remaining literal IO across145, then constructed/helper2 and all admission prerequisites. |', path.read_text())
assert count == 1
path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name)
    text, count = re.subn(r'(?m)^November17 current PNT frontier:.*$',
        'November17 current PNT frontier: Perl named includes1.1.0 are focused-checked:14 edges/12 suites/two libraries/one child context/current31. Remaining literal IO1, constructed/helper2 and generated-inline roles precede broader semantic/native reconciliation, generated Dart/frozen-input, registration4.1.2/publication30.2. No new runtime admission.', path.read_text(), count=1)
    assert count == 1
    path.write_text(text)
path = Path('docs/TASK_TREE.md')
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Perl named includes qualified; remaining literal IO1/constructed-helper2 across145 precede generated-inline, broader reconciliation and all admission/publication prerequisites.', path.read_text(), count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — fourteen named includes/three parent roles/current31/eight controls; no test execution.', text, count=1)
text, count = re.subn(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$',
    lambda hit: hit[1] + 'PNT: named Perl includes complete; remaining literal/constructed/generated roles and semantic/native/registration prerequisites stay open.' + hit[2], text)
assert count == 1
path.write_text(text)
for name, title, body in [('CHANGES.md', 'qualify named Perl includes', summary),
    ('DEVELOPMENT_NOTES.md', 'retain named suite and library roles', 'Named do paths cover three source forms: parent-directory __FILE__, repository-root File::Spec and root-cwd literals. Twelve imported Test::More suites suppress only their final plan when caller is present; their source assertions remain. Two package probe libraries suppress standalone observe output under caller. Legacy observations declares cold(), which opens a Perl child pipe; its source is context, never another selected suite. AST/scalar-copy direct selections remain2 each versus callable1 in the earlier source ledger. Three primary targets absent from the older callable-only identities are captured prospectively; historical custody stays4.2. No source/runtime change or retrospective execution claim.')]:
    path = Path(name)
    text = path.read_text()
    offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## 2026-11-17 — ' + title + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md')
text = path.read_text()
for heading, body in {'Current Activity': 'PNT: named Perl includes qualified; remaining direct fixture IO continues.', 'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda hit: hit[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — Perl named14/suites12/libraries2/child1/current31/eight controls; no execution.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean named-include activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — fourteen named Perl includes.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review.py/optional --current; PPI15/current31/named14/old callable11/eight RED controls. Capture and separate reader first pass; never replay capture.\n' +
    '- findings: Twelve caller-plan-guarded suites, two included package libraries and one nested child context. Parent source selections2/2/1 preserved. Three primary targets absent from old callable-only epoch captured prospectively; historical custody4.2. No application test or child execution.\n' +
    '- limits: Full145 literal1/constructed-helper2, generated-inline, excluded/computed/transitive/semantic, generated Dart/frozen-input and registration remain open. External PPI/Perl/library/native/outer-first-use/per-read/source-origin/physical4.2/SESSION5 and original Lua reader gap remain explicit.\n' +
    '- publication: Activation/cached4683555e estimate1,488,917,566 bytes/126 ahead/11,082,434-byte margin to director1.5GB excludes this slice. Selected telemetry retained; raw pack/full tables ignored; independent size30/native4.2 gaps. Remeasure after landing; all prerequisites/exact canonical proof remain.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GB/director90-percent rising trend policy. Last cleanup November16 10:59UTC remains under24h; nothing removed. Normal hooks mandatory.\n')
path = Path(BOOK)
text = path.read_text()
marker = '\nA closed-tree epoch can renew current text capacity'
assert text.count(marker) == 1
paragraph = ('\nNamed Perl includes need caller roles as well as paths. The fourteen inspected `do` sites name twelve suite files and two package probe libraries. Each suite imports `Test::More` and ends with `done_testing() unless caller;`: including it suppresses its final plan while leaving assertions in the source. The AST and callable parents wrap their suite includes in subtests. The two libraries guard standalone `observe` output with `unless (caller)` and expose observation functions to the parent. One declares a cold Perl subprocess; retain that child separately as context. Source-derived paths, guards and selection multiplicity establish neither actual execution nor native input custody.\n')
path.write_text(text.replace(marker, paragraph + marker, 1))
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review.py') + ' --current'
gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Exact current31 source/instrument bodies/modes, activation Git identities, consumed requests and raw PPI/reader observations are retained before target inspection. Original three primary target bodies absent from callable-only epoch gain prospective custody only. External PPI/Perl/core/library/native/OS/outer-first-use/per-read/source-origin/physical and original historical closure remain4.2/SESSION5. Publication/outer log copies are after use; no retroactive credit.')
claims = [dict(name='named-perl-include-roles', statement=summary, scope=PLAN['limits'],
    rederive=dict(status='checked', command=command, granularity='Each fourteen source site/logical target, fifteen target/context bodies, twelve suite guards, two library guards, child command source and original eleven callable identities/parent selection roles.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='gap', repair_owner=OWNER.rsplit('.', 4)[0] + '.2', reason='Independent earlier eleven-edge ledger and byte/mode identities plus eight effective consistency mutations qualify bounded source bindings. Complete independent Perl semantics, computed/transitive/caller/phase analysis remains broader reconciliation3.2; no test execution.'), durability=gap),
    dict(name='named-include-evidence-controls', statement='Eight missing/duplicate/path/role/historical-ledger/input population/body/mode controls reject altered evidence.', scope='Only the declared bounded validators and actual retained source observations; no full semantic classifier proof.',
        rederive=dict(status='checked', command=command, granularity='Each changed evidence victim with exact expected assertion and observed RED.', result=json.dumps(result['controls'], sort_keys=True)),
        falsify=dict(status='checked', hypothesis='An omitted or duplicate include, wrong literal target, probe promoted to suite, shortened historical callable ledger or missing/altered cold child could preserve acceptance.', oracle='Earlier independent callable ledger and identity map; source-path/body validators and explicit suite/library expectations.', red_control='Eight actual in-memory mutations produce the expected distinct assertions, including the cold child as the missing/body/mode victim; healthy observed evidence passes.'), durability=gap)]
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
claims.append(dict(name='activation-outgoing-estimate', statement='Activation estimates1,488,917,566 non-thin bytes against cached4683555e;11,082,434 bytes below director1.5GB.', scope=size['limits'],
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py', granularity='Actual committed activation/cached-origin estimate and retained selected metadata copied after use.', result=json.dumps(size, sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Stream/stat/footer agreement; independent actual-file falsification remains30.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Selected telemetry retained; ignored raw pack/full tables and full native/physical/producer closure remain4.2/SESSION5. No fresh-remote/wire/future guarantee.')))
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
