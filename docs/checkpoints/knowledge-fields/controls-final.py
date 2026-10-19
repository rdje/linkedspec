"""Supply the fixed historical census before recurring the original80 controls."""
import gzip
import json
import subprocess
from pathlib import Path
import common as c

before_path = c.HOME + 'before.json.gz'
before_raw = (c.ROOT / before_path).read_bytes()
before = json.loads(gzip.decompress(before_raw))
assert before['result'] == 'PASS' and before['base'] == c.BASE
assert before['producer_sha256'] == c.sha((c.ROOT / (c.HOME + 'capture-before.py')).read_bytes())
fixed_path = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-headers-census.json'
assert fixed_path not in before['inputs'], 'disclose the exact initial control-input omission'
inputs = dict(before['inputs'])
extra = {path: c.read(path) for path in (fixed_path, before_path, c.HOME + 'controls-final.py')}
inputs.update({path: dict(sha256=item['sha256'], mode=item['mode']) for path, item in extra.items()})
fixed_git = subprocess.check_output(['git', 'show', c.BASE + ':' + fixed_path], cwd=c.ROOT)
assert c.decode(extra[fixed_path]['base64']) == fixed_git
assert c.unchanged(inputs), 'complete supplied control inputs precede the new actual run'
observed = c.run(['perl', 't/knowledge_map_header_lists.t'])
assert observed == before['original_controls'], ('exact original80 control channels', observed)
assert observed['returncode'] == 0 and c.unchanged(inputs)
report = dict(version=1, result='PASS', base=c.BASE,
              original_record_sha256=c.sha(before_raw), original_producer_sha256=before['producer_sha256'],
              supplied_fixed_census=extra[fixed_path], added_input=fixed_path,
              observation=observed, inputs_unchanged=True, inputs=inputs,
              producer_sha256=c.sha(Path(__file__).read_bytes()),
              scope='Initial public omission observations remain immutable. Their original80-control '
                    'oracle additionally reads this fixed .8 census. Its exact bytes equal actual '
                    'activation Git and are captured before a distinct control-only recurrence. '
                    'All original and added inputs are guarded, complete channels equal the first '
                    'run, and no generator/native observation or first report is overwritten.')
c.write_new(c.HOME + 'controls-final.json', report)
print('Original80 control closure PASS:exact fixed census supplied before execution;all channels exact')
