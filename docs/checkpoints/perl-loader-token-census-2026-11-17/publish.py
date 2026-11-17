"""Publish the lexical census without promoting sites to resolved runtime IO."""
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
assert result['result'] == 'PASS' and result['consumers'] == result['qualified'] == 145
assert result['current_inputs'] == 162 and not result['needs_qualification'] and not result['relex']
assert result['population_counts'] == dict(eval_or_process_candidates=143, io_word_or_readline_candidates=122,
    named_helper_candidates=84, non_word_or_heredoc_contexts=127, nonblock_do_candidates=3)
assert all(value == 0 for value in result['stderr_bytes'].values())
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
    for name in sorted(set(documents) | {str(BASE / leaf) for leaf in ('publish.py', 'plan.json', 'census.json', 'commands/review-stdout.gz', 'record_review.py')}):
        path = Path(name)
        data = path.read_bytes()
        identities[name] = dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
        archive.add(path, arcname=name, recursive=False)
(BASE / 'publication-before-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
copies = []
for label, source in [('preceding-normal', '.linkedspec-data/lua-transitive-selection-commit.log'),
    ('capture-outer', '.linkedspec-data/perl-token-census-capture.log'), ('review-outer', '.linkedspec-data/perl-token-census-review.log'),
    ('ppi-preflight', '.linkedspec-data/perl-loader-ppi-preflight.log')]:
    path = Path(source)
    data = path.read_bytes()
    if label == 'preceding-normal':
        assert b'doctrines: ALL 10 enforced doctrines PASS.' in data and b'[memory-pointer] ok: post-commit' in data
    target = BASE / (label + '.log.gz')
    target.write_bytes(gzip.compress(data, mtime=0))
    copies.append(dict(source=source, target=str(target), bytes=len(data), sha256=hashlib.sha256(data).hexdigest(),
        mode=stat.S_IMODE(path.stat().st_mode), recording='after-use copy; no original first-use credit'))
(BASE / 'log-copies.json').write_text(json.dumps(copies, indent=2) + '\n')
telemetry = Path('.linkedspec-data/push-monitor/20261117T024018.698040Z')
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
summary = ('All145 Perl source documents round-trip through installed PPI1.270 with no unknown-token qualification or stderr. '
    'Overlapping lexical candidate groups are122 IO/readline,143 eval/process,84 named-helper,127 non-Word/heredoc and three nonblock-do files. '
    'Four controlled specimens pass; actual promoted-quote source is RED against the old oracle, and the controlled compiler sentinel exits255 while static lexing succeeds. '
    'Current162 input bodies/modes pass. These are lexical candidates, not resolved file edges or reached runtime calls; no LinkedSpec test/SDK execution.')
action = 'Remeasure committed outgoing size; resolve frozen Perl fixture/constructed/support edges under ' + NEXT + ', then generated/inline roles2 and excluded/dynamic/semantic reconciliation before generated Dart/frozen-input/registration and every publication prerequisite.'
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n')
end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node += '  Outcome: PPI1.270 round-trips all145/unknown0/stderr0; current162 PASS. Overlapping candidates IO122/eval143/helpers84/nonWord127/nonblock-do3. Four specimens and actual promoted-source RED/compiler255 distinguish lexical inspection from execution. Source first pass succeeded; full semantics/native/target expansion remain open.\n'
text = text[:start] + node + text[end:]
follow = '- ID: `' + NEXT + '`\n'
begin = text.index(follow)
stop = text.index('\n- ID:', begin + 1)
child = text[begin:stop] + '  Frozen include context: Nonblock do sites occur in actionir_ast_parser.t (assigned_raw_regex_payload.t), actionir_receiver_scalar_copy.t (two probe.pl targets) and callable_codeblock_literal_contract.t (eleven named includes). Resolve support/suite roles and conditional scope; do not infer execution or count probes as suites.\n'
path.write_text(text[:begin] + child + text[stop:])
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(OWNER) + r'`.*$',
    '| 1 | `' + NEXT + '` | `pending` | Perl145 lexical census complete; expand frozen fixed/constructed/support1 then remaining generated/inline2. All broader semantic/native/registration prerequisites remain. |', path.read_text())
