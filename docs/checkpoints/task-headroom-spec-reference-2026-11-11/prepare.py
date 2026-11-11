"""Prepare one activation-exact data epoch from retained approved Rust instruments."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(ROOT)
OLD = Path('docs/checkpoints/task-headroom-rust-2026-11-11')
ACTIVATION = '398d723bfb5e4e7960141944957e72a4335c7e35'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == ACTIVATION
rows = {}
for name in ('capture.py', 'check_candidate.py', 'review.py', 'seal.py', 'run_review.py'):
    source = OLD / name
    raw = source.read_bytes()
    assert raw == subprocess.check_output(['git', 'show', ACTIVATION + ':' + str(source)])
    alias = BASE / ('template-' + name + '.gz')
    assert not alias.exists() and not (BASE / name).exists()
    alias.write_bytes(gzip.compress(raw, mtime=0))
    text = raw.decode()
    replacements = [
        ('TYPE-REFERENCE-BOOK.1.2.23.4.25', 'TYPE-REFERENCE-BOOK.1.2.23.4.27'),
        ('RUST-PARITY', 'SPEC-LANG-REFERENCE'),
        ('c97b864fe9e9de16eaff5bcc840e46e97afe1699', ACTIVATION),
        (str(OLD), str(REL)),
        ('No new Rust host', 'No runtime host'),
    ]
    for old, new in replacements:
        if old in text:
            assert text.count(old) == 1, (name, old)
            text = text.replace(old, new)
    if name == 'review.py':
        old = "    unselected = next(key for key in old if key not in row['selected'])\n    reject('unselected body changed', lambda: validate(before, after.replace(now[unselected], now[unselected] + b'changed\\n', 1), row))"
        new = "    unselected = [key for key in old if key not in row['selected']]\n    if unselected:\n        key = unselected[0]\n        reject('unselected body changed', lambda: validate(before, after.replace(now[key], now[key] + b'changed\\n', 1), row))\n    else:\n        reject('undeclared closed commentary inserted', lambda: validate(before, after.replace(now[selected], now[selected] + b'changed\\n', 1), row))"
        assert text.count(old) == 1
        text = text.replace(old, new)
    if name in ('run_review.py', 'check_candidate.py'):
        old = "['bash', 'tools/run_python_project_data.sh', str(REL / 'check_candidate.py'), '--check']" if name == 'check_candidate.py' else "['bash', 'tools/run_python_project_data.sh', str(BASE / 'review.py')]"
        new = "['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(REL / 'check_candidate.py'), '--check']" if name == 'check_candidate.py' else "['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(BASE / 'review.py')]"
        assert text.count(old) == 1
        text = text.replace(old, new)
    (BASE / name).write_text(text)
    rows[name] = dict(source=str(source), template_sha256=hashlib.sha256(raw).hexdigest(),
        retained_template=alias.name, generated_sha256=hashlib.sha256(text.encode()).hexdigest())
(BASE / 'template-identities.json').write_text(json.dumps(rows, indent=2) + '\n')
print('Prepared five data-only epoch instruments; original templates retained; no migration executed.')
