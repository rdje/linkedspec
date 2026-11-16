"""Publish one finite source-route slice; retain original historical claim bindings."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
ACTIVATION = 'cb8978713452f427823f56e456ddc71ad75f0574'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1.0'
PARENT = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1'
NEXT = PARENT + '.1'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'publication-bindings.json').exists(), 'one-shot publication'
assert (BASE / 'review-exit.txt').read_text() == '0\n'
result = json.loads(gzip.decompress((BASE / 'review-stdout.gz').read_bytes()))
assert result['result'] == 'PASS' and result['branch_selection']['observed_red'] == ['missing', 'duplicate', 'disabled']
documents = [BOOK, 'MEMORY.md', 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'LIVE_ACHIEVEMENT_STATUS.md',
             'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md',
             'docs/tasks/TYPE-REFERENCE-BOOK.overview.md']
bindings = []
for path in sorted(Path('docs/claims').glob('*.json')):
    for claim in json.loads(path.read_bytes())['claims']:
        leg = claim['durability']
        for item in leg.get('inputs', []):
            if item['path'] in documents:
                assert leg['mode'] == 'historical', 'live binding requires qualified preservation'
                bindings.append(dict(record=str(path), claim=claim['name'], input=item,
                                     mode=leg['mode'], revision=leg['revision']))
(BASE / 'publication-bindings.json').write_text(json.dumps(bindings, indent=2, sort_keys=True) + '\n')
telemetry = Path('.linkedspec-data/push-monitor/20261116T191307.663356Z')
(BASE / 'telemetry').mkdir()
copies = []
for path in sorted(telemetry.iterdir()):
    if path.suffix in ('.pack', '.idx', '.log'):
        continue
    target = BASE / 'telemetry' / path.name
    shutil.copy2(path, target)
    assert target.read_bytes() == path.read_bytes() and target.stat().st_mode == path.stat().st_mode
    copies.append(dict(source=str(path), target=str(target), bytes=path.stat().st_size,
                       sha256=hashlib.sha256(path.read_bytes()).hexdigest(), mode=path.stat().st_mode & 0o777))
(BASE / 'telemetry-copies.json').write_text(json.dumps(copies, indent=2) + '\n')
summary = ('Named native source routes are focused-checked: Rust22/Dart25 convention paths, '
           'Julia20 includes and Lua16 named dofile routes; eleven Lua local routes remain unqualified. '
           'All113 retained inputs match current bodies/modes; six inert optional-branch cases and '
           'three observed selection REDs pass, alongside seven ledger controls. No SDK executed.')
next_action = ('Remeasure committed outgoing size; resolve remaining loaders/support/dormancy/transitive routes under ' +
               NEXT + ' before freezing registration4.1.2 input; all separate before-push owners remain.')
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n'); end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node += '\n  Outcome: ' + summary + '\n  Remaining: Sibling1 owns all eleven unresolved Lua routes, remaining direct loaders/support roles and independent semantic adjudication; registration/full native custody remain separate.\n'
path.write_text(text[:start] + node + text[end:])
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text, count = re.subn(r'(?m)^\| 1 \| `TYPE-REFERENCE-BOOK\.1\.2\.23\.4\.1\.1\.1\.1\.1`.*$',
    '| 1 | `' + NEXT + '` | `pending` | Native bounded routes are focused-checked; resolve remaining loaders/support/dormancy/transitive routes, then freeze registration4.1.2 input. Separate push owners remain. |', path.read_text())
assert count == 1
path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name)
    text, count = re.subn(r'(?m)^November16 current PNT frontier:.*$',
        'November16 current PNT frontier: Bounded native source routes ' + OWNER + ' are focused-checked without SDK execution. Remaining loaders/support/dormancy/transitive routes precede registration4.1.2 and publication30.2; independent semantic/native custody remains open.', path.read_text(), count=1)
    assert count == 1
    path.write_text(text)
path = Path('docs/TASK_TREE.md')
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Bounded native source routes are focused-checked; remaining loaders/support/transitive routes precede registration4.1.2 and publication30.2.', path.read_text(), count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — bounded native source routes and inert conditional selection; no SDK execution or admission.', text, count=1)
text, count = re.subn(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$',
    lambda match: match[1] + 'PNT: bounded native routes focused-checked; remaining loaders/support/transitive discovery then registration4.1.2. Publication30.2 retains all prerequisites.' + match[2], text)
assert count == 1
path.write_text(text)
for name, title, body in [('CHANGES.md', '2026-11-16 — qualify bounded native consumer source routes', summary),
    ('DEVELOPMENT_NOTES.md', '2026-11-16 — distinguish native route source from execution',
     'The finite native ledger binds the prior required-or-review selector to source harness markers and exact local route expressions. Convention paths differ from named includes; eleven Lua local routes remain unqualified. Actual optional branch text runs with inert shell recorders and an independent flag/path oracle: missing, duplicate and disabled commands all exit0 yet distinguish RED. Ledger consistency is separate from independent semantic role adjudication, which stays with the next loader owner. Existing historical claim values remain unchanged.')]:
    path = Path(name); text = path.read_text(); offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## ' + title + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md'); text = path.read_text()
for title, body in {'Current Activity': 'PNT: bounded native source routes complete; remaining loaders/support/transitive qualification precedes registration.',
                    'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': next_action}.items():
    text, count = re.subn(r'(## ' + title + r'\n\n).*?(?=\n## )', lambda match: match[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — native94/source113; conditional6/RED3; ledger7; eleven local Lua routes unresolved, no SDK.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('# MEMORY\n\n' +
    '- activation_commit: `' + ACTIVATION + '` — clean native source-route activation; derive current HEAD from Git.\n' +
    '- latest_completed_leaf: `' + OWNER + '` — bounded native source roles and conditional selection.\n' +
    '- active_work_unit: `' + OWNER + '` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.\n' +
    '- run_state: PNT; continue after each clean leaf.\n- next_action: ' + next_action + '\n' +
    '- in_flight_uncommitted: none; no required background job.\n' +
    '- evidence: ' + str(BASE / 'REVIEW.md') + '; readonly review.py; optional --current compares113 retained bodies/modes. Native94: Rust22/Dart25/Julia20/Lua27. Six inert branch cases/three observed REDs/seven ledger controls; no SDK execution.\n' +
    '- findings: Eleven Lua local routes remain unqualified; sibling1 owns transitive resolution and independent semantic role adjudication. Default literal suite3.6.1.2 omission and two repeated ActionIR direct routes remain4.1.2-owned; pipeline retains its callable include. Prior Perl/Dart ledgers remain dated/static.\n' +
    '- limits: No complete population/dynamic loader/runtime discovery/canonical claim. Full per-read/native/source-origin/physical closure remains4.2/SESSION5; prior declared5.4/formatter/context/shadowing/launcher/literal/excluded owners stay open.\n' +
    '- publication: Director1.5GB trigger governs. Activation/cached4683555e estimate1,474,669,798 bytes/115 ahead/25,330,202-byte margin is dated and excludes this slice; telemetry retained with independent-size falsification30/native4.2 gaps. Remeasure after landing;30.2 requires all prerequisites and exact canonical proof.\n' +
    '- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GB/director90-percent rising-trend policy. Daily cleanup current; nothing removed. Normal hooks are the mandatory global integrity boundary.\n')
path = Path(BOOK); text = path.read_text()
marker = '\nClosed-task commentary can use the existing explicit epoch interface'
assert text.count(marker) == 1
paragraph = ('\nNative source routes also require distinct evidence. A Rust package test command and a Dart package test command can select files by documented conventions; Julia package tests enter `test/runtests.jl` and its named includes; Lua local tests use explicit operands or named `dofile` calls. A convention-compatible filename alone establishes no execution. Inert shell recorders can verify optional flag selection, including missing, duplicated and disabled commands, while leaving SDK discovery and test results unclaimed. Remaining transitive routes and direct artifact loaders must be resolved before freezing canonical registration input.\n')
path.write_text(text.replace(marker, paragraph + marker, 1))
gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2',
           reason='Archived logical source bodies/modes, activation Git listing, instruments and actual command channels are retained. Complete native Python/Bash/Git/toolchain/library/OS, outer-launcher first-use, per-read/source-origin and physical custody remains4.2/SESSION5. No SDK or canonical admission is inferred.')
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review.py') + ' --current'
claims = [dict(name='bounded-native-source-routes', statement=summary,
    scope=result['limits'], rederive=dict(status='checked', command=command,
        granularity='Each of94 named candidate paths, source marker lines, prior selector and local route expressions;113 archived/current source bodies/modes.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='gap', repair_owner=NEXT,
        reason='Seven ledger mutations reject source inconsistency and activation Git binds the sources, but fully independent semantic classification/transitive discovery of all candidate roles is not yet available. Sibling1 must resolve the remaining population before registration; convention eligibility supplies no SDK discovery result.'),
    durability=gap), dict(name='optional-backend-branch-selection',
    statement='Six inert actual Bash branch cases agree with a separate flag/path oracle. Missing, duplicate and disabled-command scripts all exit0 but produce observed RED path populations. No SDK executes.',
    scope='Only the retained optional backend branch, using inert function recorders. Unconditional canonical commands, SDK discovery and actual gate/test execution are outside this proof.',
    rederive=dict(status='checked', command=command, granularity='All actual script inputs, flag environments, ordered recorder stdout, empty stderr and exit status for six healthy and three altered scripts.', result=json.dumps(result['branch_selection'], sort_keys=True)),
    falsify=dict(status='checked', hypothesis='Shell exit0 could hide a missing, duplicated or disabled local-gate command.',
        oracle='Separately constructed expected flag-to-local-script path lists, compared with actual inert Bash argument-recording channels from unchanged branch text and three source inverses.',
        red_control='Missing, duplicate and disabled scripts each exit0 and differ from the independently expected ordered path list. Six healthy scripts agree.'), durability=gap)]
size = json.loads((BASE / 'telemetry/result.json').read_bytes())
claims.append(dict(name='activation-outgoing-estimate', statement='Committed activation estimates1,474,669,798 non-thin serialized bytes against cached4683555e;25,330,202 bytes below the director1.5GB trigger.',
    scope=size['limits'], rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py',
        granularity='The actual committed activation/cached-origin range; original monitor producer/input/command channels and metadata copied without replay.', result=json.dumps(size, sort_keys=True)),
    falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='Original pack byte count, file stat and footer agree inside the producer. Independent actual-file size falsification remains publication30; this slice does not infer it from copied metadata.'), durability=gap))
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
