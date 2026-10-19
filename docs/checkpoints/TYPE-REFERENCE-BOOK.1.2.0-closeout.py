"""One-shot continuity closeout after the accepted bounded inventory publication."""
import base64
import gzip
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[2]
prefix = root / 'docs/checkpoints/type-reference-inventory'
claim = json.loads((root / 'docs/claims/TYPE-REFERENCE-BOOK.1.2.0.json').read_bytes())
publication = json.loads((prefix / 'publication.json').read_bytes())
assert publication['result'] == 'PASS' and publication['review']['result'] == 'PASS'
assert json.loads(base64.b64decode(publication['record_base64'])) == claim
chapter = (root / 'docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md').read_text()
section = chapter.split('## Value kinds, numeric notation and callable results\n', 1)[1].split('\n## ', 1)[0]
example = re.search(r'```text\n(.*?)```', section, re.S)[1]
cases = json.loads(gzip.decompress((prefix / 'model-inputs.json.gz').read_bytes()))['cases']
executed = next(case['spec'] for case in cases if case['id'] == 'yielded-array-receiver')
assert example == executed, 'complete book source equals actually executed native/generated case'
summary = ('Authority/model .1.2.0 retains1300 owned inputs;14 descriptor/Get/generated cases include70 '
    'neutral scalar fields, and11 distinguishing cases isolate two owned P1 Perl defects. Actual private '
    'promotion has report0/strict RED/exact restoration. Current Knowledge1487/1349/10455, all897 list '
    'items/248 fields and8387566 bytes fit unchanged limits; complete89-input book and changed-heading '
    'control pass. Whole original396/full68960 replays with exact channels and bytes/modes unchanged. '
    'Only that accepted claim is frozen at real cf4dceccd; first no-write frontmatter writer failure '
    'and separate correction remain retained. No runtime, contract, gate, budget, complete operation '
    'inventory, cross-backend or private/parent admission. P1 scalar-evaluation .1.2.3 then scoped-with '
    '.1.2.4 precede complete enumeration .1.2.1.')
paths = ['CHANGES.md', 'DEVELOPMENT_NOTES.md', 'MEMORY.md', 'LIVE_ACHIEVEMENT_STATUS.md',
         'docs/TASK_TREE.md', 'docs/tasks/TYPE-REFERENCE-BOOK.md']
before = {path: dict(base64=base64.b64encode((root / path).read_bytes()).decode(),
                     mode=(root / path).stat().st_mode & 0o7777) for path in paths}

for path in ('CHANGES.md', 'DEVELOPMENT_NOTES.md'):
    target = root / path
    text = target.read_text()
    match = re.search(r'^## ', text, re.M)
    assert match
    entry = ('## 2026-10-19 — TYPE-REFERENCE-BOOK.1.2.0 — Reconcile authority population and value model\n\n'
             + summary + '\n\nReadonly proof: docs/checkpoints/type-reference-inventory/publish.py; '
             'claim: docs/claims/TYPE-REFERENCE-BOOK.1.2.0.json. Focused uniform-binding/public-selector '
             'checks pass; ordinary doctrines, bounded histories, memory and normal hooks govern landing.\n\n')
    target.write_text(text[:match.start()] + entry + text[match.start():])

target = root / 'docs/tasks/TYPE-REFERENCE-BOOK.md'
text = target.read_text().replace('Status: `active` / .1.2.0 authorities/type model; prerequisite .1.1 complete',
    'Status: `active` / .1.2.0 complete; P1 .1.2.3/.1.2.4 before enumeration', 1)
text = text.replace('- Priority: P2 documentation completeness; P3 legacy status repair',
    '- Priority: P1 discovered runtime repairs; P2 documentation completeness; P3 legacy status repair', 1)
start = text.index('- ID: `TYPE-REFERENCE-BOOK.1.2.0`\n')
end = text.index('\n- ID: ', start + 1)
node = text[start:end].replace('Status: `active`', 'Status: `done` / bounded authority/model prerequisite', 1)
node += ('\n  Diagnostic resolution and completion: ' + summary + '\n'
         '  Verification: Current readonly source/model publication, exact whole prior replay, strict/private '
         'source controls, complete Knowledge and book/heading proof, uniform-binding and composed public '
         'selector checks PASS. Normal focused doctrines/history/memory/hooks govern landing.\n')
