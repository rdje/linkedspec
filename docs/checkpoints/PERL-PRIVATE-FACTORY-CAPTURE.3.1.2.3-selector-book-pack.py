"""One-shot lossless containment of the actual complete four-channel book capture."""
import base64,gzip,hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-selector-'
target=ROOT/(PREFIX+'book.json');raw=target.read_bytes();data=json.loads(raw)
sha=lambda r:hashlib.sha256(r).hexdigest()
assert data['result']=='PASS' and len(data['rows'])==4,'one-shot raw healthy capture'
assert data['producer_sha256']==sha((ROOT/(PREFIX+'book.py')).read_bytes())
compressed=gzip.compress(raw,mtime=0);assert gzip.decompress(compressed)==raw
packed={'encoding':'gzip-base64','bytes':len(raw),'sha256':sha(raw),
 'data':base64.b64encode(compressed).decode(),'producer_sha256':sha(Path(__file__).read_bytes()),
 'scope':'Lossless exact raw actual producer output; no channel/input/hash is refreshed or discarded.'}
encoded=(json.dumps(packed,indent=2)+'\n').encode();assert len(encoded)<=524288
target.write_bytes(encoded)
restored=gzip.decompress(base64.b64decode(json.loads(target.read_bytes())['data'],validate=True))
assert restored==raw
print('Exact raw book capture retained losslessly:',len(raw),'to',len(encoded),'bytes.')
