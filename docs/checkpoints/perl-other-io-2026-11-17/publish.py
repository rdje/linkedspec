"""Publish one bounded source qualification and preserve intersecting history."""
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
ACTIVATION = '3442fcd34318043d67e8523a2db2fd84b44148b6'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.3.1.1.1.2'
NEXT = OWNER.rsplit('.', 1)[0].rsplit('.', 1)[0] + '.2'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
result = json.loads((BASE / 'inventory.json').read_bytes())
assert result['result'] == 'PASS' and result['source_documents'] == 159 and result['sites'] == 322
documents = [BOOK, 'MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md']
bindings = []
for path in sorted(Path('docs/claims').glob('*.json')):
    for claim in json.loads(path.read_bytes())['claims']:
        leg = claim['durability']
        for item in leg.get('inputs', []):
            if item['path'] in documents:
                assert leg['mode'] == 'historical', 'preserve live binding before editing'
                bindings.append(dict(record=str(path), claim=claim['name'], input=item, mode=leg['mode'], revision=leg['revision']))
(BASE / 'publication-bindings.json').write_text(json.dumps(bindings, indent=2, sort_keys=True) + '\n')
names = documents + [str(p) for p in BASE.iterdir() if p.is_file() and p.suffix in ('.py', '.pl', '.json')]
identities = {}
with tarfile.open(BASE / 'publication-before.tar.gz', 'x:gz') as packed:
    for name in sorted(set(names)):
        path = Path(name)
        body = path.read_bytes()
        identities[name] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
        packed.add(path, arcname=name, recursive=False)
(BASE / 'publication-before-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
log = Path('.linkedspec-data/perl-variable-literal-commit.log').read_bytes()
assert b'doctrines: ALL 10 enforced doctrines PASS.' in log and b'[memory-pointer] ok: post-commit' in log
(BASE / 'preceding-normal.log.gz').write_bytes(gzip.compress(log, mtime=0))
(BASE / 'capture-outer.log.gz').write_bytes(gzip.compress(Path('.linkedspec-data/perl-other-io-capture.log').read_bytes(), mtime=0))
telemetry = Path('.linkedspec-data/push-monitor/20261117T090500.166985Z')
(BASE / 'telemetry').mkdir()
for path in telemetry.iterdir():
    if path.suffix in ('.pack', '.idx', '.log') or path.name.startswith(('objects-', 'object-metadata-')):
        continue
    shutil.copy2(path, BASE / 'telemetry' / path.name)
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
assert size['head'] == ACTIVATION
summary = ('159 retained sources/322 IO sites round-trip under PPI1.270; all320 original sites and34 earlier literal sites reconcile. '
    'Open forms:32 literal reads/two literal writes/35 scalar-output declarations/one process pipe/96 unresolved read operands/26 unresolved write operands. '
    'Non-open:121 readline syntax sites and nine Word candidates. Four independent specimens, actual scalar-reference removal RED and six evidence controls pass; current177 inputs agree. No application execution.')
action = 'Remeasure committed size; resolve nonadjacent/constructed/helper/library direct paths under ' + NEXT + ', then generated/inline, independent semantics, Dart/frozen inputs and canonical registration/publication prerequisites.'
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
text = path.read_text(); start = text.index('- ID: `' + OWNER + '`\n'); end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node += ('  Evidence: ' + str(BASE / 'REVIEW.md') + '.\n'
    '  Outcome: Sources159/sites322/original320/literal34/scalar-output35/process1/unresolved-file122/non-open130/current177; four specimens/reference-removal RED/six controls PASS. No new literal input target or runtime verdict. All unresolved sites remain explicit; parent closure is not claimed.\n'
    '  Instrument correction: First capture stops before lexer/input freeze on an incorrect expected artifact path. Original source/error retained in failed-first/. Corrected lookup uses the existing literal inventory; successful capture and separate readonly review follow.\n')
text = text[:start] + node + text[end:]
start = text.index('- ID: `' + NEXT + '`\n'); end = text.index('\n- ID:', start + 1)
text = text[:end] + '\n  Continuation: Include all122 unresolved file operands, nonadjacent literal declarations, the process pipe and130 non-open sites from other-io2. Retain all159 sources; library/custom-helper/generated/alias/phase semantics remain explicit rather than treating this bounded lexical reconciliation as closure.\n' + text[end:]
path.write_text(text)
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(OWNER) + r'`.*$', '| 1 | `' + NEXT + '` | `pending` | Literal/non-open source forms reconciled; resolve nonadjacent/constructed/helper/library paths, then generated and all admission prerequisites. |', path.read_text())
assert count == 1; path.write_text(text)
frontier = 'November17 current PNT frontier: Perl other-IO2 is focused-checked:159 sources/322 sites/literal34/scalar-output35/process1/unresolved-file122/non-open130/current177. Constructed/nonadjacent/helper/library paths then generated/semantic/native, Dart/frozen-input and registration4.1.2/publication30.2 remain. No runtime admission.'
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name); text, count = re.subn(r'(?m)^November17 current PNT frontier:.*$', frontier, path.read_text(), count=1)
    assert count == 1; path.write_text(text)
