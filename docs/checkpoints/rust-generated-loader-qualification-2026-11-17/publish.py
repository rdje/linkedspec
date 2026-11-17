"""Publish source qualification with historical claims and open native gaps intact."""
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
NEXT = OWNER.rsplit('.', 1)[0] + '.3'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'publication-bindings.json').exists(), 'one-shot publication'
result = json.loads(gzip.decompress((BASE / 'qualified-stdout.gz').read_bytes()))
assert result['result'] == 'PASS' and result['current_inputs'] == 442
assert result['input_bindings'] == 320 and result['distinct_targets'] == 319 and len(result['controls']) == 12
assert len(result['historical']['matching']) == 321 and not result['historical']['changed'] and not result['historical']['absent']
documents = [BOOK, 'MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md']
bindings = []
for path in sorted(Path('docs/claims').glob('*.json')):
    for claim in json.loads(path.read_bytes())['claims']:
        leg = claim['durability']
        for item in leg.get('inputs', []):
            if item['path'] in documents:
                assert leg['mode'] == 'historical', 'live binding needs qualified preservation'
                bindings.append(dict(record=str(path), claim=claim['name'], input=item, mode=leg['mode'], revision=leg['revision']))
(BASE / 'publication-bindings.json').write_text(json.dumps(bindings, indent=2, sort_keys=True) + '\n')
publication_inputs = set(documents) | {str(BASE / name) for name in ('publish.py', 'plan.json', 'qualified-stdout.gz', 'qualified-exit.txt')}
identities = {}
with tarfile.open(BASE / 'publication-before.tar.gz', 'x:gz') as archive:
    for name in sorted(publication_inputs):
        path = Path(name)
        assert not path.is_symlink() and path.stat().st_dev == Path('.').stat().st_dev
        data = path.read_bytes()
        identities[name] = dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
        archive.add(path, arcname=name, recursive=False)
(BASE / 'publication-before-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
for label, source in [('preceding-normal', '.linkedspec-data/headroom-perl-ast-commit.log'),
                      ('qualifier-outer', '.linkedspec-data/rust-generated-qualification.log')]:
    path = Path(source)
    data = path.read_bytes()
    if label == 'preceding-normal':
        assert b'doctrines: ALL 10 enforced doctrines PASS.' in data and b'[memory-pointer] ok: post-commit' in data
    (BASE / (label + '.log.gz')).write_bytes(gzip.compress(data, mtime=0))
    (BASE / (label + '.json')).write_text(json.dumps(dict(source=source, bytes=len(data),
        sha256=hashlib.sha256(data).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode),
        recording='after-use copy; no original first-use credit'), indent=2) + '\n')
telemetry = Path('.linkedspec-data/push-monitor/20261117T010454.559400Z')
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
summary = ('Generated Rust source qualification resolves320 bindings/319 targets: manifest plus315 corpus files, '
    'three Count macros/two fixtures and one embedded grammar. Three parent tests/two emitted test templates/three Cargo command templates/eleven filesystem sites, '
    '17 Count rows/two trace selectors,442 current inputs/321 historical identities/twelve controls pass. Original duplicate-method refusal remains exact; no Cargo/SDK or admission.')
action = ('Remeasure committed outgoing size; qualify remaining Perl loaders/support/transitive/excluded roles and eleven unresolved Lua routes under ' + NEXT +
    ', then generated Dart2/frozen-input3 before registration4.1.2 and every publication prerequisite.')
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n')
end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node = node.replace('Reader defect (owned/fix now):', 'Reader defect (owned/fixed):')
node += '  Outcome: 320 bindings/319 targets; parent3/template2/command3/fs11/Count17/trace2/current442/historical321/control12 PASS. Original duplicate-new refusal and scoped correction retained. Full details/limits in Evidence; SESSION77/native4.2 and remaining3 stay open.\n'
path.write_text(text[:start] + node + text[end:])
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(OWNER) + r'`.*$',
    '| 1 | `' + NEXT + '` | `pending` | Generated Rust source qualification complete; remaining Perl/transitive/Lua routes, generated Dart2/frozen-input3 precede registration4.1.2. All other prerequisites remain. |', path.read_text())
