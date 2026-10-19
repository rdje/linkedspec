"""Readonly semantic evidence review; --capture executes seven bounded forgeries."""
import base64
import copy
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.8/'
REG='doctrine/readme_stability/routes.jsonl'
INDEX='docs/decisions/INDEX.md'
ADR='docs/decisions/0136-finite-continuity-capacity.md'
MANIFEST='docs/history/changes/manifest.jsonl'
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
decode=lambda v:base64.b64decode(v,validate=True)
assert sys.argv[1:] in ([],['--capture'])
names=[PREFIX+'measurement.json',PREFIX+'preservation.json',PREFIX+'plan.json',PREFIX+'book.json',ADR,INDEX,MANIFEST]
def invoke():
    command=['python3',PREFIX+'review-final.py']
    run=subprocess.run(command,cwd=ROOT,capture_output=True)
    return dict(command=command,returncode=run.returncode,stdout_base64=encode(run.stdout),stderr_base64=encode(run.stderr))
def write(p,value):(ROOT/p).write_text(json.dumps(value,indent=2)+'\n')
def pack(name,value):
    data=gzip.compress(json.dumps(value,sort_keys=True,separators=(',',':')).encode(),mtime=0)
    (ROOT/(PREFIX+name)).write_bytes(data);return sha(data)
