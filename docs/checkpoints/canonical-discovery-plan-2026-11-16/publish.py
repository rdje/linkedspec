"""Publish a bounded plan; no runner, fixture, auditor or runtime is changed."""
import gzip
import json
from pathlib import Path
import re
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent
HEAD = '53cb0297c4879cb1c1cad892ccb678c3de3302b2'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.0'
PARENT = 'TYPE-REFERENCE-BOOK.1.2.23.4.1'
PART = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
BOOK = Path('docs/linkedspec-book/src/development/documentation-workflow.md')
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == HEAD
assert not (BASE / 'before.tar.gz').exists(), 'one-shot publication'
targets = [str(PART), str(BOOK), 'MEMORY.md', 'LIVE_ACHIEVEMENT_STATUS.md',
           'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'docs/TASK_TREE.md',
           'docs/tasks/TYPE-REFERENCE-BOOK.md', 'ROADMAP.md', 'ROADMAP_V2.md']
claims = subprocess.check_output(['git', 'ls-files', 'docs/claims'], text=True).splitlines()
bindings = []
with tarfile.open(BASE / 'before.tar.gz', 'x:gz') as archive:
    for name in targets + claims + [str(Path(__file__))]:
        archive.add(name, arcname=name, recursive=False)
    for name in claims:
        body = Path(name).read_bytes()
        assert body == subprocess.check_output(['git', 'show', HEAD + ':' + name])
        for claim in json.loads(body)['claims']:
            durability = claim['durability']
            if durability['status'] == 'checked':
                for item in durability['inputs']:
                    if item['path'] in targets:
                        assert durability['mode'] == 'historical', 'live shared binding:' + name
                        bindings.append(dict(record=name, claim=claim['name'], revision=durability['revision'], **item))
(BASE / 'bindings.json').write_text(json.dumps(bindings, indent=2) + '\n')

def node(source, identity):
    match = re.search(r'^- ID: `' + re.escape(identity) + r'`\n.*?(?=^- ID:|\Z)', source, re.M | re.S)
    assert match, identity
    return match[0]