assert count == 1
path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name)
    text, count = re.subn(r'(?m)^November17 current PNT frontier:.*$',
        'November17 current PNT frontier: Perl145 lexical census0 is focused-checked with PPI1.270/current162/four specimens/two observed RED distinctions. Frozen edge expansion1 then generated/inline2 precede remaining semantic/excluded, generated Dart/frozen-input, registration4.1.2/publication30.2. Lexical sites gain no runtime or native-custody credit.', path.read_text(), count=1)
    assert count == 1
    path.write_text(text)
path = Path('docs/TASK_TREE.md')
text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Perl145 lexical census0 is focused-checked; frozen edge expansion1 and generated/inline2 precede remaining reconciliation/generated Dart/frozen-input/registration and publication.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — source-token contexts and controlled distinctions; no LinkedSpec test execution.', text, count=1)
text, count = re.subn(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$',
    lambda hit: hit[1] + 'PNT: Perl145 lexical census0 complete; frozen edge expansion1/generated-inline2 and remaining semantic/native/registration prerequisites stay open.' + hit[2], text)
assert count == 1
path.write_text(text)
for name, title, body in [('CHANGES.md', 'freeze Perl loader token census', summary),
    ('DEVELOPMENT_NOTES.md', 'keep lexical source sites separate from runtime calls', 'PPI receives immutable JSON source requests rather than loading test files as Perl programs. Document serialization, not concatenated token content, preserves heredoc payloads. Word sites can be method names, fat-comma keys or declarations; strings/regex/heredocs can contain nested/interpolated execution and remain separately unqualified. The first frozen lexer/capture and readonly recovery succeed without a producer correction. Named do candidates include AST/scalar-copy support contexts beyond the earlier callable-only include review. Candidate populations overlap and retain original feature/compatibility/maintenance roles; target/caller resolution and full semantic/native proof remain scheduled.')]:
    path = Path(name)
    text = path.read_text()
    offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## 2026-11-17 — ' + title + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md')
text = path.read_text()
for heading, body in {'Current Activity': 'PNT: Perl145 lexical census complete; frozen direct-edge expansion continues.',
    'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda hit: hit[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — Perl145 PPI roundtrips/current162; lexical groups122/143/84/127/3; four specimens/promoted-source RED/compiler255.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean Perl-token-census activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — Perl145 lexical loader/caller census.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review.py/optional --current; optional --relex reruns only the retained static lexer. PPI145 roundtrip/unknown0/stderr0/current162; overlapping groups IO122/eval143/helpers84/nonWord127/nonblock-do3. Four specimens/promoted-source RED/compiler255; no capture replay or LinkedSpec test execution.\n' +
    '- findings: Word tokens are not necessarily builtin calls; non-Word/heredoc payloads may interpolate or execute later. Three do-containing sources include AST assigned-regex, scalar-copy probes and eleven callable includes. Resolve exact target/caller/conditional roles in child1, generated/inline2 and full semantic reconciliation before admission.\n' +
    '- limits: Fixed/constructed1/generated-inline2, excluded/computed/transitive/semantic, generated Dart/frozen-input and default-literal/repeated ActionIR registration remain open. External PPI/Perl/library/native/outer-first-use/per-read/source-origin/physical4.2/SESSION5 and the original Lua reader-epoch gap remain explicit.\n' +
    '- publication: Activation/cached4683555e estimate1,485,050,242 bytes/125 ahead/14,949,758-byte margin to director1.5GB excludes this slice. Selected telemetry retained; raw pack/full tables ignored; independent size30/native4.2 gaps. Remeasure after landing; all prerequisites/exact canonical proof remain.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GB/director90-percent rising trend policy. Last cleanup November16 10:59UTC remains under24h; nothing removed. Normal hooks remain mandatory.\n')
