"""Distinct one-shot native tied/callable/lifetime epoch; original96 rows stay exact."""
import base64
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
BASE = '64b66167c2277533c2393899e3754e14a74f0b31'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'native-extra-before.json')
capsule = ROOT / (PREFIX + 'native-extra-before-inputs.json.gz')
assert not target.exists() and not capsule.exists()
original = json.loads((ROOT / (PREFIX + 'native-before.json')).read_bytes())
paths = set(original['inputs']) | {PREFIX + 'pipeline-extra-probe.pl', PREFIX + 'capture-native-extra.py'}
inputs = {}
for name in sorted(paths):
    path = ROOT / name
    assert path.is_file() and not path.is_symlink()
    data = path.read_bytes()
    inputs[name] = dict(sha256=sha(data), mode=path.stat().st_mode & 0o7777, base64=encode(data))
for name, row in original['inputs'].items():
    assert inputs[name]['sha256'] == row['sha256'] and inputs[name]['mode'] == row['mode']
with capsule.open('xb') as output:
    output.write(gzip.compress(json.dumps(inputs, sort_keys=True).encode(), mtime=0))
command = ['perl', '-Iperl', PREFIX + 'pipeline-extra-probe.pl']
run = subprocess.run(command, cwd=ROOT, capture_output=True)
record = dict(base=BASE, producer_sha256=sha(Path(__file__).read_bytes()), command=command,
              returncode=run.returncode, stdout_base64=encode(run.stdout), stderr_base64=encode(run.stderr),
              inputs={name: {key: value for key, value in row.items() if key != 'base64'}
                      for name, row in inputs.items()}, input_capsule_sha256=sha(capsule.read_bytes()),
              scope='Actual native supplemental epoch before production or assertions. Whole100 supplied '
                    'inputs preserve the prior98 unchanged; host/toolchain/observed-IO limits match '
                    'the original native record. This does not replay or relabel the original96 rows.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
assert run.returncode == 0
rows = json.loads(run.stdout)
assert isinstance(rows, list) and len(rows) == 9
for name, row in inputs.items():
    path = ROOT / name
    assert sha(path.read_bytes()) == row['sha256'] and path.stat().st_mode & 0o7777 == row['mode']
print('Native supplemental observation retained:', len(rows), 'rows;', len(inputs),
      'supplied inputs;', len(run.stderr), 'stderr bytes')
