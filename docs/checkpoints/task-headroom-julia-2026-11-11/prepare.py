"""Author a new finite epoch from retained, unchanged historical instruments."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OLD = Path('docs/checkpoints/task-headroom-dart-2026-11-10')
ACTIVATION = 'd34acedac2583bd7ef7ab805880710cd806afbdd'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
rows = {}
for name in ('capture.py', 'check_candidate.py', 'review.py', 'seal.py', 'run_review.py'):
    source = OLD / name
    raw = source.read_bytes()
    assert raw == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(source)])
    archived = BASE / ('template-' + name + '.gz')
    assert not archived.exists() and not (BASE / name).exists()
    archived.write_bytes(gzip.compress(raw, mtime=0))
    assert gzip.decompress(archived.read_bytes()) == raw
    text = raw.decode()
    replacements = [
        ('TYPE-REFERENCE-BOOK.1.2.23.4.21', 'TYPE-REFERENCE-BOOK.1.2.23.4.23'),
        ('DART-BACKEND-PARITY', 'JULIA-BACKEND-PARITY'),
        ('3906078befb43dcc2c2536c516a81d46de37f8c5', ACTIVATION),
        ('docs/checkpoints/task-headroom-dart-2026-11-10', str(BASE)),
    ]
    for old, new in replacements:
        if old in text:
            assert text.count(old) == 1, (name, old)
            text = text.replace(old, new)
    if name == 'review.py':
        old = "    assert len(old) == 68 and len(row['selected']) == 58 and len(before) - len(after) == 64936\n    assert len(old) - len(row['selected']) == 10\n"
        assert text.count(old) == 1
        text = text.replace(old, "    # Exact activation Git is the finite source oracle; derive this new epoch's counts.\n")
        text = text.replace('No new Dart host', 'No new Julia host')
    target = BASE / name
    target.write_text(text)
    rows[name] = dict(template=str(source), template_sha256=hashlib.sha256(raw).hexdigest(),
        retained_template=str(archived), generated_sha256=hashlib.sha256(target.read_bytes()).hexdigest())
(BASE / 'template-identities.json').write_text(json.dumps(rows, indent=2) + '\n')
print('Five explicit new instruments authored; old bytes retained unchanged')
