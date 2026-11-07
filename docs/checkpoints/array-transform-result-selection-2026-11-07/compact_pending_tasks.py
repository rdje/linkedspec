"""Retain the failed candidate, consolidate only this selection's task text."""
import gzip
import hashlib
import json
from pathlib import Path
import re

BASE = Path(__file__).resolve().parent
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.1.38'
FAMILY = 'TYPE-REFERENCE-BOOK.1.2.23.3.78'
paths = [Path('docs/tasks/TYPE-REFERENCE-BOOK.helpers-60plus.md'),
         Path('docs/tasks/TYPE-REFERENCE-BOOK.overview.md')]
before = {str(p): p.read_bytes() for p in paths}
for path, raw in before.items():
    saved = BASE / (Path(path).name + '.before-containment.gz')
    assert not saved.exists(), 'one-shot candidate preservation'
    saved.write_bytes(gzip.compress(raw, mtime=0))

text = before[str(paths[0])].decode()
marker = '- ID: `' + FAMILY + '`\n'
prefix, family = text.split(marker)
blocks = [b for b in re.split(r'(?=^- ID: `)', marker + family, flags=re.M) if b]
assert len(blocks) == 6
common = re.search(r'^  Acceptance: (.*)$', blocks[1], re.M)[1]
route = 'public Get/descriptor/substitution/native and full emitted fresh routes'
assert route in common
common = common.replace(route, "each leaf's named public routes", 1)
verification = re.search(r'^  Planned verification: (.*)$', blocks[1], re.M)[1]
blocks[0] += '  Backend proof contract: ' + common + '\n'
blocks[0] += '  Focused execution: ' + verification + '\n\n'
for index in range(1, 6):
    node = blocks[index]
    assert node.startswith('- ID: `' + FAMILY + '.' + str(index) + '`\n')
    actual_route = (route if index == 1 else
        ('each actual PUC/LuaJIT ' if index == 5 else '') +
        'native/restored SpecFile/generated-plan/full emitted fresh routes')
    old_acceptance = re.search(r'^  Acceptance: (.*)$', node, re.M)[1]
    assert old_acceptance.replace(actual_route, "each leaf's named public routes", 1) == common
    node = re.sub(r'^  Acceptance: .*$',
        '  Acceptance: Apply parent78 Acceptance and Backend proof contract in full on ' + actual_route +
        '; independently acquire own policies before production.', node, flags=re.M)
    node = re.sub(r'^  Planned verification: .*$',
        '  Planned verification: Parent78 Focused execution, with own syntax/format or local runner include.', node, flags=re.M)
    node = re.sub(r'^  Planned canonical trigger: .*$',
        '  Planned canonical trigger: Parent78 full23.4/final clean push after feature coverage.', node, flags=re.M)
    node = re.sub(r'^  Planned claim verification: .*$',
        '  Planned claim verification: none: Finite authored controls, no population/performance measurement.', node, flags=re.M)
    blocks[index] = node
paths[0].write_text(prefix + ''.join(blocks))

text = before[str(paths[1])].decode()
marker = '- ID: `' + OWNER + '`\n'
prefix, node = text.split(marker)
assert not re.search(r'^- ID:', node, re.M), 'selection must be final current node'
# These first-intake/activation summaries duplicate the retained outcome and
# canonical REVIEW; preserve their complete original bytes above.
for label in ('Actual first intake', 'Activation', 'Immediate continuity defect',
              'Related Knowledge ambiguity', 'Tool/source mechanism'):
    node, count = re.subn(r'^  ' + re.escape(label) + r': .*\n', '', node, flags=re.M)
    assert count == 1
node = node.replace('  Continuity repairs verified:',
    '  Containment repair: First commit attempt rejected task_evidence at12586477/12582912 bytes. Stop only its still-running claim verifier after the known pressure failure; that interrupted check is not passing. Preserve complete candidate task bytes beside compact_pending_tasks.py, move five identical pending proof contracts/verification plans to parent78, retain each named route and all acceptance requirements. Shorten only this selection\'s duplicate narrative; current contracts, frozen artifacts and prior evidence stay intact. Rerun routing pressure and all ordinary hooks.\n  Continuity repairs verified:', 1)
paths[1].write_text(prefix + marker + node)

record = dict(owner=OWNER, pressure_failure=dict(surface='task_evidence', bytes=12586477, limit=12582912),
              first_commit_exit=1, claim_check='interrupted after known pressure failure; not passing',
              retained_candidates={p: dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())
                                   for p, raw in before.items()},
              saved_bytes=sum(len(raw) - Path(p).stat().st_size for p, raw in before.items()),
              scope='new pending78 duplicate fields and selection38 duplicate narrative only; no limit or infrastructure changes')
assert record['saved_bytes'] > 3565
(BASE / 'containment-record.json').write_text(json.dumps(record, indent=2) + '\n')
print('Retained failed candidate; consolidated pending requirements without weakening contracts')
