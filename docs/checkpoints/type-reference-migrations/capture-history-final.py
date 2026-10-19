"""Capture the separate EOF reader without presuming removed callbacks survive."""
import subprocess
from pathlib import Path
import common as c

path = c.PREFIX + 'history-supplement-final.py'
inputs = {path: c.read(path), c.PREFIX + 'common.py': c.read(c.PREFIX + 'common.py')}
blobs = {}
for revision in ('fff219840212c26d78d75cda0ac9356f5f8d257c', '4e9250390785b9a36ae3c48abc17fabc97b75ac0'):
    value = subprocess.check_output(['git', 'show', revision + ':perl/LinkedSpec/ActionIR/MethodLowering.pm'], cwd=c.ROOT)
    blobs[revision] = dict(base64=c.encode(value), sha256=c.sha(value))
c.write_new(c.PREFIX + 'history-final-inputs.json.gz', dict(inputs=inputs, blobs=blobs,
    producer=c.read(c.PREFIX + 'capture-history-final.py')), packed=True)
result = c.run(['python3', path])
c.write_new(c.PREFIX + 'history-final-run.json', dict(run=result, unchanged=c.unchanged(inputs),
    scope='Distinct retained execution; the earlier combined invocation channels are unavailable.'))
print('Historical EOF reader:', result['returncode'])
print(c.decode(result['stderr_base64']).decode())
