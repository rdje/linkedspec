"""One-shot actual proof-reader counterfactuals and exact restoration."""
import base64,hashlib,importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
target=ROOT/(PREFIX+'selector-evidence.json');assert not target.exists()
spec=importlib.util.spec_from_file_location('selector_review',ROOT/(PREFIX+'selector-review.py'));m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
rows=[]
for name,tail,reason in [('forged_original_publication','selector-before-claim.json','original publication identity'),
 ('forged_positive_metric','selector-after.json','actual unchanged classifier GREEN metrics'),
 ('missing_classifier_input','selector-after.json','complete actual classifier input population')]:
 path=PREFIX+tail;original=m.read(path);mutant=json.loads(original)
 if name=='forged_original_publication':mutant['claims'][0]['durability']['inputs'][0]['sha256']='0'*64
 elif name=='forged_positive_metric':mutant['stdout_base64']=base64.b64encode(b'{"public_files":70,"classified_references":0,"result":"PASS"}\n').decode()
 else:del mutant['inputs'][next(iter(mutant['inputs']))]
 raw=(json.dumps(mutant,indent=2)+'\n').encode()
 try:
  (ROOT/path).write_bytes(raw);observed=m.run(['python3',PREFIX+'selector-review.py','--proof-only'])
  assert observed['exit_code']!=0 and reason.encode() in base64.b64decode(observed['stderr_base64']),(name,observed)
  rows.append({'name':name,'path':path,'reason':reason,'mutant_base64':base64.b64encode(raw).decode(),'observed':observed})
 finally:(ROOT/path).write_bytes(original)
restored=m.run(['python3',PREFIX+'selector-review.py','--proof-only'])
assert restored['exit_code']==0 and not base64.b64decode(restored['stderr_base64']),restored
target.write_text(json.dumps({'producer_sha256':m.sha(Path(__file__).read_bytes()),
 'reviewer_sha256':m.sha(m.read(PREFIX+'selector-review.py')),'rows':rows,'restored':restored},indent=2)+'\n')
print('Three actual selector evidence REDs; exact original restoration PASS retained.')
