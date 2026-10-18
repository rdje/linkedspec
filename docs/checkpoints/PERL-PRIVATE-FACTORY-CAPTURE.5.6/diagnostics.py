"""One-shot before/after public diagnostic contract in a complete supplied root."""
import base64
import gzip
import hashlib
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '2b35b77ea0e08d178ccb054a8f8310dbe0abb9c1'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.6/'
MODULE = 'perl/LinkedSpec/ActionIR/ControlFlow.pm'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in (['before'], ['after'])
stage = sys.argv[1]
target = ROOT / (PREFIX + stage + '-diagnostics.json')
assert not target.exists()
if stage == 'before':
    assert (ROOT / MODULE).read_bytes() == subprocess.check_output(
        ['git', 'show', BASE + ':' + MODULE], cwd=ROOT)
seed_path = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.5/consumers.json'
seed = json.loads((ROOT / seed_path).read_bytes())
paths = set(seed['inputs']) | set(json.loads(gzip.decompress(
    (ROOT / (PREFIX + 'before-native-inputs.json.gz')).read_bytes())))
paths.update((seed_path, 'bin/linkedspec', 't/diagnostic_output_perl_contract.t',
              'capability_conformance/diagnostic_output_contract.json', PREFIX + 'diagnostics.py'))
capsule = {}
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    raw = source.read_bytes()
    capsule[path] = {'sha256': sha(raw), 'mode': source.stat().st_mode & 0o7777,
                     'bytes_base64': base64.b64encode(raw).decode()}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0',
                   LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
command = ['prove', '-v', '-Iperl', 't/diagnostic_output_perl_contract.t']
with tempfile.TemporaryDirectory(prefix='output-diagnostics-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, item in capsule.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(base64.b64decode(item['bytes_base64']))
        destination.chmod(item['mode'])
    result = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
    actual = {p.relative_to(supplied).as_posix(): sha(p.read_bytes())
              for p in supplied.rglob('*') if p.is_file()}
    assert actual == {p: item['sha256'] for p, item in capsule.items()}
for name, value in (('inputs', capsule), ('channels', {
        'command': command, 'returncode': result.returncode,
        'stdout_base64': base64.b64encode(result.stdout).decode(),
        'stderr_base64': base64.b64encode(result.stderr).decode()})):
    with (ROOT / (PREFIX + stage + '-diagnostics-' + name + '.json.gz')).open('xb') as output:
        output.write(gzip.compress(json.dumps(value, sort_keys=True).encode(), mtime=0))
record = {'stage': stage, 'command': command, 'returncode': result.returncode,
          'producer_sha256': sha(Path(__file__).read_bytes()),
          'inputs': {p: {k: v for k, v in item.items() if k != 'bytes_base64'}
                     for p, item in capsule.items()},
          'inputs_sha256': sha((ROOT / (PREFIX + stage + '-diagnostics-inputs.json.gz')).read_bytes()),
          'channels_sha256': sha((ROOT / (PREFIX + stage + '-diagnostics-channels.json.gz')).read_bytes()),
          'scope': 'Full dedicated public Perl diagnostic contract, including native/generated/CLI execution, '
                   'quiet sinkless operation, typed events/exit, error identity, arity and ordered effects. '
                   'System Perl/stdlib are reused read-only; every supplied file and complete channel is retained.'}
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
assert result.returncode == 0 and not result.stderr and b'Result: PASS' in result.stdout
print('Output diagnostic contract', stage, 'PASS;', len(paths), 'supplied inputs')
