"""Readonly warning evidence; --capture retains eight actual bounded corruptions."""
import base64
import copy
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
names=['warning.json','canonical-committed.receipt','warning-historical-card.md','canonical.log.gz','warning-final.json']
def invoke():
    command=['python3',PREFIX+'warning-review.py']
    run=subprocess.run(command,cwd=ROOT,capture_output=True)
    return dict(command=command,returncode=run.returncode,stdout_base64=encode(run.stdout),stderr_base64=encode(run.stderr))
def write(name,value):(ROOT/(PREFIX+name)).write_text(json.dumps(value,indent=2)+'\n')
def pack(name,value):
    data=gzip.compress(json.dumps(value,sort_keys=True,separators=(',',':')).encode(),mtime=0)
    (ROOT/(PREFIX+name)).write_bytes(data);return sha(data)
target=ROOT/(PREFIX+'warning-evidence.json')
if sys.argv[1:]:
    assert not target.exists()
    baseline=invoke();assert baseline['returncode']==0 and not decode(baseline['stderr_base64'])
    originals={name:dict(bytes_base64=encode((ROOT/(PREFIX+name)).read_bytes()),mode=(ROOT/(PREFIX+name)).stat().st_mode&0o7777) for name in names}
    original_hash=pack('warning-evidence-originals.json.gz',originals)
    controls=[('omitted-summary','complete compiler-summary occurrence population'),
        ('wrong-count','raw compiler-summary crate/count association'),
        ('wrong-crate','raw compiler-summary crate/count association'),
        ('wrong-phase','nearest public phase association'),
        ('forged-committed-receipt','actual committed canonical receipt'),
        ('changed-historical-baseline','whole dated historical warning account'),
        ('changed-actual-log','archive_sha256'),
        ('failed-canonical-outcome','local CI gate passed')]
    rows=[]
    for name,reason in controls:
        try:
            record=json.loads(decode(originals['warning.json']['bytes_base64']))
            if name=='omitted-summary':record['rows']=record['rows'][1:]
            elif name=='wrong-count':
                row=record['rows'][0];row['reported_warnings']+=1
                record['reported_values'][row['crate']]=sorted(set(record['reported_values'][row['crate']]+[row['reported_warnings']]))
            elif name=='wrong-crate':
                row=record['rows'][0];row['crate']='rgx-core' if row['crate']=='pgen' else 'pgen'
                record['reported_values'][row['crate']]=sorted(set(record['reported_values'][row['crate']]+[row['reported_warnings']]))
            elif name=='wrong-phase':record['rows'][0]['phase']='[ci] unrelated public phase'
            elif name=='forged-committed-receipt':
                value=decode(originals['canonical-committed.receipt']['bytes_base64'])
                lines=value.splitlines(True);line=next(v for v in lines if v.startswith(b'content='))
                altered=value.replace(line,b'content='+b'0'*40+b'\n',1)
                (ROOT/(PREFIX+'canonical-committed.receipt')).write_bytes(altered)
                record['committed_tree']='0'*40
                record['inputs'][PREFIX+'canonical-committed.receipt']=sha(altered)
            elif name=='changed-historical-baseline':
                value=decode(originals['warning-historical-card.md']['bytes_base64'])
                assert b'1,870' in value;value=value.replace(b'1,870',b'1,871',1)
                (ROOT/(PREFIX+'warning-historical-card.md')).write_bytes(value)
                record['historical_reported_values']['pgen']+=1
                record['inputs'][PREFIX+'warning-historical-card.md']=sha(value)
            else:
                log=gzip.decompress(decode(originals['canonical.log.gz']['bytes_base64']))
                if name=='changed-actual-log':
                    old=b'warning: `pgen` (lib) generated 7093 warnings'
                    assert old in log;log=log.replace(old,old.replace(b'7093',b'7094'),1)
                else:
                    old=b'[ci] local CI gate passed';assert log.rstrip().endswith(old)
                    log=log[:log.rfind(old)]+log[log.rfind(old):].replace(old,b'[ci] local CI gate failed',1)
                packed=gzip.compress(log,mtime=0)
                (ROOT/(PREFIX+'canonical.log.gz')).write_bytes(packed)
                record.update(log_bytes=len(log),log_sha256=sha(log))
                record['inputs'][PREFIX+'canonical.log.gz']=sha(packed)
                if name=='failed-canonical-outcome':
                    final=json.loads(decode(originals['warning-final.json']['bytes_base64']))
                    final.update(archive_sha256=sha(packed),log_bytes=len(log),log_sha256=sha(log))
                    write('warning-final.json',final)
                    record['inputs'][PREFIX+'warning-final.json']=sha((ROOT/(PREFIX+'warning-final.json')).read_bytes())
            write('warning.json',record)
            changed={n:dict(bytes_base64=encode((ROOT/(PREFIX+n)).read_bytes()),sha256=sha((ROOT/(PREFIX+n)).read_bytes()),mode=(ROOT/(PREFIX+n)).stat().st_mode&0o7777)
                for n in names if (ROOT/(PREFIX+n)).read_bytes()!=decode(originals[n]['bytes_base64'])}
            rejected=invoke();row=dict(name=name,expected_reason=reason,changed=changed,rejection=rejected)
            rows.append(row);pack('warning-evidence-reached.json.gz',dict(baseline=baseline,controls=rows))
            assert rejected['returncode']!=0 and reason.encode() in decode(rejected['stderr_base64']),('distinguishing denial',name)
        finally:
            for n,item in originals.items():(ROOT/(PREFIX+n)).write_bytes(decode(item['bytes_base64']));(ROOT/(PREFIX+n)).chmod(item['mode'])
        restored=invoke();row['restoration']=restored
        pack('warning-evidence-reached.json.gz',dict(baseline=baseline,controls=rows))
        assert restored==baseline,('exact restoration',name)
    report=dict(result='PASS',producer_sha256=sha(Path(__file__).read_bytes()),originals_sha256=original_hash,
        reached_sha256=sha((ROOT/(PREFIX+'warning-evidence-reached.json.gz')).read_bytes()),
        controls=[{k:v for k,v in row.items() if k!='changed'} for row in rows],
        scope='Eight actual bounded artifact denials with full changed bytes/modes, both channels and exact restoration. Seven semantic population/association/phase/Git-receipt/historical-account/outcome checks and one original-log custody hash check have distinct observed reasons. Coherent immediate report hashes cannot hide the stated alternatives. No dependency code or build is inspected/run.')
    with target.open('x') as output:output.write(json.dumps(report,indent=2)+'\n')
