"""Publish the bounded role result once; leave registration and loader closure open."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.0'
NEXT = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1'
ACTIVATION = '3f619e9c2aa74d0f3f8d9d64c2c90e82d11d81e0'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert (BASE / 'review-exit.txt').read_text() == '0\n'
assert gzip.decompress((BASE / 'review-stderr.gz').read_bytes()) == b''
result = json.loads(gzip.decompress((BASE / 'review-stdout.gz').read_bytes()))
assert result['result'] == 'PASS' and len(result['controls']) == 7
assert all(row['result'] == 'RED' for row in result['controls'].values())
assert not (BASE / 'publication-before.tar.gz').exists(), 'publication is one-shot'
documents = [BOOK, 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md',
             'docs/TASK_TREE.md', 'ROADMAP.md', 'ROADMAP_V2.md', 'CHANGES.md',
             'DEVELOPMENT_NOTES.md', 'MEMORY.md', 'LIVE_ACHIEVEMENT_STATUS.md']
bindings, claims = [], []
for path in sorted(Path('docs/claims').glob('*.json')):
    claim_record = json.loads(path.read_bytes())
    for claim in claim_record['claims']:
        leg = claim['durability']
        for item in leg.get('inputs', []):
            if item['path'] in documents:
                bindings.append(dict(record=str(path), claim=claim['name'], input=item,
                                     mode=leg['mode'], revision=leg.get('revision')))
                assert leg['mode'] == 'historical', 'live claim input needs separate qualified preservation'
                claims.append(str(path))
with tarfile.open(BASE / 'publication-before.tar.gz', 'x:gz') as archive:
    for name in sorted(set(documents + claims + [str(BASE / 'publish.py')])):
        path = Path(name)
        assert not path.is_absolute() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        archive.add(path, arcname=name, recursive=False)
(BASE / 'publication-bindings.json').write_text(json.dumps(bindings, indent=2, sort_keys=True) + '\n')
summary = ('The bounded Perl ledger classifies145 named candidates as134 proposed feature suites, '
           'nine compatibility suites and two maintenance suites. Twelve have direct selection, '
           'one has a named include route and132 have neither route in this bounded review. '
           'Seven ledger corruptions reject;164 retained inputs match current bytes/modes. '
           'This is static qualification, with no Perl execution or canonical admission.')
next_action = ('Complete remaining native roles and direct-loader/discovery qualification under ' + NEXT +
               ', then freeze registration4.1.2 input; remeasure committed outgoing size before growth.')
path = Path(documents[1])
text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n')
end = text.index('\n- ID:', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `completed`', 1)
node += ('\n  Owned registration findings: default_literal_operand_contract.t is a real native/fresh lazy Hash-default regression owned by completed3.6.1.2, but is absent from the retained direct selector and callable named includes. Schedule exact admission under4.1.2 before push. Pipeline value contract is included by the selected callable suite and must retain that route. Existing direct actionir_ast_parser/actionir_receiver_scalar_copy selections each occur twice (standalone plus private supplied array);4.1.2 owns exact route reconciliation without weakening either historical supplied-input contract. These are source-route findings, not executed test failures.\n'
         '  Reader repair: Initial capture retained all source bodies before the selector reader rejected a log string containing prove. Original capture/reader/channel bytes remain exact. The separate qualified reader filters actual top-level command forms before the original shell-word interpreter, agrees with the older actual Bash wire, and rejects all seven ledger mutations. No source recapture or Perl test replay.\n'
         '  Outcome: ' + summary + '\n  Evidence: ' + str(BASE / 'REVIEW.md') + '. No direct-loader, native, dynamic include, full population, per-read or source-origin closure; existing4.2/SESSION5 owners remain.\n'
         '  Commit: `' + OWNER + ' - qualify Perl consumer roles and selection`\n  Next: ' + next_action + '\n')
path.write_text(text[:start] + node + text[end:])
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text = path.read_text()
text, count = re.subn(r'(?m)^\| 1 \| `TYPE-REFERENCE-BOOK\.1\.2\.23\.4\.1\.1\.1\.1`.*$',
    '| 1 | `' + NEXT + '` | `pending` | Complete native roles/direct loaders/discovery after bounded Perl roles; freeze registration4.1.2 input. All separate before-push owners remain. |', text)
assert count == 1
path.write_text(text)
path = Path('docs/TASK_TREE.md')
text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Bounded Perl roles ' + OWNER +
              ' are focused-checked; native roles/direct loaders/discovery precede registration4.1.2 and publication30.2.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — bounded Perl roles and named selection; no SDK execution or admission.', text, count=1)
text, count = re.subn(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$',
    lambda match: match[1] + 'PNT: Perl role qualification4.1.1.1.1.0 is focused-checked; native roles/loaders/discovery then registration4.1.2. Publication30.2 retains all prerequisites.' + match[2], text)
assert count == 1
path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name)
    text, count = re.subn(r'(?m)^November16 current PNT frontier:.*$',
        'November16 current PNT frontier: Bounded Perl roles ' + OWNER + ' are focused-checked. Remaining native roles/direct loaders/discovery precede frozen registration4.1.2 and publication30.2. Default literal omission and redundant direct routes are owned by4.1.2; no SDK execution or full admission is claimed.', path.read_text(), count=1)
    assert count == 1
    path.write_text(text)
for name, heading, body in [
    ('CHANGES.md', '2026-11-16 — qualify bounded Perl consumer roles', summary),
    ('DEVELOPMENT_NOTES.md', '2026-11-16 — distinguish Perl suite roles and named includes',
     'Harness/completion source and the retained actual selector distinguish maintenance from feature/compatibility candidates. The callable suite includes the pipeline regression inside a subtest; its unless-caller completion supports that route. The lazy default-literal regression has no direct or named-callable route. Existing ActionIR parser/copy direct repetitions remain explicit for registration reconciliation. Initial reader log-string refusal is retained; command-boundary qualification fixes only the reader. No test or runner changed.')]:
    path = Path(name)
    text = path.read_text()
    offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## ' + heading + '\n\n' + OWNER + ': ' + body +
                    ' Evidence: `' + str(BASE / 'REVIEW.md') + '`. Full population/direct-input/native/source-origin closure remains separately owned.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md')
text = path.read_text()
for heading, body in {'Current Activity': 'PNT: bounded Perl role qualification complete; remaining native roles/direct loaders/discovery precede registration.',
                      'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': next_action}.items():
    text, count = re.subn(r'(## ' + heading + r'\n\n).*?(?=\n## )', lambda match: match[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — Perl145 roles/134 feature/nine compatibility/two maintenance; direct12/include1/unresolved132; seven controls/current164, static only.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('''# MEMORY

- activation_commit: `''' + ACTIVATION + '''` — clean Perl role-qualification activation; derive current HEAD from Git.
- latest_completed_leaf: `''' + OWNER + '''` — bounded Perl roles and selection.
- active_work_unit: `''' + OWNER + '''` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.
- run_state: PNT; continue after each clean leaf.
- next_action: ''' + next_action + '''
- in_flight_uncommitted: none; no required background job.
- evidence: ''' + str(BASE / 'REVIEW.md') + '''; readonly review_qualified.py; optional --current compares164 retained bodies/modes. Perl145 candidates/134 feature/nine compatibility/two maintenance; seven controls. No Perl test executed.
- findings: Default literal suite3.6.1.2 lacks direct/named-callable selection; pipeline retains selected callable include. Two repeated direct ActionIR selections remain explicit. Registration4.1.2 owns repairs before push.
- limits: No complete dynamic include/input/native discovery/population/canonical claim. Remaining roles/direct loaders stay''' + NEXT + '''. Full per-read/native/source-origin/physical closure remains4.2/SESSION5; prior declared5.4/formatter/context/shadowing/launcher/literal/excluded owners stay open.
- preparation: Original952/proposals221/candidate direct Perl omissions131 is dated preparation only; new132 counts only bounded Perl candidates with neither direct nor named-callable route. These populations are different. Prior Dart six-consumer loader ledger stays intact.
- publication: Director1.5GB trigger governs. Activation diagnostic .linkedspec-data/push-monitor/20261116T160427.428529Z estimates1,459,369,485 bytes/113 ahead/cached4683555e;40,630,515-byte margin is dated, excludes this slice, and has existing30/4.2 gaps. Remeasure after landing;30.2 requires all prerequisites and exact canonical proof.
- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GiB/current90-percent rising-trend policy. Cleanup docs/ARTIFACT_CLEANUP.md is current; nothing removed.
''')
path = Path(BOOK)
text = path.read_text()
marker = '\nArchive member names must be derived relative to the repository'
assert text.count(marker) == 1
paragraph = ('\nSource discovery also distinguishes a Perl test selected directly by `prove` from a test included inside another selected suite. For example, the callable suite loads the pipeline-value contract in a subtest; its `done_testing() unless caller` supports that include route. The bounded role review retains feature, compatibility and maintenance candidates separately. The default-literal contract has no direct or named-callable selection in that review and is owned for registration repair. Source routes and retained omission controls do not establish executed tests, complete dynamic loader coverage or canonical admission.\n')
path.write_text(text.replace(marker, paragraph + marker, 1))
command = 'bash tools/run_python_project_data.sh ' + str(BASE / 'review_qualified.py') + ' --current'
claim = dict(version=1, owner=OWNER, claims=[dict(name='bounded-perl-consumer-roles', statement=summary,
    scope=result['limits'],
    rederive=dict(status='checked', command=command,
        granularity='Each named candidate role/harness/completion/owner and ordered direct selection versus the original Bash wire; eleven named callable include expressions; archived/current bodies and modes.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='checked', hypothesis='A missing/duplicated candidate, promoted maintenance role, lost include, invented default selection, hidden repetition or removed owner could pass.',
        oracle='Activation Git source and the independently retained older actual Bash selector wire; named executable do expression and source caller-plan boundary distinguish the pipeline route from default omission.',
        red_control='Seven named ledger corruptions reject in retained actual review output; healthy source reconstruction and actual selector comparison pass.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2',
        reason='Source bodies/modes, activation Git listing, original inventory/Bash channels, actual original refusal, qualified instrument/source images and successful review channels are tracked. Complete native Python/Git/library/OS, outer-launcher first-use and per-read/source-origin/physical custody remain4.2/SESSION5. No retroactive first-use, Perl execution or complete input graph claim.'))])
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(claim, indent=2) + '\n')
print(summary)
