"""Preserve the exact used Markdown template before retiring its plain duplicate."""
import gzip
import hashlib
import json
from pathlib import Path
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
source = BASE / 'book-section.md'
target = BASE / 'book-section.md.gz'
OUT = BASE / 'template-retirement'
OUT.mkdir()
assert not target.exists() and not source.is_symlink() and source.stat().st_dev == ROOT.stat().st_dev
raw = source.read_bytes()
mode = source.stat().st_mode & 0o777
row = json.loads((BASE / 'publication-qualified/inputs-before-use.json').read_bytes())[str(source)]
assert dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=mode) == row
assert 'book-section.md' not in json.loads((BASE / 'sealed-identities.json').read_bytes())
with tarfile.open(BASE / 'publication-qualified/inputs-before-use.tar.gz') as retained:
    original = retained.getmember(str(source))
    assert retained.extractfile(original).read() == raw and original.mode == mode
with tarfile.open(OUT / 'inputs-before-delete.tar.gz', 'x:gz') as retained:
    for path in (BASE / 'retire_template.py', source):
        retained.add(path, arcname=str(path), recursive=False)
target.write_bytes(gzip.compress(raw, mtime=0))
assert gzip.decompress(target.read_bytes()) == raw
assert source.read_bytes() == raw and source.stat().st_mode & 0o777 == mode
source.unlink()
assert not source.exists() and gzip.decompress(target.read_bytes()) == raw
(OUT / 'result.json').write_text(json.dumps(dict(source=str(source), archived=str(target), identity=row,
    scope='Only the exact own duplicate is retired after independent original-archive/body/full-mode comparison and gzip readback. Original used bytes remain recoverable; publishers are one-shot and historical readers use frozen archive inputs.'), indent=2) + '\n')
print('Retained exact used template bytes/mode and retired only its staged whitespace duplicate')
