"""Freeze the complete accepted prior claim, after its actual clean readonly pass."""
import json
import subprocess
import common as c

path = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.3.json'
original = c.read(path)
record = json.loads(c.decode(original['base64']))
bindings = record['claims'][0]['durability']['inputs']
assert len(bindings) == 845 and len(c.decode(original['base64'])) == 130759
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=c.ROOT).decode().strip() == c.BASE
assert subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT) == c.decode(original['base64'])
inputs = {item['path']: c.identity(item['path']) for item in bindings}
receipt = json.loads((c.ROOT / 'docs/checkpoints/type-evaluated-values/publication-selector.json').read_bytes())
for item in bindings:
    assert inputs[item['path']]['sha256'] == item['sha256']
    assert inputs[item['path']]['mode'] == receipt['input_modes'][item['path']]
    raw = subprocess.check_output(['git', 'show', c.BASE + ':' + item['path']], cwd=c.ROOT)
    assert c.sha(raw) == item['sha256'], item['path']
    tree = subprocess.check_output(['git', 'ls-tree', c.BASE, '--', item['path']], cwd=c.ROOT)
    # Git records executable status; the accepted receipt retains full modes.
    assert bool(int(tree.split()[0], 8) & 0o111) == bool(inputs[item['path']]['mode'] & 0o111)
baseline = {suffix: c.read('.linkedspec-data/verification/type-scoped-with-prior.' + suffix)
            for suffix in ('log', 'status')}
assert c.decode(baseline['status']['base64']).strip() == b'0'
assert b'publication PASS: 845 inputs; 130759 bytes;' in c.decode(baseline['log']['base64'])
c.write_new('prior.json.gz', dict(original=original, inputs=inputs, baseline=baseline,
    accepted_revision=c.BASE, producer=c.read(c.PREFIX + 'preserve.py'),
    primitives=c.read(c.PREFIX + 'common.py'),
    receipt=c.identity('docs/checkpoints/type-evaluated-values/publication-selector.json'),
    scope='Whole original claim and all input bytes/modes are recoverable at the real accepted Git revision. '
          'Actual default readonly PASS0 ran from clean Git before new source files. No draft identity is invented.'))
record['claims'][0]['durability'].update(mode='historical', revision=c.BASE)
raw = (json.dumps(record, separators=(',', ':')) + '\n').encode()
assert len(raw) <= 131072
(c.ROOT / path).write_bytes(raw)
print('Whole prior845/full130759 and actual readonly PASS0 preserved; claim frozen at accepted Git revision')
