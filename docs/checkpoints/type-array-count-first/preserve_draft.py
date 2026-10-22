"""Preserve the unpublished first candidate and actual readonly baseline before golden edits."""
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
    baseline = c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'publish.py'])
    stable = c.unchanged(supplied['inputs'])
    value = dict(producer=producer,actor=actor,context=supplied,packets=packets,
        baseline=baseline,inputs_unchanged=stable,physical_inputs=len(actual),
        scope='Unpublished draft1 at real base a8bd8620a, not a committed acceptance. Whole claim/publication/manifest/gateway and every physical byte/full-mode identity survive before any bound Phase0-golden write. Whole changed/new plain source packets plus actual base Git and immutable current files recover the supplied state. Actual default readonly baseline precedes tracked adoption; no historical revision is fabricated.')
    raw = gzip.compress((json.dumps(value,sort_keys=True,separators=(',',':'))+'\n').encode(),mtime=0)
    name = '.linkedspec-data/verification/type-count-first-draft1.json.gz'
    with (ROOT/name).open('xb') as output:
        output.write(raw)
    assert baseline['returncode'] == 0 and not c.decode(baseline['stderr_base64']) and stable
    target_actor = ROOT/PREFIX/'preserve_draft.py'
    with target_actor.open('xb') as output:
        output.write(c.decode(producer['base64']))
    target_actor.chmod(producer['mode'])
    with (ROOT/PREFIX/'draft1.json.gz').open('xb') as output:
        output.write(raw)
    assert c.read(PREFIX+'preserve_draft.py') == producer
    print('Whole unpublished draft1 preserved:',len(actual),'inputs/full modes; actual readonly0; adopted original actor and output')


if __name__ == '__main__':
    main()