assert count == 1
path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name)
    text, count = re.subn(r'(?m)^November17 current PNT frontier:.*$',
        'November17 current PNT frontier: Generated Rust loader2 resolves source corpus/Count/generated-host/trace roles with focused proof and the duplicate-method reader correction retained. Remaining Perl-transitive3/eleven Lua routes/generated Dart2/frozen-input3 precede registration4.1.2/publication30.2; SESSION77/native/semantic/other prerequisites remain open.', path.read_text(), count=1)
    assert count == 1
    path.write_text(text)
path = Path('docs/TASK_TREE.md')
text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Generated Rust source qualification is focused-checked; remaining Perl/transitive/Lua routes and generated Dart/frozen-input work precede registration4.1.2/publication30.2.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — Rust generated corpus/Count/host/trace roles; no SDK/admission.', text, count=1)
text, count = re.subn(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$',
    lambda hit: hit[1] + 'PNT: Generated Rust loader2 focused-checked; remaining Perl/transitive/Lua/generated Dart/frozen-input work then registration4.1.2. All publication prerequisites remain.' + hit[2], text)
assert count == 1
path.write_text(text)
notes = ('A manifest expands one read helper into315 potential corpus files, without proving successful preparation or generated writes for all105 cases. The generated crate contains child test templates, distinct from three parent tests. Count combines16+1 fixture rows; the trace parent selects two rows and reads Engine-produced traces without launching Cargo. Full-manifest compilation checks status but its host run only counts markers; focused Count requires successful child exit. SESSION77 retains repair ownership. The first reader confused two impl-local new methods; a separate five-substitution reader scopes methods to CaseFailure/TempProject, preserves capture exit1 and reuses every original body. Nine graph-consistency controls are not a complete independent semantic oracle; three historical inverses separately distinguish grammar identity.')
for name, title, body in [('CHANGES.md', 'qualify generated Rust loader inputs', summary),
                          ('DEVELOPMENT_NOTES.md', 'separate classifier source inputs, child templates and trace outputs', notes)]:
    path = Path(name)
    text = path.read_text()
    offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## 2026-11-17 — ' + title + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md')
text = path.read_text()
for heading, body in {'Current Activity': 'PNT: generated Rust loaders complete; remaining Perl/transitive/Lua/generated Dart qualification continues.',
    'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda hit: hit[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — Rust generated:320 bindings/319 targets/three parents/two templates/three commands/current442/historical321/twelve controls; original reader refusal retained, no SDK.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean generated-Rust-loader activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — generated Rust classifier source/input qualification.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review_qualified.py/optional --current. Bindings320/targets319/parent3/template2/command3/fs11/Count17/trace2/current442/historical321/control12. Original capture1 and derived scoped reader0 retained. No Cargo/SDK.\n' +
    '- findings: Corpus paths are potential dependencies, prepared subset controls emitted files. Focused Count checks child status; full-manifest run status gap remains SESSION77. Trace output is generated, without Cargo in that parent. Current identities do not prove actual older embedded bytes, execution or native origins.\n' +
    '- limits: Remaining Perl-transitive3 includes eleven unresolved Lua routes. Generated Dart2/frozen-input3/default-literal/repeated ActionIR registration and all native/per-read/source-origin/physical4.2/SESSION5 or other prerequisites remain open. Full independent semantic qualification remains3.\n' +
    '- publication: Activation/cached4683555e estimate1,483,385,895 bytes/123 ahead/16,614,105-byte margin to director1.5GB excludes this slice. Selected telemetry retained; raw pack/full tables ignored; independent size30/native4.2 gaps. Remeasure after landing;30.2 needs all prerequisites/exact canonical proof.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GB/director90-percent rising trend policy. Last cleanup November16 10:59UTC remains under24h; nothing removed. Normal hooks remain mandatory.\n')
