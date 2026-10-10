"""Retain/review supplied replays and exact loading/alias instrument refinements.

--capture runs four historical commands once. Default checks their retained raw
channels and exact source populations; it never refreshes original measurements.
"""
import base64
import copy
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '2c5f84092d91c808ab82b4b886b51e65fc1ac864'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0-consumers.json'
TEST = 't/actionir_method_general_return_capture.t'
COLD = 't/actionir_method_general_return_capture_cold.t'
TARGET = ROOT / (PREFIX + 'instrument-review.json')
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()
blob = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
checked = {}


def read(path):
    raw = (ROOT / path).read_bytes()
    checked[path] = digest(raw)
    return raw


def record(tail):
    return json.loads(read(PREFIX + tail + '.json'))


seed_raw = read(SEED)
assert seed_raw == blob(SEED)
seed = json.loads(seed_raw)
original = {p: blob(p) for p in seed['inputs']}
assert len(original) == 170 and {p: digest(raw) for p, raw in original.items()} == seed['inputs']
draft = read(PREFIX + 'loading-draft.t')
initial = read(PREFIX + 'initial-fixture.t')
assert initial == draft.replace(b'use LinkedSpec ();\n', b'use LinkedSpec ();\nuse LinkedSpec::ActionIR::MethodLowering ();\n', 1), 'loading correction exceeds explicit owner import'
additions = [
    (b'   my $parser_slot;\n   if (ref($state->{args}) eq \'ARRAY\') {\n    for my $i (0..$#{$state->{args}}) {$parser_slot = $i if same(\\$_[0], \\$state->{args}[$i])}\n   }\n', b''),
    (b', parser_slot => $parser_slot', b''),
    (b"   $_[0] .= '!' if $name eq 'trim_action_ir_value' && $options->{trim_slot_mutation} && defined($_[0]);\n", b''),
    (b" push @cases, ['statement-fallback-slot-mutation', 'statement', {args => ['Node', 'payload'], payload => undef, trim_slot_mutation => 1},\n  \"return ['?Node:',  payload]\", [qw(ast-statement parse_method_function_expr trim_action_ir_value payload trim_action_ir_value)]];\n", b''),
    (b" if ($label eq 'statement-fallback-slot-mutation') {\n  is_deeply([map {$_->{parser_slot}} grep {$_->{role} eq 'trim_action_ir_value'} @{$row->{trace}}], [0, 1],\n   'label and fallback trim retain actual parser array scalar slots');\n  is_deeply($row->{args_after}, ['Node!', 'payload!'], 'actual trim mutations survive in both parser array slots');\n }\n", b''),
]
reconstructed = read(TEST)
for added, replacement in additions:
    assert reconstructed.count(added) == 1, 'alias addition must be unique'
    reconstructed = reconstructed.replace(added, replacement, 1)
assert reconstructed == initial, 'complete fixture exceeds fallback slot instrumentation'
producer = read(PREFIX + 'capture.py')
complete_producer = read(PREFIX + 'complete-capture.py')
assert complete_producer == producer.replace(
    b"PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1-'",
    b"PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1-complete-'").replace(
    b'51 bounded', b'52 bounded').replace(b"['branches']) == 51", b"['branches']) == 52").replace(
    b'count == 565', b'count == 574'), 'complete producer exceeds named population/path refinement'
loading = record('loading-capture')
assert loading['result'] == 'PASS-diagnosis-only' and loading['base'] == BASE
assert loading['seed'] == SEED and loading['seed_sha256'] == digest(seed_raw)
assert loading['producer_sha256'] == digest(read(PREFIX + 'loading-capture.py'))
loading_files = dict(original, **{PREFIX + 'loading-draft.t': draft,
                                PREFIX + 'loading-probe.pl': read(PREFIX + 'loading-probe.pl')})
initial_files = dict(original, **{TEST: initial, COLD: read(COLD)})
assert len(loading_files) == len(initial_files) == 172
assert loading['inputs'] == {p: digest(raw) for p, raw in loading_files.items()}
native, before = record('native'), record('before')
for row in (native, before):
    assert row['base'] == BASE and row['seed'] == SEED and row['seed_sha256'] == digest(seed_raw)
    assert row['producer_sha256'] == digest(producer)
    assert row['inputs'] == {p: digest(raw) for p, raw in initial_files.items()}
    assert row['unchanged'] is True
assert native['command'] == ['perl', '-Iperl', TEST, 'observe'] and native['returncode'] == 0
assert before['command'] == ['perl', '-Iperl', TEST] and before['returncode'] == 9
old_observation = json.loads(base64.b64decode(native['stdout_base64'], validate=True))
complete_native = record('complete-native')
new_observation = copy.deepcopy(json.loads(base64.b64decode(complete_native['stdout_base64'], validate=True)))
assert len(old_observation['branches']) == 51 and len(new_observation['branches']) == 52
last = new_observation['branches'].pop()
assert last['case'] == 'statement-fallback-slot-mutation' and last['args_after'] == ['Node!', 'payload!']
assert [r['parser_slot'] for r in last['trace'] if r['role'] == 'trim_action_ir_value'] == [0, 1]
for row in new_observation['callbacks'] + new_observation['branches']:
    for trace in row['trace']:
        del trace['parser_slot']
