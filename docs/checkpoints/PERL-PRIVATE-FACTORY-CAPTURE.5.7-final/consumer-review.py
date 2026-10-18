"""Readonly final consumer custody and exact accepted/preserved population review."""
import base64
import gzip
import hashlib
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/'
INITIAL = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/'
ACCEPTED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.6/'
PRESERVED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-object/'
FIXTURE = 't/actionir_default_object_capture.t'
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
assert sys.argv[1:] in ([], ['--capture'])
paths = set()
def raw(path):
    paths.add(path)
    return (ROOT / path).read_bytes()
def record(prefix):
    return json.loads(raw(prefix + 'consumers.json'))
def channels(prefix):
    return json.loads(gzip.decompress(raw(prefix + 'consumers-channels.json.gz')))
current, initial, accepted = record(PREFIX), record(INITIAL), record(ACCEPTED)
now, previous, old = channels(PREFIX), channels(INITIAL), channels(ACCEPTED)
preserved = json.loads(raw(PRESERVED + 'preservation.json'))
for name in ('consumers.json', 'consumers-channels.json.gz'):
    assert sha(raw(INITIAL + name)) == preserved['inputs'][INITIAL + name]['sha256']
assert current['command'] == now['command'] == initial['command'] + [FIXTURE], 'complete supplied suite selection'
assert initial['command'] == accepted['command'] + ['t/actionir_control_default_capture.t']
assert current['returncode'] == now['returncode'] == 0 and current['unchanged']
assert now['stderr_base64'] == previous['stderr_base64'] == old['stderr_base64']
assert current['producer_sha256'] == sha(raw(PREFIX + 'consumers.py'))
payload = raw(PREFIX + 'consumers-inputs.json.gz')
assert current['capsule_sha256'] == sha(payload)
assert current['channels_sha256'] == sha(raw(PREFIX + 'consumers-channels.json.gz'))
capsule = json.loads(gzip.decompress(payload))
mutable = {'perl/LinkedSpec/ActionIR/' + x + '.pm' for x in ('ControlFlow','FlowExpr','MethodLowering','ValueExpr')}
mutable.add('perl/LinkedSpec/RuleIR/EmitContext.pm')
assert current['inputs'] == {p: x['sha256'] for p, x in capsule.items()}
assert current['modes'] == {p: x['mode'] for p, x in capsule.items()}
for path, item in capsule.items():
    assert sha(decode(item['bytes_base64'])) == item['sha256'] == sha(raw(path))
    assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
    if path in initial['inputs'] and path not in mutable:
        assert item['sha256'] == initial['inputs'][path]
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
older, prior, final = suites(old), suites(previous), suites(now)
assert [r['path'] for r in final] == [r['path'] for r in prior] + [FIXTURE]
assert [r['plan'] for r in final] == [r['plan'] for r in prior] + [444]
assert len(older) == 89 and len(prior) == 90 and len(final) == 91 and len(capsule) == 363
added = b'LinkedSpec::RuleIR::EmitContext::_register_builtin_control_emission_callback is outside the exact FlowExpr population'
names = lambda row: re.findall(rb'^ok \d+ - (.*)$', row['body'], re.M)
for before, after in zip(older, final):
    assert before['path'] == after['path']
    if before['path'] == 't/actionir_flow_default_capture.t':
        assert after['plan'] == before['plan'] + 1
        assert names(after).count(added) == 1
        assert [v for v in names(after) if v != added] == names(before), 'exact accepted foreign-definition extension'
    else:
        assert before['plan'] == after['plan']
assert sum(r['plan'] for r in final) == 30394
assert re.search(rb'Files=91, Tests=30394\b', decode(now['stdout_base64'])) and b'Result: PASS' in decode(now['stdout_base64'])
raw(PREFIX + 'consumer-review.py')
report = dict(result='PASS', producer_sha256=sha(Path(__file__).read_bytes()),
    suites=91, supplied_inputs=363, assertions=30394,
    inputs={p: sha((ROOT / p).read_bytes()) for p in sorted(paths)},
    scope='Complete preserved90-suite logical command plus corrected444 object fixture. All original90 plans are exact. Relative to accepted89, only the independently named one-row FlowExpr foreign-definition extension changes an old plan; its every original name/order remains exact. Every supplied byte/mode and complete actual raw channel is retained. This is focused consumer proof, not canonical fixture registration.')
target = ROOT / (PREFIX + 'consumer-review.json')
if sys.argv[1:]:
    with target.open('x') as output:
        output.write(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
print('Final supplied consumer review PASS:91 suites/363 inputs/30394 assertions; exact90 plans and accepted foreign-definition delta')
