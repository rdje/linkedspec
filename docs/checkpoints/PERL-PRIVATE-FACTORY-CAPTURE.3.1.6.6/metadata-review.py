"""Actual production validator controls for historical producer provenance; default readonly."""
import base64, copy, hashlib, importlib.util, json, subprocess, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
DIR='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6/'
BASE='d8418423e7461235280e9a34b9d90f4571fc9490'
SOURCE='tools/check_claim_verification.py'
PUB='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-publish-claim.py'
CLAIM='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.json'
read=lambda p:(ROOT/p).read_bytes()
sha=lambda raw:hashlib.sha256(raw).hexdigest()
channel=lambda raw:{'base64':base64.b64encode(raw).decode(),'bytes':len(raw),'sha256':sha(raw)}
def old(p): return subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)
spec=importlib.util.spec_from_file_location('actual_claim_validator',ROOT/SOURCE)
m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m)

def models():
    original=json.loads(read(DIR+'original-claim.json'))
    fixed=copy.deepcopy(original)
    entries=fixed['claims'][1]['durability']['inputs']
    row=next(e for e in entries if e['path']=='scripts/check_readme_routing_pressure.pl'); assert row['role']=='input'; row['role']='producer'
    fixed['claims'][2]['durability']['inputs'].append({'path':PUB,'sha256':sha(old(PUB)),'role':'producer'})
    assert [sum(e['role']=='producer' for e in c['durability']['inputs']) for c in original['claims'][1:]]==[0,0]
    return original,fixed

def record(name):
    original,fixed=models(); which,index=name.split('-'); assert which in ('original','repaired') and index in ('1','2')
    chosen=original if which=='original' else fixed
    return {'version':1,'owner':chosen['owner'],'claims':[chosen['claims'][int(index)]]}

def read_input(source,revision=None):
    m.path(source); m.require(revision is not None,'these controls require historical inputs')
    rows=m.git('ls-tree','-z',revision,'--',source).split(b'\0')
    m.require(len(rows)==2 and rows[0],'missing historical input: '+source)
    header,name=rows[0].split(b'\t',1); mode,kind,blob=header.decode('ascii').split()
    m.require(mode in ('100644','100755') and kind=='blob' and name.decode()==source,'historical regular tracked input')
    return m.git('cat-file','blob',blob)

def no_gap(owner): raise ValueError('unexpected gap owner: '+owner)
mode=sys.argv[1] if len(sys.argv)==2 else 'review'
if mode.startswith(('original-','repaired-')):
    data=record(mode); m.validate(data,CLAIM,read_input,no_gap)
    print('Actual production historical provenance PASS:',mode)
    raise SystemExit(0)
assert mode in ('capture','review')
names=['original-1','repaired-1','original-2','repaired-2']
def run(name):
    args=['python3',DIR+'metadata-review.py',name]; p=subprocess.run(args,cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    return {'name':name,'record':channel((json.dumps(record(name),indent=2)+'\n').encode()),'args':args,'exit_code':p.returncode,'stdout':channel(p.stdout),'stderr':channel(p.stderr)}
if mode=='capture':
    assert not (ROOT/(DIR+'producer-role-controls.json')).exists()
    rows=[]
    for name in names:
        rows.append(run(name)); (ROOT/(DIR+'producer-role-reached.json')).write_text(json.dumps({'rows':rows},indent=2)+'\n')
        row=rows[-1]
        if name.startswith('original'): assert row['exit_code']!=0 and b'checked durability requires a tracked producer input' in base64.b64decode(row['stderr']['base64'])
        else: assert row['exit_code']==0 and row['stderr']['bytes']==0
    (ROOT/(DIR+'producer-role-controls.json')).write_text(json.dumps({'producer_sha256':sha(Path(__file__).read_bytes()),'validator_sha256':sha(read(SOURCE)),'rows':rows},indent=2)+'\n')
data=json.loads(read(DIR+'producer-role-controls.json')); assert json.loads(read(DIR+'producer-role-reached.json'))=={'rows':data['rows']}
assert data['producer_sha256']==sha(Path(__file__).read_bytes()) and data['validator_sha256']==sha(read(SOURCE))
assert [row['name'] for row in data['rows']]==names
for row in data['rows']:
    assert row['record']==channel((json.dumps(record(row['name']),indent=2)+'\n').encode())
    assert row['args']==['python3',DIR+'metadata-review.py',row['name']]
    for part in ('stdout','stderr'): assert channel(base64.b64decode(row[part]['base64']))==row[part]
    if row['name'].startswith('original'): assert row['exit_code']!=0 and b'checked durability requires a tracked producer input' in base64.b64decode(row['stderr']['base64'])
    else: assert row==run(row['name'])
prior=read(DIR+'metadata-before-claim.json'); entries=json.loads(prior)['claims'][0]['durability']['inputs']; assert len(entries)==362
oldpub=DIR+'publish.py'
for e in entries:
    path=DIR+'metadata-before-publisher.py' if e['path']==oldpub else e['path']
    assert sha(read(path))==e['sha256'],'original362 metadata input: '+e['path']
assert json.loads(read(DIR+'metadata-preservation.json'))=={'bindings_verified':362,'claim_sha256':sha(prior),'publisher_sha256':sha(read(DIR+'metadata-before-publisher.py')),'disclosure':'Exact original362-input closure preserved before current publisher repair. All361 other inputs stay exact; the prior publisher will relocate byte-identically. Two historical checked records need actual tracked producer provenance; no original hash or runtime observation is refreshed.'}
print('Metadata provenance review PASS: actual historical producer2 RED/2 GREEN; prior362 hashes/361 current/one exact publisher relocation')