old = subprocess.check_output(['git', 'show', HEAD + ':' + str(PART)]).decode()
old_parent = node(old, PARENT)
source = PART.read_text()
new_parent = old_parent.replace('  Status: `pending` / P1 canonical admission prerequisite\n', '  Status: `active` / P1 canonical admission prerequisite; bounded children below\n  Children: `TYPE-REFERENCE-BOOK.1.2.23.4.1.0`, `TYPE-REFERENCE-BOOK.1.2.23.4.1.1`, `TYPE-REFERENCE-BOOK.1.2.23.4.1.2`.\n', 1)
assert new_parent != old_parent and source.count(old_parent) == 1
source = source.replace(old_parent, new_parent, 1)
assert node(source, PARENT).split('  Goal:', 1)[1] == old_parent.split('  Goal:', 1)[1]
children = '''- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.1.1`
  Status: `pending`
  Goal: Freeze the current feature-test population and its direct producer/fixture graph against actual canonical and backend discovery routes.
  Dependencies: Completed4.1.0; every existing parent4.1 addition remains binding.
  Acceptance: Inventory the named parent obligations plus later maintained feature consumers/helpers and actual artifact loaders. Distinguish literal registration, backend automatic discovery, conditional optional-gate selection and actual execution. Classify omissions and exclusions explicitly, preserve exact activation source/commands/channels, use distinguishing missing/duplicate/disabled selection controls, and freeze the complete registration input for4.1.2. No SDK result, canonical inclusion, complete native custody or declared5.4 execution is inferred from source inventory. Keep source-shadowing/full4.2/SESSION5 owners separate.
  Planned verification tier: focused; only checkpoint data/instruments and documentation change here.
  Planned focused checks: Source-bound inventory and actual selector extraction through public interfaces, independent population/loader checks, effective omission controls, source custody and current-input identity; normal documentation/commit checks.
  Planned claim verification: Declare the measured inventory granularity and actual three legs at activation, with native/physical or unavailable discovery legs disclosed under their existing owners.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.1.2`
  Status: `pending`
  Goal: Admit exactly the frozen current feature regressions through canonical CI while preserving all historical CI and source observations.
  Dependencies: Completed4.1.1; published exact historical inverse/current-image contracts; current shared-host headroom and fully staged candidate.
  Acceptance: Repair every proven omission exactly once, including the new standalone Lua raw-error normal; preserve automatic backend discovery rather than adding duplicate execution. Retain presence/syntax/execution selection and direct artifact-input coverage. Add an exact owner-bound CI inverse and source-image admission before historical recovery consumes the new runner/auditor bytes; unchanged historical hashes, original controls and unrelated-source refusals remain required. Run focused actual selector RED/GREEN and historical inverse/source corruptions, then the complete exact staged canonical gate with the required backend flags. Record the actual receipt and selected routes. Do not claim absent declared5.4, formatter, source/context/full23.4 or native-custody closure. Complete parent4.1 only after its entire frozen inventory has verified selection. Publication30.2 still requires every separate before-push owner.
  Planned verification tier: canonical.
  Planned focused checks: Actual ordered selection and missing/duplicate/disabled substitutions; historical inverse and complete source-image reconciliation with effective corruption denials; exact staged canonical receipt, normal hooks and clean post-commit pointer.
  Planned claim verification: Declare actual selected populations/routes and retain or explicitly disclose every producer/artifact-input leg; no source-only inventory is runtime execution credit.

'''
source = source.replace(new_parent, new_parent + children, 1)
source = source.replace(f'- ID: `{OWNER}`\n  Status: `active`', f'- ID: `{OWNER}`\n  Status: `completed`', 1)
source = source.replace('  Next: Complete the bounded decomposition, then inventory4.1.1 after the clean commit.', '  Outcome: Inventory4.1.1 and canonical registration4.1.2 are ordered; the complete parent obligation body is preserved. Shared runner/auditor/runtime/fixture bytes are unchanged.\n  Next: Inventory4.1.1 after the clean plan commit; registration4.1.2 requires exact current-source admission and canonical proof.')
PART.write_text(source)
for name in ('docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md'):
    path = Path(name)
    text = path.read_text()
    if name == 'docs/TASK_TREE.md':
        text = re.sub(r'^Current frontier:.*$', 'Current frontier: Canonical discovery plan4.1.0 is complete. Inventory TYPE-REFERENCE-BOOK.1.2.23.4.1.1 precedes exact registration4.1.2 and publication30.2; all independent before-push owners remain.', text, count=1, flags=re.M)
        text = re.sub(r'^Latest PNT slice:.*$', 'Latest PNT slice: TYPE-REFERENCE-BOOK.1.2.23.4.1.0 — bounded canonical-discovery decomposition; no runner/runtime/fixture change or admission claim.', text, count=1, flags=re.M)
    else:
        marker = '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.4.1` | `pending` | Director-requested stop after raw28; on resume remeasure, register current normals and prepare exact canonical early publication. |'
        assert text.count(marker) == 1
        text = text.replace(marker, '| 1 | `TYPE-REFERENCE-BOOK.1.2.23.4.1.1` | `pending` | Freeze the current feature/discovery/input inventory before exact registration4.1.2 and early publication; separate before-push owners remain. |', 1)
    path.write_text(text)
book = BOOK.read_text()
anchor = 'Keep future tests task-owned and explicitly registered.'
assert book.count(anchor) == 1
book = book.replace(anchor, 'Accumulated feature regressions enter canonical CI in two steps: first freeze the current consumer/helper/fixture inventory and distinguish direct, automatic and optional backend selection; then repair the proven omissions with an exact historical CI inverse and current-source admission. Source inventory supplies no runtime or canonical-execution credit. The registration slice requires an exact staged receipt and actual required backend routes; declared-host and native-custody gaps retain their separate owners.\n\n' + anchor, 1)
BOOK.write_text(book)
for name, heading, body in [
    ('CHANGES.md', '2026-11-16 — bound canonical discovery before registration', 'Split accumulated discovery into inventory4.1.1 and exact canonical registration4.1.2. Preserve all prior parent obligations; no runtime, test, runner or auditor changes.'),
    ('DEVELOPMENT_NOTES.md', '2026-11-16 — separate discovery inventory from canonical source admission', 'A runner edit must preserve both current selected execution and the exact historical CI inverse/current-image contracts. The inventory step freezes consumers/helpers/actual artifact loaders, distinguishing literal, automatic and conditional backend discovery. The canonical step admits only that frozen population and retains the earlier source/observation epochs. Deferred native/declared-host/full-admission work remains separately owned.')]:
    path = Path(name)
    text = path.read_text()
    offset = text.index('\n## ')
    path.write_text(text[:offset] + f'\n## {heading}\n\n{OWNER}: {body} Planning-only focused slice; no measured population or runtime/admission result.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md')
