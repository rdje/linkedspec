"""Preserve the complete accepted numeric publication before generated-drop writes."""
import json
import subprocess
import common as c

OLD='docs/checkpoints/type-numeric-codeblocks/'
CLAIM='docs/claims/TYPE-REFERENCE-BOOK.1.2.5.json'


def main():
    activation_path='.linkedspec-data/verification/type-drop-clean-activation.json'
    activation=json.loads((c.ROOT/activation_path).read_bytes())
    assert activation['head']==c.BASE and activation['status']['returncode']==0
    assert activation['status']['stdout']==activation['status']['stderr']==''
    claim=c.read(CLAIM)
    manifest=c.read(OLD+'publication-recurrence-inputs.json')
    publication=c.read(OLD+'publication-recurrence.json')
    document=json.loads(c.decode(publication['base64']))
    assert document['record_base64']==claim['base64']
    inputs=json.loads(c.decode(manifest['base64']))['inputs']
    assert len(inputs)==10202 and c.unchanged(inputs)
    baseline={name:c.read('.linkedspec-data/verification/type-drop-prior-numeric-baseline.'+name) for name in ('log','status')}
    assert c.decode(baseline['status']['base64']).strip()==b'0'
    assert b'10202 closed inputs;318 GREEN;169 accepted RED;13 faults' in c.decode(baseline['log']['base64'])
    tree={}
    for row in subprocess.check_output(['git','ls-tree','-rz',c.BASE],cwd=c.ROOT).split(b'\0'):
        if row:
            metadata,name=row.split(b'\t',1)
            mode,kind,oid=metadata.decode().split()
            tree[name.decode()]=dict(mode=mode,kind=kind,oid=oid)
    paths=sorted(inputs)
    assert all(tree[path]['kind']=='blob' and tree[path]['mode'] in ('100644','100755') and '\n' not in path for path in paths)
    verified=c.run(['git','hash-object','--stdin-paths'],input=('\n'.join(paths)+'\n').encode())
    assert verified['returncode']==0 and not c.decode(verified['stderr_base64'])
    assert c.decode(verified['stdout_base64']).decode().splitlines()==[tree[path]['oid'] for path in paths]
    assert c.unchanged(inputs)
    c.write_new('prior.json.gz',dict(base=c.BASE,claim=claim,manifest=manifest,publication=publication,
        inputs={path:dict(**item,git=tree[path]) for path,item in inputs.items()},baseline=baseline,
        activation=c.read(activation_path),git_verification=verified,
        producer=c.read(c.PREFIX+'preserve.py'),primitives=c.read(c.PREFIX+'common.py'),
        scope='Whole accepted numeric record/publication/10202 closed inputs and full filesystem modes, '
              'actual readonly baseline0 and actual clean activation before preparation. Every input byte '
              'is independently verified against its real accepted Git blob using hash-object without writes. '
              'Git executable status and full filesystem permissions remain separate authorities. '
              'No original observation or claim leg is discarded; no fictional draft revision is used.'))
    print('Prior numeric whole publication preserved:10202 inputs/full modes; accepted9fc95b0bd; clean readonly0; all Git bytes verified')


if __name__=='__main__':
    main()