else:report=json.loads(target.read_bytes())
assert report['result']=='PASS' and report['producer_sha256']==sha(Path(__file__).read_bytes())
original_raw=(ROOT/(PREFIX+'warning-evidence-originals.json.gz')).read_bytes();assert sha(original_raw)==report['originals_sha256']
for n,item in json.loads(gzip.decompress(original_raw)).items():assert (ROOT/(PREFIX+n)).read_bytes()==decode(item['bytes_base64']) and (ROOT/(PREFIX+n)).stat().st_mode&0o7777==item['mode']
reached_raw=(ROOT/(PREFIX+'warning-evidence-reached.json.gz')).read_bytes();assert sha(reached_raw)==report['reached_sha256']
reached=json.loads(gzip.decompress(reached_raw));assert len(reached['controls'])==len(report['controls'])==8
for full,index in zip(reached['controls'],report['controls']):
    assert {k:v for k,v in full.items() if k!='changed'}==index and full['changed']
    assert full['rejection']['returncode']!=0 and full['expected_reason'].encode() in decode(full['rejection']['stderr_base64'])
    assert full['restoration']==reached['baseline']
    for item in full['changed'].values():assert sha(decode(item['bytes_base64']))==item['sha256']
print('Public warning evidence PASS:eight actual denials;full counterfactual bytes/modes;exact restoration')