text = path.read_text()
for title, body in {'Current Activity': 'PNT: inventory4.1.1 follows completed canonical-discovery decomposition4.1.0. Exact registration4.1.2 and separate before-push owners precede publication30.2.', 'Latest Completed Slice': OWNER + ' — bounded inventory/registration plan with every existing parent obligation preserved; no shared runner, auditor, runtime or fixture change.', 'Next Action': 'Freeze the current feature-test/helper/artifact-input inventory under4.1.1, then exact registration/source admission/full canonical4.1.2. Preserve all independent before-push owners.'}.items():
    text, count = re.subn(r'(## ' + title + r'\n\n).*?(?=\n## )', lambda match: match[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
text = text[:start] + '## Recent Completions\n\n- ' + OWNER + ' — bounded discovery inventory and canonical registration plan; original obligations preserved, no runner/runtime/fixture change.\n' + '\n'.join(recent[:15]) + '\n\n' + text[end:]
path.write_text(text)
Path('MEMORY.md').write_text(f'''# MEMORY

- activation_commit: `{HEAD}` — clean discovery-plan4.1.0 activation; derive current HEAD from Git.
- latest_completed_leaf: `{OWNER}` — bounded canonical-discovery plan.
- active_work_unit: `{OWNER}` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.
- run_state: PNT resumed; continue after each clean leaf.
- next_action: Inventory TYPE-REFERENCE-BOOK.1.2.23.4.1.1: freeze consumers/helpers/actual artifact loaders and distinguish literal, automatic and optional discovery. Then exact registration/source admission/canonical4.1.2 and publication30.2 after every independent before-push owner.
- in_flight_uncommitted: none; no required background job.
- evidence: docs/checkpoints/canonical-discovery-plan-2026-11-16/; complete original parent obligations retained. No new runtime, canonical or measured test-population claim; runners, auditor, fixtures and runtimes unchanged.
- publication: Preparation remains the active priority under the existing director1.5GB trigger. Current monitor artifacts are .linkedspec-data/push-monitor/20261116T114304.519595Z; raw pack stays ignored/protected. Remeasure committed HEAD before further growth; current-independent/native gaps remain30/4.2, with no remote/wire/future-size promise.
- boundaries: Full admission23.4, direct/native custody4.2/SESSION5, historical4.24, raw-error scope outside selected28, declared5.4/formatter, source/context/shadowing and launcher/SESSION7/literal/excluded owners stay open. No recover/purge while denied liveness remains unresolved.
- locality: Only this repository writable; dependencies are black boxes. Same-volume serial jobs/shared24GiB/current90-percent rising-trend policy. Latest cleanup: docs/ARTIFACT_CLEANUP.md.
''')
(BASE / 'REVIEW.md').write_text('''# Canonical discovery decomposition

Owner: TYPE-REFERENCE-BOOK.1.2.23.4.1.0.
The parent retains its entire prior obligation body. Inventory4.1.1 freezes the
consumer/helper/actual artifact-input population and classifies actual discovery
routes; registration4.1.2 repairs only proven omissions and preserves exact
historical CI/source observations before an exact staged canonical run.
No runtime, fixture, runner, auditor or shared tool changes here. No measured
population, runtime execution or canonical inclusion is claimed. All independent
native/source/context/declared-host/full-admission and before-push owners remain.
before.tar.gz retains the pre-publication documents and accepted claim records;
bindings.json records the historical shared bindings without changing them.
The one-shot publisher must not be replayed. Resume from the committed task leaf.
''')
print('bounded discovery plan published; original parent obligations preserved')
