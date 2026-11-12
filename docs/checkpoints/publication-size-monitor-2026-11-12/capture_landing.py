"""Preserve the exact failed monitor landing before bounded documentation repair."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'landing-pressure'
OUT.mkdir()
paths = [Path(p) for p in ('docs/linkedspec-book/src/development/local-ci-and-regression.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md', 'docs/tasks/TYPE-REFERENCE-BOOK.overview.md',
    'MEMORY.md', 'tools/check_claim_verification.py', 'doctrine/readme_stability/routes.jsonl',
    '.linkedspec-data/publication-size-monitor-commit.log')]
paths += [Path(__file__).resolve().relative_to(ROOT)]
rows = {}
with tarfile.open(OUT / 'inputs-before-repair.tar.gz', 'x:gz') as packed:
    for path in paths:
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        body = path.read_bytes()
        rows[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        packed.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'inputs-before-repair.tar.gz') as packed:
    assert set(packed.getnames()) == rows.keys()
    for member in packed:
        body = packed.extractfile(member).read(); row = rows[member.name]
        assert len(body) == row['bytes'] and hashlib.sha256(body).hexdigest() == row['sha256'] and member.mode & 0o777 == row['mode']
(OUT / 'identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
log = paths[6].read_bytes()
assert log.count(b'  PASS  ') == 8 and log.count(b'  FAIL  ') == 2
assert b'local-ci-and-regression.md lines 2074/2048' in log
assert b'gap repair owner is not open: TYPE-REFERENCE-BOOK.1.2.23.4.30' in log
for name, path in (('ci-before.md.gz', paths[0]), ('workflow-before.md.gz', paths[1]),
    ('overview-before.md.gz', paths[2]), ('checker-before.py.gz', paths[4]), ('first-failed-commit-combined.log.gz', paths[6])):
    (OUT / name).write_bytes(gzip.compress(path.read_bytes(), mtime=0))
assert paths[4].read_bytes() == subprocess.check_output(['git', 'show', 'HEAD:tools/check_claim_verification.py'])
(OUT / 'result.json').write_text(json.dumps(dict(observed_original_exec_exit=1, original_exec_session=56282,
    passed_doctrines=8, failures=['README-STABILITY:2074/2048 CI lines', 'CLAIM-VERIFICATION:in_progress is outside the allowed repair-owner states'],
    ci_lines_before=2074, workflow_lines_before=984,
    scope='Exact original combined log/source/full-mode images; no original producer/reviewer/claim observation is changed.'), indent=2) + '\n')
print('Preserved first monitor normal1, eight PASS/two failures and exact pre-repair inputs')
