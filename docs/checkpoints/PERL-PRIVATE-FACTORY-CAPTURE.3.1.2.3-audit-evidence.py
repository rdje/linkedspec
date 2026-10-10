"""Actual semantic evidence REDs and exact restoration for the historical repair."""
import base64,copy,gzip,hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
RUNTIME='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1.json'
TARGET=ROOT/(PREFIX+'audit-evidence.json');assert not TARGET.exists(),'one-shot evidence capture'
sha=lambda r:hashlib.sha256(r).hexdigest()
def envelope(r):return {'encoding':'gzip-base64','bytes':len(r),'sha256':sha(r),'data':base64.b64encode(gzip.compress(r,mtime=0)).decode()}
rows=[]
for name in ('forged_guard','missing_reader_input','forged_runtime_binding','forged_initial_input'):
 path=RUNTIME if name=='forged_runtime_binding' else PREFIX+('audit-after.json' if name=='forged_initial_input' else 'audit-final.json')
 original=(ROOT/path).read_bytes();mutant=json.loads(original)
 if name=='forged_runtime_binding':
  mutant['claims'][0]['durability']['inputs'][0]['sha256']='0'*64
  reason='runtime claim mode/revision-only preservation'
 else:
  data=json.loads(gzip.decompress(base64.b64decode(mutant['stdout']['data'])))
  if name=='forged_guard':data['healthy_audit_guard']['original_log_attempts']=1;reason='healthy read/write guard remains zero'
  elif name=='missing_reader_input':del data['tracked_inputs'][next(iter(data['tracked_inputs']))];reason='complete actual reader input population'
  else:data['tracked_inputs'][next(iter(data['tracked_inputs']))]='0'*64;reason='actual captured input identity'
  mutant['stdout']=envelope((json.dumps(data,indent=2,sort_keys=True)+'\n').encode())
 raw=(json.dumps(mutant,indent=2)+'\n').encode()
 try:
  (ROOT/path).write_bytes(raw)
  args=['python3',PREFIX+'audit-review.py'];p=subprocess.run(args,cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
  assert p.returncode!=0 and reason.encode() in p.stderr,name
  rows.append({'name':name,'path':path,'reason':reason,'mutant':envelope(raw),'args':args,'exit_code':p.returncode,'stdout':envelope(p.stdout),'stderr':envelope(p.stderr)})
 finally:(ROOT/path).write_bytes(original)
p=subprocess.run(['python3',PREFIX+'audit-review.py'],cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
assert p.returncode==0 and not p.stderr
TARGET.write_text(json.dumps({'producer_sha256':sha(Path(__file__).read_bytes()),'rows':rows,'restored':{'exit_code':p.returncode,'stdout':envelope(p.stdout),'stderr':envelope(p.stderr)}},indent=2)+'\n')
print('Four actual historical evidence REDs; exact restored reviewer PASS retained.')
