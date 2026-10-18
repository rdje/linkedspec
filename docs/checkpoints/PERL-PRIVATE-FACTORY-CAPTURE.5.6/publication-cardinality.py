"""Readonly cardinality control; --capture runs its original/mutant pair once."""
import base64
import gzip
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = '2b35b77ea0e08d178ccb054a8f8310dbe0abb9c1'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.6/'
MODULE = 'perl/LinkedSpec/ActionIR/SourceEmissions.pm'
CONTROL_FLOW = 'perl/LinkedSpec/ActionIR/ControlFlow.pm'
FIXTURE = 't/actionir_source_emissions.t'
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
encode = lambda value: base64.b64encode(value).decode()
assert sys.argv[1:] in ([], ['--capture'])
target = ROOT / (PREFIX + 'publication-cardinality.json')


def tap(row):
    text = decode(row['stdout_base64']).decode()
    tests = re.findall(r'^(not )?ok (\d+) - (.*)$', text, re.M)
    assert re.findall(r'^1\.\.(\d+)$', text, re.M) == [str(len(tests))]
    assert [int(n) for _, n, _ in tests] == list(range(1, len(tests) + 1))
    assert not re.search(r'^Bail out!', text, re.M)
    return len(tests), [{'number': int(n), 'name': name} for bad, n, name in tests if bad]


if sys.argv[1:]:
    assert not target.exists(), 'one-shot original/allow-multiple control'
    original = json.loads(gzip.decompress((ROOT / (PREFIX + 'before-native-inputs.json.gz')).read_bytes()))
    for path in (FIXTURE, PREFIX + 'publication-cardinality.py'):
        source = ROOT / path
        value = source.read_bytes()
        original[path] = {'sha256': sha(value), 'mode': source.stat().st_mode & 0o7777, 'bytes_base64': encode(value)}
    assert all((ROOT / path).read_bytes() == decode(item['bytes_base64']) for path, item in original.items())
    capsule = ROOT / (PREFIX + 'publication-cardinality-inputs.json.gz')
    with capsule.open('xb') as output:
        output.write(gzip.compress(json.dumps(original, sort_keys=True).encode(), mtime=0))
    source = decode(original[MODULE]['bytes_base64'])
    predicate = b'@{$_call->{publications}} == 1'
    assert source.count(predicate) == 1
    mutant = source.replace(predicate, b'@{$_call->{publications}} >= 1', 1)
    environment = dict(os.environ, PERL5LIB='', PERL5OPT='')
    environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
    rows = []
    for name, selected in (('original', source), ('allow-multiple', mutant)):
        files = {path: decode(item['bytes_base64']) for path, item in original.items()}
        files[MODULE] = selected
        with tempfile.TemporaryDirectory(prefix='publication-cardinality-', dir=os.environ['TMPDIR']) as directory:
            supplied = Path(directory)
            assert supplied.stat().st_dev == ROOT.stat().st_dev
            for path, value in files.items():
                destination = supplied / path
                destination.parent.mkdir(parents=True, exist_ok=True)
                destination.write_bytes(value)
                destination.chmod(original[path]['mode'])
            channels = []
            for command in (['perl', '-c', '-Iperl', MODULE], ['perl', '-Iperl', FIXTURE]):
                process = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
                channels.append({'command': command, 'returncode': process.returncode,
                                 'stdout_base64': encode(process.stdout), 'stderr_base64': encode(process.stderr)})
            unchanged = {p.relative_to(supplied).as_posix(): sha(p.read_bytes()) for p in supplied.rglob('*') if p.is_file()} == {p: sha(v) for p, v in files.items()}
        count, failed = tap(channels[1])
        rows.append({'name': name, 'module_base64': encode(selected), 'module_sha256': sha(selected),
                     'channels': channels, 'assertions': count, 'failures': failed, 'unchanged': unchanged})
    report = {'result': 'PASS', 'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
              'capsule_sha256': sha(capsule.read_bytes()), 'rows': rows,
              'scope': 'The existing emission foundation fixture supplies an independent two-equal-publication oracle. Complete original and single-predicate mutant sources, full coherent TAP, command channels and supplied byte/mode inputs are retained. Production source is unchanged. This calibrates interpretation of the native multi-rule rows; packet absence alone does not establish callback isolation.'}
    with target.open('x') as output:
        output.write(json.dumps(report, indent=2) + '\n')
else:
    report = json.loads(target.read_bytes())
assert report['result'] == 'PASS' and report['producer_sha256'] == sha(Path(__file__).read_bytes())
capsule_raw = (ROOT / (PREFIX + 'publication-cardinality-inputs.json.gz')).read_bytes()
assert sha(capsule_raw) == report['capsule_sha256']
original = json.loads(gzip.decompress(capsule_raw))
for path, item in original.items():
    value = decode(item['bytes_base64'])
    assert sha(value) == item['sha256']
    current = subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT) if path == CONTROL_FLOW else (ROOT / path).read_bytes()
    assert current == value
source = decode(original[MODULE]['bytes_base64'])
for index, row in enumerate(report['rows']):
    expected = source if index == 0 else source.replace(b'@{$_call->{publications}} == 1', b'@{$_call->{publications}} >= 1', 1)
    assert decode(row['module_base64']) == expected and sha(expected) == row['module_sha256']
    assert row['unchanged'] and row['channels'][0]['returncode'] == 0
    count, failed = tap(row['channels'][1])
    assert count == row['assertions'] and failed == row['failures']
    if index == 0:
        assert row['channels'][1]['returncode'] == 0 and not failed and not decode(row['channels'][1]['stderr_base64'])
    else:
        assert row['channels'][1]['returncode'] != 0 and len(failed) == 1
        assert failed[0]['name'] == 'multiple equal publications are ambiguous'
assert len(report['rows']) == 2 and report['rows'][0]['assertions'] == report['rows'][1]['assertions']
print('Publication cardinality PASS:', report['rows'][0]['assertions'], 'original assertions; one exact distinguishing semantic RED')
