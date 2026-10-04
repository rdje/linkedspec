"""Route reviewed regex provenance acceptance to its bounded continuity owners."""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0'
NEXT = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
report = json.loads((ROOT / (PREFIX + 'verification.json')).read_bytes())
assert report['owner'] == OWNER and report['sources'] == 9
assert report['before_after_pairs'] == 27 and report['private_origins'] == 81
assert report['failed_groups'] == 9 and report['green_groups'] == 10
assert len(report['rejected_evidence_controls']) == 12
subject = OWNER + ' - retain basic regex match provenance'
summary = (f"Nine basic regex contracts retain exact private full-input spans.27 source/seed before-after compiler pairs "
           f"preserve public events/arguments/substitution/diagnostics/dumps/emission;81 origins match independent scalar positions. "
           f"The same ten-group fixture fails nine before, passes ten after and retains its empty-result guard. "
           f"Thirteen unchanged suites pass{report['consumer_tests']} top-level tests, including complete Phase0. "
           f"Twelve evidence corruptions reject; two examples render with explicitly documented Markdown newline normalization. "
           f"Quoted syntactic matches remain recorded; statement/recursive framing, membership/replacement and canonical recurrence remain open.")


def update(path, transform):
    file = ROOT / path
    original = file.read_text()
    changed = transform(original)
    assert changed != original, path
    file.write_text(changed)


def replace_node(text):
    begin = text.index('- ID: `' + OWNER + '`')
    end = text.index('- ID: `' + NEXT + '`', begin)
    node = text[begin:end].replace('  Status: `in_progress`', '  Status: `done`', 1)
    node += ('  Verification: ' + summary + ' Executed captures retain capture-initial.py byte identity; current capture.py corrects only its inherited header wording. Prior three-contract claim is frozen at80ecf47f2 without manifest changes. Focused doctrine/claim/Knowledge/history/diff and hooks govern landing.\n'
             '  Commit: `' + subject + '`\n\n'
             '## Acceptance Checklist — ' + OWNER + '\n\n'
             '- [x] **REPRODUCE / ISSUE** — Public Scanner and call_spec_handler_subst/LinkedSpec::Get probes retain exact source/raw inputs; complete frozen-owner ten-group TAP fails nine missing-origin groups, empty-result guard green.\n'
             '- [x] **ROOT CAUSE (WHY + WHERE)** — PrimitiveBasicRules emits original events without producer positions; equal quoted/real raw text cannot identify the original regex occurrence. The private source hook already exists; nine direct full-input contracts need pre-record match coordinates.\n'
             '- [x] **FIX** — One producer imports the Core hook and captures original regex start/end before recording. Existing regexes, event objects/arguments, five callback dependencies and all statement scans remain unchanged.\n'
             '- [x] **ADDRESSED (verified)** — Complete unchanged fixture goes from nine failing groups to ten passing groups; actual failed-name difference is precisely the nine producer cases.81 origins in27 pairs satisfy independent Unicode scalar/source/object oracles.\n'
             '- [x] **NO REGRESSION** — All27 public compiler identities match; thirteen unchanged suites reach their complete GREEN TAP plans, including full Phase0; syntax and twelve evidence corruption controls pass.\n'
             '- [x] **LOCKSTEP** — Exact-source book examples/render, Knowledge, prior historical claim, task/index/roadmap/resume/live/change/notes and bounded-history/claim/doctrine gates accompany this private-only slice. Statement framing .1.1.1 follows after clean commit.\n\n')
    text = text[:begin] + node + text[end:]
    old = '| 43.4.2.0.1.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1` | `pending` | Complete PrimitiveBasicRules source provenance before membership. |'
    new = ('| 43.4.2.0.1.1.0 | `' + OWNER + '` | `done` | Nine regex contracts;27 public identities/81 spans, complete RED/GREEN and unchanged consumers. |\n'
           '| 43.4.2.0.1.1.1 | `' + NEXT + '` | `pending` | Exact basic statement-frame production before family composition. |\n'
           '| 43.4.2.0.1.1.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.2` | `pending` | Independent twenty-contract basic family composition. |')
    assert old in text
    text = text.replace(old, new, 1)
    text = text.replace('## Verification Log\n', '## Verification Log\n\n- `2026-10-04` — `' + OWNER + '` — ' + summary + '\n', 1)
    text = text.replace('## Commit Log\n', '## Commit Log\n\n- `' + subject + '` — private nine-contract instrumentation; Git owns commit identity.\n', 1)
    return text


