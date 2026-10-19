"""Preserve the whole workflow chapter and derive explicit-selection teaching."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BASE='858eba97c89239d187765c4af9ad18057d28a1b0'
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
CHAPTER='docs/linkedspec-book/src/development/documentation-workflow.md'
sha=lambda v:hashlib.sha256(v).hexdigest()
target=ROOT/(PREFIX+'book-preparation.json');assert not target.exists()
inventory=json.loads((ROOT/(PREFIX+'inventory.json')).read_bytes())
selection=json.loads((ROOT/(PREFIX+'selection.json')).read_bytes())
audit=json.loads((ROOT/(PREFIX+'audit-final.json')).read_bytes())
assert inventory['result']==selection['result']==audit['result']=='PASS'
original=subprocess.check_output(['git','show',BASE+':'+CHAPTER],cwd=ROOT)
assert (ROOT/CHAPTER).read_bytes()==original
text=original.decode()
old=('The current verification entrypoint checks this dated retention and reported-output\n'
    'review and preserves the complete 550-input finite-capacity publication and its actual\n'
    'successful baseline at `e953f69a9`. The complete 565-input mixed-default/package-object\n')
new=('The current verification entrypoint checks this explicit supplied fixture selection\n'
    'and preserves the complete 175-input retained-review publication and its actual successful\n'
    'baseline at `858eba97c`. That review retains the complete 550-input finite-capacity\n'
    'publication at `e953f69a9`. The complete 565-input mixed-default/package-object\n')
assert text.count(old)==1;text=text.replace(old,new,1)
old='retention review changes no budget:'
assert text.count(old)==1;text=text.replace(old,'fixture admission changes no budget or DSL semantics:',1)
old='bash tools/run_python_project_data.sh docs/checkpoints/REPO-HYGIENE.19/publish.py'
assert text.count(old)==1;text=text.replace(old,'bash tools/run_python_project_data.sh '+PREFIX+'publish.py',1)
rows=[]
for label,paths in [('Supplied suites',inventory['suites']),('Supplied test helpers',inventory['helpers'])]:
    values=[str(len(set(paths)&set(inventory['original_selection'][key]))) for key in ('tracked','syntax','execution')]
    rows.append('| '+label+' | '+str(len(paths))+' | '+values[0]+' | '+values[1]+' | '+(values[2] if label=='Supplied suites' else '—')+' |')
labels={'healthy':'Complete block','missing-suite':'Suite omitted','missing-helper':'Helper omitted','duplicate-suite':'Suite duplicated','disabled-execution':'Execution disabled'}
cases=[]
for row in selection['rows']:
    cases.append('| '+labels[row['name']]+' | '+str(len(row['syntax']))+' | '+(str(row['files']) if row['files'] is not None else '—')+' | '+str(row['returncode'])+' | '+('PASS' if all(row['oracle'].values()) else 'RED')+' |')
section=('### Explicit fixture selection\n\n'
    'The canonical runner selects an explicit supplied population. Adding a file alone\n'
    'does not add its test execution. The retained original direct-command inventory is:\n\n'
    '| Population | Paths | Original presence | Original syntax | Original direct prove |\n'
    '| --- | --- | --- | --- | --- |\n'+'\n'.join(rows)+'\n\n'
    'These counts describe literal tracked-file, syntax and prove commands; indirect\n'
    'coverage was not inventoried. The admitted block lists all 91 suites and 46 test\n'
    'helpers, checks each of the 137 paths through Git presence and Perl syntax, then\n'
    'runs all 91 suites. One suite is a historical checkpoint fixture. All 363 supplied\n'
    'input bytes and modes stay unchanged. The complete selected run passes 30394 assertions.\n\n'
    '| Actual selected-block experiment | Syntax paths | Suites | Shell exit | Population oracle |\n'
    '| --- | --- | --- | --- | --- |\n'+'\n'.join(cases)+'\n\n'
    'Each row retains the actual Bash script and full command channels. A successful\n'
    'shell exit alone permits missing or extra work; independent ordered syntax and\n'
    'test-path populations plus the harness summary distinguish it. The recurring\n'
    'historical auditor removes only the exact 150-line insertion before its older\n'
    'inverses and still requires every original runner byte. Its per-path mutations\n'
    'operate within that block, because six names also occur in older commands.\n\n'
    'Keep future tests task-owned and explicitly registered. Exact staged canonical\n'
    'CI and normal hooks govern admission. Pipeline scope and broader private/mapped\n'
    'execution retain their separate owners.\n\n')
marker='Preserve any live evidence that binds the root or book before changing them.\n'
assert text.count(marker)==1;text=text.replace(marker,section+marker,1)
value=text.encode()
record=dict(result='PASS',base=BASE,producer_sha256=sha(Path(__file__).read_bytes()),chapter=CHAPTER,
    original_base64=base64.b64encode(original).decode(),original_sha256=sha(original),current_sha256=sha(value),
    inputs={PREFIX+n:sha((ROOT/(PREFIX+n)).read_bytes()) for n in ('inventory.json','selection.json','audit-final.json')},
    scope='One workflow overlay preserves the whole accepted chapter, updates its current readonly route/predecessor and derives every supplied-population and actual fault table cell from retained observations. Existing capacity/warning/native teaching stays exact; no new language or capacity admission.')
with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
(ROOT/CHAPTER).write_bytes(value)
print('Book preparation PASS:whole original retained;two actual selection tables/current route;no native teaching change')
