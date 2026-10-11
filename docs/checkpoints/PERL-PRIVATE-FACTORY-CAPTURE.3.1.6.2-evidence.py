"""Seven actual reason-sensitive damaged/restored reviews on complete repository-volume copies."""
import base64
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-'
REVIEW=PREFIX+'review.py'
REPORT=PREFIX+'review.json'
TARGET=ROOT/(PREFIX+'evidence.json')
assert sys.argv[1:] in ([],['--capture'])
digest=lambda raw:hashlib.sha256(raw).hexdigest()
serialize=lambda value:(json.dumps(value,indent=2)+'\n').encode()
report=json.loads((ROOT/REPORT).read_bytes())
assert report['result']=='PASS'
paths=set(report['input_metadata'])|{REVIEW,REPORT}
files={path:(ROOT/path).read_bytes() for path in sorted(paths)}
modes={path:(ROOT/path).stat().st_mode & 0o777 for path in files}
assert all(digest(files[path])==sha for path,sha in report['input_metadata'].items())
assert digest(files[REVIEW])==report['producer_sha256']


def alter(path,operation):
    value=json.loads(files[path])
    operation(value)
    return {path:serialize(value)}


def positive_red(value):
    raw=base64.b64decode(value['stdout_base64'],validate=True)
    assert raw.startswith(b'ok 1 - ')
    value['stdout_base64']=base64.b64encode(b'not '+raw).decode()


def missing_fault(value):
    raw=base64.b64decode(value['stdout_base64'],validate=True)
    name=b'scalar ordinary callback string-trim_action_ir_value-effect complete native effects and aliases'
    assert raw.count(name)==1
    value['stdout_base64']=base64.b64encode(raw.replace(name,b'scalar unrelated fault')).decode()


def false_flag(value):
    data=json.loads(base64.b64decode(value['stdout_base64'],validate=True))
    assert data['callbacks'][0]['trace'][0]['readonly']==[0]
    data['callbacks'][0]['trace'][0]['readonly']=[1]
    value['stdout_base64']=base64.b64encode(serialize(data)).decode()


def missing_reason_and_binding():
    changed=alter(PREFIX+'inverse-string-copied-arguments.json',missing_fault)
    index_path=PREFIX+'inverses.json'
    index=json.loads(files[index_path])
    entries=[row for row in index['rows'] if row['label']=='string-copied-arguments']
    assert len(entries)==1
    entries[0]['sha256']=digest(changed[PREFIX+'inverse-string-copied-arguments.json'])
    changed[index_path]=serialize(index)
    return changed


def missing_checkpoint():
    path=PREFIX+'consumers.json'
    value=json.loads(files[path])
    raw=base64.b64decode(value['stdout_base64'],validate=True)
    checkpoint=next(name for name in value['command'][3:] if name.startswith('docs/checkpoints/'))
    lines=raw.splitlines(keepends=True)
    matched=[line for line in lines if line.startswith(checkpoint.encode()+b' ')]
    assert len(matched)==1
    value['stdout_base64']=base64.b64encode(raw.replace(matched[0],b'',1)).decode()
    damaged=serialize(value)
    review_path=PREFIX+'consumer-review.json'
    review=json.loads(files[review_path])
    review['consumer_sha256']=digest(damaged)
    return {path:damaged,review_path:serialize(review)}


