"""Prepare an activation-exact existing unpartitioned task-data epoch."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OLD = Path('docs/checkpoints/task-headroom-spec-reference-2026-11-11')
ACTIVATION = 'bf01d855bf913a5a839670669d9ad91e9c6314df'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
rows = {}
for name in ('capture.py', 'check_candidate.py', 'review.py', 'seal.py', 'run_review.py'):
    source = OLD / name
    raw = source.read_bytes()
    assert raw == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(source)])
    image = BASE / ('template-' + name + '.gz')
    target = BASE / name
    assert not image.exists() and not target.exists()
    image.write_bytes(gzip.compress(raw, mtime=0))
    assert gzip.decompress(image.read_bytes()) == raw
    body = raw.decode()
    for old, new in (
        ('TYPE-REFERENCE-BOOK.1.2.23.4.27', 'TYPE-REFERENCE-BOOK.1.2.23.4.29'),
        ('SPEC-LANG-REFERENCE', 'REPO-HYGIENE'),
        ('398d723bfb5e4e7960141944957e72a4335c7e35', ACTIVATION),
        (str(OLD), str(BASE)),
    ):
        if old in body:
            assert body.count(old) == 1, (name, old)
            body = body.replace(old, new)
    compile(body, str(target), 'exec')
    target.write_text(body)
    rows[name] = dict(source=str(source), template_sha256=hashlib.sha256(raw).hexdigest(),
        retained_template=str(image), generated_sha256=hashlib.sha256(body.encode()).hexdigest())
(BASE / 'template-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
print('Prepared five existing data-epoch instruments from retained exact templates; no migration executed')
