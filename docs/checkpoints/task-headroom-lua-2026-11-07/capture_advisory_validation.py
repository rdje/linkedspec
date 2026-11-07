"""Retain actual selected-validator RED/GREEN channels without overwriting."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
assert len(sys.argv) == 2 and sys.argv[1] in ('before', 'after')
phase = sys.argv[1]
prefix = BASE / ('advisory-validator-' + phase)
assert not prefix.with_suffix('.exit.txt').exists()
checker = BASE / 'check_advisory_claim.py'
raw = checker.read_bytes()
prefix.with_suffix('.producer.py.gz').write_bytes(gzip.compress(raw, mtime=0))
book = 'docs/linkedspec-book/src/development/local-ci-and-regression.md'
image = subprocess.check_output(['git', 'show', ':' + book])
prefix.with_suffix('.staged-book.md.gz').write_bytes(gzip.compress(image, mtime=0))
command = ['bash', 'tools/run_python_project_data.sh', str(checker)]
prefix.with_suffix('.command.json').write_text(json.dumps(dict(argv=command, cwd='.', staged_book_sha256=hashlib.sha256(image).hexdigest()), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name, body in (('stdout', result.stdout), ('stderr', result.stderr)):
    prefix.with_suffix('.' + name + '.log.gz').write_bytes(gzip.compress(body, mtime=0))
prefix.with_suffix('.exit.txt').write_text(str(result.returncode) + '\n')
print(phase, 'actual advisory validator exit', result.returncode)
if phase == 'before':
    assert result.returncode != 0 and book.encode() in result.stderr
    assert b'mismatch' in result.stderr.lower()
else:
    assert result.returncode == 0 and not result.stderr
