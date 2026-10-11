"""Actual reason-sensitive corruptions on supplied copies; never alter original proof inputs."""
import base64
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-'
REVIEW=PREFIX+'review.py'
REPORT=PREFIX+'review.json'
TARGET=PREFIX+'evidence.json'
assert sys.argv[1:] in ([],['--capture'])
digest=lambda raw:hashlib.sha256(raw).hexdigest()


def mutate(raw,operation):
    record=json.loads(raw)
    operation(record)
    return (json.dumps(record,indent=2)+'\n').encode()


def alias_flags(record):
    value=json.loads(base64.b64decode(record['stdout_base64'],validate=True))
    value['rows'][2]['readonly_flag']=1
    record['stdout_base64']=base64.b64encode(json.dumps(value).encode()).decode()


def missing_reason(record):
    raw=base64.b64decode(record['stdout_base64'],validate=True)
    reason=b'legacy native-hash actual readonly match alias'
    assert raw.count(reason)==1
    record['stdout_base64']=base64.b64encode(raw.replace(reason,b'legacy unrelated fault')).decode()


report=json.loads((ROOT/REPORT).read_bytes())
assert report['result']=='PASS'
paths=set(report['input_metadata'])|{REVIEW,REPORT}
files={path:(ROOT/path).read_bytes() for path in sorted(paths)}
modes={path:(ROOT/path).stat().st_mode & 0o777 for path in files}
assert all(digest(files[path])==sha for path,sha in report['input_metadata'].items())
assert digest(files[REVIEW])==report['producer_sha256']
positive=PREFIX+'positive.json'
inverse=PREFIX+'inverse-copy-argument.json'
oracle=PREFIX+'match-alias.json'
old_claim='docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0.json'
controls=[
 ('failed-positive',positive,lambda raw:mutate(raw,lambda row:row.update(returncode=1)),'positive runtime TAP'),
 ('missing-semantic-reason',inverse,lambda raw:mutate(raw,missing_reason),'effective named semantic fault'),
 ('missing-diagnostic',positive,lambda raw:mutate(raw,lambda row:row.update(stderr_base64='')),'unexpected public-copy stderr'),
 ('unexpected-diagnostic',positive,lambda raw:mutate(raw,lambda row:row.update(stderr_base64=base64.b64encode(base64.b64decode(row['stderr_base64'])+b'# unexpected warning\n').decode())),'unexpected public-copy stderr'),
 ('false-readonly-flag',oracle,lambda raw:mutate(raw,alias_flags),'match oracle flags'),
 ('original-binding',old_claim,lambda raw:mutate(raw,lambda row:row['claims'][0]['durability']['inputs'][0].update(sha256='0'*64)),'frozen original claim fields'),
]
if sys.argv[1:]:
    assert not (ROOT/TARGET).exists(),'one-shot evidence already retained'
    git_dir=subprocess.check_output(['git','rev-parse','--absolute-git-dir'],cwd=ROOT,text=True).strip()
    with tempfile.TemporaryDirectory(prefix='legacy-kind-evidence-',dir=os.environ['TMPDIR']) as temporary:
        directory=Path(temporary)
        assert directory.stat().st_dev==ROOT.stat().st_dev
        for path,raw in files.items():
            target=directory/path
            target.parent.mkdir(parents=True,exist_ok=True)
            target.write_bytes(raw)
            target.chmod(modes[path])
        environment=dict(os.environ,GIT_DIR=git_dir,GIT_WORK_TREE=str(directory),GIT_OPTIONAL_LOCKS='0',
                         PYTHONDONTWRITEBYTECODE='1')

        def run(population):
            command=['python3',REVIEW]
            result=subprocess.run(command,cwd=directory,env=environment,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=False)
            assert {p.relative_to(directory).as_posix() for p in directory.rglob('*') if p.is_file()}==set(files),'evidence file population'
            assert all(digest((directory/path).read_bytes())==sha for path,sha in population.items()),'review mutated supplied inputs'
            return {'command':command,'returncode':result.returncode,
                    'stdout_base64':base64.b64encode(result.stdout).decode(),
                    'stderr_base64':base64.b64encode(result.stderr).decode(),
                    'inputs':population,'unchanged':True}

        population={p:digest(raw) for p,raw in files.items()}
        healthy=run(population)
        assert healthy['returncode']==0 and not base64.b64decode(healthy['stderr_base64']),'healthy supplied review'
        rows=[]
        for label,path,operation,reason in controls:
            changed=operation(files[path])
            (directory/path).write_bytes(changed)
            damaged=dict(population,**{path:digest(changed)})
            red=run(damaged)
            assert red['returncode']!=0 and reason.encode() in base64.b64decode(red['stderr_base64']),('wrong evidence denial',label)
            (directory/path).write_bytes(files[path])
            restored=run(population)
            assert restored['returncode']==0 and not base64.b64decode(restored['stderr_base64']),'restored supplied review'
            rows.append({'label':label,'path':path,'reason':reason,
                         'changed_sha256':digest(changed),'changed_source_base64':base64.b64encode(changed).decode(),
                         'red':red,'restored':restored})
        result={'result':'PASS','producer_sha256':digest(Path(__file__).read_bytes()),
                'review_sha256':digest(files[REVIEW]),'review_report_sha256':digest(files[REPORT]),
                'inputs':population,'modes':modes,'healthy':healthy,'controls':rows,
                'scope':'Six actual reason-sensitive corruptions on repository-volume copies, including original historical-binding and false match-flag controls. Complete changed artifacts and command channels retained; exact healthy input population restored after every RED. Parent Git object/index reads are read-only; no original proof input is mutated.'}
        (ROOT/TARGET).write_text(json.dumps(result,indent=2)+'\n')
else:
    result=json.loads((ROOT/TARGET).read_bytes())
    population={p:digest(raw) for p,raw in files.items()}
    assert result['result']=='PASS' and result['producer_sha256']==digest(Path(__file__).read_bytes())
    assert result['review_sha256']==digest(files[REVIEW]) and result['review_report_sha256']==digest(files[REPORT])
    assert result['inputs']==population and result['modes']==modes
    assert result['healthy']['inputs']==population and result['healthy']['returncode']==0 and result['healthy']['unchanged']
    assert len(result['controls'])==len(controls)
    for row,(label,path,operation,reason) in zip(result['controls'],controls):
        changed=operation(files[path])
        assert row['label']==label and row['path']==path and row['reason']==reason
        assert base64.b64decode(row['changed_source_base64'],validate=True)==changed
        assert row['changed_sha256']==digest(changed)
        assert row['red']['inputs']==dict(population,**{path:digest(changed)})
        assert row['red']['returncode']!=0 and reason.encode() in base64.b64decode(row['red']['stderr_base64']) and row['red']['unchanged']
        assert row['restored']['inputs']==population and row['restored']['returncode']==0 and row['restored']['unchanged']
print('Legacy evidence controls PASS6 RED/restored, including original546 binding and native match-flag denial')
