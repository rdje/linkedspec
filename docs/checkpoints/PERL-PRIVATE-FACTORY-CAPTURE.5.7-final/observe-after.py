"""One-shot current native capture; ordinary recurrence excludes authority order."""
import base64
import copy
import gzip
import hashlib
import json
import os
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/'
LEGACY = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/'
INSTRUMENT = 't/actionir_control_default_native.pl'
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
encode = lambda value: base64.b64encode(value).decode()
target = ROOT / (PREFIX + 'after-native.json')
assert not target.exists(), 'one-shot current capture'
original = json.loads((ROOT / (LEGACY + 'before-native.json')).read_bytes())
before = json.loads(gzip.decompress((ROOT / (LEGACY + 'before-native-data.json.gz')).read_bytes()))
positive = json.loads((ROOT / (PREFIX + 'complete-after.json')).read_bytes())
paths = set(original['inputs']) | {LEGACY + name for name in ('before-native.json', 'before-native-data.json.gz', 'before-native-inputs.json.gz')} | {PREFIX + name for name in ('observe-after.py', 'complete-after.json')}
capsule = {}
for path in sorted(paths):
    source = ROOT / path
    assert source.is_file() and not source.is_symlink()
    value = source.read_bytes()
    capsule[path] = dict(sha256=sha(value), mode=source.stat().st_mode & 0o7777,
                         bytes_base64=encode(value))
for path in ('perl/LinkedSpec/ActionIR/ControlFlow.pm', 'perl/LinkedSpec/RuleIR/EmitContext.pm',
             'perl/LinkedSpec/ActionIR/ValueExpr.pm', 'perl/LinkedSpec/ActionIR/FlowExpr.pm', 'perl/LinkedSpec/ActionIR/MethodLowering.pm'):
    assert capsule[path]['sha256'] == positive['inputs'][path]['sha256']
commands = [['perl', '-c', '-Iperl', INSTRUMENT]] + [
    ['perl', '-Iperl', INSTRUMENT] + extra for extra in ([], [], ['cold'], ['cold'])]
environment = dict(os.environ, PERL5LIB='', PERL5OPT='')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
data = []
for command in commands:
    result = subprocess.run(command, cwd=ROOT, env=environment, capture_output=True)
    row = dict(command=command, returncode=result.returncode,
               stdout_base64=encode(result.stdout), stderr_base64=encode(result.stderr))
    if '-c' not in command:
        row['observation'] = json.loads(result.stdout)
    data.append(row)
for stem, value in (('after-native-inputs', capsule), ('after-native-data', data)):
    with (ROOT / (PREFIX + stem + '.json.gz')).open('xb') as output:
        output.write(gzip.compress(json.dumps(value, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
record = dict(result='captured', producer_sha256=sha(Path(__file__).read_bytes()),
    instrument_sha256=sha((ROOT / INSTRUMENT).read_bytes()),
    capsule_sha256=sha((ROOT / (PREFIX + 'after-native-inputs.json.gz')).read_bytes()),
    data_sha256=sha((ROOT / (PREFIX + 'after-native-data.json.gz')).read_bytes()),
    inputs={p: {k: x[k] for k in ('sha256', 'mode')} for p, x in capsule.items()},
    warm_raw_recurrence=data[1] == data[2], cold_raw_recurrence=data[3] == data[4],
    scope='All original26 warm/26 cold ordinary rows and recurrences remain exact. Actual authority channels retain hash-iteration registration-attempt order without an ordered recurrence promise; sorted attempt bags and all other authority fields recur exactly. The original writer namespace failure and its independent predicate review stay frozen. Complete supplied inputs and raw channels remain recoverable.')
with target.open('x') as output:
    output.write(json.dumps(record, indent=2) + '\n')
assert all(r['returncode'] == 0 for r in data)
assert not decode(data[0]['stdout_base64']) and decode(data[0]['stderr_base64']) == (INSTRUMENT + ' syntax OK\n').encode()

def ordinary(value):
    if isinstance(value, dict):
        return {k: ordinary(v) for k, v in value.items() if k != 'authority'}
    if isinstance(value, list):
        return [ordinary(v) for v in value]
    return value

def unordered(value):
    value = copy.deepcopy(value)
    for row in value['rows']:
        row['authority']['registrations'].sort()
    return value

for first, second in ((1, 2), (3, 4)):
    assert not decode(data[first]['stderr_base64']) and not decode(data[second]['stderr_base64'])
    current = data[first]['observation']
    assert ordinary(current) == ordinary(before[first]['observation']), 'complete original ordinary ledger'
    assert ordinary(current) == ordinary(data[second]['observation']), 'ordinary recurrence'
    assert unordered(current) == unordered(data[second]['observation']), 'registration-bag recurrence'
    assert {'perl/' + p for p in current['loaded_project_modules']} <= paths
for path, item in capsule.items():
    assert sha((ROOT / path).read_bytes()) == item['sha256']
    assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
print('Current mixed-default native PASS:26 warm/26 cold ordinary rows exact; ordinary and registration-bag recurrences')
