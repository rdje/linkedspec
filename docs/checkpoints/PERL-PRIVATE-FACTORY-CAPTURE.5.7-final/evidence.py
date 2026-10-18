"""Readonly final semantic artifact review; --capture executes bounded forgeries."""
import base64
import copy
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/'
OBJECT='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-object/'
sha=lambda v:hashlib.sha256(v).hexdigest()
decode=lambda v:base64.b64decode(v,validate=True)
encode=lambda v:base64.b64encode(v).decode()
assert sys.argv[1:] in ([],['--capture'])
target=ROOT/(PREFIX+'evidence.json')
names=[PREFIX+p for p in ('after-native.json','after-native-data.json.gz','consumers.json','book.json')]
names += [OBJECT+p for p in ('initial-claim.json','after.json','after-data.json.gz')]
def invoke():
    command=['python3',PREFIX+'review.py']
    result=subprocess.run(command,cwd=ROOT,capture_output=True)
    return dict(command=command,returncode=result.returncode,stdout_base64=encode(result.stdout),stderr_base64=encode(result.stderr))
def write(path,value):
    (ROOT/path).write_text(json.dumps(value,indent=2)+'\n')
if sys.argv[1:]:
    assert not target.exists()
    baseline=invoke()
    assert baseline['returncode']==0 and not decode(baseline['stderr_base64'])
    originals={p:dict(bytes_base64=encode((ROOT/p).read_bytes()),mode=(ROOT/p).stat().st_mode&0o7777) for p in names}
    archive=ROOT/(PREFIX+'evidence-originals.json.gz')
    with archive.open('xb') as output:output.write(gzip.compress(json.dumps(originals,sort_keys=True).encode(),mtime=0))
    rows=[]
    controls=[('native-error-effect','complete native ordinary ledger'),
        ('opaque-reference-grant','actual native callback selection'),
        ('fixed-provider-attempt-loss','observed in-scope provider registration attempts'),
        ('missing-selection-observation','complete selection observation population'),
        ('whole-logical-claim','whole logical publication custody'),
        ('missing-consumer','complete supplied suite selection'),
        ('rendered-provider-key','native-derived provider table'),
        ('object-equality-effect','complete native package-object effects'),
        ('object-facade-grant','object aliases cannot grant facade authority'),
        ('rendered-object-effect','native-derived object-effects table')]
    for name,reason in controls:
        try:
            if name in ('native-error-effect','opaque-reference-grant','fixed-provider-attempt-loss','missing-selection-observation'):
                path=PREFIX+'after-native-data.json.gz'
                data=json.loads(gzip.decompress(decode(originals[path]['bytes_base64'])))
                native=data[1]['observation']['rows']
                if name=='native-error-effect':native[0]['successful_error']='forged-error-effect'
                elif name=='opaque-reference-grant':
                    row=next(r for r in native if r['label']=='copied-name-trim_action_ir_value')
                    selected=next(v for v in row['authority']['values'][0] if v['key']=='trim_action_ir_value')
                    assert selected['selected']==0;selected['selected']=1
                elif name=='fixed-provider-attempt-loss':
                    row=next(r for r in native if r['label']=='custom-native-alias' and r['context']=='scalar')
                    assert len(row['authority']['registrations'])==1;row['authority']['registrations']=[]
                else:
                    assert len(native[0]['authority']['values'])==1;native[0]['authority']['values']=[]
                data[1]['stdout_base64']=encode(json.dumps(data[1]['observation'],sort_keys=True,separators=(',',':')).encode()+b'\n')
                data[2]=copy.deepcopy(data[1])
                payload=gzip.compress(json.dumps(data,sort_keys=True,separators=(',',':')).encode(),mtime=0)
                (ROOT/path).write_bytes(payload)
                index=json.loads(decode(originals[PREFIX+'after-native.json']['bytes_base64']))
                index.update(data_sha256=sha(payload),warm_raw_recurrence=True,cold_raw_recurrence=data[3]==data[4])
                write(PREFIX+'after-native.json',index)
            elif name=='whole-logical-claim':
                value=json.loads(decode(originals[OBJECT+'initial-claim.json']['bytes_base64']))
                value['claims'][0]['statement']+=' altered';write(OBJECT+'initial-claim.json',value)
            elif name=='missing-consumer':
                value=json.loads(decode(originals[PREFIX+'consumers.json']['bytes_base64']))
                value['command']=value['command'][:-1];write(PREFIX+'consumers.json',value)
            elif name in ('object-equality-effect','object-facade-grant'):
                path=OBJECT+'after-data.json.gz'
                data=json.loads(gzip.decompress(decode(originals[path]['bytes_base64'])))
                row=next(r for r in data[1]['observation']['rows'] if r['owner'].endswith('ControlFlow')
                    and r['variant']=='eq-true' and r['context']=='scalar' and r['stage']=='current-factory')
                if name=='object-equality-effect':row['ordinary']['equal_calls']+=1
                else:
                    entry=next(v for v in row['authority'] if v['key']=='trim_action_ir_value')
                    assert entry['selected']==0;entry['selected']=1
                data[1]['stdout_base64']=encode(json.dumps(data[1]['observation'],sort_keys=True,separators=(',',':')).encode()+b'\n')
                data[2]=copy.deepcopy(data[1])
                payload=gzip.compress(json.dumps(data,sort_keys=True,separators=(',',':')).encode(),mtime=0)
                (ROOT/path).write_bytes(payload)
                index=json.loads(decode(originals[OBJECT+'after.json']['bytes_base64']))
                index['data_sha256']=sha(payload);write(OBJECT+'after.json',index)
            else:
                envelope=json.loads(decode(originals[PREFIX+'book.json']['bytes_base64']))
                book=json.loads(gzip.decompress(decode(envelope['data'])))
                for row in book['rows']:
                    html=decode(row['target_html_base64'])
                    if not html:continue
                    if name=='rendered-provider-key':
                        old=b'<td><code>extract_array_symbol_name</code></td><td>Fixed provider and actual retained definition</td>'
                        new=b'<td><code>extract_hash_symbol_name</code></td><td>Fixed provider and actual retained definition</td>'
                    else:
                        old=b'<td>ControlFlow</td><td>0</td><td>0</td><td>0</td>'
                        new=b'<td>ControlFlow</td><td>1</td><td>0</td><td>0</td>'
                    assert html.count(old)==1
                    row['target_html_base64']=encode(html.replace(old,new,1))
                payload=json.dumps(book,sort_keys=True,separators=(',',':')).encode()
                envelope.update(data=encode(gzip.compress(payload,mtime=0)),bytes=len(payload),sha256=sha(payload))
                write(PREFIX+'book.json',envelope)
            changed={p:sha((ROOT/p).read_bytes()) for p in names if (ROOT/p).read_bytes()!=decode(originals[p]['bytes_base64'])}
            rejection=invoke();row=dict(name=name,expected_reason=reason,changed=changed,rejection=rejection)
            rows.append(row);write(PREFIX+'evidence-reached.json',dict(baseline=baseline,controls=rows))
            assert rejection['returncode']!=0 and reason.encode() in decode(rejection['stderr_base64']), ('semantic denial',name)
        finally:
            for path,item in originals.items():
                (ROOT/path).write_bytes(decode(item['bytes_base64']));(ROOT/path).chmod(item['mode'])
        restored=invoke();row['restoration']=restored
        write(PREFIX+'evidence-reached.json',dict(baseline=baseline,controls=rows))
        assert restored==baseline
    report=dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),originals_sha256=sha(archive.read_bytes()),
        baseline=baseline,controls=rows,
        scope='Ten actual semantic artifact denials with exact byte/mode restoration. Native/object data forgeries retain matching raw/parsed JSON and recurrences while updating outer hashes. Independent native-builder, provider/completeness, preserved-whole-publication and exact command oracles reject them. Both rendered tables are checked against actual native observations before report identity comparison. Runtime sources remain untouched.')
    with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
else:report=json.loads(target.read_bytes())
assert report['result']=='PASS' and report['producer_sha256']==sha(Path(__file__).read_bytes())
payload=(ROOT/(PREFIX+'evidence-originals.json.gz')).read_bytes();assert sha(payload)==report['originals_sha256']
for path,item in json.loads(gzip.decompress(payload)).items():
    assert (ROOT/path).read_bytes()==decode(item['bytes_base64']) and (ROOT/path).stat().st_mode&0o7777==item['mode']
assert len(report['controls'])==10
for row in report['controls']:
    assert row['changed'] and row['rejection']['returncode']!=0
    assert row['expected_reason'].encode() in decode(row['rejection']['stderr_base64'])
    assert row['restoration']==report['baseline']
print('Corrected default evidence PASS:10 semantic artifact denials;exact byte/mode restoration')
