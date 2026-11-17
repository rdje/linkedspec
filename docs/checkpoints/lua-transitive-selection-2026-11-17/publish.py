"""Publish bounded named-selection proof with the actual reader-epoch gap explicit."""
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
result = json.loads(gzip.decompress((BASE / 'commands/qualified-stdout.gz').read_bytes()))
assert result['result'] == 'PASS' and result['current_inputs'] == 23 and result['census']['blobs'] == 1107
assert len(result['candidates']) == 11 and not result['census']['matching_files']
assert all(row['direct_primary'] == row['direct_secondary'] == 0 and not row['shared_runner'] and not row['references'] for row in result['candidates'])
assert result['direct_commands'] == 44 and result['shared_dofile_calls'] == 83 and result['inherited_named'] == 16
assert result['probes']['observed_red'] == 2 and len(result['reader_epoch']['unchanged_helpers']) == 7
documents = [BOOK, 'MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
    'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md']
bindings = []
for path in sorted(Path('docs/claims').glob('*.json')):
    for claim in json.loads(path.read_bytes())['claims']:
        leg = claim['durability']
        for item in leg.get('inputs', []):
            if item['path'] in documents:
                assert leg['mode'] == 'historical', 'live binding needs separate preservation'
                bindings.append(dict(record=str(path), claim=claim['name'], input=item, mode=leg['mode'], revision=leg['revision']))
(BASE / 'publication-bindings.json').write_text(json.dumps(bindings, indent=2, sort_keys=True) + '\n')
identities = {}
with tarfile.open(BASE / 'publication-before.tar.gz', 'x:gz') as archive:
    for name in sorted(set(documents) | {str(BASE / leaf) for leaf in ('publish.py', 'plan.json', 'commands/qualified-stdout.gz', 'reader-epoch.json')}):
        path = Path(name)
        data = path.read_bytes()
        identities[name] = dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest(), mode=stat.S_IMODE(path.stat().st_mode))
        archive.add(path, arcname=name, recursive=False)
(BASE / 'publication-before-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
copies = []
for label, source in [('preceding-normal', '.linkedspec-data/rust-generated-loader-commit.log'),
    ('capture-outer', '.linkedspec-data/lua-transitive-capture.log'), ('probe-outer', '.linkedspec-data/lua-transitive-probes.log'),
    ('failed-support', '.linkedspec-data/lua-transitive-review.log'), ('reader-epoch-repair', '.linkedspec-data/lua-reader-epoch-repair.log'),
    ('qualified-review-outer', '.linkedspec-data/lua-selection-completion.log'), ('failed-diagnosis', '.linkedspec-data/lua-selection-setup-diagnosis.log'),
    ('qualified-diagnosis', '.linkedspec-data/lua-selection-setup-qualified.log')]:
    path = Path(source)
    data = path.read_bytes()
    if label == 'preceding-normal':
        assert b'doctrines: ALL 10 enforced doctrines PASS.' in data and b'[memory-pointer] ok: post-commit' in data
    target = BASE / (label + '.log.gz')
    target.write_bytes(gzip.compress(data, mtime=0))
    copies.append(dict(source=source, target=str(target), bytes=len(data), sha256=hashlib.sha256(data).hexdigest(),
        mode=stat.S_IMODE(path.stat().st_mode), recording='after-use copy; first failed setup raw channels and separate outer probe exit remain unavailable'))
(BASE / 'log-copies.json').write_text(json.dumps(copies, indent=2) + '\n')
telemetry = Path('.linkedspec-data/push-monitor/20261117T014942.580797Z')
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
summary = ('Eleven Lua candidates have no direct configured-driver/shared-runner operands or literal basename references in1107 regular Git blobs under six named project subtrees. '
    'Two isolated inert Bash blocks select44 operands each; missing/duplicate runner controls are RED at exit0. Shared source has83 literal dofile calls, no dynamic dofile sites and all16 earlier named candidates. '
    'Current23, positive locator and qualified reader proof pass; seven shared helper bodies are unchanged. Actual expanded-reader first-use capture is missing and remains disclosed under4.2; no SDK or complete transitive/admission claim.')
action = 'Remeasure committed outgoing size; qualify Perl145 direct loaders under ' + NEXT + ', then relevant excluded/dynamic/semantic reconciliation2 and generated Dart/frozen-input work before registration4.1.2/publication30.2 with every other prerequisite.'
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n')
end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node = node.replace('Evidence-tool defect (owned/fix now):', 'Evidence-tool defect (qualified; historical gap retained):')
node += '  Outcome: Eleven named routes absent in bounded scopes;1107 Git blobs/zero refs,44 operands per isolated ABI block/83 shared dofile/16 older names/current23 PASS. Two actual Bash inverses and positive locator pass; seven helpers exact, three reader controls. Full details and missing epoch custody in Evidence. Computed/excluded/semantic2/native4.2 remain open.\n'
path.write_text(text[:start] + node + text[end:])
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text, count = re.subn(r'(?m)^\| 1 \| `' + re.escape(OWNER) + r'`.*$',
    '| 1 | `' + NEXT + '` | `pending` | Lua named-selection slice complete with explicit reader-epoch gap; Perl145 next, then excluded/dynamic/semantic2. All later prerequisites remain. |', path.read_text())
assert count == 1
path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name)
    text, count = re.subn(r'(?m)^November17 current PNT frontier:.*$',
        'November17 current PNT frontier: Lua named-selection0 is focused-checked: eleven candidates lack named routes in inspected local/shared/literal scopes; computed/transitive/semantic2 remains open. Reader-epoch first-use gap is explicit4.2. Perl145 loader1 is next, followed by remaining reconciliation/generated Dart/frozen-input before registration4.1.2/publication30.2.', path.read_text(), count=1)
    assert count == 1
    path.write_text(text)
