"""Actual fact-pointer fault, exact first-image denials and fresh composed proof."""
import copy
import json
import sys
from pathlib import Path
sys.path.insert(1,str(Path(__file__).resolve().parents[1]))
import common as c
import context
import verify


def main():
    extras=[path.relative_to(c.ROOT).as_posix() for path in (c.ROOT/c.PREFIX).rglob('*')
            if path.is_file() and '__pycache__' not in path.parts]
    extras+=['tests/drop-generated/cases.json','tests/drop-generated/book-cases.json','t/drop_keys_generated.t',
             'tests/language-readiness/drop-generated-regression-evolution.json.gz']
    snapshot=context.snapshot(extras)
    original=c.read(verify.FACT)
    snapshot.update(fact=original,producer=c.read(c.PREFIX+'admission/capture_fact.py'))
    c.write_new('admission/fact-inputs.json.gz',snapshot)
    command=['bash','tools/run_python_project_data.sh',c.PREFIX+'admission/check_fact.py']
    healthy=c.run(command)
    assert healthy['returncode']==0 and not c.decode(healthy['stderr_base64'])
    raw=c.decode(original['base64'])
    old,new=verify.COMMAND.encode(),verify.OLD_COMMAND.encode()
    assert raw.count(old)==1
    target=c.ROOT/verify.FACT
    try:
        target.write_bytes(raw.replace(old,new,1))
        mutant=c.read(verify.FACT)
        fault=c.run(command)
        c.write_new('admission/fact-pointer-observed.json.gz',dict(run=fault,mutant=mutant))
    finally:
        target.write_bytes(raw);target.chmod(original['mode'])
    assert fault['returncode']!=0 and b'current historical reverify must use composed producer' in c.decode(fault['stderr_base64'])
    restored=c.run(command)
    assert restored['returncode']==0 and not c.decode(restored['stderr_base64'])
    assert c.read(verify.FACT)==original and c.unchanged(snapshot['inputs'])
    first=c.load('admission/first.json.gz')
    controls=[]
    tasks=[('baseline-status','first readonly baseline must be zero'),
           ('image-oid','staged image/index mismatch'),
           ('retained-mode','retained packet/staged image mismatch')]
    for name,reason in tasks:
        altered=copy.deepcopy(first)
        if name=='baseline-status':
            path=['baseline','status','base64'];before=first['baseline']['status']['base64'];after=c.encode(b'1\n')
            altered['baseline']['status']['base64']=after
        elif name=='image-oid':
            path=['images',c.SOURCE,'oid'];before=first['images'][c.SOURCE]['oid'];after='0'*40
            altered['images'][c.SOURCE]['oid']=after
        else:
            path=['before',verify.FACT,'mode'];before=first['before'][verify.FACT]['mode'];after=before^1
            altered['before'][verify.FACT]['mode']=after
        error=None
        try:verify.first_image(altered)
        except AssertionError as failure:error=str(failure)
        observed=dict(name=name,path=path,before=before,after=after,observed=error,expected=reason)
        c.write_new('admission/artifact-'+name+'-observed.json.gz',observed)
        assert error==reason,(name,error)
        controls.append(observed)
    history=c.run(verify.COMMAND.split())
    knowledge=c.run(['bash','knowledge-map/scripts/check_knowledge_map.sh'])
    assert history['returncode']==knowledge['returncode']==0
    actual=json.loads(c.decode(history['stdout_base64']))
    assert actual['audit_controls']['governance_mutations_rejected']==650
    assert c.unchanged(snapshot['inputs'])
    c.write_new('admission/fact-run.json.gz',dict(result='PASS',healthy=healthy,
        fact_pointer_fault=fault,restored=restored,source_restored=True,inputs_unchanged=True,
        artifact_controls=controls,composed_history=history,knowledge=knowledge,
        actual_old_route_red=first['old_reverify']['returncode']!=0,
        first_image=verify.first_image(),producer=c.read(c.PREFIX+'admission/capture_fact.py'),
        scope='Current fact metadata uses the actual composed historical producer; reverting its real '
              'source pointer rejects and restores. Three exact reason-sensitive first-draft artifact '
              'denials reject; all10308 original stage images and whole10304-input draft/readonly0 '
              'remain recoverable. Current Knowledge and composed650/archive134/22/zero guard pass.'))
    print('Final fact admission PASS: actual pointer RED/restoration;3 artifact denials;10308 stage images; composed650; Knowledge')


if __name__=='__main__':main()