text = text[:start] + node + text[end:]
start = text.index('## Current Frontier\n')
end = text.index('\n## Decisions', start)
frontier = '''## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `TYPE-REFERENCE-BOOK.1.2.3` | `pending` | P1 preserve evaluated scalar values across later callbacks; activate from clean .1.2.0. |
| 2 | `TYPE-REFERENCE-BOOK.1.2.4` | `pending` | P1 restore callable scoped with value after scalar boundary repair. |
| 3 | `TYPE-REFERENCE-BOOK.1.2.1` | `pending` | Enumerate complete supported operations/spellings after the owned P1 repairs. |
| 4 | `TYPE-REFERENCE-BOOK.1.2.2` | `pending` | Map every reconciled item to actual book coverage. |
| 5 | `TYPE-REFERENCE-BOOK.1.3` | `pending` | Independently review the complete inventory and bounded layout plan. |
| 6 | `TYPE-REFERENCE-BOOK.8` | `pending` | Reconcile owned legacy metadata contradictions from exact history. |
| 7 | `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.13` | `pending` | Deferred unconfirmed literal-rendering question after Type .1/.8. |
| 8 | `TYPE-REFERENCE-BOOK.2` | `pending` | Inventory-backed type-family references and independent .7 closeout follow. |
'''
text = text[:start] + frontier + text[end:]
text = text.replace('None requiring director input. .1.2.0 is active from clean cf4dceccd; no source/book/fact bound writes or new measurements yet.',
    'None requiring director input. .1.2.0 closes the bounded model; confirmed P1 .1.2.3/.1.2.4 block full operation enumeration and are scheduled next.')
text = text.replace('## Verification Log\n', '## Verification Log\n\n- `2026-10-19` — `.1.2.0`: ' + summary + '\n', 1)
text = text.replace('Inventory .1.2 remains pending clean activation.',
    'Authority/model .1.2.0 is complete; derive its accepted commit by subject. P1 .1.2.3 activates only from clean Git.')
text += '\n- `2026-10-19`: Complete authority/model prerequisite; schedule both source-isolated P1 repairs before exhaustive operation enumeration.\n'
target.write_text(text)

target = root / 'docs/TASK_TREE.md'
text = target.read_text()
text, count = re.subn(r'^Latest PNT slice: .*$', 'Latest PNT slice: ' + summary, text, count=1, flags=re.M)
assert count == 1
rows = text.splitlines()
for index, row in enumerate(rows):
    if row.startswith('| `TYPE-REFERENCE-BOOK` |'):
        rows[index] = ('| `TYPE-REFERENCE-BOOK` | `active` / P1 .1.2.3 then .1.2.4 | `.spec documentation / per-type reference` | '
            '.1.1 migration and .1.2.0 authority/model complete. Two confirmed Perl defects have exact native/generated '
            'controls and P1 repair owners: evaluated scalar boundaries .1.2.3 then scoped with callable .1.2.4. '
            'Both precede full enumeration .1.2.1, book mapping .1.2.2, independent .1.3 and legacy .8. '
            'No exhaustive coverage or runtime repair admission. | [docs/tasks/TYPE-REFERENCE-BOOK.md](docs/tasks/TYPE-REFERENCE-BOOK.md) |')
        break
else:
    raise AssertionError('task index row absent')
target.write_text('\n'.join(rows) + '\n')

target = root / 'LIVE_ACHIEVEMENT_STATUS.md'
text = target.read_text()
for heading, value in (
    ('Current Activity', 'TYPE-REFERENCE-BOOK.1.2.0 is complete; activate P1 scalar-evaluation repair .1.2.3 from clean Git.'),
    ('Latest Completed Slice', summary),
    ('Next Action', 'From clean Git activate TYPE-REFERENCE-BOOK.1.2.3 with canonical tier. Preserve the whole current '
        'inventory claim/inputs and actual readonly baseline before bound runtime/book/fact changes. Retain original '
        'model failures; correct scalar value timing with independent RED/GREEN, then repair scoped with .1.2.4 '
        'before full operation enumeration. Continue full PNT without a dirty pivot or push.')):
    pattern = r'(^## ' + heading + r'\n\n).*?(?=\n## )'
    text, count = re.subn(pattern, lambda match: match[1] + value + '\n', text, count=1, flags=re.M | re.S)
    assert count == 1
