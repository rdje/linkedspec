"""Seal only completed own raw channels losslessly; retain every preparation epoch."""
import gzip,hashlib,json
from pathlib import Path
BASE=Path(__file__).parent.relative_to(Path.cwd())
records={}
for phase in ['intake','intake-qualified','terminal-profile','before','after','final']:
 out=BASE/phase
 marker='exits.json' if phase in ['before','after'] else ('owner-syntax-exit.txt' if phase=='final' else 'exit.txt')
 assert (out/marker).is_file(),'never seal a running phase'
 for p in sorted(out.glob('*.log')):
  body=p.read_bytes();destination=Path(str(p)+'.gz');assert not destination.exists()
  capsule=gzip.compress(body,mtime=0);assert gzip.decompress(capsule)==body
  with destination.open('xb') as f:f.write(capsule)
  assert gzip.decompress(destination.read_bytes())==p.read_bytes()
  records[str(p)]={'capsule':str(destination),'capsule_sha256':hashlib.sha256(capsule).hexdigest(),'sha256':hashlib.sha256(body).hexdigest(),'bytes':len(body)}
  p.unlink()
with (BASE/'raw-identities.json').open('x') as f:f.write(json.dumps(records,indent=2,sort_keys=True)+'\n')
print('Completed original/qualified/terminal/before/after/final raw channels sealed and verified byte-exactly.')
