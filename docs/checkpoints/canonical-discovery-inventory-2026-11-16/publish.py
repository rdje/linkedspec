"""Publish the verified source preparation and qualified portable archive."""
import gzip
import json
from pathlib import Path
import re
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.0'
ACTIVATION = 'e3940a675d6313b226c6492198cbdb60c18b78dd'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
OLD_REVIEW = 'docs/checkpoints/canonical-discovery-plan-2026-11-16/REVIEW.md'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION


def stage(name):
    folder = BASE / 'steps' / name
    assert (folder / 'exit.txt').read_text() == '0\n'
    assert gzip.decompress((folder / 'stderr.gz').read_bytes()) == b''
    return json.loads(gzip.decompress((folder / 'stdout.gz').read_bytes()))


proof, current = stage('epoch-check'), stage('current-check')
assert proof['result'] == current['result'] == 'PASS'
rows, proposals, missing = proof['consumers'], proof['producer_proposals'], proof['proposal_perl_omissions']
members = proof['archive']['canonical_members']
assert len(proof['integrity_controls']) == len(proof['selector_controls']) == 5
targets = [BOOK, OLD_REVIEW, 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'MEMORY.md',
           'LIVE_ACHIEVEMENT_STATUS.md', 'ROADMAP.md', 'ROADMAP_V2.md',
           'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md',
           'docs/tasks/TYPE-REFERENCE-BOOK.overview.md']
claims = subprocess.check_output(['git', 'ls-files', 'docs/claims'], text=True).splitlines()
bindings = []
with tarfile.open(BASE / 'publication-before.tar.gz', 'x:gz') as archive:
    for name in targets + claims:
        assert not Path(name).is_absolute() and '..' not in Path(name).parts
        archive.add(name, arcname=name, recursive=False)
    for name in claims:
        body = Path(name).read_bytes()
        assert body == subprocess.check_output(['git', 'show', ACTIVATION + ':' + name])
        for item in json.loads(body)['claims']:
            durability = item['durability']
            if durability['status'] == 'checked':
                for entry in durability['inputs']:
                    if entry['path'] in targets:
                        assert durability['mode'] == 'historical', 'preserve live binding:' + name
                        bindings.append(dict(record=name, claim=item['name'], revision=durability['revision'], **entry))
(BASE / 'publication-bindings.json').write_text(json.dumps(bindings, indent=2) + '\n')


def edit(name, old, new):
    path = Path(name)
    text = path.read_text()
    assert text.count(old) == 1, 'exact publication anchor:' + name
    path.write_text(text.replace(old, new, 1))


summary = f'{rows} filename-universe candidates, {proposals} captured-classifier proposals and {missing} proposed Perl paths without direct unconditional selection; five actual Bash selector controls and five evidence controls pass.'
archive_summary = f'All{members} planning-archive member bodies/modes recover independently through native tar after correcting one noncanonical self-source name. Original archive/producer stay exact; legacy namespace RED and five archive controls pass.'
edit('docs/tasks/TYPE-REFERENCE-BOOK.overview.md', f'- ID: `{OWNER}`\n  Status: `active`', f'- ID: `{OWNER}`\n  Status: `completed`')
edit('docs/tasks/TYPE-REFERENCE-BOOK.overview.md', '  Next: Capture and verify the bounded source preparation, then qualify actual loaders and final targets under4.1.1.1 after a clean commit.',
     f'  Outcome: {summary} {archive_summary} Actual preparation/readonly/current identity pass; no SDK test executed. Candidate paths/keyword lines and raw proposal roles remain unqualified.\n  Evidence: {BASE}/REVIEW.md; default verify_epoch.py is readonly. Qualification4.1.1.1 remains next and parent4.1.1 stays active; exact registration/full canonical4.1.2 and every separate before-push owner remain. Native/source-origin/physical custody stays4.2/SESSION5.')