path = Path('docs/TASK_TREE.md')
text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Lua named-selection0 is focused-checked; Perl145 loaders1 then excluded/dynamic/semantic2 and generated Dart/frozen-input work precede registration4.1.2/publication30.2.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — bounded Lua named routes and actual Bash operand controls; reader first-use gap explicit, no SDK.', text, count=1)
text, count = re.subn(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$',
    lambda hit: hit[1] + 'PNT: Lua named selection0 focused-checked; Perl145 loader1/excluded-dynamic-semantic2/generated Dart/frozen-input then registration4.1.2. All publication prerequisites remain.' + hit[2], text)
assert count == 1
path.write_text(text)
for name, title, body in [('CHANGES.md', 'qualify bounded Lua named selection', summary),
    ('DEVELOPMENT_NOTES.md', 'retain actual evidence reader epochs', 'The local command blocks and shared runner give named routes, not complete computed reachability. Git literal census and a positive selected-name control distinguish a real empty result from a disabled locator. A readonly support addition after capture was used by probes after a grouped-shell setup failure. Preserve the used body, original frozen source and exact channels; compare seven common helper bodies before recovering the actual Bash observations. Missing before-use custody cannot be repaired retrospectively. The original draft omitted one separator newline; the following partial gzip archive has an empty decoded payload and is not a valid tar. Both initial refusal and separate qualified diagnosis remain unchanged. No capture/probe writer is replayed.')]:
    path = Path(name)
    text = path.read_text()
    offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## 2026-11-17 — ' + title + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md')
text = path.read_text()
for heading, body in {'Current Activity': 'PNT: bounded Lua named routes complete; Perl145 loaders and remaining reconciliation continue.',
    'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda hit: hit[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — Lua eleven named routes absent/1107 scoped blobs;44 commands per ABI block/83 dofile/current23/two Bash REDs; reader epoch gap disclosed.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean Lua-selection activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — bounded Lua named-selection qualification.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review_epoch_qualified.py/optional --current and diagnose_setup_qualified.py. Current23/1107 scoped blobs/eleven zero named routes/44 operands per isolated ABI block/83 shared dofile/16 earlier names; two actual Bash REDs/positive locator/seven exact helpers/three reader controls. No SDK.\n' +
    '- findings: Syntax loadfile compiles without calling the chunk. Named selection and computed reachability remain distinct. Used reader body was expanded after capture; actual body/failures are retained, seven shared helpers exact. Missing before-use capture/first setup raw channels/separate outer producer exit stay explicit4.2; no retrospective custody credit.\n' +
    '- limits: Perl145 loader1 and relevant excluded/computed/transitive/semantic2 remain open, as do generated Dart/frozen-input/default-literal/repeated ActionIR registration and all native/per-read/source-origin/physical4.2/SESSION5 or other prerequisites.\n' +
    '- publication: Activation/cached4683555e estimate1,484,126,518 bytes/124 ahead/15,873,482-byte margin to director1.5GB excludes this slice. Selected telemetry retained; raw pack/full tables ignored; independent size30/native4.2 gaps. Remeasure after landing; all prerequisites/exact canonical proof remain.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GB/director90-percent rising trend policy. Last cleanup November16 10:59UTC remains under24h; nothing removed. Normal hooks remain mandatory.\n')
