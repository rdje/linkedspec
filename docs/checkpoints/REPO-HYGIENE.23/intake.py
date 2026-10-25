"""Preserve exact authorized note copies as inert inputs, not project paths."""
import base64
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT=Path(__file__).resolve().parents[3]
PREFIX=Path('docs/checkpoints/REPO-HYGIENE.23')
names={'00-index.md':'input-index.md','linkedspec.md':'input-linkedspec.md'}
packets={}
for original,name in names.items():
    path=ROOT/PREFIX/name
    assert not path.is_symlink() and path.stat().st_dev==ROOT.stat().st_dev
    assert subprocess.run(['git','ls-files','--error-unmatch','--',str(PREFIX/name)],
        cwd=ROOT,capture_output=True).returncode!=0
    raw=path.read_bytes()
    packets[original]=dict(base64=base64.b64encode(raw).decode(),
        sha256=hashlib.sha256(raw).hexdigest(),mode=path.stat().st_mode & 0o7777)
record=dict(version=1,owner='REPO-HYGIENE.23',intake_date='2026-10-25',note_date='2026-10-21',
    sources=packets,
    scope='Exact already verified copies of the director-authorized read-only Desktop disk-notes '
        'index and LinkedSpec note. Historical external paths/commands are inert source bytes, '
        'not project configuration or cleanup authority. No new current size/reclaim measurement. '
        'The external originals and all other project data remain unchanged.')
destination=ROOT/PREFIX/'input-notes.json.gz'
with destination.open('xb') as stream:
    stream.write(gzip.compress((json.dumps(record,sort_keys=True)+'\n').encode(),mtime=0))
restored=json.loads(gzip.decompress(destination.read_bytes()))
for original,name in names.items():
    raw=base64.b64decode(restored['sources'][original]['base64'])
    assert raw==(ROOT/PREFIX/name).read_bytes()
    assert hashlib.sha256(raw).hexdigest()==restored['sources'][original]['sha256']
for name in names.values():
    (ROOT/PREFIX/name).unlink()
    assert not (ROOT/PREFIX/name).exists()
print('Both exact supplied notes retained as inert source packets; duplicate project copies removed.')
