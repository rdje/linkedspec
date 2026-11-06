"""Seal completed own partial/qualified channels without rewriting any epoch."""
import gzip,hashlib,json
from pathlib import Path
base=Path(__file__).resolve().parent.relative_to(Path.cwd());records={}
for phase in ['intake','normal','direct','intake-qualified','normal-qualified','direct-qualified','format']:
 out=base/phase;marker='empty-phase-exit.txt' if phase=='format' else 'custody.json'
 assert (out/marker).is_file(),'never seal a running phase'
 for p in sorted(out.glob('*.log')):
  body=p.read_bytes();capsule=gzip.compress(body,mtime=0);q=Path(str(p)+'.gz');assert not q.exists()
  with q.open('xb') as f:f.write(capsule)
  assert gzip.decompress(q.read_bytes())==p.read_bytes()
  records[str(p)]={'capsule':str(q),'capsule_sha256':hashlib.sha256(capsule).hexdigest(),'sha256':hashlib.sha256(body).hexdigest(),'bytes':len(body)}
  p.unlink()
with (base/'raw-identities.json').open('x') as f:f.write(json.dumps(records,indent=2,sort_keys=True)+'\n')
print('Original partial and qualified Dart channels sealed losslessly; no runtime epoch overwritten.')