assert new_observation == old_observation, 'earlier native observations changed beyond new alias field/row'
complete_before = record('complete-before')
old_out = base64.b64decode(before['stdout_base64'], validate=True)
new_out = base64.b64decode(complete_before['stdout_base64'], validate=True)
names = lambda raw: [line.split(b' - ', 1)[1] for line in raw.splitlines() if re.match(rb'^(?:not )?ok [0-9]+ - ', line)]
old_names, new_names = names(old_out), names(new_out)
assert len(old_names) == 565 and len(new_names) == 574
extra = [n for n in new_names if n.startswith(b'statement-fallback-slot-mutation ') or n in (
    b'label and fallback trim retain actual parser array scalar slots', b'actual trim mutations survive in both parser array slots')]
assert len(extra) == 9 and [n for n in new_names if n not in extra] == old_names
assert re.findall(rb'^1\.\.(\d+)$', old_out, re.M) == [b'565']
assert re.findall(rb'^1\.\.(\d+)$', new_out, re.M) == [b'574']
assert [n for n in old_out.splitlines() if n.startswith(b'not ok ')] == [n for n in new_out.splitlines() if n.startswith(b'not ok ')]
cases = [(loading_files, row) for row in loading['rows']] + [(initial_files, row) for row in (native, before)]
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot instrument replay already captured'
    rows = []
    for files, old in cases:
        with tempfile.TemporaryDirectory(prefix='return-instrument-', dir=os.environ['TMPDIR']) as temporary:
            supplied = Path(temporary)
            assert supplied.stat().st_dev == ROOT.stat().st_dev
            for path, raw in files.items():
                target = supplied / path
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(raw)
            result = subprocess.run(old['command'], cwd=supplied, env=environment, capture_output=True, check=False)
            census = {p.relative_to(supplied).as_posix(): digest(p.read_bytes()) for p in supplied.rglob('*') if p.is_file()}
            rows.append({'command': old['command'], 'inputs': {p: digest(raw) for p, raw in files.items()},
                         'returncode': result.returncode, 'stdout_base64': base64.b64encode(result.stdout).decode(),
                         'stderr_base64': base64.b64encode(result.stderr).decode(), 'unchanged': census == {p: digest(raw) for p, raw in files.items()}})
    TARGET.write_text(json.dumps({'result': 'retained-replay', 'producer_sha256': digest(Path(__file__).read_bytes()),
                                 'checked': dict(sorted(checked.items())), 'rows': rows}, indent=2) + '\n')
report = json.loads(TARGET.read_bytes())
assert report['result'] == 'retained-replay' and report['producer_sha256'] == digest(Path(__file__).read_bytes())
assert report['checked'] == dict(sorted(checked.items()))
assert len(report['rows']) == len(cases) == 4
for index, (row, (files, old)) in enumerate(zip(report['rows'], cases)):
    assert row['command'] == old['command'] and row['returncode'] == old['returncode'] and row['unchanged'] is True
    assert row['inputs'] == {p: digest(raw) for p, raw in files.items()}
    out, err = [base64.b64decode(row[k], validate=True) for k in ('stdout_base64', 'stderr_base64')]
    old_out, old_err = [base64.b64decode(old[k], validate=True) for k in ('stdout_base64', 'stderr_base64')]
    assert out == old_out, 'instrument replay stdout differs'
    if index == 0:
        pattern = rb'(?m)^#     \$expected = HASH\(0x[0-9a-fA-F]+\)$'
        assert len(re.findall(pattern, err)) == len(re.findall(pattern, old_err)) == 1
        assert re.sub(pattern, b'<expected HASH address>', err) == re.sub(pattern, b'<expected HASH address>', old_err)
        assert row['returncode'] == 255 and not re.search(rb'^1\.\.', out, re.M)
        assert len(re.findall(rb'^(?:not )?ok [0-9]+', out, re.M)) == 28
        assert b'Undefined subroutine &LinkedSpec::ActionIR::MethodLowering::_lower_return_payload_expr' in err
    else:
        assert err == old_err, 'instrument replay stderr differs beyond named draft HASH address'
    if index == 1:
        assert json.loads(out) == {'before': {'loaded': 0, 'callback': 0}, 'after': {'loaded': 1, 'callback': 1}, 'value': 'return 1'}
print('Instrument review PASS: exact owner-import correction; initial565 preserved; complete574 adds9 alias controls; supplied4 replays/172 files; only draft expected HASH address normalized')