path = Path(BOOK)
text = path.read_text()
marker = '\nA closed-tree epoch can renew current text capacity'
assert text.count(marker) == 1
paragraph = '''
Named test selection needs more than a file census. For Lua, `assert(loadfile(path))` returns a compiled chunk; the caller must invoke that chunk to run its body. Keep the syntax loop separate from explicit test operands and the shared runner's `dofile` calls. The current isolated primary and secondary command blocks each select44 operands, while the shared source contains83 literal `dofile` calls. Inert Bash recording can expose a missing or duplicated runner even when the shell exits0; it establishes operand selection, not successful Lua execution or host availability. A literal-reference census also leaves computed names and callers outside its declared source roots unresolved.

Freeze each evidence instrument before using it. Adding readonly recovery support creates a new instrument epoch. If a probe already imported a changed reader, retain the actual body and compare the helpers it called with the frozen original. Later recovery can qualify the saved observations while honestly retaining the missing before-use capture; it cannot recreate that earlier custody event.
'''
path.write_text(text.replace(marker, '\n' + paragraph.strip() + '\n' + marker, 1))
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review_epoch_qualified.py') + ' --current'
gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Activation Git retains1107 scoped logical source blobs;19 context sources/four original instruments, actual four Bash inputs/channels/exits and the expanded used reader are retained. That expanded reader was captured only after probe import; first failed setup raw channels and separate outer producer exit were not retained. Qualified reader retains seven identical shared helpers and actual observations without retroactive custody credit. Complete Python/Git/Bash/OS/native/outer-first-use/per-read/source-origin/physical/publication closure remains4.2/SESSION5.')
claims = [dict(name='bounded-lua-named-route-absence', statement='Eleven candidates have zero named local-driver/shared-runner routes and zero literal basename references in1107 regular blobs under the six named project subtrees.', scope=result['limits'] + ' Literal census excludes nonregular Git boundaries and other roots; no complete computed reachability or intentional-exclusion decision.',
    rederive=dict(status='checked', command=command, granularity='Each eleven candidate, each named operand/shared dofile site and every regular activation Git blob in the six exact subtrees.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='checked', hypothesis='An always-empty or disabled literal locator could explain the zero result.', oracle='Independent Python byte census agrees with actual Git fixed-string grep; a known selected concat candidate yields lua/test/run.lua through the same actual Git locator.', red_control='The positive actual lookup succeeds; a forced-empty locator fails that known selected-source oracle. Candidate identities remain the earlier independent eleven-route population.'), durability=gap),
    dict(name='actual-isolated-lua-command-selection', statement='Two isolated inert Bash command blocks record44 operands each. Actual missing-runner and duplicate-runner variants both exit0 but fail the ordered operand oracle.', scope='Only frozen local-driver primary and configured secondary command blocks; no startup/build/syntax loop/SDK/test execution or actual command-v guard result.',
        rederive=dict(status='checked', command=command, granularity='Each actual Bash stdin/argv/cwd/exit/stdout/stderr and ordered operand, compared with the separate shell-word source interpreter.', result=json.dumps(result['probes'], sort_keys=True)),
        falsify=dict(status='checked', hypothesis='Successful shell exit alone could establish complete exact operand selection.', oracle='Independent ordered shell-word interpretation of the frozen source block versus actual Bash recorder output.', red_control='Removing or duplicating the selected run.lua command changes the actual recorded population and rejects despite exit0; both healthy blocks agree.'), durability=gap),
    dict(name='actual-reader-epoch-qualification', statement='Seven shared helpers, including all helpers used by the probe producer, are byte-identical between the frozen original and actual expanded reader. The expanded body and failed support artifacts survive; missing before-use custody remains explicit.', scope='Only common helper bytes/module bindings, actual saved Bash records and three reader controls; no complete original first-use or native/outer-producer custody.',
        rederive=dict(status='checked', command=command, granularity='Both full reader bodies, original shared-function source segments, exact three-edit derivation and original raw Bash observations.', result=json.dumps(result['reader_epoch'], sort_keys=True)),
        falsify=dict(status='checked', hypothesis='The after-capture edit could silently change a helper used to select operands.', oracle='Independent frozen original function bodies compared byte-for-byte with AST-bounded functions in the actual used body.', red_control='Changed scan body and changed command-population guard reject at the exact scan helper; the unmodified seven helpers agree. The always-empty locator control separately rejects.'), durability=gap)]
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
claims.append(dict(name='activation-outgoing-estimate', statement='Committed activation estimates1,484,126,518 non-thin bytes against cached4683555e;15,873,482 bytes below director1.5GB.', scope=size['limits'],
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py', granularity='Actual committed activation/cached-origin range, selected producer/ref/config/command metadata copied after use.', result=json.dumps(size, sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Producer stream/stat/footer agree; independent actual-file size falsification stays30.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Selected telemetry retained; raw pack/full object tables ignored on this volume. Native/physical/complete input closure remains4.2/SESSION5; no fresh remote/wire/future guarantee.')))
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
