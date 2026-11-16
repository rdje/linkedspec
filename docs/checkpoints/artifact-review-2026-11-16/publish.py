"""Publish the bounded review after checking existing shared claim bindings."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.33'
ACTIVATION = 'b3ab04a22019bd8e95fcba47d278b95bb401d709'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
targets = ['docs/ARTIFACT_CLEANUP.md', BOOK, 'CHANGES.md', 'DEVELOPMENT_NOTES.md',
           'MEMORY.md', 'LIVE_ACHIEVEMENT_STATUS.md', 'docs/TASK_TREE.md',
           'docs/tasks/TYPE-REFERENCE-BOOK.overview.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md',
           'docs/tasks/TYPE-REFERENCE-BOOK.index.jsonl']
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
assert not (BASE / 'publication-before.tar.gz').exists(), 'one-shot publication'
claims = subprocess.check_output(['git', 'ls-files', 'docs/claims'], text=True).splitlines()
hits = []
with tarfile.open(BASE / 'publication-before.tar.gz', 'x:gz') as archive:
    for name in claims + targets + [str(BASE / 'publish.py')]:
        archive.add(name, arcname=name, recursive=False)
    for name in claims:
        record = json.loads(Path(name).read_bytes())
        for item in record['claims']:
            durability = item['durability']
            if durability['status'] == 'checked':
                for source in durability['inputs']:
                    if source['path'] in targets:
                        assert durability['mode'] == 'historical', 'preserve live shared binding before editing:' + name
                        hits.append(dict(record=name, claim=item['name'], **source, revision=durability['revision']))
(BASE / 'publication-bindings.json').write_text(json.dumps(dict(activation=ACTIVATION, historical=hits, live=[]), indent=2) + '\n')
report = json.loads(gzip.decompress((BASE / 'observation.json.gz').read_bytes()))
result = json.loads((BASE / 'result.json').read_bytes())
for mode in ('capture', 'review'):
    assert (BASE / (mode + '-exit.txt')).read_text() == '0\n'
    assert gzip.decompress((BASE / (mode + '-stderr.log.gz')).read_bytes()) == b''
    assert json.loads(gzip.decompress((BASE / (mode + '-stdout.log.gz')).read_bytes())) == result
assert report['owner'] == OWNER and report['activation_commit'] == ACTIVATION and report['removed'] == []
rows = sum(len(row['primary']) for row in report['scopes'].values())
assert rows == result['scoped_rows'] and len(report['scopes']) == 8
summary = f'{rows} dated metadata rows agree in eight named scopes; five altered-evidence controls and separate readonly recovery pass. All artifacts, caches and proof remain retained; nothing removed.'
command = f'bash tools/run_python_project_data.sh {BASE}/review.py'

def edit(name, old, new):
    path = Path(name)
    source = path.read_text()
    assert source.count(old) == 1, 'exact anchor:' + name
    path.write_text(source.replace(old, new, 1))

Path('docs/ARTIFACT_CLEANUP.md').write_text(f'# Latest artifact cleanup\n\n- Date: {report["at_utc"]}\n- Summary: {OWNER}: {summary} Evidence: {BASE}/. Full native/OS custody remains23.4.2/SESSION5.\n')
edit(BOOK, 'A daily review can retain every candidate.', f'The November16 retention review compares {rows} dated path/suffix/byte rows in the same eight scopes with independent scandir/lstat, rejects five altered-evidence controls, and removes nothing. Source images precede helper import and scanning; the complete native/OS custody leg remains open. Its readonly recovery is `{command}`.\n\nA daily review can retain every candidate.')
for name, title, text in [
    ('CHANGES.md', 'November16 bounded artifact retention review', summary),
    ('DEVELOPMENT_NOTES.md', '2026-11-16 — retain artifacts before publication preparation',
     'Reused the accepted non-following scanner and composed a separate dated reader from retained November7 templates. Actual source bodies/modes precede helper import and scanning, and command channels and raw Git-index input survive. Historical recovery reads the observation; it does not rescan runtime state. Native/OS/transitive custody remains TYPE-REFERENCE-BOOK.1.2.23.4.2/SESSION5. The three supplied portable-policy hashes still match their recorded canonical comparison; no donor update is required.')]:
    path = Path(name)
    source = path.read_text()
    first = source.index('\n## ')
    path.write_text(source[:first] + f'\n## {title}\n\n{OWNER}: {text} Evidence and readonly command: `{BASE}/REVIEW.md`. Focused maintenance only; current canonical discovery4.1/publication30.2 remain pending.\n' + source[first:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md')
source = path.read_text()
updates = {'Current Activity': 'PNT resumed. Daily maintenance33 is complete with focused checks; current canonical discovery4.1 and early publication30.2 are next. No feature-admission or full-CI credit is implied.',
           'Latest Completed Slice': OWNER + ' — ' + summary,
           'Next Action': 'Inventory and register current canonical feature tests under4.1, including the Lua raw-error normal. Complete exact candidate canonical proof and all before-push owners, then normal publication30.2 around the1.5GB trigger.'}
for heading, body in updates.items():
    source, count = re.subn(r'(## ' + re.escape(heading) + r'\n\n).*?(?=\n## )', lambda match: match[1] + body + '\n', source, count=1, flags=re.S)
    assert count == 1
start, end = source.index('## Recent Completions\n'), source.index('\n## History')
old_rows = [line for line in source[start:end].splitlines() if line.startswith('- ')]
recent = [f'- {OWNER} — {summary}'] + old_rows[:15]
source = source[:start] + '## Recent Completions\n\n' + '\n'.join(recent) + '\n\n' + source[end:]
path.write_text(source)
Path('MEMORY.md').write_text(f'''# MEMORY

- activation_commit: `{ACTIVATION}` — clean daily33 activation; derive current HEAD from Git.
- latest_completed_leaf: `{OWNER}` — dated artifact retention review.
- active_work_unit: `{OWNER}` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.
- run_state: PNT resumed by the director on November16; continue after each clean leaf.
- next_action: Current canonical discovery TYPE-REFERENCE-BOOK.1.2.23.4.1 including the Lua raw-error normal; then publication30.2 after all before-push prerequisites. Remeasure committed outgoing bytes before growth.
- in_flight_uncommitted: none; no required background job.
- evidence: {BASE}/REVIEW.md; readonly review.py retains the dated observation and five effective corruption controls. {summary}
- publication: Current startup monitor at b3ab04a22/cached origin4683555e is1,430,901,703 bytes/109 ahead/69,098,297 trigger margin; raw pack remains ignored in .linkedspec-data/push-monitor/20261116T105751.125946Z. Preparation is due; no fresh remote/wire/future-size guarantee. This maintenance is excluded. Current independent/native gaps remain30/4.2.
- boundaries: Full admission23.4, native/input custody4.2/SESSION5, historical4.24, raw-error coverage outside selected28, declared5.4/formatter, source/context/shadowing, launcher/SESSION7/literal/excluded owners remain open.
- locality: Only this repository writable; dependencies are black boxes. Same-volume serial jobs/shared24GiB/current90-percent rising-trend policy. Latest cleanup: docs/ARTIFACT_CLEANUP.md.
''')
path = Path('docs/TASK_TREE.md')
source = path.read_text()
source = re.sub(r'^Current frontier:.*$', 'Current frontier: November16 PNT resumed; daily retention33 is focused-checked. Canonical discovery TYPE-REFERENCE-BOOK.1.2.23.4.1, then size-driven publication30.2 after all prerequisites.', source, count=1, flags=re.M)
source = re.sub(r'^Latest PNT slice:.*$', 'Latest PNT slice: TYPE-REFERENCE-BOOK.1.2.23.4.33 — dated eight-scope retention review; current discovery4.1 is next.', source, count=1, flags=re.M)
path.write_text(source)
edit('docs/tasks/TYPE-REFERENCE-BOOK.overview.md', '`TYPE-REFERENCE-BOOK.1.2.23.4.32`; remaining admission leaves split at activation.', '`TYPE-REFERENCE-BOOK.1.2.23.4.32`, `TYPE-REFERENCE-BOOK.1.2.23.4.33`; remaining admission leaves split at activation.')
edit('docs/tasks/TYPE-REFERENCE-BOOK.overview.md', f'- ID: `{OWNER}`\n  Status: `active`', f'- ID: `{OWNER}`\n  Status: `completed`')
edit('docs/tasks/TYPE-REFERENCE-BOOK.overview.md', '  Next: Capture the dated observation without deleting any artifact; return to discovery4.1 after the clean maintenance commit. Native/physical custody remains4.2/SESSION5.', f'  Outcome: {summary} Actual observation/source images/modes/index/commands/channels: {BASE}/. Reverify: {command}. Normal hooks govern landing. Native/physical custody remains4.2/SESSION5.\n  Next: Current canonical discovery4.1, then early publication30.2 after all prerequisites.')
(BASE / 'REVIEW.md').write_text(f'''# November16 retention-only artifact review

Owner: {OWNER}. Clean activation: {ACTIVATION}.
Dated observation: {report['at_utc']}.

{summary}

The primary non-following scanner and independent scandir/lstat compare every
path/suffix/byte row in the eight existing root/Rust/log scopes. The configured
Cargo target is covered. Dart/Julia caches and Lua managed runs stay retained.
This is a dated scoped observation, not a whole-project census, liveness,
disposal, content-ownership or space-reclamation claim. No dependency source or
other repository was traversed. Source bytes/modes precede helper import and
scanning; observation.json.gz retains those images and raw Git-index input.
Accepted composition templates and their hashes/modes are retained separately.
Actual capture and recovery argv/cwd/exit/full stdout/stderr are preserved.
The readonly entrypoint repeats five missing/changed/duplicate/outside/source
corruption denials against the retained observation, without a fresh scan:

```sh
{command}
```

The native Python/Git/interpreter/library/filesystem/kernel input epoch remains
an explicit durability gap under4.2/SESSION5. Retaining project source and
channels gives no original first-use credit for that larger population.
publication-before.tar.gz and publication-bindings.json preserve accepted
historical claim bindings before the shared book/live edits; old claims remain
unchanged. No runtime, shared checker, storage default, CI or hook changed.
Current discovery4.1 and exact canonical proof remain required before push.
''')
claim = dict(version=1, owner=OWNER, claims=[dict(
    name='dated-bounded-artifact-retention-review', statement=summary,
    scope='Dated eight named root/Rust/log scopes only. No whole-project inventory, content ownership, disposability, liveness, reclamation or concurrent-adversarial claim. All artifacts and reusable caches retained.',
    rederive=dict(status='checked', command=command, granularity='Every retained primary path/suffix/byte row against separately acquired scandir/lstat rows; independent process readonly recovery of the dated observation.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='checked', hypothesis='Missing, altered, duplicated or outside-path rows or corrupted retained producer bytes could pass.', oracle='Independent scandir/lstat against the primary os.walk scanner; immutable observation is the readonly recovery oracle.', red_control='Actual capture and separate recovery reject missing-row, wrong-size, duplicate-row, outside-path and producer-byte controls; both exit0 with empty stderr.'),
    durability=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Actual project source bodies/modes, composition templates, raw Git-index observation and full command channels are retained in the checkpoint before helper import/scanning. Complete native Python/Git/library/filesystem/kernel/transitive input custody is unavailable;4.2/SESSION5 owns it. Earlier template or wrapper execution gains no retroactive first-use credit.'))])
Path('docs/claims', OWNER + '.json').write_text(json.dumps(claim, indent=2) + '\n')
print('published dated retention review and clean resume pointer; previous claim records unchanged')
