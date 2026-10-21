"""Retain current routing admission after portable handoff/fact changes."""
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c
import context


def main():
    extras=[path.relative_to(ROOT).as_posix() for path in (ROOT/c.PREFIX).rglob('*')
        if path.is_file() and not path.is_symlink()]
    snapshot=context.snapshot(extras)
    assert not any(path.endswith(('.gz','.part')) for path in snapshot['overrides'])
    c.write_new('admission/portable/pressure-inputs.json.gz',snapshot)
    run=c.run(['perl','scripts/check_readme_routing_pressure.pl','--report'])
    stable=c.unchanged(snapshot['inputs'])
    c.write_new('admission/portable/pressure-run.json.gz',dict(run=run,inputs_unchanged=stable,
        producer=c.read(c.PREFIX+'admission/portable/pressure.py')))
    print(c.decode(run['stdout_base64']).decode(),end='')
    print(c.decode(run['stderr_base64']).decode(),end='',file=sys.stderr)
    assert stable and run['returncode']==0


if __name__=='__main__':main()