update('docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md', replace_node)
update('MEMORY.md', lambda text: re.sub(r'^- latest_completed_leaf:.*$', '- latest_completed_leaf: `' + subject + '`.',
    re.sub(r'^- active_work_unit:.*$', '- active_work_unit: `' + NEXT + '` (pending) — basic statement source frames.',
    re.sub(r'^- next_action:.*$', '- next_action: Activate basic statement framing .1.1.1 from the clean regex commit; freeze this live claim and use exact public split/scanner probes before selecting a frame representation.',
    re.sub(r'^- in_flight_uncommitted:.*$', '- in_flight_uncommitted: none; basic regex hooks, complete proof and documentation are committed; no background job remains.', text, flags=re.M), flags=re.M), flags=re.M), flags=re.M))

for path, title, body in (
    ('CHANGES.md', 'retain basic regex match provenance', summary),
    ('DEVELOPMENT_NOTES.md', 'producer match coordinates preserve occurrence identity',
     'PrimitiveBasicRules captures original regex coordinates before the private hook validates raw slices. Six producer sites cover nine contracts without changing regexes, objects, arguments or public fields. Direct match coordinates distinguish quoted syntactic twins and later repeated real matches; lexical membership remains separate. Eleven statement contracts still consume trimmed splitter output, so exact producer-side frames require a distinct leaf; do not recover them by raw-key matching. The complete before/current public compiler records remain identical. Historical first-channel proof keeps its original artifact identities at80ecf47f2.')):
    record = '## 2026-10-04 — ' + OWNER + ': ' + title + '\n\n' + body + '\n'
    update(path, lambda text, record=record: text.replace('\n## ', '\n' + record + '\n## ', 1))

def live(text):
    text = re.sub(r'(## Current Activity\n\n).*?(?=\n## Latest Completed Slice)',
                  r'\1Full PNT: basic regex provenance is complete; exact statement frames and remaining producer families precede membership/replacement and canonical composition.\n', text, flags=re.S)
    text = re.sub(r'(## Latest Completed Slice\n\n).*?(?=\n## Next Action)',
                  lambda match: match[1] + '`' + OWNER + '` — ' + summary + '\n', text, flags=re.S)
    text = re.sub(r'(## Next Action\n\n).*?(?=\n## Recent Completions)',
                  lambda match: match[1] + 'Activate basic statement frames `' + NEXT + '` after clean regex landing. Freeze current proof; public split/scanner tools select exact framing before implementation. Family composition, remaining pipeline/flow/legacy/staged producers, membership/replacement, recurring canonical acceptance and marker/comments remain owned. No recovery/purge.\n', text, flags=re.S)
    start = text.index('## Recent Completions\n')
    end = text.index('## History\n', start)
    rows = re.findall(r'^- `.*$', text[start:end], re.M)
    rows.insert(0, '- `2026-10-04` — `' + OWNER + '` retains private positions for nine basic regex contracts; public compiler output unchanged.')
    return text[:start] + '## Recent Completions\n\n' + '\n\n'.join(rows[:16]) + '\n\n' + text[end:]


update('LIVE_ACHIEVEMENT_STATUS.md', live)
update('ROADMAP.md', lambda text: re.sub(r'^October 4 private source provenance:.*$', 'October4 basic regex provenance: ' + OWNER + ' — ' + summary, text, count=1, flags=re.M))
for path in ('docs/TASK_TREE.md', 'ROADMAP.md', 'ROADMAP_V2.md'):
    file = ROOT / path
    rows = file.read_text().splitlines(keepends=True)
    for index, row in enumerate(rows):
        if row.startswith('| `SPEC-LANGUAGE-SELF-CONTAINMENT` |') or row.startswith('| Expressive `.spec` self-containment |'):
            cells = row.rstrip('\n').split(' | ')
            cells[1] = '`active: basic statement provenance next`'
            cells[3] = 'Nine basic regex contracts retain private spans with27 public identities/81 origins and complete RED/GREEN. Exact statement framing .1.1.1 and family composition precede remaining producers, membership/replacement and canonical recurrence. Marker/comments and separate trace repairs stay owned.'
            rows[index] = ' | '.join(cells) + '\n'
    file.write_text(''.join(rows))
print('Published reviewed acceptance and clean next-leaf continuity; stage/gates/commit still required')
