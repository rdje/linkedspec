"""Run full cold reconstruction with the final guarded helper on the project volume."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c
import large_inputs


def main():
    value=large_inputs.manifest()
    with tempfile.TemporaryDirectory(prefix='aggregate-final-cold-',dir=os.environ['TMPDIR']) as directory:
        root=Path(directory);assert root.stat().st_dev==ROOT.stat().st_dev
        restored=large_inputs.ensure_all(destination_root=root)
        actual={item['path']:large_inputs.identity(root/item['path']) for item in value['objects']}
        assert actual=={item['path']:{key:item[key] for key in ('sha256','size','mode')} for item in value['objects']}
        assert set(restored)==large_inputs.LOGICAL_PATHS
    print(json.dumps(dict(aliases=actual,helper=c.read(c.PREFIX+'large_inputs.py'),
        loaded_path=Path(large_inputs.__file__).resolve().relative_to(ROOT).as_posix(),
        project_volume=True,temporary_outputs_removed=True),sort_keys=True))


if __name__=='__main__':main()
