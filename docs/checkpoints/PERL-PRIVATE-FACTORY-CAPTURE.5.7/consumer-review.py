"""Readonly complete consumer review, including the exact dynamic fixture delta."""
import base64
import gzip
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/'
PRIOR = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.6/'
FIXTURE = 't/actionir_control_default_capture.t'
FLOW = 't/actionir_flow_default_capture.t'
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
assert sys.argv[1:] in ([], ['--capture'])
paths = set()

def read(path):
    paths.add(path)
    return (ROOT / path).read_bytes()

def load(path):
    return json.loads(read(path))

current = load(PREFIX + 'consumers.json')
prior = load(PRIOR + 'consumers.json')
channels = json.loads(gzip.decompress(read(PREFIX + 'consumers-channels.json.gz')))
old_channels = json.loads(gzip.decompress(read(PRIOR + 'consumers-channels.json.gz')))
capsule_raw = read(PREFIX + 'consumers-inputs.json.gz')
capsule = json.loads(gzip.decompress(capsule_raw))
assert current['returncode'] == channels['returncode'] == 0 and current['unchanged']
assert current['command'] == channels['command'] == prior['command'] + [FIXTURE], 'complete supplied suite selection'
assert current['producer_sha256'] == sha(read(PREFIX + 'consumers.py'))
assert current['capsule_sha256'] == sha(capsule_raw)
assert current['channels_sha256'] == sha(read(PREFIX + 'consumers-channels.json.gz'))
assert channels['stderr_base64'] == old_channels['stderr_base64']
assert current['inputs'] == {p: x['sha256'] for p, x in capsule.items()}
assert current['modes'] == {p: x['mode'] for p, x in capsule.items()}
mutable = {'perl/LinkedSpec/ActionIR/ControlFlow.pm', 'perl/LinkedSpec/RuleIR/EmitContext.pm',
           'perl/LinkedSpec/ActionIR/ValueExpr.pm'}
for path, item in capsule.items():
    assert sha(decode(item['bytes_base64'])) == item['sha256'] == sha(read(path))
    assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
    if path in prior['inputs'] and path not in mutable:
        assert item['sha256'] == prior['inputs'][path]

def suites(value):
    text = decode(value['stdout_base64'])
    headers = list(re.finditer(rb'^([^\s]+\.t)\s+\.{2,}\s*$', text, re.M))
    result = []
    for i, match in enumerate(headers):
        body = text[match.end():headers[i + 1].start() if i + 1 < len(headers) else len(text)]
        plans = re.findall(rb'^1\.\.(\d+)\s*$', body, re.M)
        assert len(plans) == 1 and not re.search(rb'^not ok|^Bail out!', body, re.M)
        result.append(dict(path=match[1].decode(), plan=int(plans[0]), body=body))
    return result

old, new = suites(old_channels), suites(channels)
assert len(old) == 89 and len(new) == 90 and len(capsule) == 356
assert [r['path'] for r in new] == [r['path'] for r in old] + [FIXTURE]
added = b'LinkedSpec::RuleIR::EmitContext::_register_builtin_control_emission_callback is outside the exact FlowExpr population'
delta = []
for before, after in zip(old, new):
    if before['path'] != FLOW:
        assert before['plan'] == after['plan'], ('unchanged predecessor plan', before['path'])
        continue
    assert after['plan'] == before['plan'] + 1
    names = lambda row: re.findall(rb'^ok \d+ - (.*)$', row['body'], re.M)
    original_names, current_names = names(before), names(after)
    assert current_names.count(added) == 1 and added not in original_names
    assert [name for name in current_names if name != added] == original_names, 'exact dynamic foreign-definition delta'
    delta.append(dict(path=FLOW, old_plan=before['plan'], new_plan=after['plan'], added_name=added.decode()))
assert len(delta) == 1 and new[-1]['plan'] == 445
assert sum(r['plan'] for r in new) == 29950
assert re.search(rb'Files=90, Tests=29950\b', decode(channels['stdout_base64']))
assert b'Result: PASS' in decode(channels['stdout_base64'])
read(PREFIX + 'consumer-review.py')
report = dict(result='PASS', producer_sha256=sha(Path(__file__).read_bytes()),
    suites=90, supplied_inputs=356, assertions=29950, dynamic_delta=delta,
    inputs={p: sha((ROOT / p).read_bytes()) for p in sorted(paths)},
    scope='Complete accepted89-suite ordered command plus the identical445-assertion fixture. Every supplied byte/mode and raw channel is checked. All predecessor plans remain exact except the existing FlowExpr dynamic foreign-definition enumeration: its sole added row rejects the new private ControlFlow selector; every original named assertion remains exact and ordered. No source fixture is rewritten to hide the delta.')
target = ROOT / (PREFIX + 'consumer-review.json')
if sys.argv[1:]:
    with target.open('x') as output:
        output.write(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
print('Complete consumer review PASS:90 suites/356 inputs/29950 assertions; exact one-row FlowExpr foreign-definition extension')
