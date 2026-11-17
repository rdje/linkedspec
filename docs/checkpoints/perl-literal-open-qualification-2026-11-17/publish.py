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
assert result['result'] == 'PASS' and result['current_inputs'] == 189 and result['literal_sites'] == 34
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
    for name in sorted(set(documents) | {str(BASE / n) for n in ('publish.py', 'prepare_publication.py', 'review_publication.py', 'plan.json', 'inventory.json', 'commands/review-stdout.gz')}):
        path = Path(name)
        body = path.read_bytes()
        identities[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
        archive.add(path, arcname=name, recursive=False)
(BASE / 'publication-before-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
copies = []
for label, source in [('preceding-normal', '.linkedspec-data/perl-named-includes-commit.log'),
    ('capture-outer', '.linkedspec-data/perl-literal-open-capture.log'), ('review-outer', '.linkedspec-data/perl-literal-open-review.log')]:
    path = Path(source)
    body = path.read_bytes()
    if label == 'preceding-normal':
        assert b'doctrines: ALL 10 enforced doctrines PASS.' in body and b'[memory-pointer] ok: post-commit' in body
    target = BASE / (label + '.log.gz')
    target.write_bytes(gzip.compress(body, mtime=0))
    copies.append(dict(source=source, target=str(target), bytes=len(body), sha256=hashlib.sha256(body).hexdigest(),
        mode=stat.S_IMODE(path.stat().st_mode), recording='after-use copy; no original first-use credit'))
(BASE / 'log-copies.json').write_text(json.dumps(copies, indent=2) + '\n')
telemetry = Path('.linkedspec-data/push-monitor/20261117T044555.567744Z')
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
summary = ('The bounded literal-open grammar classifies34 of191 open Word sites across145 Perl sources:32 input reads/32 targets and two declared output writes. '
    'All157 unmatched open sites remain explicit. Current189 bodies/modes, five independent source specimens and eight evidence controls pass. '
    'Actual changed read-to-write source makes the old oracle RED at lexer exit0. No application test, runtime IO or output production is observed.')
action = 'Remeasure committed size, then resolve direct literal variable bindings under ' + NEXT + '; other literal IO2, constructed/helper and generated/inline roles plus all broader admission/publication prerequisites remain.'
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n')
end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node += '  Outcome: Literal34/191: inputs32/output declarations2/unmatched157; all145 retained/current189/five specimens/eight controls/actual mode-source RED PASS. No application IO execution. Other literal/variable/helper/support/generated/native roles remain.\n'
path.write_text(text[:start] + node + text[end:])
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(OWNER) + r'`.*$', '| 1 | `' + NEXT + '` | `pending` | Literal open forms qualified; resolve variable-bound literals, other IO and all145/helper/support/generated follow-ups. |', path.read_text())
assert count == 1
path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name)
    text, count = re.subn(r'(?m)^November17 current PNT frontier:.*$', 'November17 current PNT frontier: Perl literal open0 is focused-checked:34/191 sites,32 input targets/two declared outputs/157 unmatched/current189. Variable literals1/other IO2 and constructed/helper/generated/support roles precede broader reconciliation, generated Dart/frozen-input, registration4.1.2/publication30.2. No runtime or canonical admission.', path.read_text(), count=1)
    assert count == 1
    path.write_text(text)
