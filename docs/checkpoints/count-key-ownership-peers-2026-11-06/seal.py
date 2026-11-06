"""One-shot lossless sealing of completed peer and scoped-format channels."""
import gzip,hashlib,json
from pathlib import Path
BASE=Path(__file__).resolve().parent.relative_to(Path.cwd().resolve())
records={}
def seal(path):
    body=path.read_bytes();capsule=gzip.compress(body,mtime=0)
    target=Path(str(path)+'.gz');assert not target.exists();target.write_bytes(capsule)
    assert gzip.decompress(target.read_bytes())==body==path.read_bytes()
    records[str(path)]=dict(sha256=hashlib.sha256(body).hexdigest(),bytes=len(body),capsule=str(target),capsule_sha256=hashlib.sha256(capsule).hexdigest())
    path.unlink()
for phase in ('rust-probe','dart-probe','rust-normal','dart-normal'):
    assert (BASE/phase/'custody.json').is_file()
    for path in sorted((BASE/phase).glob('*.log')):seal(path)
for tag in ('rust-format','dart-format'):
    assert (BASE/(tag+'-exit.txt')).read_text()=='0\n'
    for channel in ('stdout','stderr'):seal(BASE/(tag+'-'+channel+'.log'))
assert records
(BASE/'raw-identities.json').write_text(json.dumps(records,indent=2,sort_keys=True)+'\n')
print('Completed peer and formatting channels sealed losslessly; all declared archives retained')
