"""Readonly custody controls; --capture retains four actual forgeries/restorations."""
import base64
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/REPO-HYGIENE.19/'
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
decode=lambda v:base64.b64decode(v,validate=True)
assert sys.argv[1:] in ([],['--capture'])
def pack(name,value):
    data=gzip.compress(json.dumps(value,sort_keys=True).encode(),mtime=0)
    (ROOT/(PREFIX+name)).write_bytes(data);return sha(data)
def invoke(reader):
    command=['python3',PREFIX+reader];run=subprocess.run(command,cwd=ROOT,capture_output=True)
    return dict(command=command,returncode=run.returncode,stdout_base64=encode(run.stdout),stderr_base64=encode(run.stderr))
target=ROOT/(PREFIX+'evidence.json')
if sys.argv[1:]:
    assert not target.exists()
    originals={n:dict(bytes_base64=encode((ROOT/(PREFIX+n)).read_bytes()),mode=(ROOT/(PREFIX+n)).stat().st_mode&0o7777) for n in ('preservation.json','book.json')}
    original_hash=pack('evidence-originals.json.gz',originals)
    baselines={n:invoke(n) for n in ('review-final.py','book-review.py')}
    assert all(v['returncode']==0 and not decode(v['stderr_base64']) for v in baselines.values())
    cases=[('missing-namespace','complete accepted claim namespace','review-final.py'),
        ('coherent-whole-claim','whole accepted claim bytes','review-final.py'),
        ('missing-original-binding','complete original binding population','review-final.py'),
        ('coherent-rendered-count','independently derived reported warning table','book-review.py')]
    rows=[]
    for name,reason,reader in cases:
        file='book.json' if reader=='book-review.py' else 'preservation.json'
        try:
            value=json.loads(decode(originals[file]['bytes_base64']))
            if name=='missing-namespace':value['census'].pop()
            elif name=='coherent-whole-claim':
                chosen=value['selected'][0];claim=json.loads(decode(chosen['original_base64']))
                claim['claims'][0]['statement']+=' forged custody'
                changed=(json.dumps(claim,indent=2)+'\n').encode()
                chosen.update(original_base64=encode(changed),sha256=sha(changed),bytes=len(changed))
            elif name=='missing-original-binding':value['selected'][0]['hits'][0]['bindings'].pop(next(iter(value['selected'][0]['hits'][0]['bindings'])))
            else:
                book=json.loads(gzip.decompress(decode(value['data'])))
                for row in book['rows']:
                    if row['name']=='missing-summary':continue
                    html=decode(row['html_base64']);assert b'7093' in html
                    row['html_base64']=encode(html.replace(b'7093',b'7094'))
                changed=json.dumps(book,sort_keys=True,separators=(',',':')).encode()
                value.update(data=encode(gzip.compress(changed,mtime=0)),bytes=len(changed),sha256=sha(changed))
            changed=(json.dumps(value,indent=2)+'\n').encode();(ROOT/(PREFIX+file)).write_bytes(changed)
            rejected=invoke(reader)
            row=dict(name=name,path=PREFIX+file,expected_reason=reason,changed_base64=encode(changed),changed_sha256=sha(changed),rejection=rejected)
            rows.append(row);pack('evidence-reached.json.gz',dict(baselines=baselines,controls=rows))
            assert rejected['returncode']!=0 and reason.encode() in decode(rejected['stderr_base64']),('actual distinguishing denial',name)
        finally:
            for n,item in originals.items():
                (ROOT/(PREFIX+n)).write_bytes(decode(item['bytes_base64']));(ROOT/(PREFIX+n)).chmod(item['mode'])
        row['restoration']=invoke(reader)
        pack('evidence-reached.json.gz',dict(baselines=baselines,controls=rows))
        assert row['restoration']==baselines[reader],('exact restoration',name)
        print('Custody control PASS:',name,flush=True)
    report=dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),originals_sha256=original_hash,
        reached_sha256=sha((ROOT/(PREFIX+'evidence-reached.json.gz')).read_bytes()),
        controls=[{k:v for k,v in row.items() if k!='changed_base64'} for row in rows],
        scope='Four actual semantic denials: incomplete fixed accepted namespace, coherently rehashed whole claim, omitted original binding, and coherently repacked rendered warning count. Complete changed bytes and original modes, both actual channels and byte-exact restored PASS remain retained. No producer or original observation is refreshed.')
    with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
else:report=json.loads(target.read_bytes())
assert report['result']=='PASS' and report['producer_sha256']==sha(Path(__file__).read_bytes())
original_raw=(ROOT/(PREFIX+'evidence-originals.json.gz')).read_bytes();assert sha(original_raw)==report['originals_sha256']
for n,item in json.loads(gzip.decompress(original_raw)).items():assert (ROOT/(PREFIX+n)).read_bytes()==decode(item['bytes_base64']) and (ROOT/(PREFIX+n)).stat().st_mode&0o7777==item['mode']
reached_raw=(ROOT/(PREFIX+'evidence-reached.json.gz')).read_bytes();assert sha(reached_raw)==report['reached_sha256']
reached=json.loads(gzip.decompress(reached_raw));assert len(reached['controls'])==len(report['controls'])==4
for full,index in zip(reached['controls'],report['controls']):
    assert {k:v for k,v in full.items() if k!='changed_base64'}==index
    assert sha(decode(full['changed_base64']))==full['changed_sha256']
    assert full['rejection']['returncode']!=0 and full['expected_reason'].encode() in decode(full['rejection']['stderr_base64'])
    assert full['restoration']==reached['baselines'][full['restoration']['command'][-1].split('/')[-1]]
print('Custody evidence PASS:four actual denials/full counterfactual bytes/channels/exact restoration')