controls=[
 ('false-positive',lambda:alter(PREFIX+'fixture.json',positive_red),'positive runtime TAP'),
 ('fault-artifact-hash',lambda:alter(PREFIX+'inverse-string-copied-arguments.json',missing_fault),'inverse artifact binding'),
 ('missing-semantic-reason',missing_reason_and_binding,'effective named semantic fault'),
 ('false-native-flag',lambda:alter(PREFIX+'current.json',false_flag),'native callback values aliases effects errors'),
 ('omitted-checkpoint-suite',missing_checkpoint,'all63 command paths including checkpoint fixture'),
 ('original-binding',lambda:alter('docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.1.json',
   lambda value:value['claims'][0]['durability']['inputs'][0].update(sha256='0'*64)),'frozen original claim fields'),
 ('changed-book-source',lambda:{'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md':
    files['docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md']+b'\n'},'complete current book input'),
]
population={path:digest(raw) for path,raw in files.items()}
if sys.argv[1:]:
    assert not TARGET.exists(),'one-shot evidence already retained'
    git_dir=subprocess.check_output(['git','rev-parse','--absolute-git-dir'],cwd=ROOT,text=True).strip()
    with tempfile.TemporaryDirectory(prefix='scalar-required-evidence-',dir=os.environ['TMPDIR']) as temporary:
        supplied=Path(temporary)
        assert supplied.stat().st_dev==ROOT.stat().st_dev
        for path,raw in files.items():
            destination=supplied/path
            destination.parent.mkdir(parents=True,exist_ok=True)
            destination.write_bytes(raw)
            destination.chmod(modes[path])
        environment=dict(os.environ,GIT_DIR=git_dir,GIT_WORK_TREE=str(supplied),GIT_OPTIONAL_LOCKS='0',PYTHONDONTWRITEBYTECODE='1')

        def run(expected):
            command=['python3',REVIEW]
            result=subprocess.run(command,cwd=supplied,env=environment,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=False)
            assert {p.relative_to(supplied).as_posix() for p in supplied.rglob('*') if p.is_file()}==set(files),'exact evidence file population'
            assert all(digest((supplied/path).read_bytes())==sha for path,sha in expected.items()),'review mutated supplied input'
            return {'command':command,'returncode':result.returncode,'stdout_base64':base64.b64encode(result.stdout).decode(),
                    'stderr_base64':base64.b64encode(result.stderr).decode(),'inputs':expected,'unchanged':True}

        healthy=run(population)
        assert healthy['returncode']==0 and not base64.b64decode(healthy['stderr_base64']),'healthy supplied review'
        rows=[]
        reached=ROOT/(PREFIX+'evidence-reached.json')
        assert not reached.exists(),'one-shot reached-channel log already retained'
        reached.write_text(json.dumps({'healthy':healthy,'rows':rows},indent=2)+'\n')
        for label,operation,reason in controls:
            changed=operation()
            for path,raw in changed.items():
                (supplied/path).write_bytes(raw)
            damaged=dict(population,**{path:digest(raw) for path,raw in changed.items()})
            red=run(damaged)
            reached_row={'label':label,'reason':reason,'changed':{path:{'sha256':digest(raw),'bytes_base64':base64.b64encode(raw).decode()} for path,raw in changed.items()},'red':red}
            reached.write_text(json.dumps({'healthy':healthy,'rows':rows+[reached_row]},indent=2)+'\n')
            assert red['returncode']!=0 and reason.encode() in base64.b64decode(red['stderr_base64']),('wrong evidence denial',label)
            for path in changed:
                (supplied/path).write_bytes(files[path])
            restored=run(population)
            reached_row['restored']=restored
            reached.write_text(json.dumps({'healthy':healthy,'rows':rows+[reached_row]},indent=2)+'\n')
            assert restored['returncode']==0 and not base64.b64decode(restored['stderr_base64']),'restored supplied review'
            rows.append({'label':label,'reason':reason,'changed':{path:{'sha256':digest(raw),'bytes_base64':base64.b64encode(raw).decode()} for path,raw in changed.items()},
                         'red':red,'restored':restored})
        result={'result':'PASS','producer_sha256':digest(Path(__file__).read_bytes()),
                'review_sha256':digest(files[REVIEW]),'report_sha256':digest(files[REPORT]),'inputs':population,'modes':modes,
                'healthy':healthy,'controls':rows,
                'scope':'Seven actual named RED/restorations over complete supplied copies. The checkpoint omission intervention changes the actual output and its immediate review binding together, so the oracle reaches the path-complete census rather than a stale-hash denial. Complete changed bytes, all input identities and distinct command channels retained; exact originals restored. Parent Git access is read-only. Original native instruments and runtime observations stay unchanged.'}
        TARGET.write_text(json.dumps(result,indent=2)+'\n')
else:
    result=json.loads(TARGET.read_bytes())
    assert result['result']=='PASS' and result['producer_sha256']==digest(Path(__file__).read_bytes())
    assert result['review_sha256']==digest(files[REVIEW]) and result['report_sha256']==digest(files[REPORT])
    assert result['inputs']==population and result['modes']==modes
    assert result['healthy']['inputs']==population and result['healthy']['returncode']==0 and result['healthy']['unchanged']
    assert len(result['controls'])==len(controls)
    for row,(label,operation,reason) in zip(result['controls'],controls):
        changed=operation()
        assert row['label']==label and row['reason']==reason and set(row['changed'])==set(changed)
        for path,raw in changed.items():
            assert base64.b64decode(row['changed'][path]['bytes_base64'],validate=True)==raw
            assert row['changed'][path]['sha256']==digest(raw)
        assert row['red']['inputs']==dict(population,**{path:digest(raw) for path,raw in changed.items()})
        assert row['red']['returncode']!=0 and reason.encode() in base64.b64decode(row['red']['stderr_base64']) and row['red']['unchanged']
        assert row['restored']['inputs']==population and row['restored']['returncode']==0 and row['restored']['unchanged']
print('Scalar required evidence PASS7 actual RED/restorations; checkpoint path, aliases, positive/fault/book/original314 controls')
