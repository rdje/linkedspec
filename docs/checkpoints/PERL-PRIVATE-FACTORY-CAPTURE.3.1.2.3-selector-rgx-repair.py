"""One-shot exact published-README snapshot alias; parent tracking rules remain unchanged."""
import base64,hashlib,importlib.util,json,os,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
CLAIM='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3.json'
PUBLISHER=PREFIX+'selector-publication-source.py'
SNAPSHOT=PREFIX+'selector-rgx-readme.md'
sha=lambda r:hashlib.sha256(r).hexdigest()
before_claim=ROOT/(PREFIX+'selector-claim-before-rgx.json')
before_producer=ROOT/(PREFIX+'selector-publication-before-rgx.py')
assert not before_claim.exists() and not before_producer.exists() and not (ROOT/SNAPSHOT).exists()
original=(ROOT/CLAIM).read_bytes();producer=(ROOT/PUBLISHER).read_bytes()
before_claim.write_bytes(original);before_producer.write_bytes(producer)
args=['python3',PREFIX+'selector-rgx-red.py']
p=subprocess.run(args,cwd=ROOT,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
assert p.returncode!=0 and b'untracked input: rgx/README.md' in p.stderr,(p.returncode,p.stderr)
(ROOT/(PREFIX+'selector-rgx-red.json')).write_text(json.dumps({'args':args,'exit_code':p.returncode,
 'stdout_base64':base64.b64encode(p.stdout).decode(),'stderr_base64':base64.b64encode(p.stderr).decode(),
 'producer_sha256':sha(Path(__file__).read_bytes()),'validator_sha256':sha((ROOT/'tools/check_claim_verification.py').read_bytes()),
 'rejected_claim_sha256':sha(original),'reader_sha256':sha((ROOT/args[1]).read_bytes())},indent=2)+'\n')
published=(ROOT/'rgx/README.md').read_bytes()
for mode in ('before','after'):
 record=json.loads((ROOT/(PREFIX+'selector-'+mode+'.json')).read_bytes())
 assert record['inputs']['rgx/README.md']==sha(published),'exact actually scanned public README identity'
(ROOT/SNAPSHOT).write_bytes(published)
text=producer.decode();needle=' return record\n'
addition=""" snapshot=PREFIX+'selector-rgx-readme.md'
 assert (ROOT/snapshot).read_bytes()==(ROOT/'rgx/README.md').read_bytes(),'exact read-only published RGX README snapshot'
 for mode in ('before','after'):
  captured=json.loads((ROOT/(PREFIX+'selector-'+mode+'.json')).read_bytes())
  assert captured['inputs']['rgx/README.md']==m.sha((ROOT/snapshot).read_bytes()),'actual public README capture identity'
 original_inputs=claim['durability']['inputs']
 assert sum(r['path']=='rgx/README.md' for r in original_inputs)==1
 claim['durability']['inputs']=[r for r in original_inputs if r['path']!='rgx/README.md']
 assert sum(r['path']==snapshot for r in claim['durability']['inputs'])==1
 claim['scope']+=' Actual public discovery reads only RGX published README documentation. Parent Git tracks its Gitlink, so an exact tracked documentation snapshot replaces only the untracked durability path; actual scan hashes/current published bytes must match. No dependency implementation, pin or tracked-input policy changes. The rejected publication/producer and actual production-reader RED remain retained.'
 return record
"""
assert text.count(needle)==1
(ROOT/PUBLISHER).write_text(text.replace(needle,addition))
spec=importlib.util.spec_from_file_location('aliased_publication',ROOT/PUBLISHER);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
record=m.expected();raw=(json.dumps(record,indent=2)+'\n').encode();assert len(raw)<=131072
assert (ROOT/CLAIM).read_bytes()==original
(ROOT/CLAIM).write_bytes(raw)
print('Exact read-only RGX published README alias retained; actual untracked-input RED; final claim',len(raw),'bytes; additional',len(record['claims'][2]['durability']['inputs']))
