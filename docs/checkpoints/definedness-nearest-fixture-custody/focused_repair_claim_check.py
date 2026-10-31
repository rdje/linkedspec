"""Focused existing-validator proof; no checker or record schema changes."""
import hashlib,json,re,runpy,subprocess

def git(*args):
    return subprocess.check_output(['git',*args])

def fingerprint():
    return hashlib.sha256(git('diff','--cached','--binary','--full-index')).hexdigest()

before=fingerprint()
ns=runpy.run_path('tools/check_claim_verification.py')
ns['self_test']()
files=ns['index_files']()
owner='TYPE-REFERENCE-BOOK.1.2.23.3.67.6'
path='docs/claims/'+owner+'.json'

def read_input(source,revision=None):
    ns['path'](source)
    assert revision is None,'This focused capture requires live retained inputs'
    mode,blob=files[source]
    assert mode in ('100644','100755')
    return git('cat-file','blob',blob)

def no_gap_owner(value):
    raise AssertionError('This fully checked claim must not add a gap: '+value)

count,gaps=ns['validate'](ns['strict_json'](read_input(path)),path,read_input,no_gap_owner)
assert count==1 and gaps==0
selected=subprocess.check_output(['perl','tools/check_task_verification_fields.pl','--owner'],text=True).strip()
assert selected==owner
task=read_input('docs/tasks/TYPE-REFERENCE-BOOK.md').decode()
node=re.search(r'^- ID: `'+re.escape(owner)+r'`\n(.*?)(?=^- ID:|^## |\Z)',task,re.M|re.S)[1]
assert re.findall(r'^  Claim verification: (.+)$',node,re.M)==['`'+path+'`']
changed=set(git('diff','--cached','--name-only').decode().splitlines())
hits=[]
for name in git('ls-tree','-r','--name-only','HEAD','docs/claims/').decode().splitlines():
    if not name.endswith('.json'):continue
    for claim in json.loads(git('show','HEAD:'+name))['claims']:
        durability=claim['durability']
        if durability.get('mode')=='live':
            hits.extend((name,item['path']) for item in durability['inputs'] if item['path'] in changed)
assert not hits,hits
assert fingerprint()==before
print('Focused claim verification: PASS; existing validator/self-tests, selected owner/declaration, new record1/claim1/gaps0, all declared input bytes, pre-existing live input intersections none; unchanged staged fingerprint '+before)
print('Historical collection revalidation remains canonical admission/push work; no full-collection pass claimed.')
