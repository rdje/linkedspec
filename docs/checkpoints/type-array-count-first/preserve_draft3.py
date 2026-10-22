"""Preserve the third unpublished candidate before private generated-source expectation repair."""
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
    log = c.read('.linkedspec-data/verification/type-count-first-canonical2.log')
    baseline = c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'publish.py'])
    private = c.run(['prove','-v','-Iperl','t/actionir_method_kind_capture.t'])
    stable = c.unchanged(supplied['inputs'])
    value = dict(producer=producer,actor=actor,context=supplied,packets=packets,
        baseline=baseline,private=private,failed_canonical_log=log,
        inputs_unchanged=stable,physical_inputs=len(actual),
        scope='Unpublished draft3 at real base a8bd8620a; not a committed acceptance. Actual readonly0 and three stale private emitted-source expectations precede any bound write. Canonical attempt2 completed1 naturally:90 of91 private suites pass; failed3/230 rows compare old defined guards with current ARRAY guards. Whole inputs, changed plain packets, claim/publication/manifest/gateway and modes remain recoverable.')
    raw = gzip.compress((json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode(),mtime=0)
    with (ROOT/'.linkedspec-data/verification/type-count-first-draft3.json.gz').open('xb') as output:
        output.write(raw)
    assert baseline['returncode'] == 0 and not c.decode(baseline['stderr_base64']) and stable
    assert private['returncode'] != 0
    errors = c.decode(private['stdout_base64']) + c.decode(private['stderr_base64'])
    assert b'Failed 3/230 subtests' in errors
    assert c.read('.linkedspec-data/verification/type-count-first-canonical2.log') == log
    with (ROOT/PREFIX/'preserve_draft3.py').open('xb') as output:
        output.write(c.decode(producer['base64']))
    (ROOT/PREFIX/'preserve_draft3.py').chmod(producer['mode'])
    with (ROOT/PREFIX/'draft3.json.gz').open('xb') as output:
        output.write(raw)
    print('Whole unpublished draft3 preserved:',len(actual),'inputs/full modes; actual readonly0 and private expectation RED')


if __name__ == '__main__':
    main()
