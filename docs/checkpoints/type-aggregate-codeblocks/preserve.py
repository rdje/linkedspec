"""Preserve accepted drop6 whole publication before aggregate7 bound writes."""
import json
import subprocess
import common as c

OLD='docs/checkpoints/type-drop-generated/'
CLAIM='docs/claims/TYPE-REFERENCE-BOOK.1.2.6.json'


def main():
    activation=c.read('.linkedspec-data/verification/type-aggregate-clean-activation.json')
    state=json.loads(c.decode(activation['base64']))
    assert state['head']==c.BASE and state['status']==dict(returncode=0,stdout='',stderr='')
    claim=c.read(CLAIM)
    manifest=c.read(OLD+'publication-final-inputs.json')
    publication=c.read(OLD+'publication-final.json')
    inputs=json.loads(c.decode(manifest['base64']))['inputs']
    assert len(inputs)==10334 and c.unchanged(inputs)
    assert json.loads(c.decode(publication['base64']))['record_base64']==claim['base64']
    baseline={name:c.read('.linkedspec-data/verification/type-aggregate-prior-drop-baseline.'+name) for name in ('log','status')}
    assert c.decode(baseline['status']['base64']).strip()==b'0'
    assert b'10334 closed inputs;34 values/14 diagnostics;4 producer faults' in c.decode(baseline['log']['base64'])
    tree={}
    for row in subprocess.check_output(['git','ls-tree','-rz',c.BASE],cwd=c.ROOT).split(b'\0'):
        if row:
            metadata,name=row.split(b'\t',1);mode,kind,oid=metadata.decode().split()
            tree[name.decode()]=dict(mode=mode,kind=kind,oid=oid)
    paths=sorted(inputs)
    assert all(tree[path]['kind']=='blob' and tree[path]['mode'] in ('100644','100755') for path in paths)
    verified=c.run(['git','hash-object','--stdin-paths'],input=('\n'.join(paths)+'\n').encode())
    assert verified['returncode']==0 and not c.decode(verified['stderr_base64'])
    assert c.decode(verified['stdout_base64']).decode().splitlines()==[tree[path]['oid'] for path in paths]
    assert c.unchanged(inputs)
    c.write_new('prior.json.gz',dict(base=c.BASE,claim=claim,manifest=manifest,publication=publication,
        inputs={path:dict(**item,git=tree[path]) for path,item in inputs.items()},baseline=baseline,
        activation=activation,git_verification=verified,producer=c.read(c.PREFIX+'preserve.py'),
        primitives=c.read(c.PREFIX+'common.py'),
        scope='Whole accepted drop record/publication/10334 closed inputs/full filesystem modes, actual '
              'clean readonly0 and activation; every input independently matches its real efad62 Git blob. '
              'All earlier drop/numeric source images, corrections and artifact inputs remain intact. '
              'No observation is refreshed or draft Git revision invented.'))
    print('Whole accepted drop publication preserved:10334 inputs/full modes; clean readonly0; Git bytes verified')


if __name__=='__main__':main()
