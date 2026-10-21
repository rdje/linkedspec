"""Probe output-root routing read-only; never create anything in a Gitlink."""
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c
import large_inputs


def main():
    roots=['.']
    for row in subprocess.check_output(['git','ls-files','--stage','-z'],cwd=ROOT).split(b'\0'):
        if row:
            metadata,path=row.split(b'\t',1)
            if metadata.split()[0]==b'160000' and (ROOT/path.decode()/'.git').exists():roots.append(path.decode())
    assert len(roots)>1
    result={}
    for path in roots:
        try:
            routed=large_inputs._inside(ROOT/path,'__linkedspec_readonly_boundary_probe__')
            result[path]=dict(accepted=True,path=routed.relative_to(ROOT).as_posix())
        except ValueError as error:result[path]=dict(accepted=False,error=str(error))
    print(json.dumps(dict(roots=result,helper=c.read(c.PREFIX+'large_inputs.py'),
        loaded_path=Path(large_inputs.__file__).resolve().relative_to(ROOT).as_posix(),
        scope='Only main Gitlink metadata/.git existence and a non-writing path validator; '
              'no target is created and no submodule implementation is read.'),sort_keys=True))


if __name__=='__main__':main()