path = Path(BOOK)
text = path.read_text()
marker = '\nA closed-tree epoch can renew current text capacity'
assert text.count(marker) == 1
paragraph = '''
Perl source inventory also needs token context. The same text `open` can appear in a builtin-like word, a method name, a hash key, a declaration or an expected-code string. A static PPI census round-trips145 retained sources and freezes overlapping follow-up groups:122 files with IO/readline candidates,143 with eval/process candidates,84 with named helper candidates,127 with non-Word/heredoc contexts and three with non-block `do` sites. These counts describe source candidates, not reached operations or resolved input files. The vocabulary is bounded; retain the full145-source population when resolving custom helper and library loaders.

Preserve heredocs through document serialization: token or statement `content` alone omits their payload. Quoted and interpolated payloads can also carry later execution and need separate analysis. Controlled examples can distinguish static inspection from compiling a `BEGIN` block without running the LinkedSpec tests. Resolve each candidate's exact caller, target, mode and phase before treating it as a fixture dependency or a selected suite.
'''
path.write_text(text.replace(marker, '\n' + paragraph.strip() + '\n' + marker, 1))
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review.py') + ' --current'
gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Reused original164-source archive and four gated references, current145 consumer identities,17 preparation bodies/modes, actual consumed JSON requests, frozen lexer/reviewer/capture source and raw command channels are retained. Existing host PPI1.270/Perl/core/dependency library bodies, native executable/OS/outer-launcher first-use and complete per-read/source-origin/physical/publication closure remain4.2/SESSION5. Public API docs/preflight/outer copies are after-use development inputs, not full toolchain custody. No LinkedSpec test/SDK admission.')
claims = [dict(name='perl-source-token-census', statement=summary, scope=result['limits'] + ' The declared word vocabulary is bounded; custom helper/library loaders and unlisted word forms require follow-up across the full145-source population.',
    rederive=dict(status='checked', command=command, granularity='Each145 input source, exact JSON request/digest/order, observed PPI document/token class/site/context, overlapping candidate population and162 current retained bodies/modes.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='gap', repair_owner=OWNER.rsplit('.', 2)[0] + '.2', reason='Four independent controlled source oracles and actual promoted-code/compiler-sentinel RED distinctions qualify bounded lexical aspects. Complete independent Perl semantic, caller/target/phase and nested/generated/interpolation classification remains the existing broader reconciliation2 owner.'), durability=gap),
    dict(name='controlled-static-lexical-distinction', statement='Four controlled specimens pass exact Word/include/heredoc/quote-IO oracles. Promoting a quoted-only specimen to an executable open Word makes the old oracle RED; compiling the controlled mixed specimen executes BEGIN and exits255 while PPI inspection succeeds.',
        scope='Only these retained controlled snippets, actual PPI inputs/results and actual Perl compiler sentinel; no LinkedSpec source is compiled or executed.',
        rederive=dict(status='checked', command=command, granularity='Each independent manual specimen oracle, changed executable source, consumed raw stdin/argv/cwd/channels/exit and unchanged source digest.', result=json.dumps(result['controls'], sort_keys=True)),
        falsify=dict(status='checked', hypothesis='Quoted keyword text could count as a source Word, source promotion could leave the old oracle satisfied, or static inspection could execute the sentinel BEGIN.', oracle='Independent literal specimen expectations and actual installed Perl compilation behavior, compared with the actual PPI lexical observations.', red_control='Promoted open produces actual Word count1 versus expected0 at lexer exit0; actual compiler exits255 with EXECUTION_SENTINEL while PPI inspects the same controlled text successfully. Method/key/declaration and qualified-word controls retain their distinct contexts.'), durability=gap)]
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
claims.append(dict(name='activation-outgoing-estimate', statement='Committed activation estimates1,485,050,242 non-thin bytes against cached4683555e;14,949,758 bytes below director1.5GB.', scope=size['limits'],
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py', granularity='Actual committed activation/cached-origin range with selected original producer/ref/config/command metadata copied after use.', result=json.dumps(size, sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Producer stream/stat/footer agree; independent actual-file size falsification remains30.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Selected telemetry retained; raw pack/full object tables stay ignored on this volume. Full native/physical/producer-input closure remains4.2/SESSION5; no fresh-remote/wire/future guarantee.')))
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