path = Path('docs/TASK_TREE.md')
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Perl literal open forms qualified; variable-bound literals1/other IO2 and constructed/helper/support/generated roles across145 precede remaining admission/publication prerequisites.', path.read_text(), count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — literal34/inputs32/declared outputs2/unmatched157/current189; five specimens/eight controls/actual mode-source RED.', text, count=1)
text, count = re.subn(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$', lambda hit: hit[1] + 'PNT: literal Perl open forms complete; variable/other/helper/support/generated and semantic/native/registration prerequisites remain.' + hit[2], text)
assert count == 1
path.write_text(text)
for name, title, body in [('CHANGES.md', 'qualify literal Perl open paths', summary), ('DEVELOPMENT_NOTES.md', 'keep literal inputs and output declarations distinct', 'A source Word is first qualified by token context, then by an explicit literal-mode/path grammar. The retained191 open sites partition into34 accepted and157 unmatched; all145 source bodies remain. Thirty-two read targets are captured, while two fixed .linkedspec-data output declarations supply no artifact input or production credit. Variable paths, scalar-backed handles, concatenations and other IO remain follow-ups. Five manual source oracles cover quoting, methods/heredocs, qualified words, scalar references and excluded paths. Actual mode promotion changes classification to two outputs and rejects the old read/write oracle. Complete independent Perl semantics and external/native closure remain3.2/4.2/SESSION5.')]:
    path = Path(name)
    text = path.read_text()
    offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## 2026-11-17 — ' + title + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md')
text = path.read_text()
for heading, body in {'Current Activity': 'PNT: literal Perl open forms qualified; variable-bound literals and other IO continue.', 'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda hit: hit[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — Perl literal34/input32/output2/unmatched157/current189; five specimens/eight controls/actual mode RED.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean literal-open activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — literal Perl open paths and roles.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review.py/optional --current; all145 retained/191 open sites/literal34/input32/output2/unmatched157/current189. Five source specimens/eight controls/actual mode RED. Capture and separate reader first pass; never replay capture.\n' +
    '- findings: Literal input paths have exact prospective bytes/modes. Two declared output paths are not captured as inputs and have no production credit. Full unmatched157, non-open/support/library/generated IO and dynamic semantics remain follow-ups. No application tests or runtime IO.\n' +
    '- limits: Variable literals1/other literal IO2, constructed/helper/support/generated-inline, excluded/computed/transitive/independent semantics, generated Dart/frozen-input and registration remain open. Historical/native/PPI/Perl/outer-first-use/per-read/source-origin/physical4.2/SESSION5 and original Lua reader gap remain.\n' +
    '- publication: Activation/cached4683555e estimate1,490,288,908 bytes/127 ahead/9,711,092-byte margin to director1.5GB excludes this slice. Selected telemetry retained; raw pack/full tables ignored; independent size30/native4.2 gaps. Remeasure after landing; all prerequisites/exact canonical proof remain.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GB/director90-percent rising trend policy. Last cleanup November16 10:59UTC remains under24h; nothing removed. Normal hooks mandatory.\n')
path = Path(BOOK)
text = path.read_text()
marker = '\nA closed-tree epoch can renew current text capacity'
assert text.count(marker) == 1
paragraph = '\nLiteral file opens need mode and token context. In the inspected Perl population, a deliberately bounded grammar accepts34 of191 `open` Word sites:32 literal input reads and two declared output writes. All157 unmatched sites remain in the follow-up inventory. For example, `open my $fh, \'<:raw\', \'tests/fixtures/example.json\' or die $!;` declares an input, while a `\'>\'` mode declares output. A scalar reference such as `\\$buffer` names an in-memory capture; a variable or concatenated path needs separate binding analysis. Quoted expected code, method names and heredoc payloads do not automatically qualify as literal opens. Retaining source-declared paths proves neither actual reachability nor complete file origins.\n'
path.write_text(text.replace(marker, paragraph + marker, 1))
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review.py') + ' --current'
gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='All189 project source/instrument/target bodies and modes recover through before-use archives and original145 source requests; committed inputs bind to activation Git identities. Actual controlled PPI requests/channels and current-input review retained. External PPI/Perl/core/library/native/OS/outer-first-use/per-read/source-origin/physical and historical intake closure remain4.2/SESSION5. Publication/outer log copies are after use. No application IO or canonical admission.')
reconcile = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.3.2'
claims = [dict(name='perl-literal-open-source-inventory', statement=summary, scope=PLAN['limits'], rederive=dict(status='checked', command=command, granularity='All145 source identities and191 retained Word sites, accepted34 path/mode/role bindings,157 explicit unmatched sites,32 input body/mode identities and two output declarations.', result=json.dumps(result, sort_keys=True)), falsify=dict(status='gap', repair_owner=reconcile, reason='Five independent manual source oracles, actual changed-mode source RED and eight consistency mutations qualify the declared grammar and bindings. Complete independent Perl/callee/phase/alias/helper/interpolation semantics remains broader3.2; unmatched/non-open/support/library routes remain explicit.'), durability=gap),
    dict(name='literal-open-controls', statement='Five controlled source specimens pass. An actual read-to-write mode substitution makes the old oracle RED at lexer exit0; eight evidence corruptions reject.', scope='Only the retained declared grammar, controlled sources and exact evidence validators; no complete semantic classifier proof.', rederive=dict(status='checked', command=command, granularity='Each independent literal/path/mode/token-context oracle, actual changed source request/PPI output and exact altered-evidence assertion.', result=json.dumps(dict(specimens=5, controls=result['controls'], actual=result['actual_mode_control']), sort_keys=True)), falsify=dict(status='checked', hypothesis='Quoted/method/heredoc text or scalar/constructed paths could enter the literal population, or changing a read to a write could preserve the old role oracle.', oracle='Independent manual specimen expectations and actual PPI lexical observations through the unchanged lexer; exact target/custody validators.', red_control='Changing <:raw to >:raw in the controlled source produces two output declarations versus expected input/output and rejects the old oracle at actual lexer exit0. Eight actual missing/site/path/mode/output-role/body/mode mutations reject their exact expected assertion.'), durability=gap)]
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
claims.append(dict(name='activation-outgoing-estimate', statement='Activation estimates1,490,288,908 non-thin bytes against cached4683555e;9,711,092 below director1.5GB.', scope=size['limits'], rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py', granularity='Actual committed activation/cached-origin estimate and selected original metadata copied after use.', result=json.dumps(size, sort_keys=True)), falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Stream/stat/footer agree; independent actual-file falsification remains30.'), durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Selected telemetry retained; ignored raw pack/full tables and full native/physical/producer closure remain4.2/SESSION5. No fresh-remote/wire/future guarantee.')))
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
