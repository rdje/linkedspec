"""Losslessly package two actual failed-reader channels; preserve raw identities."""
import gzip,hashlib,json
from pathlib import Path
base=Path(__file__).resolve().parent.relative_to(Path.cwd());aliases={}
for name in ['review-stderr.log','review-qualified-stderr.log']:
 p=base/name;body=p.read_bytes();q=Path(str(p)+'.gz');assert not q.exists()
 packed=gzip.compress(body,mtime=0);q.write_bytes(packed);assert gzip.decompress(q.read_bytes())==p.read_bytes()
 aliases[str(p)]=dict(capsule=str(q),raw_sha256=hashlib.sha256(body).hexdigest(),raw_bytes=len(body),capsule_sha256=hashlib.sha256(packed).hexdigest())
 p.unlink()
(base/'reader-channel-aliases.json').write_text(json.dumps(aliases,indent=2,sort_keys=True)+'\n')
print('Two actual failed-reader channels losslessly compressed; historical identities unchanged')
