"""Own the discovered stale global index through a separate protected query."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
rows = {}
for original, target in (('check_publication_inputs.py', 'check_index_inputs.py'),
        ('review_publication_inputs.py', 'review_index_inputs.py')):
    body = (BASE / original).read_text()
    assert body.count("OUT = BASE / 'publication-inputs'") == 1
    modified = body.replace("OUT = BASE / 'publication-inputs'", "OUT = BASE / 'index-publication-inputs'")
    if original.startswith('check_'):
        start = modified.index('targets = ')
        end = modified.index('\n', start)
        modified = modified[:start] + "targets = ['docs/TASK_TREE.md']" + modified[end:]
    assert not (BASE / target).exists()
    (BASE / target).write_text(modified)
    rows[target] = dict(original=original, original_sha256=hashlib.sha256(body.encode()).hexdigest(),
        resulting_sha256=hashlib.sha256(modified.encode()).hexdigest())
(BASE / 'index-query-adaptation.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
print('Prepared a separate accepted-binding query for the stale global task-index row')
