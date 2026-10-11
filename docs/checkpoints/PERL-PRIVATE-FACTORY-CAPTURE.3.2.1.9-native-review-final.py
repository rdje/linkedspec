"""Readonly exact native/public and legacy observation review; --capture writes once."""
import base64
import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'de02b83a1a794370b4071bb53677ab675745acc2'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9-'
PREVIOUS = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_uniform_target_probe.pl'
SEED = PREVIOUS + 'consumers.json'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT)
load = lambda p: json.loads((ROOT / p).read_bytes())
decode = lambda value: base64.b64decode(value, validate=True)
payload = lambda row: json.loads(decode(row['stdout_base64']))
assert sys.argv[1:] in ([], ['--capture'])
old_line = rb'return undef unless $target_expr =~ /^\Q$container\E\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\s*\)$/o;'
new_line = old_line.replace(b'$/o;', b'$/;')
original_source = old(MODULE)
assert original_source.count(old_line) == 1
assert (ROOT / MODULE).read_bytes() == original_source.replace(old_line, new_line), 'sole current-container source correction'
seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert len(seed['inputs']) == 223
names = 'first other first-again other-again stale-wrong empty-wrong empty-literal literal-dot dot-lookalike bare undefined-target undefined-container spaced compound kind-array kind-undefined kind-zero effect fatal trailing-newline'.split()
called = set('first other first-again other-again empty-literal literal-dot spaced kind-array kind-undefined kind-zero effect fatal trailing-newline'.split())
values = {name: 'item' for name in 'first other first-again other-again empty-literal literal-dot bare spaced trailing-newline'.split()}
values['effect'] = 'item!'
records = {}
for mode in ('before', 'after'):
    record = load(PREFIX + mode + '-observations.json')
    records[mode] = record
    if mode == 'after': assert record['modes'] == records['before']['modes'], 'exact native/public input modes'
    assert record['base'] == BASE and record['mode'] == mode and record['unchanged']
    assert record['producer_sha256'] == sha((ROOT / (PREFIX + 'observe.py')).read_bytes())
    expected = dict(seed['inputs'])
    if mode == 'after': expected[MODULE] = sha((ROOT / MODULE).read_bytes())
    expected[PROBE] = sha((ROOT / PROBE).read_bytes())
    assert record['inputs'] == expected and len(expected) == 224, 'complete native/public supplied inputs'
    assert set(record['modes']) == set(expected) and all(m in (0o640, 0o644, 0o750, 0o755) for m in record['modes'].values())
    assert [(r['surface'], r['first']) for r in record['rows']] == [(s, f) for s in ('native', 'public') for f in ('array', 'hash')]
    for row in record['rows']:
        assert row['command'] == ['perl', '-Iperl', './' + PROBE, row['surface'], row['first']]
        assert row['returncode'] == 0 and not decode(row['stderr_base64'])
        observed = payload(row)
        assert observed['mode'] == row['surface'] and observed['first'] == row['first']
        if row['surface'] != 'native': continue
        assert [r['id'] for r in observed['rows']] == names, 'complete exact native member order'
        by_name = {r['id']: r for r in observed['rows']}
        if mode == 'before':
            assert by_name['first']['value'] == 'item' and by_name['other']['value'] is None
            assert by_name['stale-wrong']['value'] == by_name['empty-wrong']['value'] == 'item', 'actual stale acceptance and rejection'
        else:
            for native in observed['rows']:
                name = native['id']
                assert native['value'] == values.get(name), ('current-container native result', row['first'], name)
                assert native['calls'] == ([{'argument': 'item', 'context': 'scalar', 'incoming_error': 'target incoming'}] if name in called else []), 'native actual arguments/context/error/once-only count'
                assert native['caller_after'] == native['input'], 'native caller alias preserved'
                assert native['error'] == ({'type': 'UniformTargetProbe::Fatal', 'actual': 1} if name == 'fatal' else None), 'native fatal object identity'
                assert native['success_error'] == (None if name == 'fatal' else 'target success' if name in called else 'target incoming'), 'native successful error effect'
changes = 0
for before, after in zip(records['before']['rows'], records['after']['rows']):
    a, b = payload(before), payload(after)
    if before['surface'] == 'public':
        assert a == b, 'complete actual public observations/emitted bytes changed'
        assert len(b['lowering']) == 4 and b['warm'] == 'item'
        for index, surface in enumerate(('array', 'hash')):
            assert b['lowering'][index]['value'] is None
            assert b['lowering'][index]['error'] == f'aggregate_selector_removed surface={surface} identifier=item replacement=item\n'
        assert all(r['error'] is None and r['value'] for r in b['lowering'][2:])
        expected = load('capability_conformance/uniform_binding_contract.json')['fixture']['expected']
        assert b['parser_type'] == 'CODE' and b['value'] == b['generated_value'] == expected
        assert b['error'] is b['last_error'] is b['generated_error'] is None and b['generated']
    else:
        changes += sum(x != y for x, y in zip(a['rows'], b['rows']))
assert changes == 26, 'exact changed native rows'
for mode in records:
    public = [payload(r) for r in records[mode]['rows'] if r['surface'] == 'public']
    for p in public: p.pop('first')
    assert public[0] == public[1], 'public first-container order independence'
legacy = load(PREFIX + 'legacy.json')
assert legacy['base'] == BASE and legacy['unchanged'] and legacy['producer_sha256'] == sha((ROOT / (PREFIX + 'legacy.py')).read_bytes())
expected = dict(seed['inputs']); expected[MODULE] = sha((ROOT / MODULE).read_bytes())
assert legacy['inputs'] == expected and len(expected) == 223
assert [r['name'] for r in legacy['rows']] == ['main', 'symbolic', 'reference']
for row, tail in zip(legacy['rows'], ('current', 'symbolic-current', 'reference-current')):
    assert row['returncode'] == 0 and not decode(row['stderr_base64'])
    previous = payload(load(PREVIOUS + tail + '.json'))
    expected = copy.deepcopy(previous)
    if row['name'] == 'main':
        native = next(r for r in expected['branches'] if r['name'] == 'target/container-empty')
        native.update(eligible=[], events=[], trace=[], success_error='incoming small kind', value=None)
    assert payload(row) == expected, 'sole five-field legacy observation migration / all symbolic and object rows exact'
paths = [PREFIX + 'native-review.py', PREFIX + 'first-native-review-failure.json', SEED, MODULE, PROBE, 'capability_conformance/uniform_binding_contract.json']
paths += [PREFIX + tail for tail in ('observe.py', 'before-observations.json', 'before-reached.json', 'after-observations.json', 'after-reached.json', 'legacy.py', 'legacy.json', 'legacy-reached.json', 'native-review-final.py')]
paths += [PREVIOUS + tail + '.json' for tail in ('current', 'symbolic-current', 'reference-current')]
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'inputs': {p: sha((ROOT / p).read_bytes()) for p in paths}, 'native_rows': 40, 'changed_native_rows': changes,
    'fresh_before_commands': 4, 'fresh_after_commands': 4, 'legacy_commands': 3,
    'scope': 'Complete224-input native/public before/after commands, exact40 member rows and26 intended changes; public full observations/emitted source stay exact across changes/orders. Complete223-input legacy probes change only five fields of target/container-empty; full symbolic/object observations unchanged. No authored-language failure, full-helper/private/parent/canonical admission.'}
target = ROOT / (PREFIX + 'native-review-final.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'native-review-final.json') == report
print('Container-target native review PASS40/26; actual public source/results unchanged; sole legacy five-field migration')
