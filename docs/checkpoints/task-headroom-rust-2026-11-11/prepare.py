"""Author one finite epoch from activation-exact retained Julia instruments."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OLD = Path('docs/checkpoints/task-headroom-julia-2026-11-11')
ACTIVATION = 'c97b864fe9e9de16eaff5bcc840e46e97afe1699'
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
        ('TYPE-REFERENCE-BOOK.1.2.23.4.23', 'TYPE-REFERENCE-BOOK.1.2.23.4.25'),
        ('JULIA-BACKEND-PARITY', 'RUST-PARITY'),
        ('d34acedac2583bd7ef7ab805880710cd806afbdd', ACTIVATION),
        ('docs/checkpoints/task-headroom-julia-2026-11-11', str(BASE)),
        ('No new Julia host', 'No new Rust host'),
    ]
    for old, new in replacements:
        if old in text:
            assert text.count(old) == 1, (name, old)
            text = text.replace(old, new)
    target = BASE / name
    target.write_text(text)
    rows[name] = dict(template=str(source), template_sha256=hashlib.sha256(raw).hexdigest(),
        retained_template=str(archived), generated_sha256=hashlib.sha256(target.read_bytes()).hexdigest())
(BASE / 'template-identities.json').write_text(json.dumps(rows, indent=2) + '\n')
print('Five explicit Rust-epoch instruments authored; original templates retained')
