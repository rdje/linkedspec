"""Seal complete installed-host Lua phases and exact source-version patches."""
import difflib,gzip,hashlib,json,tarfile
from pathlib import Path
base=Path(__file__).resolve().parent.relative_to(Path.cwd())
def source(phase,path):
 with tarfile.open(base/phase/'inputs-before-first-run.tar.gz') as archive:return archive.extractfile(path).read()
for phase in ('intake','before','after','direct'):assert (base/phase/'complete.txt').exists(),'never seal an active phase'
for name,path in [('producer-change','lua/src/linkedspec/interpreter.lua'),('runner-registration','lua/test/run.lua')]:
 b=''.join(difflib.unified_diff(source('intake',path).decode().splitlines(True),source('after',path).decode().splitlines(True),fromfile='a/'+path,tofile='b/'+path)).encode();p=base/(name+'.patch.gz');assert not p.exists();p.write_bytes(gzip.compress(b,mtime=0));assert gzip.decompress(p.read_bytes())==b
records={}
for p in sorted(base.rglob('*')):
 if p.is_file() and p.name not in {'sealed-identities.json','REVIEW.md'} and not p.name.startswith('review-'):
  b=p.read_bytes();records[str(p)]=dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
(base/'sealed-identities.json').write_text(json.dumps(records,indent=2,sort_keys=True)+'\n');print('Both installed-host complete epochs and exact source patches sealed')
