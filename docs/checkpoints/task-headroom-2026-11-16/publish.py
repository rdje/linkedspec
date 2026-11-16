"""Publish one proven data epoch; preserve all prior claim values and source epochs."""
import gzip
import hashlib
import json
from pathlib import Path
import re
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.34'
NEXT = 'TYPE-REFERENCE-BOOK.1.2.23.4.1.1.1.1.1'
ACTIVATION = 'e476d208dcee58f67ca4d0d7a950d5aa8bdcab00'
BOOK = 'docs/linkedspec-book/src/development/documentation-workflow.md'
OLD_REVIEW = 'docs/checkpoints/perl-consumer-roles-2026-11-16/REVIEW.md'
OLD_CARD = 'docs/knowledge/perl-consumer-roles-and-selection.md'
assert not (BASE / 'publication-before.tar.gz').exists(), 'publication is one-shot'
assert hashlib.sha256(Path(__file__).read_bytes()).hexdigest() == json.loads((BASE / 'before-identities.json').read_bytes())[str(BASE / 'publish.py')]['sha256']
result = json.loads((BASE / 'review-stdout.json').read_bytes())
historical = json.loads((BASE / 'historical-pressure-stdout.json').read_bytes())
assert (BASE / 'review-stderr.txt').read_bytes() == (BASE / 'historical-pressure-stderr.txt').read_bytes() == b''
assert result['result'] == historical['result'] == 'PASS' and len(result['controls']) == 10
assert result['current_target_and_manifest'] == 'PASS'
documents = [BOOK, OLD_REVIEW, OLD_CARD, 'CHANGES.md', 'DEVELOPMENT_NOTES.md', 'MEMORY.md',
             'LIVE_ACHIEVEMENT_STATUS.md', 'ROADMAP.md', 'ROADMAP_V2.md', 'docs/TASK_TREE.md',
             'docs/tasks/TYPE-REFERENCE-BOOK.md', 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md']
claims = sorted(Path('docs/claims').glob('*.json'))
bindings = []
for path in claims:
    for claim in json.loads(path.read_bytes())['claims']:
        leg = claim['durability']
        for item in leg.get('inputs', []):
            if item['path'] in documents or item['path'] == 'docs/tasks/NONCURRENT-HELPER-CODE-PURGE.md':
                assert leg['mode'] == 'historical', 'live binding requires qualified preservation before publication'
                bindings.append(dict(record=str(path), name=claim['name'], input=item, mode=leg['mode'], revision=leg['revision']))
with tarfile.open(BASE / 'publication-before.tar.gz', 'x:gz') as archive:
    for name in sorted(set(documents + [str(path) for path in claims] + [str(BASE / 'publish.py')])):
        assert not Path(name).is_absolute() and not Path(name).is_symlink()
        archive.add(name, arcname=name, recursive=False)
(BASE / 'publication-bindings.json').write_text(json.dumps(bindings, indent=2, sort_keys=True) + '\n')
summary = (f"The existing NONCURRENT-HELPER-CODE-PURGE epoch preserves {result['ids']} ordered IDs/all CORE fields, "
           f"{result['unselected']} complete unselected bodies and the complete frontier/trailing section of {result['tail_bytes']} bytes. "
           f"{result['selected']} closed narratives renew {result['saved_bytes']} current-text bytes; all {result['public_queries']} public source/node queries and ten corruption controls pass. "
           'Dated pressure reconstruction preserves the original result and four controls without comparing today\'s TYPE task. No SDK or fresh helper-admission credit.')
next_action = 'Remeasure committed outgoing size, then complete remaining native roles/direct loaders/discovery under ' + NEXT + ' before freezing registration4.1.2 input; all separate before-push owners remain.'
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')
text = path.read_text()
start = text.index('- ID: `' + OWNER + '`\n')
end = text.index('\n- ID:', start + 1)
old_node = text[start:end]
assert 'Status: `active`' in old_node
node = ('- ID: `' + OWNER + '`\n  Status: `completed`\n'
        '  Goal: Renew task-evidence headroom through an existing data epoch.\n'
        '  Acceptance: Preserve original contracts, full unselected bodies/frontier and historical proof per Evidence.\n'
        '  Verification tier: `focused`\n'
        '  Focused checks: Epoch/public queries; independent preservation/current identity and ten controls; historical pressure/four controls; book, memory, histories, diff and normal hooks.\n'
        '  Canonical trigger: Registration4.1.2/push30.2; no shared tool/limit/schema/runtime change.\n'
        '  Claim verification: `docs/claims/' + OWNER + '.json`\n'
        '  Evidence: docs/checkpoints/task-headroom-2026-11-16/REVIEW.md.\n'
        '  Outcome: Eight closed commentary pointers; original contracts and trailing bytes exact. Full original activation and normal log retained; next is qualification under ' + NEXT + '. Native/source-origin closure remains4.2/SESSION5.\n')
path.write_text(text[:start] + node + text[end:])
path = Path('docs/tasks/TYPE-REFERENCE-BOOK.md')
text = path.read_text()
text, count = re.subn(r'(?m)^\| 0 \| `TYPE-REFERENCE-BOOK\.1\.2\.23\.4\.34`.*\n', '', text)
assert count == 1
anchor = 'Renew task headroom, then finish native roles/loaders and registration4.1.2 inventory; separate push owners remain.'
assert text.count(anchor) == 1
text = text.replace(anchor, 'Finish native roles/direct loaders/discovery after headroom34; freeze registration4.1.2 input. Separate push owners remain.', 1)
path.write_text(text)
for name in ('ROADMAP.md', 'ROADMAP_V2.md'):
    path = Path(name)
    text, count = re.subn(r'(?m)^November16 current PNT frontier:.*$', 'November16 current PNT frontier: Headroom34 preserves the closed helper-purge task source through an existing data epoch; bounded Perl roles are focused-checked. Remaining native roles/direct loaders/discovery precede frozen registration4.1.2 and publication30.2 after every separate prerequisite. No fresh SDK or full admission claim.', path.read_text(), count=1)
    assert count == 1
    path.write_text(text)
path = Path('docs/TASK_TREE.md')
text = path.read_text()
text = re.sub(r'(?m)^Current frontier:.*$', 'Current frontier: Task headroom34 is focused-checked; native roles/direct loaders/discovery precede frozen registration4.1.2 and publication30.2.', text, count=1)
text = re.sub(r'(?m)^Latest PNT slice:.*$', 'Latest PNT slice: ' + OWNER + ' — existing closed-task epoch and historical pressure recovery; no SDK replay or new admission.', text, count=1)
text = re.sub(r'(?m)^(\| `TYPE-REFERENCE-BOOK` \|[^\n]*?\| `\.spec documentation / complete type and fluent reference` \| ).*?( \| \[docs/tasks/TYPE-REFERENCE-BOOK.md\].*)$',
    lambda match: match[1] + 'PNT: headroom34 is focused-checked; remaining native roles/loaders/discovery then registration4.1.2. Publication30.2 retains all prerequisites.' + match[2], text)
path.write_text(text)
for name, title, body in [('CHANGES.md', '2026-11-16 — retain closed helper-purge task narratives', summary),
    ('DEVELOPMENT_NOTES.md', '2026-11-16 — bound task growth and separate historical pressure views',
     'Preflight uses immutable source proposals rather than filename size as capacity credit. The unchanged writer and independent source/CORE/unselected/frontier oracle agree. The earlier pressure reader deliberately checks its dated current task view; its expected current-identity refusal is retained. A new historical route uses its unchanged retained pure validator and archived task bytes, preserving every old result and control without requiring later task edits to equal the old source. No old claim hash, source, result or shared tool changes.')]:
    path = Path(name)
    text = path.read_text(); offset = text.index('\n## ')
    path.write_text(text[:offset] + '\n## ' + title + '\n\n' + OWNER + ': ' + body + ' Evidence: `' + str(BASE / 'REVIEW.md') + '`. Full source-origin/native/physical closure remains4.2/SESSION5.\n' + text[offset:])
path = Path('LIVE_ACHIEVEMENT_STATUS.md')
text = path.read_text()
for title, body in {'Current Activity': 'PNT: bounded task headroom renewed; native roles/direct-loader qualification resumes before registration.', 'Latest Completed Slice': OWNER + ' — ' + summary, 'Next Action': next_action}.items():
    text, count = re.subn(r'(## ' + title + r'\n\n).*?(?=\n## )', lambda match: match[1] + body + '\n', text, count=1, flags=re.S)
    assert count == 1
start, end = text.index('## Recent Completions\n'), text.index('\n## History')
recent = [line for line in text[start:end].splitlines() if line.startswith('- ')]
path.write_text(text[:start] + '## Recent Completions\n\n- ' + OWNER + f" — helper-purge{result['ids']} IDs/eight closed/two unchanged/full{result['tail_bytes']}-byte tail/{result['saved_bytes']} renewed; eleven queries/ten controls; historical pressure/four controls.\n" + '\n'.join(recent[:15]) + '\n\n' + text[end:])
Path('MEMORY.md').write_text('''# MEMORY

- activation_commit: `''' + ACTIVATION + '''` — clean headroom34 activation; derive current HEAD from Git.
- latest_completed_leaf: `''' + OWNER + '''` — existing closed-task data epoch and historical pressure recovery.
- active_work_unit: `''' + OWNER + '''` (completed); task_owner: docs/tasks/TYPE-REFERENCE-BOOK.overview.md.
- run_state: PNT; continue after each clean leaf.
- next_action: ''' + next_action + '''
- in_flight_uncommitted: none; no required background job.
- evidence: docs/checkpoints/task-headroom-2026-11-16/REVIEW.md; readonly review.py/historical_pressure.py. Whole source/every ID, exact original CORE/open bodies/frontier, ten effective controls; old pressure result/four controls unchanged. No SDK execution or new helper semantics.
- findings: Default literal suite3.6.1.2 lacks bounded direct/named-callable selection; pipeline has selected callable include. Two repeated ActionIR direct routes remain for4.1.2 reconciliation. Perl role0 and Dart loader0 remain dated/static.
- limits: Remaining native roles/direct loaders/discovery stay''' + NEXT + '''; no full population or canonical admission claim. Complete native/per-read/source-origin/physical closure remains4.2/SESSION5; prior declared5.4/formatter/context/shadowing/launcher/literal/excluded owners stay open.
- publication: Director1.5GB trigger governs. Activation e476/cached4683555e estimate1,463,675,787 bytes/114 ahead/36,324,213-byte margin is dated and excludes this slice; telemetry metadata retained here with independent-file falsification30/native4.2 gaps. Remeasure after landing;30.2 requires all prerequisites and exact canonical proof.
- locality: Only this repository writable; submodules black boxes. Same-volume serial jobs/shared24GB/director90-percent rising-trend policy. Daily cleanup remains current; nothing deleted. Use normal hooks as the single mandatory global integrity boundary, without duplicate standalone scans.
''')
path = Path(BOOK)
text = path.read_text(); marker = '\nArchive member names must be derived relative to the repository'
assert text.count(marker) == 1
paragraph = ('\nClosed-task commentary can use the existing explicit epoch interface while every current contract, unselected body and complete frontier stays in place. The helper-purge epoch retains its original source and every stable-ID query; it changes no helper behavior or old delivery date. Historical pressure recovery similarly reads the archived task view, while the original strict current-view reader remains dated. Neither form supplies fresh SDK or canonical-admission credit. For the complete helper-purge source, run `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree NONCURRENT-HELPER-CODE-PURGE --epoch TYPE-REFERENCE-BOOK.1.2.23.4.34 --all`.\n')
path.write_text(text.replace(marker, paragraph + marker, 1))
path = Path(OLD_REVIEW)
text = path.read_text()
text += ('\n## Historical recovery after later task edits\n\nThe original `review_pressure.py` is a dated strict current-task check and requires its accepted e476 task view. Headroom34 retains its expected current-identity refusal after later task activation, without changing that source, result or claim. For historical byte/contract recovery use `bash tools/run_python_project_data.sh docs/checkpoints/task-headroom-2026-11-16/historical_pressure.py`. This reads the archived task bytes/mode through the unchanged retained pure validator and preserves all four original controls; it makes no current task-identity claim.\n')
path.write_text(text)
path = Path(OLD_CARD)
text = path.read_text()
text += ('\nHeadroom34 qualifies historical pressure recovery after later task edits. The original strict reader and its dated current-identity refusal remain exact; `docs/checkpoints/task-headroom-2026-11-16/historical_pressure.py` reads archived task bytes/mode through the retained pure validator and preserves the original result/four controls. It asserts no current TYPE task identity.\n')
path.write_text(text)
# Claim publication is derived from the actual retained results, with missing
# native and operational falsification legs explicitly left with their owners.
common_gap = dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.2', reason='Actual project source/data/producer images, full modes, native command channels and immutable Git ancestor are retained. Complete native Python/Git/library/OS, outer-launcher first-use, source-origin and physical closure remains4.2/SESSION5; no retroactive full custody claim.')
claims = [dict(name='closed-helper-purge-task-epoch', statement=summary, scope=result['limits'],
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + str(BASE / 'review.py') + ' --current', granularity='Every ordered ID/CORE field, selected pointer and full unselected body/prefix/frontier; actual public whole-source/every-ID outputs and point-in-time target/manifest modes.', result=json.dumps(result, sort_keys=True)),
    falsify=dict(status='checked', hypothesis='Altered prefix/tail/status/goal, omitted node, changed unselected body/pointer/source/selection or mode could pass.', oracle='Immutable activation Git source and independently parsed original/current bodies, contrasted with the unchanged production epoch/reader outputs and source proposals.', red_control='All ten named corruptions reject in actual review output; exact source and every public query pass.'), durability=common_gap),
    dict(name='dated-pressure-historical-view', statement='Archived pressure reconstruction preserves the original589-byte result and four controls while the original strict reader rejects the changed current task view.', scope=historical['limits'],
        rederive=dict(status='checked', command='bash tools/run_python_project_data.sh ' + str(BASE / 'historical_pressure.py'), granularity='Complete original validator source/task bytes/modes/result/normal refusal; original four mutations in an archived view.', result=json.dumps(historical, sort_keys=True)),
        falsify=dict(status='checked', hypothesis='Historical preservation would require later current task bytes to equal the dated source, or changed archived contracts could pass.', oracle='Actual original current-identity RED versus archived-view recovery and unchanged original pure-validator controls, with immutable Git source.', red_control='Original reader exits1 with current task identity; the archived route passes and all four original controls reject.'), durability=common_gap),
    dict(name='activation-operational-pack-estimate', statement='At activation e476d208d versus cached origin4683555e, the retained primary monitor reports1,463,675,787 serialized non-thin bytes/114 commits and36,324,213 bytes below director1.5GB.', scope=result['operational_limits'],
        rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/publication-size-monitor-2026-11-12/measure.py', granularity='Actual activation refs, producer/config/policy/command metadata and primary serialized-byte result retained in telemetry; excludes this uncommitted slice.', result='Retained telemetry/result.json agrees with actual completed monitor output; raw pack remains ignored on the repository volume.'),
        falsify=dict(status='gap', repair_owner='TYPE-REFERENCE-BOOK.1.2.23.4.30', reason='This maintenance reuses the completed primary operation without an independent current actual-pack size falsification. Broader monitor qualification remains30; no copied metadata alone supplies that oracle.'), durability=common_gap)]
Path('docs/claims/' + OWNER + '.json').write_text(json.dumps(dict(version=1, owner=OWNER, claims=claims), indent=2) + '\n')
print(summary)
