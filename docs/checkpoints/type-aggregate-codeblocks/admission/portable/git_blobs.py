"""Read-only exact staged Git-blob size admission for the portable candidate."""
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c
import large_inputs


def main():
    paths={}
    for row in subprocess.check_output(['git','ls-files','--stage','-z'],cwd=ROOT).split(b'\0'):
        if not row:continue
        metadata,name=row.split(b'\t',1);mode,oid,stage=metadata.decode().split()
        assert stage=='0'
        if mode in ('100644','100755'):paths[name.decode()]=oid
    assert not set(paths)&large_inputs.LOGICAL_PATHS
    run=c.run(['git','cat-file','--batch-check=%(objectname) %(objectsize)'],
        input=('\n'.join(paths[path] for path in sorted(paths))+'\n').encode())
    assert run['returncode']==0 and not c.decode(run['stderr_base64'])
    rows=c.decode(run['stdout_base64']).decode().splitlines();assert len(rows)==len(paths)
    maximum=0
    for path,row in zip(sorted(paths),rows):
        oid,size=row.split();assert oid==paths[path]
        maximum=max(maximum,int(size));assert int(size)<=104857600,(path,int(size))
    print('Staged Git blob admission PASS:',len(paths),'regular objects;max',maximum,'bytes;logical aliases0')


if __name__=='__main__':main()
