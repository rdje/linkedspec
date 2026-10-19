"""Retain a distinct native callable epoch with the framework's actual preload."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'native-context-before.json')
capsule = ROOT / (PREFIX + 'native-context-before-inputs.json.gz')
assert not target.exists() and not capsule.exists()
previous = json.loads((ROOT / (PREFIX + 'native-extra-before.json')).read_bytes())
paths = set(previous['inputs']) | {PREFIX + 'capture-native-context.py'}
inputs = {}
for name in sorted(paths):
    path = ROOT / name
    assert path.is_file() and not path.is_symlink()
    data = path.read_bytes()
    inputs[name] = dict(sha256=sha(data), mode=path.stat().st_mode & 0o7777, base64=encode(data))
for name, row in previous['inputs'].items():
    assert inputs[name]['sha256'] == row['sha256'] and inputs[name]['mode'] == row['mode']
with capsule.open('xb') as output:
    output.write(gzip.compress(json.dumps(inputs, sort_keys=True).encode(), mtime=0))
command = ['perl', '-Iperl', '-MLinkedSpec::ActionIR::SourceEmissions', PREFIX + 'pipeline-extra-probe.pl']
run = subprocess.run(command, cwd=ROOT, capture_output=True)
record = dict(base=previous['base'], command=command, returncode=run.returncode,
              stdout_base64=encode(run.stdout), stderr_base64=encode(run.stderr),
              producer_sha256=sha(Path(__file__).read_bytes()), input_capsule_sha256=sha(capsule.read_bytes()),
              inputs={name: {key: value for key, value in row.items() if key != 'base64'}
                      for name, row in inputs.items()},
              scope='Distinct actual native epoch, before production. SourceEmissions preload matches '
                    'the selected framework suite and its derived absolute @INC bootstrap. Original '
                    'standalone9/100 and original96/98 observations remain immutable. No error '
                    'path normalization or immutable host/toolchain claim.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
assert run.returncode == 0 and not run.stderr and len(json.loads(run.stdout)) == 9
for name, row in inputs.items():
    path = ROOT / name
    assert sha(path.read_bytes()) == row['sha256'] and path.stat().st_mode & 0o7777 == row['mode']
print('Native context observation retained:9 rows;', len(inputs), 'supplied inputs; no normalized errors')
