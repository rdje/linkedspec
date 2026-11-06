"""Seal complete own epochs and the explicitly stopped format epoch losslessly."""
import difflib,gzip,hashlib,json,tarfile
from pathlib import Path
ROOT=Path.cwd();base=Path(__file__).resolve().parent.relative_to(ROOT)
phases=['intake','before','after','after-intake','direct','format','format-final','direct-final','after-intake-final'];raw={}
def get(phase,path):
 with tarfile.open(base/phase/'root-before-first-run.tar.gz') as a:return a.extractfile(path).read()
owner='dart/lib/src/runtime/interpreter.dart'
for name,old,new,a,b in [('producer-change',get('intake',owner),get('direct-final',owner),'a/'+owner,'b/'+owner),('capture-final-phases',get('intake',str(base/'capture.py')),get('direct-final',str(base/'capture.py')),'a/capture.py','b/capture.py')]:
 body=''.join(difflib.unified_diff(old.decode().splitlines(True),new.decode().splitlines(True),fromfile=a,tofile=b)).encode()
 p=base/(name+'.patch.gz');assert not p.exists();p.write_bytes(gzip.compress(body,mtime=0));assert gzip.decompress(p.read_bytes())==body
for phase in phases:
 out=base/phase;assert (out/'custody.json').exists(),'never seal a running phase'
 for p in sorted(out.glob('*.log')):
  body=p.read_bytes();q=Path(str(p)+'.gz');assert not q.exists();q.write_bytes(gzip.compress(body,mtime=0));assert gzip.decompress(q.read_bytes())==p.read_bytes()
  raw[str(p)]=dict(bytes=len(body),sha256=hashlib.sha256(body).hexdigest());p.unlink()
(base/'raw-identities.json').write_text(json.dumps(raw,indent=2,sort_keys=True)+'\n')
sealed={}
for p in sorted(base.rglob('*')):
 if p.is_file() and p.name not in {'sealed-identities.json','REVIEW.md'} and not p.name.startswith('review-'):
  b=p.read_bytes();sealed[str(p)]=dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
(base/'sealed-identities.json').write_text(json.dumps(sealed,indent=2,sort_keys=True)+'\n')
print('Actual raw epochs and both source-version patches sealed; original format RED retained')
