"""Prepare a bounded source-binding publication from retained preservation code."""
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PRIOR = Path('docs/checkpoints/perl-literal-open-qualification-2026-11-17')
original = (PRIOR / 'publish.py').read_text()
prefix = original[:original.index('summary = (')]
changes = []


def replace(old, new):
    global prefix
    assert prefix.count(old) == 1, old
    prefix = prefix.replace(old, new)
    changes.append(dict(old=old, new=new))


replace("NEXT = OWNER.rsplit('.', 1)[0] + '.1'", "NEXT = OWNER.rsplit('.', 1)[0] + '.2'")
replace("result['current_inputs'] == 189 and result['literal_sites'] == 34", "result['current_inputs'] == 190 and result['bindings'] == 1")
replace("len(result['controls']) == 8", "len(result['controls']) == 7")
replace('.linkedspec-data/perl-named-includes-commit.log', '.linkedspec-data/task-headroom-staged-commit.log')
replace('.linkedspec-data/perl-literal-open-capture.log', '.linkedspec-data/perl-variable-literal-capture.log')
replace("('review-outer', '.linkedspec-data/perl-literal-open-review.log')", "('preparation-outer', '.linkedspec-data/perl-variable-literal-preparation.log')")
replace('20261117T044555.567744Z', '20261117T063455.779176Z')
assert not (BASE / 'telemetry').exists(), 'new publication owns its telemetry copy'
tail = r'''summary = ('All159 original/named Perl sources round-trip under PPI1.270:192 open sites, one bounded adjacent literal-variable read and191 unmatched sites. '
    'The read supplies the historical scalar-copy comparison baseline, never a new runtime verdict. '
    'Current190 input bodies/modes, six independent source specimens, actual intervening-write RED and seven evidence controls pass. No application source executes.')
action = 'Remeasure committed size; reconcile other literal/non-open IO under ' + NEXT + ', then constructed/helper/support/generated and broader semantic/native/registration/publication prerequisites.'
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
text = path.read_text(); start = text.index('- ID: `' + OWNER + '`\n'); end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node += '  Outcome: Sources159/open192/binding1/unmatched191/current190; six specimens/actual intervening-write RED/seven controls PASS. Historical comparison baseline and original source-selection2 retained; no runtime verdict. Other forms remain pending.\n'
path.write_text(text[:start] + node + text[end:])
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(OWNER) + r'`.*$', '| 1 | `' + NEXT + '` | `pending` | Adjacent variable literal qualified; reconcile remaining literal/non-open IO, then helper/support/generated and all admission prerequisites. |', path.read_text())
assert count == 1; path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name)
    text, count = re.subn(r'(?m)^November17 current PNT frontier:.*$', 'November17 current PNT frontier: Perl adjacent literal-variable1 is focused-checked over159 sources/192 open sites:one historical baseline binding/191 unmatched/current190. Other literal/non-open IO2 then helper/support/generated and broader semantic/native, generated Dart/frozen-input, registration4.1.2/publication30.2 remain. No runtime admission.', path.read_text(), count=1)
    assert count == 1; path.write_text(text)
path = Path('docs/TASK_TREE.md'); text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Adjacent Perl variable literal qualified; other literal/non-open IO2 and helper/support/generated roles precede remaining semantic/native/registration/publication prerequisites.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — sources159/open192/binding1/unmatched191/current190; six specimens/changed-source RED/seven controls.', text, count=1)
text, count = re.subn(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$', lambda hit: hit[1] + 'PNT: adjacent literal-variable1 complete; other IO/helper/support/generated and all semantic/native/admission/publication prerequisites remain.' + hit[2], text)
assert count == 1; path.write_text(text)
notes = 'Restricted quote contents are source strings, not evaluated Perl values. The grammar accepts an adjacent single lexical-my initializer in the same PPI parent as a guarded three-argument open; all other forms remain explicit. Original145 sources and15 named contexts deduplicate to159. All191 original open identities match the earlier census; the added support supplies one further open site. The qualified legacy_native_path read supplies stored historical JSON/stdout for comparison, while the parent source selection count remains2. Inserting an intervening assignment in a controlled source removes the first binding at lexer exit0, rejecting the old oracle. No test/helper/child body executes and no historical baseline verdict is refreshed.'
for name, title, body in [('CHANGES.md', 'qualify adjacent Perl literal-variable inputs', summary), ('DEVELOPMENT_NOTES.md', 'bound variable initializer source bindings', notes)]:
    path = Path(name); text = path.read_text(); offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## 2026-11-17 — ' + title + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md'); text = path.read_text()
for heading, body in {'Current Activity': 'PNT: adjacent Perl variable literal qualified; remaining other literal/non-open IO continues.', 'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda hit: hit[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — adjacent variable input:159 sources/192 open/one baseline/191 unmatched/current190; six specimens/changed-source RED/seven controls.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean variable-literal activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — adjacent Perl literal-variable source binding.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review.py/optional --current. Sources159/open192/binding1/unmatched191/current190; six specimens/actual intervening-write RED/seven controls. Original191 sites align exactly.\n' +
    '- findings: One source-declared legacy_native_path read supplies a historical comparison JSON baseline; source selection2 is not execution2. Quote string strips wrappers and is not a Perl evaluator. No app/helper/child runs.\n' +
    '- limits: Nonadjacent/other literal IO2, constructed/helper/library/support/process/generated-inline, excluded/computed/transitive/full independent semantics, generated Dart/frozen-input/registration remain. Native/PPI/Perl/outer-first-use/per-read/source-origin/physical4.2/SESSION5 and original Lua reader gap remain.\n' +
    '- publication: Activation/cached4683555e estimate1,496,425,185 bytes/129 ahead/3,574,815-byte margin to director1.5GB excludes this slice. Immutable source images reused by hash/mode; selected telemetry retained. Independent size30/native4.2 gaps and all prerequisites remain; remeasure after landing.\n' +
    '- preceding_normal: .linkedspec-data/task-headroom-staged-commit.log is complete all10/post-pointer PASS for9a6c6613; earlier failed/qualified publications remain distinct.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GB/director90-percent rising trend policy. Last cleanup November16 10:59UTC remains under24h; nothing removed. Normal hooks mandatory.\n')
path = Path(BOOK); text = path.read_text(); marker = '\nA closed-tree epoch can renew current text capacity'
assert text.count(marker) == 1
paragraph = '\nVariable-bound paths need a narrower source claim. Across159 retained original and named-support files, a bounded adjacent lexical-initializer grammar qualifies one read among192 open sites. It requires a simple quoted ASCII path, matching source symbol and the same PPI parent, while preserving191 unmatched sites for other analyses. The read supplies a historical JSON comparison baseline; a stored successful result is not a new execution verdict. PPI quote strings strip delimiters and do not generally evaluate Perl escapes or interpolation. Controlled source changes can test adjacency without running the application.\n'
path.write_text(text.replace(marker, paragraph + marker, 1))
gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='All190 project source/instrument/input bodies/modes recover through gated immutable original/named references, new before/target images and exact JSON requests. Git activation identities and actual PPI/reader channels retained. Public API docs are after-use development evidence. Full external PPI/Perl/core/library/native/OS/outer-first-use/per-read/source-origin/physical and original historical baseline custody remain4.2/SESSION5; no runtime or canonical admission.')
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review.py') + ' --current'
claims = [dict(name='adjacent-perl-literal-variable-binding', statement=summary, scope=PLAN['limits'], rederive=dict(status='checked', command=command, granularity='Each159 source/body/mode,192 open site, original191 source identity, adjacent initializer/operand binding and retained historical baseline input.', result=json.dumps(result, sort_keys=True)), falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.3.2', reason='Six independent controlled source expectations, actual intervening-write RED and seven evidence controls qualify this bounded grammar. Complete independent Perl/callee/alias/scope/phase/interpolation semantics and all unmatched/library/helper forms remain broader3.2 and explicit follow-ups.'), durability=gap),
    dict(name='adjacent-variable-source-controls', statement='Six controlled source specimens pass; an actual intervening assignment rejects the old adjacency oracle at lexer exit0; seven evidence corruptions reject.', scope='Only retained bounded source grammar and exact evidence validators, not full semantic classification.', rederive=dict(status='checked', command=command, granularity='Each independent expected path/symbol/mode/role and actual modified source request/PPI output, plus distinct source/target/input evidence victims.', result=json.dumps(dict(specimens=6, actual=result['actual_changed_source'], controls=result['controls']), sort_keys=True)), falsify=dict(status='checked', hypothesis='Quoted/indirect/scalar/nonadjacent/outer-scope source could satisfy the adjacent grammar, or an intervening assignment could preserve the original read/output pair.', oracle='Independent literal specimen expectations and actual PPI observations; old191 site ledger and exact input bindings.', red_control='Actual intervening assignment leaves only the output binding versus the old expected read/output pair, observed RED at lexer exit0. Seven missing/site/path/mode/role/body/input mutations reject.'), durability=gap)]
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
claims.append(dict(name='activation-outgoing-estimate', statement='Activation estimates1,496,425,185 non-thin bytes against cached4683555e;3,574,815 below director1.5GB.', scope=size['limits'], rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py', granularity='Actual committed activation/cached-origin estimate and selected original metadata copied after use.', result=json.dumps(size, sort_keys=True)), falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Stream/stat/footer agree; independent actual-file falsification remains30.'), durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Selected telemetry retained; ignored raw pack/full tables and full native/physical/producer closure remain4.2/SESSION5. No fresh-remote/wire/future guarantee.')))
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
'''
with tarfile.open(BASE / 'publication-composition-before.tar.gz', 'x:gz') as archive:
    for path in (PRIOR / 'publish.py', PRIOR / 'review_publication.py', BASE / 'prepare_publication.py'):
        archive.add(path, arcname=str(path), recursive=False)
with (BASE / 'publish.py').open('xb') as stream:
    stream.write((prefix + tail).encode())
with (BASE / 'review_publication.py').open('xb') as stream:
    stream.write((PRIOR / 'review_publication.py').read_bytes())
(BASE / 'publication-composition.json').write_text(json.dumps(dict(template=str(PRIOR / 'publish.py'), substitutions=changes,
    actual_publisher_sha256=hashlib.sha256((prefix + tail).encode()).hexdigest(),
    limits='Exact original template/preparer images before new publisher use; old writer never replayed. Full outer-first-use/native/physical closure remains4.2/SESSION5.'), indent=2) + chr(10))
print('Prepared bounded adjacent-variable publisher')
