"""Adopt the complete first unpublished epoch after its actual baseline and pressure RED."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

ROOT=Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
sys.path.insert(0,str(ROOT/'docs/checkpoints/type-aggregate-codeblocks'))
import common as c


def main():
    here=c.ROOT/(c.PREFIX+'admission')
    for source,target in [('epoch','first'),('baseline','first-baseline'),('pressure','first-pressure')]:
        raw=(ROOT/('.linkedspec-data/verification/type-aggregate-first-'+source+'.json.gz')).read_bytes()
        with (here/(target+'.json.gz')).open('xb') as output:output.write(raw)
    first=c.load('admission/first.json.gz')
    producer=ROOT/'.linkedspec-data/verification/type-aggregate-pressure-preserve.py'
    assert c.read(producer.relative_to(ROOT).as_posix())==first['producer']
    with (here/'preserve.py').open('xb') as output:output.write(producer.read_bytes())
    (here/'preserve.py').chmod(first['producer']['mode'])
    assert first['baseline']['returncode']==0 and first['pressure']['returncode']!=0
    assert len(first['inputs'])==10496 and len(first['images'])==10499
    assert c.unchanged(first['inputs'])
    absent=c.run(['ps','-p','49697,50378','-o','pid=,ppid=,command='])
    assert absent['returncode']==1 and not c.decode(absent['stdout_base64'])
    c.write_new('admission/preflight-superseded.json.gz',dict(
        wrapper_pid=49697,child_pid=50378,signal='TERM',joined_status=143,absence=absent,
        action='Documented wrapper termination after observed public_reference50007/50000 failure; '
               'remaining old-candidate checks were deliberately superseded before bound changes. '
               'Corrected exact candidate receives the complete canonical gate; no success is claimed.',
        producer=c.read(c.PREFIX+'admission/adopt.py')))
    print('Whole first10496/input images10499 adopted; actual readonly0/pressure RED; failed preflight143 joined')


if __name__=='__main__':main()