def snapshot():return {p:dict(bytes_base64=encode((ROOT/p).read_bytes()),mode=(ROOT/p).stat().st_mode&0o7777) for p in names}
target=ROOT/(PREFIX+'evidence.json')
if sys.argv[1:]:
    assert not target.exists()
    baseline=invoke();assert baseline['returncode']==0 and not decode(baseline['stderr_base64'])
    original=snapshot();original_hash=pack('evidence-originals.json.gz',original)
    rows=[]
    controls=[('missing-immutable-member','complete prior immutable census'),
        ('whole-accepted-claim','whole accepted publication custody'),
        ('extra-registry-reserve','exact finite registry delta'),
        ('proposed-authority','accepted sole authority'),
        ('displaced-index','exact sole index row placement'),
        ('forged-source-coordinate','exact source suffix/blob/range/digest'),
        ('rendered-finite-allowance','independently derived finite allowance table')]
    for name,reason in controls:
        try:
            if name=='missing-immutable-member':
                value=json.loads(decode(original[PREFIX+'measurement.json']['bytes_base64']))
                del value['preserved'][sorted(value['preserved'])[0]];write(PREFIX+'measurement.json',value)
            elif name=='whole-accepted-claim':
                value=json.loads(decode(original[PREFIX+'preservation.json']['bytes_base64']))
                claimed=json.loads(decode(value['selected'][0]['original_base64']))
                claimed['claims'][0]['statement']+=' changed'
                payload=(json.dumps(claimed,indent=2)+'\n').encode()
                value['selected'][0].update(original_base64=encode(payload),sha256=sha(payload),bytes=len(payload))
                write(PREFIX+'preservation.json',value)
            elif name in ('extra-registry-reserve','proposed-authority','displaced-index'):
                plan=json.loads(decode(original[PREFIX+'plan.json']['bytes_base64']))
                if name=='extra-registry-reserve':
                    records=[json.loads(v) for v in decode(plan['changed'][REG]['bytes_base64']).splitlines()]
                    next(v for v in records if v.get('id')=='change_history')['limits']['max_files']+=1
                    payload=b''.join(json.dumps(v,sort_keys=True,separators=(',',':')).encode()+b'\n' for v in records)
                    plan['changed'][REG]=dict(bytes_base64=encode(payload),sha256=sha(payload))
                elif name=='proposed-authority':
                    payload=decode(original[ADR]['bytes_base64'])
                    assert payload.count(b'- Status: accepted ')==1
                    payload=payload.replace(b'- Status: accepted ',b'- Status: proposed ',1)
                    (ROOT/ADR).write_bytes(payload)
                    plan['changed'][ADR]=dict(bytes_base64=encode(payload),sha256=sha(payload))
                else:
                    payload=decode(original[INDEX]['bytes_base64'])
                    row=next(v for v in payload.splitlines(True) if v.startswith(b'| [0136]'))
                    payload=payload.replace(row,b'',1)+row
                    assert len(payload)==len(decode(original[INDEX]['bytes_base64']))
                    (ROOT/INDEX).write_bytes(payload)
                    plan['changed'][INDEX]=dict(bytes_base64=encode(payload),sha256=sha(payload))
                write(PREFIX+'plan.json',plan)
            elif name=='forged-source-coordinate':
                records=[json.loads(v) for v in decode(original[MANIFEST]['bytes_base64']).splitlines()]
                records[1]['source_end_line']+=1
                (ROOT/MANIFEST).write_bytes(b''.join(json.dumps(v,sort_keys=True,separators=(',',':')).encode()+b'\n' for v in records))
            else:
                envelope=json.loads(decode(original[PREFIX+'book.json']['bytes_base64']))
                value=json.loads(gzip.decompress(decode(envelope['data'])))
                for row in value['rows']:
                    html=decode(row['html_base64'])
                    if not html:continue
                    old=b'<td>Engineering-note aggregate lines</td><td>29512</td><td>30024</td>'
                    new=b'<td>Engineering-note aggregate lines</td><td>29512</td><td>30025</td>'
                    assert html.count(old)==1
                    row['html_base64']=encode(html.replace(old,new,1))
                payload=json.dumps(value,sort_keys=True,separators=(',',':')).encode()
                envelope.update(data=encode(gzip.compress(payload,mtime=0)),bytes=len(payload),sha256=sha(payload))
                write(PREFIX+'book.json',envelope)
            changed={p:dict(bytes_base64=encode((ROOT/p).read_bytes()),sha256=sha((ROOT/p).read_bytes()),mode=(ROOT/p).stat().st_mode&0o7777)
                for p in names if (ROOT/p).read_bytes()!=decode(original[p]['bytes_base64'])}
            rejection=invoke();row=dict(name=name,expected_reason=reason,changed=changed,rejection=rejection)
            rows.append(row);pack('evidence-reached.json.gz',dict(baseline=baseline,controls=rows))
            assert rejection['returncode']!=0 and reason.encode() in decode(rejection['stderr_base64']),('semantic denial',name)
        finally:
            for p,item in original.items():(ROOT/p).write_bytes(decode(item['bytes_base64']));(ROOT/p).chmod(item['mode'])
        restored=invoke();row['restoration']=restored
        pack('evidence-reached.json.gz',dict(baseline=baseline,controls=rows))
        assert restored==baseline,('exact restoration',name)
    report=dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),originals_sha256=original_hash,
        reached_sha256=sha((ROOT/(PREFIX+'evidence-reached.json.gz')).read_bytes()),
        controls=[{k:v for k,v in row.items() if k!='changed'} for row in rows],
        scope='Seven actual semantic artifact denials with complete changed counterfactual bytes/modes, channels and exact restoration. Whole original claim, finite numeric reserve, accepted/indexed authority, exact historical coordinates and independently derived rendered allowances are distinguished before final report identities. No runtime source changes.')
    with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
else:report=json.loads(target.read_bytes())
assert report['result']=='PASS' and report['producer_sha256']==sha(Path(__file__).read_bytes())
original_raw=(ROOT/(PREFIX+'evidence-originals.json.gz')).read_bytes()
assert sha(original_raw)==report['originals_sha256']
for p,item in json.loads(gzip.decompress(original_raw)).items():assert (ROOT/p).read_bytes()==decode(item['bytes_base64']) and (ROOT/p).stat().st_mode&0o7777==item['mode']
reached_raw=(ROOT/(PREFIX+'evidence-reached.json.gz')).read_bytes();assert sha(reached_raw)==report['reached_sha256']
reached=json.loads(gzip.decompress(reached_raw));assert len(reached['controls'])==len(report['controls'])==7
for full,index in zip(reached['controls'],report['controls']):
    assert {k:v for k,v in full.items() if k!='changed'}==index and full['changed']
    assert full['rejection']['returncode']!=0 and full['expected_reason'].encode() in decode(full['rejection']['stderr_base64'])
    assert full['restoration']==reached['baseline']
    for value in full['changed'].values():assert sha(decode(value['bytes_base64']))==value['sha256']
print('Finite continuity evidence PASS:seven semantic denials;full counterfactual bytes/modes;exact restoration')
