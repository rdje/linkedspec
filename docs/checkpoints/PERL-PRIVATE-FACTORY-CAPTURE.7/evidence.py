"""Readonly artifact denials; --capture retains six coherent corruptions/restorations."""
import base64
import gzip
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/'
sha=lambda v:hashlib.sha256(v).hexdigest()
encode=lambda v:base64.b64encode(v).decode()
decode=lambda v:base64.b64decode(v,validate=True)
assert sys.argv[1:] in ([],['--capture'])
def packed(value):return gzip.compress(json.dumps(value,sort_keys=True).encode(),mtime=0)
def save(name,value):
    data=packed(value);(ROOT/(PREFIX+name)).write_bytes(data);return sha(data)
def write(name,value):
    data=(json.dumps(value,indent=2)+'\n').encode();(ROOT/(PREFIX+name)).write_bytes(data);return data
def invoke(reader):
    command=['python3',PREFIX+reader];run=subprocess.run(command,cwd=ROOT,capture_output=True)
    return dict(command=command,returncode=run.returncode,stdout_base64=encode(run.stdout),stderr_base64=encode(run.stderr))
target=ROOT/(PREFIX+'evidence.json')
if sys.argv[1:]:
    assert not target.exists()
    names=('preservation.json','selection.json','selection-reached.json.gz','selection-final-reached.json.gz',
        'selection-native-failure.json','audit-final.json','audit-final-channels.json.gz','audit-metadata-failure.json',
        'audit-final-inputs.json.gz','book.json')
    originals={n:dict(bytes_base64=encode((ROOT/(PREFIX+n)).read_bytes()),mode=(ROOT/(PREFIX+n)).stat().st_mode&0o7777) for n in names}
    original_hash=save('evidence-originals.json.gz',originals)
    readers=('review-current.py','review-selection.py','review-audit.py','book-review.py')
    baselines={n:invoke(n) for n in readers}
    assert all(v['returncode']==0 and not decode(v['stderr_base64']) for v in baselines.values())
    cases=[('whole-predecessor','review-current.py','whole accepted predecessor claim'),
        ('coherent-positive-summary','review-selection.py','positive complete supplied population'),
        ('coherent-missing-syntax','review-selection.py','complete expected syntax population'),
        ('omitted-actual-fault','review-selection.py','complete actual selected case population'),
        ('coherent-evolution-count','review-audit.py','all actual evolution source populations'),
        ('coherent-rendered-selection','book-review.py','independently derived actual selection fault table')]
    rows=[]
    for name,reader,reason in cases:
        try:
            if name=='whole-predecessor':
                value=json.loads(decode(originals['preservation.json']['bytes_base64']));chosen=value['selected'][0]
                claim=json.loads(decode(chosen['original_base64']));claim['claims'][0]['statement']+=' forged'
                data=(json.dumps(claim,indent=2)+'\n').encode()
                chosen.update(original_base64=encode(data),sha256=sha(data),bytes=len(data));write('preservation.json',value)
            elif name in ('coherent-positive-summary','coherent-missing-syntax','omitted-actual-fault'):
                record=json.loads(decode(originals['selection.json']['bytes_base64']))
                actual=json.loads(gzip.decompress(decode(originals['selection-final-reached.json.gz']['bytes_base64'])))
                if name=='omitted-actual-fault':
                    actual.pop();record['actors'].pop('disabled-execution')
                else:
                    row=actual[0]
                    if name=='coherent-positive-summary':
                        out=decode(row['stdout_base64']);assert out.count(b'Files=91, Tests=30394,')==1
                        row['stdout_base64']=encode(out.replace(b'Files=91, Tests=30394,',b'Files=90, Tests=30394,',1))
                        row['files']=90;row['oracle']['complete_summary']=False
                    else:
                        helper='t/actionir_receiver_scalar_copy_probe.pl'
                        err=decode(row['stderr_base64']);line=(helper+' syntax OK\n').encode();assert err.count(line)==1
                        row['stderr_base64']=encode(err.replace(line,b'',1));row['syntax'].remove(helper);row['oracle']['syntax_population']=False
                    first=actual[:4];first_hash=save('selection-reached.json.gz',first)
                    record['first_reached_sha256']=first_hash
                    failure=json.loads(decode(originals['selection-native-failure.json']['bytes_base64']))
                    failure['original_reached_sha256']=first_hash;write('selection-native-failure.json',failure)
                record['reached_sha256']=save('selection-final-reached.json.gz',actual)
                record['rows']=[{k:v for k,v in row.items() if k not in ('stdout_base64','stderr_base64')} for row in actual]
                write('selection.json',record)
            elif name=='coherent-evolution-count':
                record=json.loads(decode(originals['audit-final.json']['bytes_base64']))
                channels=json.loads(gzip.decompress(decode(originals['audit-final-channels.json.gz']['bytes_base64'])))
                actual=json.loads(decode(channels['stdout_base64']))
                actual['audit_controls']['governance_mutations_by_source']['tools/run_ci_local.sh']-=1
                actual['audit_controls']['governance_mutations_rejected']-=1
                channels['stdout_base64']=encode(json.dumps(actual,sort_keys=True).encode())
                record['channels_sha256']=save('audit-final-channels.json.gz',channels)
                record['audit_controls']=actual['audit_controls']
                failure=json.loads(decode(originals['audit-metadata-failure.json']['bytes_base64']))
                failure['actual_channels_sha256']=record['channels_sha256'];write('audit-metadata-failure.json',failure)
                capsule=json.loads(gzip.decompress(decode(originals['audit-final-inputs.json.gz']['bytes_base64'])))
                for n in ('audit-final-channels.json.gz','audit-metadata-failure.json'):
                    p=PREFIX+n;data=(ROOT/p).read_bytes();mode=capsule[p]['mode']
                    capsule[p]=dict(sha256=sha(data),mode=mode,bytes_base64=encode(data))
                    record['inputs'][p]=dict(sha256=sha(data),mode=mode)
                record['capsule_sha256']=save('audit-final-inputs.json.gz',capsule);write('audit-final.json',record)
            else:
                record=json.loads(decode(originals['book.json']['bytes_base64']))
                book=json.loads(gzip.decompress(decode(record['data'])))
                for row in book['rows']:
                    if row['name']=='missing-summary':continue
                    html=decode(row['html_base64'])
                    html,count=re.subn(rb'(<td>Suite omitted</td>\s*<td>136</td>\s*<td>)90(</td>)',rb'\g<1>91\2',html)
                    assert count==1;row['html_base64']=encode(html)
                data=json.dumps(book,sort_keys=True,separators=(',',':')).encode()
                record.update(data=encode(gzip.compress(data,mtime=0)),bytes=len(data),sha256=sha(data));write('book.json',record)
            changed={n:dict(bytes_base64=encode((ROOT/(PREFIX+n)).read_bytes()),sha256=sha((ROOT/(PREFIX+n)).read_bytes()),mode=(ROOT/(PREFIX+n)).stat().st_mode&0o7777)
                for n in names if (ROOT/(PREFIX+n)).read_bytes()!=decode(originals[n]['bytes_base64'])}
            rejected=invoke(reader);row=dict(name=name,reader=reader,expected_reason=reason,changed=changed,rejection=rejected)
            rows.append(row);save('evidence-reached.json.gz',dict(baselines=baselines,controls=rows))
            assert rejected['returncode']!=0 and reason.encode() in decode(rejected['stderr_base64']),('actual distinguishing artifact denial',name,rejected)
        finally:
            for n,value in originals.items():(ROOT/(PREFIX+n)).write_bytes(decode(value['bytes_base64']));(ROOT/(PREFIX+n)).chmod(value['mode'])
        row['restoration']=invoke(reader);save('evidence-reached.json.gz',dict(baselines=baselines,controls=rows))
        assert row['restoration']==baselines[reader],('exact restored PASS',name)
        print('Artifact control PASS:',name,flush=True)
    report=dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),originals_sha256=original_hash,
        reached_sha256=sha((ROOT/(PREFIX+'evidence-reached.json.gz')).read_bytes()),
        controls=[{k:v for k,v in row.items() if k!='changed'} for row in rows],
        scope='Six actual denials retain complete changed bytes/modes, both channels and exact restoration: whole accepted predecessor, coherent positive summary, coherent missing syntax, omitted fault, coherent evolution source count and coherently repacked rendered selection count. Updated immediate hashes/populations cannot hide the stated alternatives; accepted Git, original supplied command, exact block and actual native data remain distinguishing oracles. No producer or original observation is refreshed.')
    with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
