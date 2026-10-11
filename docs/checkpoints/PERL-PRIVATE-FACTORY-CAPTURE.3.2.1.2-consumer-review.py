"""Independently check every actual supplied command path, plan and assertion."""
import base64
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '61cca1cccff6027461e120e4236431d1bc7d20b1'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_small_kind_capture.t'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
seed_raw = subprocess.check_output(['git', 'show', BASE + ':' + SEED], cwd=ROOT)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
raw = (ROOT / (PREFIX + 'consumers.json')).read_bytes()
record = json.loads(raw)
assert record['base'] == BASE and record['seed_sha256'] == sha(seed_raw)
assert record['command'] == seed['command'] + [TEST], 'complete supplied consumer command population'
assert record['returncode'] == 0 and record['unchanged'], 'positive consumer command must pass'
assert record['producer_sha256'] == sha((ROOT / (PREFIX + 'capture-final.py')).read_bytes())
expected = dict(seed['inputs'])
expected[MODULE] = sha((ROOT / MODULE).read_bytes())
for path in ('t/actionir_small_kind_probe.pl', 't/actionir_small_kind_symbolic_probe.pl', 't/actionir_small_kind_reference_probe.pl', TEST, PREFIX + 'native.json', PREFIX + 'symbolic-native.json', PREFIX + 'reference-native.json', PREFIX + 'reference-native-final.json'):
    assert path not in expected
    expected[path] = sha((ROOT / path).read_bytes())
assert record['inputs'] == expected and len(expected) == 223, 'complete supplied consumer input population'
assert all(sha((ROOT / p).read_bytes()) == digest for p, digest in expected.items()), 'actual live consumer input identity'
stdout = base64.b64decode(record['stdout_base64'], validate=True)
stderr = base64.b64decode(record['stderr_base64'], validate=True)
assert stderr == base64.b64decode(seed['stderr_base64'], validate=True), 'exact predecessor diagnostic channel'
assert b'All tests successful.' in stdout and b'Result: PASS' in stdout
groups, current, assertions, plans = [], None, [], []
for line in stdout.splitlines():
    header = re.match(rb'^([^\s]+\.t)[ \t]+\.{2,}[ \t]*$', line)
    if header:
        if current is not None:
            groups.append((current, assertions, plans))
        current, assertions, plans = header[1].decode(), [], []
        continue
    if current is None:
        continue
    assertion = re.match(rb'^(not )?ok (\d+)(?: - (.*))?$', line)
    if assertion:
        assert not assertion[1], 'failed consumer assertion'
        assertions.append(int(assertion[2]))
    plan = re.match(rb'^1\.\.(\d+)$', line)
    if plan:
        plans.append(int(plan[1]))
if current is not None:
    groups.append((current, assertions, plans))
assert [path for path, _, _ in groups] == record['command'][3:], 'actual ordered suite header population'
assert len(groups) == 69
for path, assertions, plans in groups:
    assert len(plans) == 1 and assertions == list(range(1, plans[0] + 1)), ('complete actual suite plan', path)
total = sum(plans[0] for _, _, plans in groups)
assert total == 15093 and groups[-1][2] == [1135], 'actual consumer assertion population'
summary = re.findall(rb'^Files=(\d+), Tests=(\d+),', stdout, re.M)
assert summary == [(str(len(groups)).encode(), str(total).encode())], 'actual prove summary matches every plan'
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'capture_sha256': sha(raw), 'source_inputs': expected,
    'suite_plans': [{'path': path, 'assertions': plans[0]} for path, _, plans in groups],
    'suites': len(groups), 'assertions': total, 'inputs': len(expected),
    'scope': 'Every actual ordered command/header and full numeric plan, including checkpoint suites. Exact live input and predecessor stderr identities; no omitted path can be hidden by a summary count.'}
target = ROOT / (PREFIX + 'consumer-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot consumer review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
print('Small optional-kind consumer review PASS69 suites/223 inputs/15093 actual assertions')
