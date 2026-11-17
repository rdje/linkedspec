"""Retain the old source planner and prepare a new bounded scan before use."""
import hashlib
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
PRIOR = Path('docs/checkpoints/task-headroom-perl-ast-2026-11-17')
ACTIVATION = '873003e8901e2b48fd0a289db2540e94bc4d5039'
OWNER = 'TYPE-REFERENCE-BOOK.1.2.23.4.36'
changes = []
source = (PRIOR / 'scan.py').read_text()
for old, new in [
    ('08c39a2dfb4be628af24a445a7fdbb98a82e962f', ACTIVATION),
    ('TYPE-REFERENCE-BOOK.1.2.23.4.35', OWNER),
    ("names = ['docs/tasks/PERL-ACTIONIR-AST-MIGRATION.md']", "names = ['docs/tasks/STAGED-LINKED-PARSING.md']")]:
    assert source.count(old) == 1
    source = source.replace(old, new)
    changes.append(dict(old=old, new=new))
with tarfile.open(BASE / 'scan-composition-before.tar.gz', 'x:gz') as archive:
    for path in (PRIOR / 'scan.py', BASE / 'prepare_scan.py'):
        archive.add(path, arcname=str(path), recursive=False)
with (BASE / 'scan.py').open('xb') as stream:
    stream.write(source.encode())
(BASE / 'scan-composition.json').write_text(json.dumps(dict(template=str(PRIOR / 'scan.py'), substitutions=changes,
    actual_sha256=hashlib.sha256(source.encode()).hexdigest(),
    limits='New bounded planner only; old main never replayed. Source images retained before new planner use; full outer-first-use/native/physical closure remains4.2/SESSION5.'), indent=2) + chr(10))
print('Prepared exact new staged-tree planner')
