"""Preserve accepted aggregate7 physical/logical custody before pipeline9 writes."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c
import large_inputs
import publish as initial
import publish_portable

BASE='49ce3fb472b01dc6a7987b0038fae22686dee7cd'
OUT=ROOT/'.linkedspec-data/verification/type-pipeline-prior.json.gz'


def main():
    producer=c.read(Path(__file__).resolve().relative_to(ROOT).as_posix())
    head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT).decode().strip()
    status=c.run(['git','status','--porcelain'])
    assert head==BASE and status['returncode']==0 and not c.decode(status['stdout_base64'])
    baseline=c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'publish_portable.py'])
    preliminary=dict(base=BASE,producer=producer,baseline=baseline,status=status)
    with (ROOT/'.linkedspec-data/verification/type-pipeline-baseline.json.gz').open('xb') as output:
        output.write(gzip.compress((json.dumps(preliminary,sort_keys=True,separators=(',',':'))+'\n').encode(),mtime=0))
    assert baseline['returncode']==0 and not c.decode(baseline['stderr_base64'])
    assert b'10608 physical inputs;214/106 RED/7 faults;14/1948;book89/3' in c.decode(baseline['stdout_base64'])
    inputs={path:c.identity(path) for path in publish_portable.input_paths()}
    declared=c.load('publication-portable-inputs.json.gz')
    initial.validate_inputs(declared['inputs'],inputs)
    logical={item['path']:large_inputs.identity(ROOT/item['path']) for item in large_inputs.manifest()['objects']}
    assert logical==declared['logical_inputs'] and len(inputs)==10608
    entries={}
    for row in subprocess.check_output(['git','ls-tree','-rz',BASE],cwd=ROOT).split(b'\0'):
        if row:
            metadata,name=row.split(b'\t',1);mode,kind,oid=metadata.decode().split()
            entries[name.decode()]=dict(mode=mode,kind=kind,oid=oid)
    images={};excluded=[]
    for row in subprocess.check_output(['git','ls-files','--stage','-z'],cwd=ROOT).split(b'\0'):
        if not row:continue
        metadata,name=row.split(b'\t',1);mode,oid,stage=metadata.decode().split()
        assert stage=='0'
        path=name.decode()
        if mode not in ('100644','100755'):
            excluded.append(dict(path=path,git_mode=mode,reason='Uninspected Gitlink/symlink boundary'));continue
        entry=dict(mode=mode,kind='blob',oid=oid)
        assert entries[path]==entry
        images[path]=dict(**c.identity(path),git=entry)
    assert len(images)==10611
    assert all({key:images[path][key] for key in ('sha256','mode')}==item for path,item in inputs.items())
    verified=c.run(['git','hash-object','--stdin-paths'],input=('\n'.join(sorted(images))+'\n').encode())
    assert verified['returncode']==0 and not c.decode(verified['stderr_base64'])
    assert c.decode(verified['stdout_base64']).decode().splitlines()==[
        images[path]['git']['oid'] for path in sorted(images)]
    final_status=c.run(['git','status','--porcelain'])
    assert final_status==status and inputs=={path:c.identity(path) for path in publish_portable.input_paths()}
    value=dict(**preliminary,inputs=inputs,logical_inputs=logical,images=images,excluded=excluded,
        git_verification=verified,claim=c.read('docs/claims/'+c.OWNER+'.json'),
        publication=c.read(publish_portable.PUBLICATION),manifest=c.read(publish_portable.MANIFEST),
        gateway=c.read(c.PREFIX+'publish_portable.py'),chunk_manifest=c.read(large_inputs.MANIFEST),
        scope='Complete accepted aggregate7 claim/publication/10608 physical inputs and three '
              'logical full-byte/full-mode inputs, actual clean readonly0, and10611 independently '
              'verified committed Git images precede pipeline9 writes. All physical sources recover '
              'from real accepted49ce; logical aliases recover from the tracked37 exact chunks. '
              'No binary data is recursively copied and no other repository is inspected or written.')
    with OUT.open('xb') as output:
        output.write(gzip.compress((json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode(),mtime=0))
    assert c.read(Path(__file__).resolve().relative_to(ROOT).as_posix())==producer
    print('Accepted7 preserved:10608 physical/3 logical/10611 committed images;actual clean readonly0;pipeline9 owns next writes')


if __name__=='__main__':main()
