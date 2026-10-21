"""Retain the complete third draft and actual oversized staged-blob RED before migration."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c
import publish
import publish_admitted


def main():
    inputs={path:c.identity(path) for path in publish_admitted.input_paths()}
    assert len(inputs)==10540
    publish.validate_inputs(c.load('publication-admitted-inputs.json.gz')['inputs'],inputs)
    baseline={name:c.read('.linkedspec-data/verification/type-aggregate-admitted-readonly.'+name)
        for name in ('log','status')}
    assert c.decode(baseline['status']['base64']).strip()==b'0'
    assert b'10540 closed inputs;214/106 RED/7 faults;14/1948;book89/3' in c.decode(baseline['log']['base64'])
    base={}
    for row in subprocess.check_output(['git','ls-tree','-rz',c.BASE],cwd=ROOT).split(b'\0'):
        if row:
            metadata,name=row.split(b'\t',1);mode,kind,oid=metadata.decode().split()
            base[name.decode()]=dict(mode=mode,kind=kind,oid=oid)
    images={};packets={}
    for row in subprocess.check_output(['git','ls-files','--stage','-z'],cwd=ROOT).split(b'\0'):
        if not row:continue
        metadata,name=row.split(b'\t',1);mode,oid,stage=metadata.decode().split()
        assert stage=='0'
        if mode not in ('100644','100755'):continue
        path=name.decode();entry=dict(mode=mode,kind='blob',oid=oid)
        images[path]=dict(**c.identity(path),git=entry)
        if base.get(path)!=entry and not path.endswith('.gz'):packets[path]=c.read(path)
    assert len(images)==10543
    assert all({key:images[path][key] for key in ('sha256','mode')}==item for path,item in inputs.items())
    verified=c.run(['git','hash-object','--stdin-paths'],input=('\n'.join(sorted(images))+'\n').encode())
    assert verified['returncode']==0 and not c.decode(verified['stderr_base64'])
    assert c.decode(verified['stdout_base64']).decode().splitlines()==[
        images[path]['git']['oid'] for path in sorted(images)]
    sizes=c.run(['git','cat-file','--batch-check=%(objectname) %(objectsize)'],
        input=('\n'.join(images[path]['git']['oid'] for path in sorted(images))+'\n').encode())
    assert sizes['returncode']==0 and not c.decode(sizes['stderr_base64'])
    rows=c.decode(sizes['stdout_base64']).decode().splitlines()
    assert len(rows)==len(images)
    oversized={}
    for path,row in zip(sorted(images),rows):
        oid,size=row.split();assert oid==images[path]['git']['oid']
        if int(size)>104857600:oversized[path]=int(size)
    assert len(oversized)==3
    try:assert not oversized,'Staged Git blobs exceed the GitHub100MiB limit'
    except AssertionError as error:red=dict(rejected=True,message=str(error))
    else:raise AssertionError('Oversized producer did not distinguish the portability contract')
    assert inputs=={path:c.identity(path) for path in publish_admitted.input_paths()}
    value=dict(base=c.BASE,inputs=inputs,images=images,before=packets,git_verification=verified,
        claim=c.read('docs/claims/'+c.OWNER+'.json'),
        publication=c.read(c.PREFIX+'publication-admitted.json'),
        manifest=c.read(c.PREFIX+'publication-admitted-inputs.json.gz'),baseline=baseline,
        blob_sizes=sizes,oversized=oversized,blob_limit_red=red,
        limit=dict(bytes=104857600,source='https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github'),
        producer=c.read(Path(__file__).resolve().relative_to(ROOT).as_posix()),
        scope='Complete third unpublished10540-input claim/publication/full modes, actual readonly0 '
              'and10543 Git-verified staged images precede portable retention. Actual staged Git '
              'blob sizes expose three above the verified GitHub100MiB limit. Preserve exact logical '
              'bytes/modes using tracked bounded chunks and verified project-local reconstruction. '
              'Canonical2 is still in flight at this capture and is not claimed complete. No draft '
              'Git revision is invented; all earlier source epochs remain immutable/recoverable.')
    raw=(json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode()
    with (ROOT/'.linkedspec-data/verification/type-aggregate-third-epoch.json.gz').open('xb') as output:
        output.write(gzip.compress(raw,mtime=0))
    print('Third draft preserved:10540 inputs/10543 images;readonly0;actual oversized Git blobs3 RED')


if __name__=='__main__':main()
