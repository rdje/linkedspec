"""One-shot actual native observation; retain inputs/channels before adjudication."""
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
target = ROOT / (PREFIX + 'native-before.json')
capsule = ROOT / (PREFIX + 'native-before-inputs.json.gz')
assert not target.exists() and not capsule.exists()
assert json.loads((ROOT / (PREFIX + 'preservation.json')).read_bytes())['result'] == 'PASS'
paths = set(subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE,
                                   '--', 'perl'], cwd=ROOT, text=True).splitlines())
paths.update({PREFIX + 'pipeline-probe.pl', PREFIX + 'capture-native.py',
              'tools/run_python_project_data.sh', 'tools/project_data_env.sh'})
inputs = {}
for name in sorted(paths):
    path = ROOT / name
    assert path.is_file() and not path.is_symlink()
    data = path.read_bytes()
    inputs[name] = dict(sha256=sha(data), mode=path.stat().st_mode & 0o7777,
                        base64=encode(data))
with capsule.open('xb') as output:
    output.write(gzip.compress(json.dumps(inputs, sort_keys=True).encode(), mtime=0))
command = ['perl', '-Iperl', PREFIX + 'pipeline-probe.pl']
run = subprocess.run(command, cwd=ROOT, capture_output=True)
record = dict(base=BASE, producer_sha256=sha(Path(__file__).read_bytes()), command=command,
              returncode=run.returncode, stdout_base64=encode(run.stdout),
              stderr_base64=encode(run.stderr), inputs={name: {
                  key: value for key, value in row.items() if key != 'base64'}
                  for name, row in inputs.items()},
              input_capsule_sha256=sha(capsule.read_bytes()),
              scope='Actual-root native command before production or assertion changes. '
                    'Complete parent Perl tree plus actual probe/instrument/wrappers is a retained '
                    'supplied-input superset. Host Perl/OS/toolchain remain read-only prerequisites; '
                    'no immutable host-toolchain or minimal observed IO claim.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
assert run.returncode == 0
rows = json.loads(run.stdout)
assert isinstance(rows, list) and rows
for name, row in inputs.items():
    path = ROOT / name
    assert sha(path.read_bytes()) == row['sha256'] and path.stat().st_mode & 0o7777 == row['mode']
print('Native pipeline observation retained:', len(rows), 'rows;', len(inputs), 'supplied inputs;',
      len(run.stderr), 'stderr bytes')
