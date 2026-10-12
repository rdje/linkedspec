"""One-shot bounded continuity update after actual table-layout inspection."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-'
target = ROOT / (PREFIX + 'continuity.json')
assert not target.exists(), 'one-shot current projection update'
tree = (ROOT / 'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md').read_text()
result = next(line[len('  Result: '):] for line in tree.splitlines() if line.startswith('  Result: Required FlowExpr .4.0 isolates'))
changed = []
for name in ['ROADMAP.md', 'ROADMAP_V2.md']:
    path = ROOT / name
    lines = path.read_text().splitlines()
    for index, line in enumerate(lines):
        if line.startswith('October12 current callback activity:'):
            lines[index] = 'October12 current callback activity: ' + result
        elif line.startswith('| Expressive `.spec` self-containment |'):
            fields = line.split('|')
            assert len(fields) == 6 and not fields[0] and not fields[-1]
            fields[-2] = (' Original-event input/construction composition is independently accepted under '
                'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.3. '
                'Factory/dependency implementation has bounded owners in docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md. '
                + result + ' Detailed earlier factory evidence and accepted Git boundaries remain in that tree. '
                'Full private Phase0 .2.5, mapped replacement .1.1.2 and independent canonical .0.3.2 remain open. ')
            lines[index] = '|'.join(fields)
    path.write_text('\n'.join(lines) + '\n')
    changed.append(name)
path = ROOT / 'docs/TASK_TREE.md'
lines = path.read_text().splitlines()
for index, line in enumerate(lines):
    if line.startswith('Latest callback verification:'):
        lines[index] = 'Latest callback verification: ' + result
    elif line.startswith('| `PERL-PRIVATE-FACTORY-CAPTURE` |'):
        fields = line.split('|')
        assert len(fields) == 7
        fields[2] = ' `active` / optional FlowExpr kind .4.2 next '
        fields[4] = ' ' + result + ' '
        lines[index] = '|'.join(fields)
    elif line.startswith('| `SPEC-LANGUAGE-SELF-CONTAINMENT` |'):
        fields = line.split('|')
        assert len(fields) == 7
        prefix = fields[4].split('The 17 original MethodLowering sites have bounded repairs.')[0]
        fields[4] = (prefix + result + ' Detailed earlier factory evidence and accepted Git boundaries remain in '
            'docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md. Full private Phase0 .2.5, mapped replacement .1.1.2 '
            'and independent canonical .0.3.2 remain open. ')
        lines[index] = '|'.join(fields)
path.write_text('\n'.join(lines) + '\n')
changed.append('docs/TASK_TREE.md')
for name, title in [('CHANGES.md', 'PERL-PRIVATE-FACTORY-CAPTURE.4.0 — Isolate required FlowExpr callbacks'),
                    ('DEVELOPMENT_NOTES.md', 'Required FlowExpr bindings preserve original diagnostic lines')]:
    path = ROOT / name
    text = path.read_text()
    start = text.index('\n## ')
    entry = '\n## 2026-10-12 — ' + title + '\n\n' + result + '\n'
    if name == 'DEVELOPMENT_NOTES.md':
        entry += ('\nThe resolver selects and validates one actual CODE before constructing its private lexical thunk. '
            'Appending the helper preserves every original global function/diagnostic line. Scalar arguments stay '
            'helper-local; parser argument arrays stay shared. Use the actual callback with _invoke_emission_dependency; '
            'wrapping it in a new opaque CODE loses its registration. The private channel remains lazy. The optional '
            'kind seam has two map reads and needs separate native-first preservation, including tied-map results. '
            'The first inline projection writer stopped on its own table field-count assertion; the corrected writer '
            'uses actual pipe-delimited cells. No runtime or observation changed in that correction. Owner '
            'PERL-PRIVATE-FACTORY-CAPTURE.4.0; readonly proof: '
            'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-publish-claim.py.\n')
    path.write_text(text[:start] + entry + text[start:])
    changed.append(name)
path = ROOT / 'LIVE_ACHIEVEMENT_STATUS.md'
text = path.read_text()
sections = [
 ('Current Activity', 'Full PNT: required FlowExpr .4.0 verified; focused normal landing from clean81b356ce, then optional two-read kind .4.2. No push.'),
 ('Latest Completed Slice', '`PERL-PRIVATE-FACTORY-CAPTURE.4.0` — ' + result),
 ('Next Action', 'After normal commit/brief0/post-pointer/post-memory and clean Git, activate PERL-PRIVATE-FACTORY-CAPTURE.4.2. Preserve intersecting accepted proof before bound writes; capture native optional two-read kind selection/callable forms/aliases/diagnostics before expectations or production edits. Then .4.1 defaults, .5, .7, .6, metadata .12 and TYPE-REFERENCE-BOOK. No parent admission is inferred.'),
]
for header, value in sections:
    start = text.index('## ' + header + '\n') + len('## ' + header + '\n')
    end = text.index('\n## ', start)
    text = text[:start] + '\n' + value + '\n' + text[end:]
start = text.index('## Recent Completions\n') + len('## Recent Completions\n')
end = text.index('\n## History', start)
rows = [line for line in text[start:end].splitlines() if line.startswith('- ')]
rows.insert(0, '- `PERL-PRIVATE-FACTORY-CAPTURE.4.0` — native100/387/235 exact recurrences; paired1795/490 RED/1305 controls;13 faults;77/256/19470/evidence5;Knowledge1485/1349/7;book89/4;standard1035;original218/58582; optional kind .4.2 next.')
text = text[:start] + '\n' + '\n'.join(rows[:16]) + '\n' + text[end:]
path.write_text(text)
changed.append('LIVE_ACHIEVEMENT_STATUS.md')
(ROOT / 'MEMORY.md').write_text('''# MEMORY

- activation_commit: `81b356cef997ea2bb65a8fb120c77506fed9241e` — clean required FlowExpr leaf activation.
- latest_completed_leaf: `PERL-PRIVATE-FACTORY-CAPTURE.4.0 - isolate required FlowExpr callbacks`.
- active_work_unit: `PERL-PRIVATE-FACTORY-CAPTURE.4.2` (pending clean activation after this commit).
- next_action: Derive HEAD; after normal commit/brief0/post-pointer/post-memory/clean Git, activate optional two-read kind .4.2. Preserve intersecting accepted proof before bound writes, then capture native selection/callable/error/alias behavior before expectations or production changes. Commit .4.2 before defaults .4.1, ControlFlow .5, fixture registration .7, pipeline .6, metadata .12 and TYPE-REFERENCE-BOOK.
- in_flight_uncommitted: Required FlowExpr .4.0 verified; normal focused landing/public guard/claim and final post-commit checks remain. All native/fault/consumer/Phase0/book/Knowledge jobs completed actual0; no background job.
- blockers: none for next bounded implementation. Complete helper/private/parent admissions remain open.
- standing_limit: SESSION-STARTUP-READING.7 open; artifact recovery/purge prohibited. October11T18:33UTC cleanup removed0; next due October12T18:33UTC. No pivot while dirty. Knowledge has no spare slot. Other repositories/submodules read-only black boxes.
- task_owner: `docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md`.
- authority: Current required-only readonly proof is docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-publish-claim.py. First100-input/387-warm/235-cold native observations and exact recurrences, paired1795/490 original RED/1305 controls/all GREEN,13 source faults and77 suites/256 inputs/19470 assertions are retained. Five artifact denials/restorations, Knowledge1485/1349/seven lineages, book89/four controls and supplemental public Phase01035 pass. Original .11/218/full58582 stays historical at81b356ce with full before-record/baseline. Native and capture writers are retired. Optional kind/defaults and independent admissions are unchanged.
''')
changed.append('MEMORY.md')
target.write_text(json.dumps({'result': 'PASS', 'producer_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    'updated': changed, 'scope': 'Bounded current projections only. The failed inline expression/channel and unavailable full-inline-source limit are retained separately. Native instruments, runtime, fixtures and measured proof artifacts are untouched.'}, indent=2) + '\n')
print('FlowExpr continuity update PASS: seven current projections; original evidence unchanged')
