"""Readonly actual-channel evidence; --capture executes four coherent forgeries."""
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
    data=gzip.compress(json.dumps(value,sort_keys=True,separators=(',',':')).encode(),mtime=0)
    (ROOT/(PREFIX+name)).write_bytes(data);return sha(data)
def invoke():
    command=['python3',PREFIX+'actual-review.py']
    run=subprocess.run(command,cwd=ROOT,capture_output=True)
    return dict(command=command,returncode=run.returncode,stdout_base64=encode(run.stdout),stderr_base64=encode(run.stderr))
target=ROOT/(PREFIX+'metadata-evidence.json');actual=ROOT/(PREFIX+'actual.json')
if sys.argv[1:]:
    assert not target.exists()
    original=dict(bytes_base64=encode(actual.read_bytes()),mode=actual.stat().st_mode&0o7777)
    original_hash=pack('metadata-evidence-original.json.gz',original)
    baseline=invoke();assert baseline['returncode']==0 and not decode(baseline['stderr_base64'])
    controls=[('failed-producer','actual producer exit'),('missing-channel','both complete actual channels'),
        ('coherent-stdout-forgery','actual complete stdout artifact'),('coherent-producer-forgery','actual producer source custody')]
    rows=[]
    for name,reason in controls:
        try:
            value=json.loads(decode(original['bytes_base64']))
            if name=='failed-producer':value['runs'][0]['exit']=1
            elif name=='missing-channel':del value['runs'][1]['stderr']
            elif name=='coherent-stdout-forgery':
                out=value['runs'][0]['stdout'];data=json.loads(gzip.decompress(decode(out['gzip_base64'])))
                data['artifact_files']+=1
                payload=(json.dumps(data,indent=2,sort_keys=True)+'\n').encode()
                value['runs'][0]['stdout']=dict(bytes=len(payload),sha256=sha(payload),gzip_base64=encode(gzip.compress(payload,mtime=0)))
            else:
                p=sorted(value['inputs'])[0];value['inputs'][p]='0'*64
                for row in value['runs']:
                    row['inputs_before'][p]='0'*64;row['inputs_after'][p]='0'*64
            changed=(json.dumps(value,indent=2)+'\n').encode();actual.write_bytes(changed)
            rejection=invoke();row=dict(name=name,expected_reason=reason,changed_base64=encode(changed),changed_sha256=sha(changed),rejection=rejection)
            rows.append(row);pack('metadata-evidence-reached.json.gz',dict(baseline=baseline,controls=rows))
            assert rejection['returncode']!=0 and reason.encode() in decode(rejection['stderr_base64']),('actual channel denial',name)
        finally:actual.write_bytes(decode(original['bytes_base64']));actual.chmod(original['mode'])
        row['restoration']=invoke();pack('metadata-evidence-reached.json.gz',dict(baseline=baseline,controls=rows))
        assert row['restoration']==baseline
    record=dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),original_sha256=original_hash,
        reached_sha256=sha((ROOT/(PREFIX+'metadata-evidence-reached.json.gz')).read_bytes()),
        controls=[{k:v for k,v in row.items() if k not in ('changed_base64',)} for row in rows],
        scope='Four actual reader denials distinguish failed producers, lost complete channels, a coherently rehashed forged stdout and coherent initial/before/after producer hashes. Full changed bytes/channels and exact restoration are retained. Dated metadata and original census/live-review producers remain untouched.')
    with target.open('x') as output:output.write(json.dumps(record,indent=2)+'\n')
else:record=json.loads(target.read_bytes())
assert record['result']=='PASS' and record['producer_sha256']==sha(Path(__file__).read_bytes())
original_raw=(ROOT/(PREFIX+'metadata-evidence-original.json.gz')).read_bytes();assert sha(original_raw)==record['original_sha256']
original=json.loads(gzip.decompress(original_raw));assert actual.read_bytes()==decode(original['bytes_base64']) and actual.stat().st_mode&0o7777==original['mode']
reached_raw=(ROOT/(PREFIX+'metadata-evidence-reached.json.gz')).read_bytes();assert sha(reached_raw)==record['reached_sha256']
reached=json.loads(gzip.decompress(reached_raw));assert len(reached['controls'])==len(record['controls'])==4
for row,index in zip(reached['controls'],record['controls']):
    assert {k:v for k,v in row.items() if k!='changed_base64'}==index
    assert sha(decode(row['changed_base64']))==row['changed_sha256']
    assert row['rejection']['returncode']!=0 and row['expected_reason'].encode() in decode(row['rejection']['stderr_base64'])
    assert row['restoration']==reached['baseline']
print('Metadata channel evidence PASS:four actual denials;complete changed bytes/channels;exact restoration')
