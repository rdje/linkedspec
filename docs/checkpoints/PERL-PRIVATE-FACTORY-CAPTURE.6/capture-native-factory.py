"""Retain actual public-facade factory/canonical identities and their source superset."""
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
target = ROOT / (PREFIX + 'native-factory.json')
capsule = ROOT / (PREFIX + 'native-factory-inputs.json.gz')
assert not target.exists() and not capsule.exists()
paths = set(subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', 'HEAD',
                                   '--', 'perl', 'noncore', 'config', 'specs'], cwd=ROOT, text=True).splitlines())
paths.update({PREFIX + 'native-factory-probe.pl', PREFIX + 'capture-native-factory.py',
              'tools/run_python_project_data.sh', 'tools/project_data_env.sh'})
inputs = {}
for name in sorted(paths):
    path = ROOT / name
    assert path.is_file() and not path.is_symlink()
    data = path.read_bytes()
    inputs[name] = dict(sha256=sha(data), mode=path.stat().st_mode & 0o7777, base64=encode(data))
with capsule.open('xb') as output:
    output.write(gzip.compress(json.dumps(inputs, sort_keys=True).encode(), mtime=0))
environment = os.environ.copy()
environment.update(PERL5LIB='', PERL5OPT='')
command = ['perl', '-Iperl', PREFIX + 'native-factory-probe.pl']
run = subprocess.run(command, cwd=ROOT, env=environment, capture_output=True)
record = dict(command=command, environment_controls=dict(PERL5LIB='', PERL5OPT=''),
              returncode=run.returncode, stdout_base64=encode(run.stdout), stderr_base64=encode(run.stderr),
              producer_sha256=sha(Path(__file__).read_bytes()), input_capsule_sha256=sha(capsule.read_bytes()),
              inputs={name: {key: value for key, value in row.items() if key != 'base64'}
                      for name, row in inputs.items()},
              scope='Actual public Toolbox call_spec_handler_subst route and native factory/apply identities. '
                    'Complete parent Perl/noncore/config/spec regular-source superset plus actual instrument '
                    'is captured before execution. Submodules/dependency implementations are excluded. '
                    'Host Perl/OS/toolchain remain read-only prerequisites; no minimal observed IO claim.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
assert run.returncode == 0 and not run.stderr
observed = json.loads(run.stdout)
assert observed['canonical_calls'] and observed['scopes_restored'] == 1
for row in observed['canonical_calls']:
    assert all(row[key] == 1 for key in ('actual_public_apply', 'registered_actual', 'producer_token', 'input_token', 'actual_origin')), row
for key, value in observed['modules'].items():
    if not isinstance(value, str):
        continue
    path = Path(value)
    if not path.is_absolute():
        path = ROOT / path
    try:
        name = path.resolve().relative_to(ROOT).as_posix()
    except ValueError:
        continue
    assert name in inputs, (key, name)
for name, row in inputs.items():
    path = ROOT / name
    assert sha(path.read_bytes()) == row['sha256'] and path.stat().st_mode & 0o7777 == row['mode']
print('Actual public factory/canonical proof PASS:', len(observed['canonical_calls']),
      'canonical calls;', len(inputs), 'supplied inputs')
