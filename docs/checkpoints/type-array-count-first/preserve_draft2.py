"""Preserve the second unpublished candidate before portability representation repair."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(subprocess.check_output(['git','rev-parse','--show-toplevel']).decode().strip())
PREFIX = 'docs/checkpoints/type-array-count-first/'
sys.path.insert(0,str(ROOT/PREFIX))
import common as c
import context
import publish


def main():
    actor = Path(__file__).resolve().relative_to(ROOT).as_posix()
    supplied = context.snapshot()
    producer = c.read(actor)
    actual = {path:c.identity(path) for path in publish.input_paths()}
    publish.validate_inputs(c.load(publish.MANIFEST_NAME)['inputs'],actual)
    packets = {key:c.read(path) for key,path in [('claim',publish.CLAIM),
        ('manifest',publish.MANIFEST),('publication',publish.PUBLICATION),('gateway',c.PREFIX+'publish.py')]}
    log = c.read('.linkedspec-data/verification/type-count-first-canonical.log')
    baseline = c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'publish.py'])
    portability = c.run(['bash','scripts/check_repo_root_path_portability.sh'])
    stable = c.unchanged(supplied['inputs'])
    value = dict(producer=producer,actor=actor,context=supplied,packets=packets,
        baseline=baseline,portability=portability,failed_canonical_log=log,
        inputs_unchanged=stable,physical_inputs=len(actual),
        scope='Unpublished draft2 at real base a8bd8620a; not a committed acceptance. Actual readonly0 and the production portability RED precede any bound write. The failed canonical process group was explicitly identified and terminated after its path failure; completion143 is not canonical success. Whole inputs, changed plain packets, original summaries, claim, publication, manifest, gateway and full modes remain recoverable.')
    raw = gzip.compress((json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode(),mtime=0)
    with (ROOT/'.linkedspec-data/verification/type-count-first-draft2.json.gz').open('xb') as output:
        output.write(raw)
    assert baseline['returncode'] == 0 and not c.decode(baseline['stderr_base64']) and stable
    assert portability['returncode'] != 0
    errors = c.decode(portability['stderr_base64'])+c.decode(portability['stdout_base64'])
    assert all(name.encode() in errors for name in ('phase0-accepted-result.json','phase0-candidate-result.json'))
    assert c.read('.linkedspec-data/verification/type-count-first-canonical.log') == log
    with (ROOT/PREFIX/'preserve_draft2.py').open('xb') as output:
        output.write(c.decode(producer['base64']))
    (ROOT/PREFIX/'preserve_draft2.py').chmod(producer['mode'])
    with (ROOT/PREFIX/'draft2.json.gz').open('xb') as output:
        output.write(raw)
    print('Whole unpublished draft2 preserved:',len(actual),'inputs/full modes; actual readonly0 and production portability RED')


if __name__ == '__main__':
    main()
