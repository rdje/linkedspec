"""One-shot current native recurrence; original instrument and ledger stay frozen."""
import base64
import gzip
import hashlib
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '09000223f2dac822b2c0d75c69dce587f2b5b2c0'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.3/'
INSTRUMENT = 't/actionir_control_switch_native.pl'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
target = ROOT / (PREFIX + 'after-native.json')
assert not target.exists(), 'one-shot first observation'
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip() == BASE
positive = json.loads((ROOT / (PREFIX + 'after.json')).read_bytes())
assert sha((ROOT / 'perl/LinkedSpec/ActionIR/ControlFlow.pm').read_bytes()) == positive['inputs']['perl/LinkedSpec/ActionIR/ControlFlow.pm']['sha256']
original = json.loads(gzip.decompress((ROOT / (PREFIX + 'before-native-inputs.json.gz')).read_bytes()))
for path, item in original.items():
    if path != 'perl/LinkedSpec/ActionIR/ControlFlow.pm':
        assert sha((ROOT / path).read_bytes()) == item['sha256'], ('unchanged original instrument/input', path)

tree = subprocess.check_output(
    ['git', 'ls-tree', '-r', BASE, '--', 'perl'], cwd=ROOT, text=True).splitlines()
paths = set(original)
paths.update((PREFIX+'after.json', PREFIX+'before-native.json',
              PREFIX+'before-native-inputs.json.gz', PREFIX+'before-native-data.json.gz'))
for line in tree:
    metadata, path = line.split('\t', 1)
    mode, kind, identity = metadata.split()
    if kind == 'blob':
        paths.add(path)
paths.update((INSTRUMENT, PREFIX + 'observe-after.py', 'tools/project_data_env.sh',
              'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
              '.knowledge_map.conf'))
capsule = {}
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink(), ('regular parent-owned input', path)
    raw = source.read_bytes()
    capsule[path] = {'sha256': sha(raw), 'mode': source.stat().st_mode & 0o7777,
                     'bytes_base64': base64.b64encode(raw).decode()}

environment = dict(os.environ, PERL5LIB='', PERL5OPT='')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
commands = [
    ['perl', '-c', '-Iperl', INSTRUMENT],
    ['perl', '-Iperl', INSTRUMENT],
    ['perl', '-Iperl', INSTRUMENT],
    ['perl', '-Iperl', INSTRUMENT, 'cold'],
    ['perl', '-Iperl', INSTRUMENT, 'cold'],
]
observations = []
for command in commands:
    process = subprocess.run(command, cwd=ROOT, env=environment, capture_output=True)
    row = {'command': command, 'returncode': process.returncode,
           'stdout_base64': base64.b64encode(process.stdout).decode(),
           'stderr_base64': base64.b64encode(process.stderr).decode()}
    if '-c' not in command:
        try:
            row['observation'] = json.loads(process.stdout)
        except (UnicodeDecodeError, json.JSONDecodeError) as error:
            row['parse_error'] = type(error).__name__
    observations.append(row)

capsule_path = ROOT / (PREFIX + 'after-native-inputs.json.gz')
data_path = ROOT / (PREFIX + 'after-native-data.json.gz')
for path, value in ((capsule_path, capsule), (data_path, observations)):
    with path.open('xb') as output:
        output.write(gzip.compress(json.dumps(value, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
result = {'result': 'captured', 'base': BASE,
          'producer_sha256': sha(Path(__file__).read_bytes()),
          'instrument_sha256': capsule[INSTRUMENT]['sha256'],
          'inputs': {path: {'sha256': item['sha256'], 'mode': item['mode']}
                     for path, item in capsule.items()},
          'capsule_sha256': sha(capsule_path.read_bytes()),
          'data_sha256': sha(data_path.read_bytes()),
          'commands': [{key: value for key, value in row.items()
                        if key not in ('stdout_base64', 'stderr_base64', 'observation')}
                       for row in observations],
          'scope': 'Current native recurrence after the positive paired proof; first original instrument/observations remain immutable. Complete native channels and observations are compressed without loss. All parent-owned Perl inputs, diagnostic/producer and wrapper bytes/modes are recoverable; loaded-project-module membership is checked. System Perl/stdlib are reused read-only without an immutable portable toolchain claim. Ordinary complete native rows must equal the original ledger; separate authority changes are checked by the unchanged paired fixture.'}
with target.open('x') as output:
    output.write(json.dumps(result, indent=2) + '\n')

assert all(item['returncode'] == 0 for item in observations), 'actual native commands'
assert base64.b64decode(observations[0]['stderr_base64']) == (INSTRUMENT + ' syntax OK\n').encode()
assert not base64.b64decode(observations[0]['stdout_base64'])
for item in observations[1:]:
    assert not base64.b64decode(item['stderr_base64']), 'native stderr is retained and must be reviewed'
    assert 'observation' in item, 'actual complete JSON observation'
    assert set(item['observation']['loaded_project_modules']) <= paths, 'complete parent runtime namespace'
for first, second in ((1, 2), (3, 4)):
    assert observations[first] == observations[second], 'byte-exact fresh-process recurrence'
for path, item in capsule.items():
    assert sha((ROOT / path).read_bytes()) == item['sha256'], ('unchanged actual input', path)
    assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
warm = observations[1]['observation']
cold = observations[3]['observation']
first = json.loads(gzip.decompress((ROOT / (PREFIX + 'before-native-data.json.gz')).read_bytes()))
for index in (1, 3):
    assert [row['label'] for row in observations[index]['observation']['rows']] == [row['label'] for row in first[index]['observation']['rows']], 'whole original label order/population'
    assert [row['native'] for row in observations[index]['observation']['rows']] == [row['native'] for row in first[index]['observation']['rows']], 'every original ordinary row exact'
print('Current ControlFlow native capture:', len(paths), 'complete parent inputs;',
      len(warm['rows']), 'warm rows;', len(cold['rows']), 'cold rows; byte-exact recurrences')