edit('docs/tasks/TYPE-REFERENCE-BOOK.md', '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.4.1.1` | `pending` | Freeze the current feature/discovery/input inventory before exact registration4.1.2 and early publication; separate before-push owners remain. |',
     '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1` | `pending` | Qualify proposed consumer/support roles and actual loaders after source preparation0; then freeze registration4.1.2 input. All separate before-push owners remain. |')
path = Path('docs/TASK_TREE.md')
text = path.read_text()
text = re.sub(r'^Current frontier:.*$', 'Current frontier: Source preparation TYPE-REFERENCE-BOOK.1.2.23.4.1.1.0 is focused-checked. Qualification4.1.1.1 owns actual target/loader interpretation before registration4.1.2 and publication30.2; no source-only canonical credit.', text, count=1, flags=re.M)
text = re.sub(r'^Latest PNT slice:.*$', 'Latest PNT slice: TYPE-REFERENCE-BOOK.1.2.23.4.1.1.0 — source/selector preparation and portable planning-archive qualification; no SDK execution or admission.', text, count=1, flags=re.M)
path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name)
    text = path.read_text()
    marker = 'November16 current PNT frontier: Canonical-discovery plan TYPE-REFERENCE-BOOK.1.2.23.4.1.0 is complete. Inventory4.1.1 precedes exact registration/source admission/canonical4.1.2 and publication30.2 after every independent before-push owner. No runner, runtime, fixture or admission change is claimed.'
    assert text.count(marker) == 1
    text = text.replace(marker, 'November16 current PNT frontier: Source preparation TYPE-REFERENCE-BOOK.1.2.23.4.1.1.0 is focused-checked; actual consumer/loader qualification4.1.1.1 is next. Registration/source admission/canonical4.1.2 and all separate before-push owners precede publication30.2. No SDK execution or runtime/admission change is claimed.', 1)
    path.write_text(text)
edit(BOOK, 'Accumulated feature regressions enter canonical CI in two steps:',
     f'The current source preparation retains {rows} candidate consumer files and {proposals} classifier proposals; {missing} proposed Perl paths have no direct unconditional selector. Actual Bash argument extraction uses stubs, with five missing/duplicate/disabled-command controls and five independent evidence controls. These are preparation results. Target ownership, actual loaders, automatic backend discovery, SDK tests and canonical inclusion still need their own proof.\n\nArchive member names must be derived relative to the repository before adding source images. The planning capture used an absolute self-source name and retained the checkout prefix in that one archive member. A separate qualified archive restores the canonical namespace while retaining all{members} member bodies/modes; native tar independently recovers every body/mode. The original capture stays historical, with no new original first-use or native-custody credit. Recovery: `bash tools/run_python_project_data.sh {BASE}/verify_epoch.py`.\n\nAccumulated feature regressions enter canonical CI in two steps:')
Path(OLD_REVIEW).write_text(Path(OLD_REVIEW).read_text() + f'''\n## Portable source-image qualification\n\nThe original archive retains one noncanonical self-source member created from an\nabsolute `__file__` value. Keep the original archive/producer unchanged as historical\nevidence. Portable logical recovery now uses `{BASE}/plan-archive/before-qualified.tar.gz`\nand the readonly `{BASE}/verify_epoch.py`. All{members} member bodies/modes are preserved;\nonly the self-source member name is normalized. Native tar recovery, original\nnamespace RED and five path/body/mode controls pass. This supplies no retroactive\noriginal producer-first-use or complete native/OS input-custody credit.\n''')
for name, heading, body in [('CHANGES.md', '2026-11-16 — prepare canonical source selection and portable recovery', summary + ' ' + archive_summary),
    ('DEVELOPMENT_NOTES.md', '2026-11-16 — preserve preparation limits and source-image namespace', 'The inventory freezes an activation filename universe and actual stubbed Bash arguments. Captured classifier proposals, literal references and potential keyword lines are unqualified source evidence; they do not establish ownership, actual input reads, SDK results or canonical admission. Qualification4.1.1.1 precedes registration4.1.2. The earlier archive defect comes from passing absolute Path(__file__) as arcname. A separate root-relative image preserves original member bodies/modes and actual producer bytes; native recovery and source/data controls verify it without rewriting the original epoch.')]:
    path = Path(name)
    text = path.read_text()
    offset = text.index('\n## ')
    path.write_text(text[:offset] + f'\n## {heading}\n\n{OWNER}: {body} Evidence: `{BASE}/REVIEW.md`. Focused preparation only; full canonical and all before-push owners remain open.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md')