else:report=json.loads(target.read_bytes())
assert report['result']=='PASS' and report['producer_sha256']==sha(Path(__file__).read_bytes())
original_raw=(ROOT/(PREFIX+'evidence-originals.json.gz')).read_bytes();assert sha(original_raw)==report['originals_sha256']
for n,value in json.loads(gzip.decompress(original_raw)).items():assert (ROOT/(PREFIX+n)).read_bytes()==decode(value['bytes_base64']) and (ROOT/(PREFIX+n)).stat().st_mode&0o7777==value['mode']
reached_raw=(ROOT/(PREFIX+'evidence-reached.json.gz')).read_bytes();assert sha(reached_raw)==report['reached_sha256']
reached=json.loads(gzip.decompress(reached_raw));assert len(reached['controls'])==len(report['controls'])==6
for full,index in zip(reached['controls'],report['controls']):
    assert {k:v for k,v in full.items() if k!='changed'}==index and full['changed']
    assert full['rejection']['returncode']!=0 and full['expected_reason'].encode() in decode(full['rejection']['stderr_base64'])
    assert full['restoration']==reached['baselines'][full['reader']]
    for value in full['changed'].values():assert sha(decode(value['bytes_base64']))==value['sha256']
print('Fixture artifact evidence PASS:six actual coherent denials/full changed bytes/modes/channels/exact restoration')
