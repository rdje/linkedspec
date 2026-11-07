"""Qualify one missing composition input; preserve the original observation/draft."""
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import sys

BASE=Path(__file__).resolve().parent.relative_to(Path.cwd())
BEFORE=BASE/'claim-before-template-binding.json'
TEMPLATE=Path('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.13.json')
OUTPUT=Path('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.15.json')
RESULT=BASE/'template-binding-result.json'
old=json.loads(BEFORE.read_bytes())
old_inputs={row['path']:row for row in old['claims'][0]['durability']['inputs']}
assert str(TEMPLATE) not in old_inputs
assert hashlib.sha256((BASE/'publish.py').read_bytes()).hexdigest()==old_inputs[str(BASE/'publish.py')]['sha256']
assert str(TEMPLATE) in (BASE/'publish.py').read_text()
template=TEMPLATE.read_bytes()
assert template==subprocess.check_output(['git','show','12cfcaa7ae01af8451fda2d9533ac612a08d7317:'+str(TEMPLATE)])
expected=hashlib.sha256(template).hexdigest()
new=copy.deepcopy(old)
inputs=new['claims'][0]['durability']['inputs']
for path,role in ((TEMPLATE,'input'),(BEFORE,'input'),(BASE/'qualify_claim.py','producer'),(BASE/'run_qualification.py','producer')):
    assert str(path) not in {row['path'] for row in inputs}
    inputs.append(dict(path=str(path),sha256=hashlib.sha256(path.read_bytes()).hexdigest(),role=role))


def validate(record):
    rows={row['path']:row for row in record['claims'][0]['durability']['inputs']}
    assert str(TEMPLATE) in rows and rows[str(TEMPLATE)]['sha256']==expected


rejected=[]
for label,record in (('original draft missing template',old),('removed template binding',copy.deepcopy(new)),('altered template SHA',copy.deepcopy(new))):
    if label=='removed template binding':
        record['claims'][0]['durability']['inputs']=[row for row in record['claims'][0]['durability']['inputs'] if row['path']!=str(TEMPLATE)]
    if label=='altered template SHA':
        next(row for row in record['claims'][0]['durability']['inputs'] if row['path']==str(TEMPLATE))['sha256']='0'*64
    try: validate(record)
    except AssertionError: rejected.append(label)
    else: raise AssertionError('ineffective input-binding control')
validate(new)
result=dict(result='PASS',template=str(TEMPLATE),template_sha256=expected,original_draft_sha256=hashlib.sha256(BEFORE.read_bytes()).hexdigest(),rejected_controls=rejected,observation='unchanged1157 rows/five metadata controls; separate readonly replay remains valid')
body=(json.dumps(result,indent=2)+'\n').encode()
assert sys.argv[1:] in ([],['--write'])
if sys.argv[1:]:
    assert not RESULT.exists()
    RESULT.write_bytes(body)
else: assert RESULT.read_bytes()==body
inputs.append(dict(path=str(RESULT),sha256=hashlib.sha256(body).hexdigest(),role='input'))
if sys.argv[1:]:
    assert OUTPUT.read_bytes()==BEFORE.read_bytes()
    OUTPUT.write_text(json.dumps(new,indent=2)+'\n')
else: assert json.loads(OUTPUT.read_bytes())==new
print(json.dumps(result,sort_keys=True))