path = Path('docs/TASK_TREE.md'); text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Perl literal/non-open source forms reconciled; constructed/nonadjacent/helper/library paths and generated roles precede semantic/native/registration/publication prerequisites.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — sources159/sites322/original320/literal34/scalar-output35/process1/unresolved-file122/non-open130/current177; four specimens/source RED/six controls.', text, count=1)
text = re.sub(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$', lambda m: m[1] + 'PNT: literal/non-open2 complete; nonadjacent/constructed/helper/library/generated and all semantic/native/admission/publication prerequisites remain.' + m[2], text)
path.write_text(text)
notes = ('Lexical source shape separates35 scalar-backed output declarations from file paths, and a named support process pipe from file reads. '
    'The nine non-open Words are two glob, two opendir, two readdir, two pipe and one sysread sites;121 readline syntax sites use source handle names. '
    'These are declaration/candidate roles, not proof of resolved builtins, handle origin, reachability or execution. '
    'The earlier34 literal sites remain exact. All122 unresolved file operands and130 non-open sites continue with the helper/library lane; generated/inline and independent semantic/native owners remain open. '
    'The first incorrect artifact lookup failed before lexical observations; its sources and original channels survive. Corrected capture and separate current review pass. '
    'Startup shared policy digests match the recorded October23 values; due cleanup remains November16 10:59UTC, still under24h.')
for name, title, body in [('CHANGES.md', 'reconcile remaining Perl IO source forms', summary), ('DEVELOPMENT_NOTES.md', 'separate scalar captures and non-open IO from file inputs', notes)]:
    path = Path(name); text = path.read_text(); offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## 2026-11-17 — ' + title + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md'); text = path.read_text()
for heading, body in {'Current Activity': 'PNT: Perl other-IO source forms qualified; helper/library path resolution continues.', 'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda m: m[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — IO322/original320/literal34/scalar-output35/process1/unresolved-file122/non-open130/current177; four specimens/source RED/six controls.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean other-IO activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — remaining Perl IO source forms.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review.py/optional --current. Sources159/sites322/original320/literal34/scalar-output35/process1/unresolved-file122/non-open130/current177; four specimens/source RED/six controls.\n' +
    '- limits: Declared source forms only. Nonadjacent/constructed/helper/library/process/generated/inline/transitive and independent semantics remain. Native/PPI/Perl/outer-first-use/per-read/source-origin/physical4.2/SESSION5 remain. No application execution or full graph/admission.\n' +
    '- publication: Activation/cached4683555e estimate1,497,568,747 bytes/130 ahead/2,431,253-byte margin to director1.5GB excludes this slice. Reused immutable inputs avoid payload duplication; selected telemetry retained. Independent size30/native4.2 and publication prerequisites remain; remeasure after landing.\n' +
    '- preceding_normal: .linkedspec-data/perl-variable-literal-commit.log completes all10/post-pointer for3442fcd3; first artifact-lookup failure and corrected capture remain distinct.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial/shared24GB. Shared policies unchanged; last cleanup November16 10:59UTC remains under24h. Normal hooks mandatory.\n')
path = Path(BOOK); text = path.read_text(); marker = '\nA closed-tree epoch can renew current text capacity'
assert text.count(marker) == 1
paragraph = '\nIO syntax also needs operand roles. A subsequent159-source inventory retains322 sites, including the same34 direct literal sites,35 scalar-output declarations and one process-pipe declaration. It leaves122 variable or constructed file operands and130 non-open sites explicit:121 readline forms plus nine glob, directory, pipe or sysread Words. Scalar-backed output captures supply no input file; a handle read needs its handle origin resolved before it can identify an input. A source-shape role alone establishes neither the selected callee nor runtime reachability. Controlled scalar-reference removal distinguishes a capture declaration from a variable file operand without running the application.\n'
path.write_text(text.replace(marker, paragraph + marker, 1))
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review.py') + ' --current'
gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Project source/instrument bytes and modes recover through frozen new inputs and hash-gated immutable original/named references; actual source requests are exactly reconstructible and hash-bound to recorded commands/channels. Selected outgoing telemetry copied after use. External PPI/Perl/library/native/OS, outer-first-use/per-read/source-origin/physical and raw-pack closure remain4.2/SESSION5; no application/runtime/canonical admission.')
scoped = dict(result); scoped.pop('non_open')
claims = [dict(name='remaining-perl-io-source-forms', statement=summary,
    scope='Only bounded lexical IO vocabulary across159 retained original/named sources. Shape roles and unresolved populations do not prove callee, handle origin, alias, phase, reachability, complete graph or runtime execution.',
    rederive=dict(status='checked', command=command, granularity='Every159 source and322 source sites; original320 identities, earlier34 literal sites, open roles and130 explicit non-open candidates.', result=json.dumps(scoped, sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.1.1.1.1.1.3.2', reason='Four independent source specimens, actual scalar-reference removal RED and six reason-sensitive evidence mutations qualify source shape only. Full independent Perl/callee/alias/scope/phase/interpolation and helper/library semantics remain broader3.2.'), durability=gap),
    dict(name='other-io-source-controls', statement='Four source specimens pass; removing the scalar reference produces the distinguishing source-role RED at lexer exit0; six evidence corruptions reject.', scope='Retained bounded source grammar and explicit evidence validators only.',
    rederive=dict(status='checked', command=command, granularity='Each independent specimen expectation and actual changed-source request/output plus six separate evidence victims.', result=json.dumps(dict(specimens=4, red=result['actual_changed_source'], controls=result['controls']), sort_keys=True)),
    falsify=dict(status='checked', hypothesis='A scalar capture and a variable file operand could receive the same role, or omitted/altered sites and roles could pass recovery.', oracle='Independent source expectations; actual removal of the reference operator; original320 and literal34 ledgers.', red_control='Removing the reference operator changes the role and rejects the old oracle at lexer exit0. Six document/site/source/role/mode/operand alterations reject their exact expected assertion.'), durability=gap),
    dict(name='activation-outgoing-estimate', statement='Committed activation estimates1,497,568,747 non-thin bytes against cached4683555e, leaving2,431,253 before the director1.5GB trigger.', scope=size['limits'],
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py', granularity='Committed activation/cached-origin serialized pack; selected source/ref/config/command/channels retained after use.', result=json.dumps(size, sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Stream/stat/footer agree; full independent actual-file falsification remains30.'), durability=gap)]
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
