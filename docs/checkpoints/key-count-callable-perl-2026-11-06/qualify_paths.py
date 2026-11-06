"""Qualify actual absolute-path sealing metadata into portable relative identities."""
import gzip,hashlib,json
from pathlib import Path
root=Path.cwd();base=Path(__file__).parent.relative_to(root)
original=json.loads(gzip.decompress((base/'raw-identities.json.gz').read_bytes()))
qualified={}
for name,value in original.items():
 p=Path(name);q=Path(value['capsule']);assert p.is_absolute() and q.is_absolute()
 relative=p.relative_to(root);capsule=q.relative_to(root)
 assert relative.parent.parent==base and capsule==Path(str(relative)+'.gz')
 body=capsule.read_bytes();assert hashlib.sha256(body).hexdigest()==value['capsule_sha256']
 assert hashlib.sha256(gzip.decompress(body)).hexdigest()==value['sha256'] and len(gzip.decompress(body))==value['bytes']
 qualified[str(relative)]={**value,'capsule':str(capsule)}
with (base/'raw-identities-qualified.json').open('x') as f:f.write(json.dumps(qualified,indent=2,sort_keys=True)+'\n')
print('Actual identities qualified root-relative; original seal metadata and rejected review preserved losslessly.')
