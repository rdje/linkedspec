"""Retain the actual first direct GREEN without replaying its command."""
import base64
import gzip
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'first-green.json')
capsule = ROOT / (PREFIX + 'first-green-inputs.json.gz')
assert not target.exists() and not capsule.exists()
red = json.loads((ROOT / (PREFIX + 'red-semantic.json')).read_bytes())
implementation = json.loads((ROOT / (PREFIX + 'implementation.json')).read_bytes())
inputs = {}
for name, previous in red['inputs'].items():
    path = ROOT / name
    data = path.read_bytes()
    assert path.stat().st_mode & 0o7777 == previous['mode']
    expected = implementation['after_sha256'] if name == implementation['path'] else previous['sha256']
    assert sha(data) == expected
    inputs[name] = dict(sha256=sha(data), mode=previous['mode'], base64=encode(data))
combined = (ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.6-first-green-attempt1.log').read_bytes()
assert re.search(rb'^1\.\.1988\s*$', combined, re.M)
assert b'Files=1, Tests=1988,' in combined and b'Result: PASS' in combined
assert not re.search(rb'^not ok ', combined, re.M)
with capsule.open('xb') as output:
    output.write(gzip.compress(json.dumps(inputs, sort_keys=True).encode(), mtime=0))
record = dict(command=['prove', '-v', '-Iperl', 't/actionir_factory_capture.t'],
              environment_controls=red['environment_controls'], tool_observed_returncode=0,
              combined_stdout_stderr_base64=encode(combined),
              producer_sha256=sha(Path(__file__).read_bytes()), input_capsule_sha256=sha(capsule.read_bytes()),
              inputs={name: {key: value for key, value in row.items() if key != 'base64'}
                      for name, row in inputs.items()},
              scope='Metadata retention of the actual direct checking command; no replay. Its shell '
                    'explicitly merged channels, so separate streams are unavailable. This is an '
                    'immediate post-run input snapshot, not an originally serialized pre-run census. '
                    'Every pre-production108 input remains exact except the single implementation '
                    'output, whose exact writer transformation and hash are retained. A later '
                    'supplied-input proof owns separate pre-run capture and semantic fault admission.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
print('Actual first GREEN1988 retained without replay; all108 input identities and merged channel exact')
