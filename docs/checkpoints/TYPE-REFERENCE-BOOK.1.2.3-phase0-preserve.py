"""Preserve the whole current uncommitted publication before Phase0 consumer edits."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

prefix = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-'
producer = prefix + 'preserve.py'
original = c.read(c.CLAIM)
preflight = c.read(c.PREFIX + 'publication-final.json')
receipt = json.loads(c.decode(preflight['base64']))
record = json.loads(c.decode(original['base64']))
assert receipt['record_base64'] == original['base64']
bindings = record['claims'][0]['durability']['inputs']
assert len(bindings) == 573 and len(c.decode(original['base64'])) == 92573
identities = {}
for binding in bindings:
    item = c.read(binding['path'])
    assert item['sha256'] == binding['sha256']
    assert item['mode'] == receipt['input_modes'][binding['path']]
    identities[binding['path']] = dict(sha256=item['sha256'], mode=item['mode'])
mutable = ('t/phase0_regression.t', c.PREFIX + 'review.py',
           c.PREFIX + 'publish.py', c.PREFIX + 'README.md')
c.write_new(prefix + 'preservation.json.gz', dict(original_claim=original,
    preflight=preflight, identities=identities, before={path: c.read(path) for path in mutable},
    producer=c.read(producer), helper=c.read(c.PREFIX + 'common.py'),
    activation_commit=c.BASE,
    scope='Whole actual573/full92573 uncommitted draft and every binding hash/mode precede '
          'test/reader/publication edits. Full original mutable bytes are retained here; all '
          'other inputs remain exact at their tracked paths. No historical Git identity is '
          'invented for the draft. A fresh unchanged readonly baseline follows this capture.'), packed=True)
run = c.run(['python3', c.PREFIX + 'publish.py'])
c.write_new(prefix + 'readonly.json', dict(run=run,
    claim_unchanged=c.read(c.CLAIM) == original,
    all_inputs_bytes_modes_unchanged=all(c.read(path)['sha256'] == wanted['sha256'] and
        c.read(path)['mode'] == wanted['mode'] for path, wanted in identities.items())))
assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
assert c.decode(run['stdout_base64']) == b'Current Perl evaluated values publication PASS: 573 inputs; 92573 bytes;23 GREEN/19 baseline RED\n'
assert c.read(c.CLAIM) == original
print('Whole current573/full92573 and actual readonly baseline preserved before Phase0 edits')
