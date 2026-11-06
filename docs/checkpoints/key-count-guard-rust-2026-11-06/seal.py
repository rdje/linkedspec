"""One-shot lossless seal of completed Rust CountKeys proof channels."""
import gzip
import hashlib
import json
from pathlib import Path
BASE = Path(__file__).parent.relative_to(Path.cwd())
records = {}
for phase in ('probe-before','normal-before','probe-after','normal-after','nearest'):
    assert (BASE/phase/'custody.json').is_file()
    for path in sorted((BASE/phase).glob('*.log')):
        body=path.read_bytes();capsule=gzip.compress(body,mtime=0)
        target=Path(str(path)+'.gz');assert not target.exists();target.write_bytes(capsule)
        assert gzip.decompress(target.read_bytes())==body==path.read_bytes()
        records[str(path)]=dict(sha256=hashlib.sha256(body).hexdigest(),bytes=len(body),capsule=str(target),capsule_sha256=hashlib.sha256(capsule).hexdigest())
        path.unlink()
assert records
(BASE/'raw-identities.json').write_text(json.dumps(records,indent=2,sort_keys=True)+'\n')
print('Completed Rust Cargo/native/fresh/normal channels sealed losslessly; declared input archives retained')
