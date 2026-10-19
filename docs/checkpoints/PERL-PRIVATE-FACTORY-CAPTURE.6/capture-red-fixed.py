"""One-shot complete valid-TAP RED before changing the native pipeline."""
import base64
import gzip
import hashlib
import json
import os
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'red-fixed.json')
capsule = ROOT / (PREFIX + 'red-fixed-inputs.json.gz')
assert not target.exists() and not capsule.exists()
native = json.loads((ROOT / (PREFIX + 'native-extra-before.json')).read_bytes())
paths = set(native['inputs']) | {'t/actionir_factory_capture.t'}
paths.update(path.relative_to(ROOT).as_posix() for path in (ROOT / PREFIX).iterdir() if path.is_file())
inputs = {}
for name in sorted(paths):
    path = ROOT / name
    assert path.is_file() and not path.is_symlink()
    data = path.read_bytes()
    inputs[name] = dict(sha256=sha(data), mode=path.stat().st_mode & 0o7777, base64=encode(data))
with capsule.open('xb') as output:
    output.write(gzip.compress(json.dumps(inputs, sort_keys=True).encode(), mtime=0))
controls = dict(PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment = os.environ.copy()
environment.update(controls)
command = ['prove', '-v', '-Iperl', 't/actionir_factory_capture.t']
run = subprocess.run(command, cwd=ROOT, env=environment, capture_output=True)
record = dict(command=command, environment_controls=controls, returncode=run.returncode,
              stdout_base64=encode(run.stdout), stderr_base64=encode(run.stderr),
              producer_sha256=sha(Path(__file__).read_bytes()), input_capsule_sha256=sha(capsule.read_bytes()),
              inputs={name: {key: value for key, value in row.items() if key != 'base64'}
                      for name, row in inputs.items()})
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
assert run.returncode != 0
assert b'pipeline producer source scope' in run.stdout + run.stderr
assert b'pipeline actual callback boundary' in run.stdout + run.stderr
assert re.search(rb'^1\.\.\d+\s*$', run.stdout, re.M) and b'Bail out!' not in run.stdout + run.stderr
for name, row in inputs.items():
    path = ROOT / name
    assert sha(path.read_bytes()) == row['sha256'] and path.stat().st_mode & 0o7777 == row['mode']
print('Complete pipeline semantic RED retained:', len(inputs), 'supplied inputs')
