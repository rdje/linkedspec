# Exact capture fragment executed inline before correcting the workflow paragraph.
# Retired: exclusive creation prevents replacing the original first proof snapshot.
from pathlib import Path
import base64,gzip,hashlib,json
p=Path('docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.3');r=json.loads((p/'evidence.json').read_bytes())
files={}
for path,item in r['inputs'].items():
 source=Path(path);raw=source.read_bytes();assert hashlib.sha256(raw).hexdigest()==item['sha256'];assert source.stat().st_mode&0o7777==item['mode'];files[path]={**item,'bytes_base64':base64.b64encode(raw).decode()}
with (p/'first-proof-inputs.json.gz').open('xb') as out:out.write(gzip.compress(json.dumps(files,sort_keys=True,separators=(',',':')).encode(),mtime=0))
