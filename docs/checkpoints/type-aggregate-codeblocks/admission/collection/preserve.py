"""Preserve the complete second unpublished candidate before merging its new fact."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c
import publish
import publish_final


def main():
    inputs={path:c.identity(path) for path in publish_final.input_paths()}
    assert len(inputs)==10522
    publish.validate_inputs(c.load('publication-final-inputs.json.gz')['inputs'],inputs)
    readonly={name:c.read('.linkedspec-data/verification/type-aggregate-final-readonly.'+name)
              for name in ('log','status')}
    canonical={name:c.read('.linkedspec-data/verification/type-aggregate-canonical1.'+name)
               for name in ('log','status')}
    assert c.decode(readonly['status']['base64']).strip()==b'0'
    assert b'10522 closed inputs;214/106 RED/7 faults;14/1948;book89/3' in c.decode(readonly['log']['base64'])
    assert c.decode(canonical['status']['base64']).strip()==b'143'
    assert b'surface knowledge_cards exceeds control: files 1351/1350' in c.decode(canonical['log']['base64'])
    absent=c.run(['ps','-p','45080,45083,45445,45991','-o','pid=,ppid=,comm='])
    assert absent['returncode']==1 and not c.decode(absent['stdout_base64'])
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
    assert len(images)==10525
    assert all({key:images[path][key] for key in ('sha256','mode')}==item for path,item in inputs.items())
    verified=c.run(['git','hash-object','--stdin-paths'],input=('\n'.join(sorted(images))+'\n').encode())
    assert verified['returncode']==0 and not c.decode(verified['stderr_base64'])
    assert c.decode(verified['stdout_base64']).decode().splitlines()==[
        images[path]['git']['oid'] for path in sorted(images)]
    assert inputs=={path:c.identity(path) for path in publish_final.input_paths()}
    value=dict(base=c.BASE,inputs=inputs,images=images,before=packets,git_verification=verified,
        claim=c.read('docs/claims/'+c.OWNER+'.json'),
        publication=c.read(c.PREFIX+'publication-final.json'),
        manifest=c.read(c.PREFIX+'publication-final-inputs.json.gz'),
        readonly=readonly,canonical=canonical,absence=absent,
        producer=c.read(Path(__file__).resolve().relative_to(ROOT).as_posix()),
        scope='Complete second unpublished10522-input claim/publication/full modes, actual readonly0 '
              'and10525 Git-verified staged images precede the new-card consolidation. Canonical1 '
              'observed knowledge_cards1351/1350 and was deliberately joined143; no CI success is '
              'claimed. Whole changed plain sources, real accepted efad and immutable gzip artifacts '
              'recover every input. No draft Git revision is invented; corrected exact canonical remains required.')
    output=ROOT/'.linkedspec-data/verification/type-aggregate-second-epoch.json.gz'
    raw=(json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode()
    with output.open('xb') as stream:stream.write(gzip.compress(raw,mtime=0))
    print('Second candidate preserved:10522 inputs/10525 images;readonly0;actual1351/1350 RED;canonical1 joined143')


if __name__=='__main__':main()