text = path.read_text()
for heading, body in {'Current Activity': 'PNT: actual consumer/loader qualification4.1.1.1 follows focused source preparation0. Exact registration/source admission4.1.2 and every independent before-push owner remain.',
    'Latest Completed Slice': OWNER + ' — ' + summary + ' ' + archive_summary,
    'Next Action': 'Qualify proposed consumer/support/dormant/fixture roles and actual loaders under4.1.1.1; preserve direct/native/source-origin gaps under4.2/SESSION5. Freeze registration input, then exact staged canonical4.1.2 and publication30.2 after all prerequisites.'}.items():
    text, count = re.subn(r'(## ' + re.escape(heading) + r'\n\n).*?(?=\n## )', lambda match: match[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
text = text[:start] + '## Recent Completions\n\n- ' + OWNER + f' — source{rows}/proposals{proposals}/candidate Perl omissions{missing}/five selector+five evidence controls; portable archive{members}/five controls; no SDK or canonical credit.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:]
path.write_text(text)
Path('MEMORY.md').write_text(f'''# MEMORY

- activation_commit: `{ACTIVATION}` — clean source-preparation0 activation; derive current HEAD from Git.
- latest_completed_leaf: `{OWNER}` — source/selector preparation and portable source-image qualification.
- active_work_unit: `{OWNER}` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.
- run_state: PNT; continue after each clean leaf.
- next_action: Qualify proposed consumer/support/dormant/fixture roles and actual loaders under TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1. Then freeze registration input, exact source admission/canonical4.1.2 and publication30.2 after every independent before-push owner.
- in_flight_uncommitted: none; no required background job.
- evidence: {BASE}/REVIEW.md; default verify_epoch.py is readonly. {summary}
- archive: Qualified root-relative source image preserves all{members} old member bodies/modes; original bad namespace/producer stay exact, native recovery and five controls pass. No retroactive first-use/native custody credit.
- limits: No SDK test ran. Raw proposal roles, literal path candidates, keyword lines, backend automatic discovery and actual per-read closure remain unqualified; parent4.1.1 stays active. Full23.4, direct/native4.2/SESSION5, historical4.24, declared5.4/formatter, source/context/shadowing and launcher/SESSION7/literal/excluded owners remain open.
- publication: Existing director1.5GB trigger still governs; remeasure committed HEAD before growth. Current diagnostic is .linkedspec-data/push-monitor/20261116T122344.625889Z; raw pack stays ignored/protected. No remote/wire/future-size promise; current-independent/native gaps remain30/4.2.
- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GiB/current90-percent rising-trend policy; no recover/purge while denied liveness remains unresolved. Cleanup: docs/ARTIFACT_CLEANUP.md.
''')
(BASE / 'REVIEW.md').write_text(f'''# Canonical source preparation and portable archive qualification

Owner: {OWNER}. Activation: {ACTIVATION}.

{summary}

The {rows} records are a Git filename universe plus selected external Perl fixtures.
The {proposals} records are the captured classifier's proposals, not the qualified
registration population. The {missing} paths are proposed Perl records absent from
actual unconditional selector arguments. Presence, syntax and prove are stubbed:
no SDK test executes. Independent shell-word interpretation and actual changed
Bash executions distinguish omitted, duplicated and disabled selection even when
the shell exits0. Separate source/population/route/path corruptions also reject.
Literal references are candidate edges; keyword lines include comments, strings
and possible writes. Actual loader interpretation, ownership/support/dormancy,
automatic backend discovery and canonical execution remain qualification1 and
registration4.1.2. Full per-read/native/transitive closure remains4.2/SESSION5.

{archive_summary}

The older publisher passed absolute Path(__file__) as arcname. The new qualified
image uses only root-relative canonical member names, preserving every original
body/mode. Original bytes/Git blob, native full name/mode/body channels and five
effective controls survive in plan-archive/. No filesystem extraction occurs.
The original archive is retained as historical evidence; use before-qualified.tar.gz
for portable namespace recovery. Earlier original capture/producer timing stays
unchanged and gains no first-use credit.

Actual sources, Git blob packets/path mappings, command inputs/full channels and
before-child producer images survive. Capture outer launchers already execute
before their self-images; unused extra source snapshots grant no earlier use
credit. Python/Bash/Git/Tar/native/cache/library/filesystem/OS epochs and wider
source-origin/physical closure remain explicit4.2/SESSION5 gaps. Current-source
checks apply only at their observed pre-landing point, never future freshness.

Readonly recovery (no SDK, writer or capture replay):

```sh
bash tools/run_python_project_data.sh {BASE}/verify_epoch.py
```

The capture/controls/qualification/publication writers are completed one-shot
instruments. Do not replay them or refresh older observations/claim hashes.
Next: actual qualification4.1.1.1; parent inventory and canonical admission remain
open. Shared publication inputs are preserved before these edits and all accepted
claim bindings retain their prior fields/hashes/revisions.
''')
gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Actual project code, activation Git sources/blob mappings, before-child images and full command channels are retained. Complete native Python/Bash/Git/Tar/cache/library/filesystem/OS and outer-launcher first-use epochs remain4.2/SESSION5. Candidate paths/keyword lines provide no actual per-read closure; no retroactive original plan-source timing credit.')
record = dict(version=1, owner=OWNER, claims=[dict(name='source-universe-and-stubbed-selector-preparation',
    statement=summary, scope='Activation-bound filename universe and captured-classifier proposals only, including selected external Perl fixtures. Proposed ownership/roles and actual loaders remain unqualified. Bash stubs emit arguments rather than perform presence/syntax/prove or SDK tests. No automatic backend discovery, runtime result or canonical admission is inferred.',
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + str(BASE / 'verify_epoch.py'), granularity='Every candidate/source identity and actual ordered Bash selector argument; preserved original/changed scripts and separate readonly recovery.', result=json.dumps(proof, sort_keys=True)),
    falsify=dict(status='checked', hypothesis='Missing/duplicated consumers, changed source bytes, false route or candidate path, or missing/disabled/duplicated selector commands could pass.', oracle='Independent Git path population, source Git blobs, shell-word interpretation and actual Bash argument channels; evidence routes checked against those observations.', red_control='Five actual Bash selector mutations have native exit0 but independent population/order RED. Five consumer/source/route/path corruptions reject in verify_epoch.py. Original and first/final readonly channels remain exact.'), durability=gap),
    dict(name='portable-plan-source-image-qualification', statement=archive_summary,
    scope='Exactly the original planning archive at activation and its226 retained member bodies/modes; one source-member logical name is corrected in a separate image. Original archive/producer stay unchanged. No original-first-use, whole-project archive census, native closure or filesystem-extraction claim.',
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + str(BASE / 'verify_epoch.py'), granularity='Every original/qualified member path/body/mode, original Git blob and independent native tar name/mode/full-body recovery.', result='Actual qualification0 and readonly recovery0: original namespace RED, qualified namespace/body/modes GREEN; all' + str(members) + ' members and five controls. Full actual channels retained.'),
    falsify=dict(status='checked', hypothesis='A checkout-prefixed source member or lost/duplicated/unsafe/changed body/mode could be accepted as portable recovery.', oracle='Activation Git publisher bytes and original archive; independent native tar recovers every qualified body/mode.', red_control='Actual original namespace rejects; qualified image passes. Missing, duplicate, unsafe-path, body and mode controls are effective; original archive hash/Git identity remains exact.'), durability=gap)])
claim = Path('docs/claims') / (OWNER + '.json')
assert not claim.exists()
claim.write_text(json.dumps(record, indent=2) + '\n')
print('verified source preparation, archive qualification and explicit limits published')
