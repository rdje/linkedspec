"""Complete only the failed finite launch-list setup; retain its original actual1."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
assert not (BASE / 'completed-launches.json').exists()
failed = BASE / 'launches/prepare-recovery'
assert (failed / 'exit.txt').read_text() == '1\n'
stderr = gzip.decompress((failed / 'stderr.log.gz').read_bytes())
assert b'FileNotFoundError' in stderr and b'launches/prepare-recovery/exit.txt' in stderr
old = ROOT / 'docs/checkpoints/array-pipeline-callable-lua-2026-11-11'
for name in ('check_current.py', 'capture_current.py', 'seal.py'):
    wanted = (old / name).read_text().replace('9a6b229ce3f944ef3822e71935b1c40c109f74b9', 'fff959ef7e8896b5b97f311a276cabc4f5034551').replace('traceq/', 'trace/')
    assert (BASE / name).read_text() == wanted
rows = []
for folder in sorted((BASE / 'launches').iterdir()):
    if folder.name == 'qualify-recovery-setup':
        assert not (folder / 'exit.txt').exists()
        continue
    assert (folder / 'exit.txt').read_text() == ('1\n' if folder.name == 'prepare-recovery' else '0\n')
    body = gzip.decompress((folder / 'stderr.log.gz').read_bytes())
    assert body == (stderr if folder.name == 'prepare-recovery' else b'')
    rows.append(dict(name=folder.name, actual_exit=int((folder / 'exit.txt').read_text()),
        stderr_bytes=len(body), stderr_sha256=hashlib.sha256(body).hexdigest()))
(BASE / 'completed-launches.json').write_text(json.dumps(rows, indent=2) + '\n')
(BASE / 'recovery-setup-qualification.json').write_text(json.dumps(dict(
    original='launches/prepare-recovery', actual_exit=1,
    cause='The launch-list setup included its own unfinished launcher before exit.txt existed. Current/seal instruments were already created exactly.',
    correction='Exclude only this qualifier in flight; include the original actual1 and exact stderr in the finite completed-launch list. No SDK epoch replay or instrument rewrite.'), indent=2) + '\n')
print('Qualified finite completed launch list; original setup1/channels/source retained, no SDK replay')
