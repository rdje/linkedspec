"""Losslessly seal only this completed acquisition's owned raw channels."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT=Path.cwd().resolve()
BASE=Path(__file__).resolve().parent.relative_to(ROOT)
output=BASE/'raw-identities.json'
assert not output.exists(), 'one-shot sealer; never rewrite retained identities'
records={}
for path in sorted(BASE.rglob('*.log')):
    assert path.is_file() and not path.is_symlink()
    assert path.stat().st_dev==ROOT.stat().st_dev
    capsule=Path(str(path)+'.gz')
    assert not capsule.exists()
    body=path.read_bytes()
    capsule.write_bytes(gzip.compress(body,mtime=0))
    assert gzip.decompress(capsule.read_bytes())==body
    records[str(path)]=dict(sha256=hashlib.sha256(body).hexdigest(),bytes=len(body),
        capsule=str(capsule),capsule_sha256=hashlib.sha256(capsule.read_bytes()).hexdigest())
    path.unlink()  # Exactly this byte-verified redundant representation.
assert records
output.write_text(json.dumps(records,indent=2,sort_keys=True)+'\n')
print('raw channels sealed losslessly; no diagnostics filtered')
