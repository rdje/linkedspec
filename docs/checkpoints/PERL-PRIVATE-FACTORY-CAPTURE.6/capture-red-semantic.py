"""One-shot fixed-plan semantic RED with the actual native load-context oracle."""
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
target = ROOT / (PREFIX + 'red-semantic.json')
capsule = ROOT / (PREFIX + 'red-semantic-inputs.json.gz')
assert not target.exists() and not capsule.exists()
context = json.loads((ROOT / (PREFIX + 'native-prove-context-before.json')).read_bytes())
paths = set(context['inputs']) | {
    't/actionir_factory_capture.t', PREFIX + 'pipeline-assertions-current.pl',
    PREFIX + 'native-before.json', PREFIX + 'native-prove-context-before.json',
    PREFIX + 'capture-red-semantic.py',
}
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
                      for name, row in inputs.items()},
              scope='Complete actual fixed-plan RED. Parent Perl superset, actual test/helpers/native '
                    'reader artifacts/instruments retained. Historical failure/recovery artifacts are '
                    'separately retained rather than recursively copied as unused runtime inputs.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
assert run.returncode != 0
assert re.search(rb'^1\.\.1988\s*$', run.stdout, re.M) and b'Bail out!' not in run.stdout + run.stderr
failures = re.findall(rb'^not ok \d+ - (.*)$', run.stdout, re.M)
allowed = re.compile(rb'^pipeline (?:producer source scope|input source scope|actual callback boundary|'
                     rb'actual native arguments|retains every actual|actual registered factory)')
assert failures and all(allowed.match(name) for name in failures), [name for name in failures if not allowed.match(name)]
for name, row in inputs.items():
    path = ROOT / name
    assert sha(path.read_bytes()) == row['sha256'] and path.stat().st_mode & 0o7777 == row['mode']
print('Accepted fixed-plan pipeline RED retained:1988 assertions;', len(failures),
      'scoped failures;', len(inputs), 'supplied inputs')
