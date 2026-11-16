"""One-shot whitespace repair retaining the original captured reader and refusal."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
path = BASE / 'review.py'
assert not (BASE / 'reader-normalization.json').exists(), 'one-shot normalization'
original = path.read_bytes()
with tarfile.open(BASE / 'preparation.tar.gz') as archive:
    assert archive.extractfile(str(path)).read() == original
assert original.endswith(b'\n\n')
command = dict(argv=['git','diff','--cached','--check'], cwd='.')
refusal = subprocess.run(command['argv'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
assert refusal.returncode != 0 and b'review.py:252: new blank line at EOF.' in refusal.stdout
for channel in ('stdout','stderr'):
    (BASE / ('whitespace-red-'+channel+'.gz')).write_bytes(gzip.compress(getattr(refusal,channel),mtime=0))
command['exit'] = refusal.returncode
(BASE / 'whitespace-red-command.json').write_text(json.dumps(command,indent=2)+'\n')
normalized = original.rstrip(b'\n') + b'\n'
(BASE / 'reader-normalization.json').write_text(json.dumps(dict(path=str(path),
    operation='rstrip only LF bytes at EOF, then append one LF',
    original=dict(bytes=len(original),sha256=hashlib.sha256(original).hexdigest()),
    normalized=dict(bytes=len(normalized),sha256=hashlib.sha256(normalized).hexdigest()),
    mode=path.stat().st_mode&0o777,
    limits='Original reader body/mode remains exact in preparation archive with original successful command channels. Only the landing form loses an extra final LF; qualified current verification treats this one explicit normalization separately.'),indent=2)+'\n')
path.write_bytes(normalized)
log = Path('.linkedspec-data/lua-ordinary-loader-commit.log')
(BASE / 'interrupted-hook.log.gz').write_bytes(gzip.compress(log.read_bytes(),mtime=0))
(BASE / 'interrupted-hook.json').write_text(json.dumps(dict(source=str(log),
    recording='after-use copy; commit/hook deliberately stopped before landing to repair known whitespace',
    sha256=hashlib.sha256(log.read_bytes()).hexdigest(),mode=log.stat().st_mode&0o777),indent=2)+'\n')
print('Normalized one extra EOF LF; original image and actual staged whitespace RED retained.')