path = Path(BOOK)
text = path.read_text()
marker = '\nA closed-tree epoch can renew current text capacity'
assert text.count(marker) == 1
paragraph = '''
A generated-source classifier has both a parent program and programs assembled as strings. The Rust full-manifest source has three parent tests; its two child-test templates are written into generated modules. Its manifest names105 cases, each with `input.spec`, `input.txt` and `expected.json`: these315 paths are potential preparation inputs. Only successfully prepared cases reach generated module writing. Extra manifest provenance metadata is not another file dependency.

| Rust parent route | Source inputs and generated artifacts | Child-process check |
| --- | --- | --- |
| Full manifest | Runtime manifest/corpus, embedded function grammar, generated crate/modules/index | Compile status required; run markers counted while run status is diagnostic. Known repair: `SESSION-STARTUP-READING.77`. |
| Focused emitted Count | Two embedded fixtures containing16+1 rows, generated crate/modules/index | Separate `cargo test --lib` requires successful exit. |
| Native Count trace | Two named rows from the16-row fixture; Engine writes then reads trace files | No Cargo launch in this parent. |

The source-level Cargo helper requests offline/quiet execution, a generated-project cwd and its own target directory. Actual Cargo identity, dependency resolution, effective temporary root, embedded bytes and successful test execution require separate runtime evidence. A current source/fixture identity match with an older ledger supplies none of those execution results.
'''
path.write_text(text.replace(marker, '\n' + paragraph.strip() + '\n' + marker, 1))
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review_qualified.py') + ' --current'
gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Native113 plus329 new source/instrument/corpus bodies and modes, activation Git bindings, original failure channels, scoped derived reader and qualifier bodies are recoverable. Complete native/Python/Git/Rust/OS, outer-launcher first-use, transitive/per-read/source-origin and physical custody remains4.2/SESSION5. Publication bindings are retained without duplicating every old historical claim input; no complete publication custody or SDK/admission credit.')
claims = [dict(name='generated-rust-loader-source-roles', statement=summary, scope=result['limits'],
    rederive=dict(status='checked', command=command, granularity='Each manifest case/suffix, three direct Count macros/two fixture populations, embedded grammar, parent/template/process/trace and filesystem role;442 current original bodies/modes plus two qualifier inputs.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='gap', repair_owner=NEXT, reason='Nine victim-bearing graph-consistency corruptions reject, and independent dated321 identities/three grammar inverses distinguish selected identity aspects. Complete independent semantic/transitive/selection qualification remains remaining3. No actual process or current admission proof.'), durability=gap),
    dict(name='generated-rust-historical-identities', statement='All321 distinct selected source/parser/input identities match the older qualified-direct root ledger; zero absent/changed and three grammar identity inverses reject.',
        scope=result['historical']['limits'], rederive=dict(status='checked', command=command, granularity='Each consumer, parser source and319 distinct targets versus exact historical archive locator.', result=json.dumps(result['historical'], sort_keys=True)),
        falsify=dict(status='checked', hypothesis='Changed grammar bytes/mode or a forged historical digest could retain the same identity result.', oracle='Independent dated root archive metadata compared with retained current bodies/modes.', red_control='Appended grammar byte, toggled executable mode and zeroed old digest each reject; healthy321 identities match.'), durability=gap),
    dict(name='generated-rust-reader-method-scope', statement='The original reader rejects two impl-local new methods; separately derived implementation-scoped lookup recovers CaseFailure::new at45 and TempProject::new at65 with the full original source/capture exit1 unchanged.',
        scope='Five exact source substitutions and the actual two scoped definitions only; no classifier behavior change or capture replay.',
        rederive=dict(status='checked', command=command, granularity='Original pure refusal, two actual method definitions/lines/bodies and full qualified reader reconstruction.', result=json.dumps(result['actual_victims'], sort_keys=True)),
        falsify=dict(status='checked', hypothesis='Unqualified method names are globally unique in this retained source.', oracle='Two separate implementation scopes, CaseFailure and TempProject, each contain new with distinct source bodies.', red_control='The original pure function reader reproduces unique parent function refusal; scoped reader retains both with their distinct stage/temp-dir bodies.'), durability=gap)]
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
claims.append(dict(name='activation-outgoing-estimate', statement='Committed activation estimates1,483,385,895 non-thin serialized bytes against cached4683555e;16,614,105 bytes below director1.5GB.', scope=size['limits'],
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py', granularity='Actual committed activation/cached-origin range; selected original producer/ref/config/command channels copied after use without replay.', result=json.dumps(size, sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Producer stream/stat/footer agree; independent actual-file size falsification remains30.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Selected telemetry retained; raw pack/full object tables remain ignored. Complete native/physical custody remains4.2/SESSION5; no fresh-remote/wire/future guarantee.')))
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