start = text.index('## Recent Completions\n')
end = text.index('\n## History', start)
old = [line for line in text[start:end].splitlines() if line.startswith('- ')]
row = '- `TYPE-REFERENCE-BOOK.1.2.0` — source1300/native14+11/scalar70; private report0/strict RED; graph8387566/book89; whole396/68960 replay; P1 evaluation3/scoped-with4 next.'
text = text[:start] + '## Recent Completions\n\n' + '\n'.join([row] + old[:15]) + '\n' + text[end:]
target.write_text(text)

(root / 'MEMORY.md').write_text('''# MEMORY

- activation_commit: `cf4dceccd24bc6642fc9c7d8d10b329e136849b6` — clean TYPE-REFERENCE-BOOK.1.2.0 activation; derive latest identity from Git.
- latest_completed_leaf: `TYPE-REFERENCE-BOOK.1.2.0` — planned subject `TYPE-REFERENCE-BOOK.1.2.0 - reconcile authority population and value model`.
- active_work_unit: `none` — completed authority/model boundary; activate P1 .1.2.3 from clean Git.
- task_owner: `docs/tasks/TYPE-REFERENCE-BOOK.md`; full operation enumeration/book mapping remain .1.2.1/.1.2.2.
- next_action: Activate P1 TYPE-REFERENCE-BOOK.1.2.3 with canonical tier; preserve the whole current inventory publication/inputs and actual readonly baseline before bound runtime/book/fact writes, then correct early scalar evaluation with independent RED/GREEN.
- in_flight_uncommitted: none.
- blockers: no director input required. Confirmed P1 scalar lvalue timing and scoped-with callable projection repairs precede complete inventory; no runtime fix has landed yet.
- evidence: Source1300; native descriptor/Get/generated14 plus11 distinguishing controls; neutral scalar70; actual private promotion report0/strict RED/restoration; full Knowledge1487/1349/10455/897/248, 8387566 bytes and book89/heading control. Exact original396/full68960 replay passes with all supplied bytes/modes unchanged.
- current_proof: docs/claims/TYPE-REFERENCE-BOOK.1.2.0.json; readonly docs/checkpoints/type-reference-inventory/publish.py. One-shot captures/closeout are not resume entrypoints.
- custody: Migration396/full68960 is historical at actual cf4dceccd; original208, draft355 and all earlier epochs remain immutable. Preserve the entire current claim and every input before its next freeze. Other live warning6/capacity14 guards remain unchanged.
- canonical_environment: Canonical CI starts with approved host execution; nested sandbox controls are71 inside/0 host. Never weaken or skip the profile. Runtime P1 repairs require canonical staged receipts.
- cleanup: Latest scoped2026-10-19T12:12:28.273239+00:00; full REPO-HYGIENE.19. No artifact disposal or purge authority is inferred.
- deferred: Toolbox2.2 capture recipes remain CONFORMANCE-SOURCE-READING.2.11-owned. Metadata .3.2.1.13 is unconfirmed and follows Type .1/.8. Original output/composition/mapping/quoted-first/private-parent admissions remain open.
- standing_limit: Other repositories/submodules are read-only black boxes; no dependency internals/build reconstruction/pin changes. Startup.7 lifecycle/kernel gaps remain open.
- sequence: P1 .1.2.3 -> .1.2.4 -> .1.2.1 -> .1.2.2 -> .1.3 -> .8 -> metadata QA -> type references. Full PNT continues; no push yet.
''')

artifact = root / 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.0-continuity.json'
assert not artifact.exists()
artifact.write_text(json.dumps(dict(producer_base64=base64.b64encode(Path(__file__).read_bytes()).decode(),
    before=before, summary=summary, exact_executed_book_example=example,
    focused_logs={name: base64.b64encode((root / '.linkedspec-data/verification' / name).read_bytes()).decode()
        for name in ('type-inventory-uniform.log', 'type-inventory-public.log')}), indent=1) + '\n')
print('Bounded source/model continuity closeout written; normal commit workflow remains required')
