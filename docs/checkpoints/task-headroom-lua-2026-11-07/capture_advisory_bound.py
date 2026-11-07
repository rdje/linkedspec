"""Qualified actual diagnostic capture with producer/material bytes before use."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert len(sys.argv) == 2 and sys.argv[1] in ('before', 'after')
phase = sys.argv[1]
OUT = BASE / ('advisory-bound-' + phase)
assert not OUT.exists()
OUT.mkdir()
names = [BASE / 'check_advisory_candidate.py', BASE / 'capture_advisory_bound.py',
         BASE / 'run_advisory_step.py', Path('tools/check_claim_verification.py')]
names += [Path('tools') / p for p in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
names += [Path('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.8.json'),
          Path('docs/linkedspec-book/src/development/local-ci-and-regression.md')]
records = {}
with tarfile.open(OUT / 'inputs-before-validator.tar.gz', 'x:gz') as archive:
    for path in names:
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        raw = path.read_bytes()
        records[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'input-identities.json').write_text(json.dumps(records, indent=2) + '\n')
index = subprocess.check_output(['git', 'ls-files', '--stage', '-z'])
(OUT / 'actual-index.txt.gz').write_bytes(gzip.compress(index, mtime=0))
command = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'check_advisory_candidate.py')]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.', overlay='current book/current record; other inputs from captured index or declared historical Git'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name, raw in (('stdout', result.stdout), ('stderr', result.stderr)):
    (OUT / (name + '.log.gz')).write_bytes(gzip.compress(raw, mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
if phase == 'before':
    assert result.returncode == 1 and b'stale input: docs/linkedspec-book/src/development/local-ci-and-regression.md' in result.stderr
else:
    assert result.returncode == 0 and not result.stderr
assert subprocess.check_output(['git', 'ls-files', '--stage', '-z']) == index
for path, expected in records.items():
    raw = Path(path).read_bytes()
    assert len(raw) == expected['bytes'] and hashlib.sha256(raw).hexdigest() == expected['sha256']
print('Qualified actual validator', phase, 'retained with pre-use producers/material and specific diagnostic')
