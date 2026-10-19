"""Observe the actual prove include conversion, then retain a matching native oracle."""
import base64
import gzip
import hashlib
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
sha = lambda value: hashlib.sha256(value).hexdigest()
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'native-prove-context-before.json')
capsule = ROOT / (PREFIX + 'native-prove-context-before-inputs.json.gz')
assert not target.exists() and not capsule.exists()
previous = json.loads((ROOT / (PREFIX + 'native-context-before.json')).read_bytes())
paths = set(previous['inputs']) | {PREFIX + 'capture-native-prove-context.py',
                                  PREFIX + 'observe-include-context.t'}
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
environment = os.environ.copy()
environment.update(PERL5LIB='', PERL5OPT='')
commands = [
    ['perl', '-Iperl', PREFIX + 'observe-include-context.t'],
    ['prove', '-v', '-Iperl', PREFIX + 'observe-include-context.t'],
    ['perl', '-I' + str(ROOT / 'perl'), PREFIX + 'pipeline-extra-probe.pl'],
]
observations = []
for command in commands:
    run = subprocess.run(command, cwd=ROOT, env=environment, capture_output=True)
    observations.append(dict(command=command, returncode=run.returncode,
                             stdout_base64=encode(run.stdout), stderr_base64=encode(run.stderr)))
record = dict(base=previous['base'], command=commands[-1],
              **{key: value for key, value in observations[-1].items() if key != 'command'},
              include_observations=observations[:2], environment_controls=dict(PERL5LIB='', PERL5OPT=''),
              producer_sha256=sha(Path(__file__).read_bytes()), input_capsule_sha256=sha(capsule.read_bytes()),
              inputs={name: {key: value for key, value in row.items() if key != 'base64'}
                      for name, row in inputs.items()},
              scope='Distinct actual native load-context epoch before production. Direct/prove include '
                    'observations precede LinkedSpec imports. Matching native oracle derives its absolute '
                    'include from current ROOT; no diagnostic normalization or fixed checkout path in code. '
                    'Original standalone/preload epochs stay exact; host toolchain remains a read-only prerequisite.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
assert all(row['returncode'] == 0 and not base64.b64decode(row['stderr_base64']) for row in observations)
direct, prove = [base64.b64decode(row['stdout_base64']) for row in observations[:2]]
direct_rows = [json.loads(line[2:]) for line in direct.splitlines() if line.startswith(b'# {')]
prove_rows = [json.loads(line[2:]) for line in prove.splitlines() if line.startswith(b'# {')]
assert direct_rows[0]['module_preloaded'] == prove_rows[0]['module_preloaded'] == 0
assert direct_rows[0]['before_linkedspec'][0] == 'perl'
assert prove_rows[0]['before_linkedspec'][0] == str(ROOT / 'perl')
assert direct_rows[1]['loaded_module'] == 'perl/LinkedSpec/ActionIR/RewritePipeline.pm'
assert prove_rows[1]['loaded_module'] == str(ROOT / 'perl/LinkedSpec/ActionIR/RewritePipeline.pm')
assert len(json.loads(base64.b64decode(record['stdout_base64']))) == 9
for name, row in inputs.items():
    path = ROOT / name
    assert sha(path.read_bytes()) == row['sha256'] and path.stat().st_mode & 0o7777 == row['mode']
print('Actual direct/prove include root cause PASS; distinct native9 oracle;', len(inputs), 'inputs')
