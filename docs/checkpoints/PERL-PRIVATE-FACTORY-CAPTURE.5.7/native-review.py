"""Readonly first native capture review; --capture freezes namespace controls."""
import base64
import gzip
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = 'ce9eaf32e19002c5fe11e22e5de3c3094270843d'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/'
INSTRUMENT = 't/actionir_control_default_native.pl'
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
encode = lambda value: base64.b64encode(value).decode()
assert sys.argv[1:] in ([], ['--capture'])
paths = {PREFIX + name for name in ('observe.py', 'before-native.json',
    'before-native-inputs.json.gz', 'before-native-data.json.gz', 'native-review.py')}
raw = lambda name: (ROOT / (PREFIX + name)).read_bytes()
record = json.loads(raw('before-native.json'))
capsule = json.loads(gzip.decompress(raw('before-native-inputs.json.gz')))
data = json.loads(gzip.decompress(raw('before-native-data.json.gz')))
assert record['base'] == BASE
assert record['producer_sha256'] == sha(raw('observe.py'))
assert record['capsule_sha256'] == sha(raw('before-native-inputs.json.gz'))
assert record['data_sha256'] == sha(raw('before-native-data.json.gz'))
assert record['instrument_sha256'] == sha((ROOT / INSTRUMENT).read_bytes())
assert record['inputs'] == {p: {k: x[k] for k in ('sha256', 'mode')} for p, x in capsule.items()}
mutable = {'perl/LinkedSpec/ActionIR/ControlFlow.pm', 'perl/LinkedSpec/RuleIR/EmitContext.pm',
           'perl/LinkedSpec/ActionIR/ValueExpr.pm'}
for path, item in capsule.items():
    value = decode(item['bytes_base64'])
    assert sha(value) == item['sha256']
    if path in mutable:
        assert value == subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
    else:
        assert (ROOT / path).read_bytes() == value
        assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
    paths.add(path)
assert len(data) == 5 and all(row['returncode'] == 0 for row in data)
assert not decode(data[0]['stdout_base64'])
assert decode(data[0]['stderr_base64']) == (INSTRUMENT + ' syntax OK\n').encode()
assert data[1] == data[2] and data[3] == data[4], 'original exact recurrences'
for index in (1, 3):
    row = data[index]
    assert not decode(row['stderr_base64'])
    assert json.loads(decode(row['stdout_base64'])) == row['observation']
    observed = row['observation']
    assert len(observed['rows']) == 26
    assert len({(r['label'], r['context']) for r in observed['rows']}) == 26
    assert observed['source_emissions_loaded'] == (1 if index == 1 else 0)
    assert observed['trace_loaded'] == 0
    assert {'perl/' + p for p in observed['loaded_project_modules']} <= set(capsule), 'normalized loaded namespace'
source = raw('observe.py')
predicate = "assert set(item['observation']['loaded_project_modules']) <= paths, 'complete parent runtime namespace'"
assert source.count(predicate.encode()) == 1
setup = ("import gzip,json\nfrom pathlib import Path\n"
    "p=Path(" + repr(PREFIX) + ")\n"
    "paths=set(json.loads((p/'before-native.json').read_bytes())['inputs'])\n"
    "item=json.loads(gzip.decompress((p/'before-native-data.json.gz').read_bytes()))[1]\n")
commands = [
    ['python3', '-c', setup + predicate + '\n'],
    ['python3', '-c', setup + "assert {'perl/'+p for p in item['observation']['loaded_project_modules']} <= paths, 'normalized loaded namespace'\n"],
    ['python3', '-c', setup + "item['observation']['loaded_project_modules'].append('LinkedSpec/NotSupplied.pm')\nassert {'perl/'+p for p in item['observation']['loaded_project_modules']} <= paths, 'normalized loaded namespace'\n"],
]
failed_review = PREFIX + 'native-review-syntax-failure.py'
paths.add(failed_review)
failed_source = (ROOT / failed_review).read_bytes()
assert failed_source.replace(b"'normalized loaded namespace'\\n'],", b"'normalized loaded namespace'\\n\"],", 1) != failed_source
syntax_command = ['python3', failed_review]
target = ROOT / (PREFIX + 'native-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot namespace review'
    controls = []
    for command in commands:
        result = subprocess.run(command, cwd=ROOT, capture_output=True)
        controls.append(dict(command=command, returncode=result.returncode,
            stdout_base64=encode(result.stdout), stderr_base64=encode(result.stderr)))
    result = subprocess.run(syntax_command, cwd=ROOT, capture_output=True)
    syntax_control = dict(command=syntax_command, returncode=result.returncode,
        stdout_base64=encode(result.stdout), stderr_base64=encode(result.stderr))
else:
    controls = json.loads(target.read_bytes())['namespace_controls']
    syntax_control = json.loads(target.read_bytes())['syntax_control']
assert syntax_control['command'] == syntax_command and syntax_control['returncode'] != 0
assert not decode(syntax_control['stdout_base64']) and b'SyntaxError: unterminated string literal' in decode(syntax_control['stderr_base64'])
assert [r['command'] for r in controls] == commands
assert controls[0]['returncode'] != 0 and b'complete parent runtime namespace' in decode(controls[0]['stderr_base64'])
assert controls[1]['returncode'] == 0 and not decode(controls[1]['stderr_base64'])
assert controls[2]['returncode'] != 0 and b'normalized loaded namespace' in decode(controls[2]['stderr_base64'])
assert all(not decode(row['stdout_base64']) for row in controls)
report = dict(result='PASS', base=BASE, producer_sha256=sha(Path(__file__).read_bytes()),
    rows=dict(warm=26, cold=26), namespace_controls=controls, syntax_control=syntax_control,
    inputs={p: sha((ROOT / p).read_bytes()) for p in sorted(paths) if p not in mutable},
    scope='The original observation writer failed its post-capture namespace assertion after retaining all five successful native command channels, sources and26/26 exact recurrences. No observation is refreshed. The exact original assertion is re-evaluated against its retained inputs and observed RED; normalization alone passes and an added unsupplied module is rejected. These are actual predicate subprocess channels, not a claimed rerun or separated-channel reconstruction of the original writer failure. Mutable production bytes remain pinned to accepted Git/capsule originals; current behavior is separate.')
if sys.argv[1:]:
    with target.open('x') as output:
        output.write(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
print('Mixed-default native review PASS:26 warm/26 cold; original namespace RED; normalized PASS; unsupplied module RED')
