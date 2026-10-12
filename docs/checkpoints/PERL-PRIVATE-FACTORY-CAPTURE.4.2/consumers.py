"""One-shot complete supplied predecessor consumers plus the FlowExpr fixture."""
import base64
import gzip
import hashlib
import json
import os
import stat
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '708c1afa04bb10aeacbdaf0a8133a95f380df434'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.2/'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-consumers.json'
SEED_CHANNELS = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-consumers-channels.json.gz'
MODULE = 'perl/LinkedSpec/ActionIR/FlowExpr.pm'
FIXTURE = 't/actionir_flow_kind_capture.t'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
target = ROOT / (PREFIX + 'consumers.json')
assert not target.exists(), 'one-shot supplied consumer capture'
seed_raw = subprocess.check_output(['git', 'show', BASE + ':' + SEED], cwd=ROOT)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
seed_channels_raw = subprocess.check_output(['git', 'show', BASE + ':' + SEED_CHANNELS], cwd=ROOT)
assert (ROOT / SEED_CHANNELS).read_bytes() == seed_channels_raw
seed_channels = json.loads(gzip.decompress(seed_channels_raw))
assert seed['returncode'] == 0 and seed['unchanged']
assert seed['command'][:3] == ['prove', '-v', '-Iperl']
files, modes = {}, {}
for path, expected in seed['inputs'].items():
    raw = (ROOT / path).read_bytes()
    assert path == MODULE or sha(raw) == expected, ('unchanged accepted consumer input', path)
    files[path] = raw
    modes[path] = stat.S_IMODE((ROOT / path).stat().st_mode)
native = json.loads(gzip.decompress((ROOT / (PREFIX + 'before-native-inputs.json.gz')).read_bytes()))
for path in native:
    files[path] = (ROOT / path).read_bytes()
    modes[path] = stat.S_IMODE((ROOT / path).stat().st_mode)
for path in (FIXTURE, PREFIX + 'before-native-data.json.gz', SEED, SEED_CHANNELS, PREFIX + 'consumers.py'):
    files[path] = (ROOT / path).read_bytes()
    modes[path] = stat.S_IMODE((ROOT / path).stat().st_mode)
positive = json.loads((ROOT / (PREFIX + 'accepted-after.json')).read_bytes())
assert sha(files[MODULE]) == positive['inputs'][MODULE]['sha256']
capsule = {path: {'sha256': sha(raw), 'mode': modes[path],
                  'bytes_base64': base64.b64encode(raw).decode()}
           for path, raw in sorted(files.items())}
capsule_path = ROOT / (PREFIX + 'consumers-inputs.json.gz')
with capsule_path.open('xb') as output:
    output.write(gzip.compress(json.dumps(capsule, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
environment = dict(os.environ, PERL5LIB='', PERL5OPT='',
                   LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
command = seed['command'] + [FIXTURE]
with tempfile.TemporaryDirectory(prefix='flow-kind-consumers-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(raw)
        destination.chmod(modes[path])
    process = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
    actual = {path.relative_to(supplied).as_posix(): sha(path.read_bytes())
              for path in supplied.rglob('*') if path.is_file()}
    actual_modes = {path: stat.S_IMODE((supplied / path).stat().st_mode) for path in actual}
channels = {'command': command, 'returncode': process.returncode,
            'stdout_base64': base64.b64encode(process.stdout).decode(),
            'stderr_base64': base64.b64encode(process.stderr).decode()}
channels_path = ROOT / (PREFIX + 'consumers-channels.json.gz')
with channels_path.open('xb') as output:
    output.write(gzip.compress(json.dumps(channels, sort_keys=True).encode(), mtime=0))
result = {'result': 'PASS' if process.returncode == 0 else 'FAIL', 'base': BASE,
          'producer_sha256': sha(Path(__file__).read_bytes()), 'seed': SEED,
          'seed_sha256': sha(seed_raw), 'command': command, 'returncode': process.returncode,
          'inputs': {path: item['sha256'] for path, item in capsule.items()}, 'modes': modes,
          'capsule_sha256': sha(capsule_path.read_bytes()), 'channels_sha256': sha(channels_path.read_bytes()),
          'unchanged': actual == {path: item['sha256'] for path, item in capsule.items()} and actual_modes == modes,
          'scope': 'Complete fixed accepted consumer command/input population plus the identical final optional FlowExpr fixture and complete parent Perl namespace. Every supplied byte/mode and full actual TAP/channel is retained. Only FlowExpr differs from the accepted seed runtime inputs. System Perl/stdlib are reused read-only; no complete helper/private/parent/canonical admission is inferred.'}
with target.open('x') as output:
    output.write(json.dumps(result, indent=2) + '\n')
assert result['unchanged'] and process.returncode == 0
assert b'All tests successful.' in process.stdout and b'Result: PASS' in process.stdout
assert process.stderr == base64.b64decode(seed_channels['stderr_base64'])
print('Optional FlowExpr supplied consumers PASS:', len(command[3:]), 'suites;', len(files), 'complete inputs')
