"""Readonly review of the complete original/current native populations."""
import base64
import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '61a73324f06238418301eac88fd3f908665ecbe3'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
PROBE = 't/actionir_method_kind_probe.pl'
EXTRA = 't/actionir_method_kind_authority_probe.pl'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
load = lambda path: json.loads((ROOT / path).read_bytes())
decode = lambda value: base64.b64decode(value, validate=True)
payload = lambda row: json.loads(decode(row['stdout_base64']))
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert sys.argv[1:] in ([], ['--capture'])
seed_raw = old(SEED)
seed = json.loads(seed_raw)
assert len(seed['inputs']) == 225 and seed['returncode'] == 0 and seed['unchanged']
observations = {}
for mode in ('before', 'after'):
    expected = dict(seed['inputs'])
    if mode == 'after':
        expected[MODULE] = sha((ROOT / MODULE).read_bytes())
    expected[PROBE] = sha((ROOT / PROBE).read_bytes())
    for extra, producer, tail in ((False, 'observe.py', '-native.json'),
                                  (True, 'authority-observe.py', '-authority-native.json')):
        record = load(PREFIX + mode + tail)
        selected = dict(expected)
        if extra:
            selected[EXTRA] = sha((ROOT / EXTRA).read_bytes())
        assert record['base'] == BASE and record['mode'] == mode and record['unchanged']
        assert record['producer_sha256'] == sha((ROOT / (PREFIX + producer)).read_bytes())
        assert record['seed'] == SEED and record['seed_sha256'] == sha(seed_raw)
        assert record['inputs'] == selected and len(selected) == (227 if extra else 226)
        assert set(record['modes']) == set(selected)
        assert all(value in (0o640, 0o644, 0o750, 0o755) for value in record['modes'].values())
        surfaces = ['authority'] if extra else ['observe', 'cold-observe']
        assert [row['surface'] for row in record['rows']] == surfaces
        for row in record['rows']:
            command = ['perl', '-Iperl', './' + EXTRA] if extra else ['perl', '-Iperl', './' + PROBE, row['surface']]
            assert row['command'] == command and row['returncode'] == 0 and not decode(row['stderr_base64'])
            observations[mode, row['surface']] = payload(row)
        if mode == 'after':
            before = load(PREFIX + 'before' + tail)
            assert record['modes'] == before['modes'], 'exact native input modes'
    main = observations[mode, 'observe']
    cold = observations[mode, 'cold-observe']
    extra = observations[mode, 'authority']
    assert main['mode'] == 'observe' and main['loaded_before'] == 0 and main['loaded_after'] == 1
    assert cold['mode'] == 'cold-observe' and cold['loaded_before'] == cold['loaded_after'] == 0
    assert [len(main[key]) for key in ('callbacks', 'branches', 'authority', 'symbolic')] == [12, 59, 4, 16]
    assert len(cold['callbacks']) == 6 and not any(cold[key] for key in ('branches', 'authority', 'symbolic'))
    assert extra['original_replay'].encode() == decode(load(PREFIX + mode + '-native.json')['rows'][0]['stdout_base64'])
    assert len(extra['rows']) == 36
    assert [row['id'] for row in extra['rows']] == [
        owner + '/' + variant + '/known-' + str(known)
        for owner in ('outer', 'inner')
        for variant in ('code', 'qualified', 'unqualified', 'blessed-code', 'glob', 'undefined', 'array', 'hash', 'name-object')
        for known in (0, 1)]

before = observations['before', 'observe']
after = observations['after', 'observe']
expected = copy.deepcopy(before)
for row in expected['authority']:
    if row['id'].endswith('known-0'):
        row['eligible'] = [0]
    row['parent_packet'] = 0
assert after == expected, 'complete native population / sole authority changes'
assert observations['before', 'cold-observe'] == observations['after', 'cold-observe'], 'complete cold native population'
expected_extra = copy.deepcopy(observations['before', 'authority'])
expected_extra['original_replay'] = observations['after', 'authority']['original_replay']
for row in expected_extra['rows']:
    if row['eligible']:
        row['eligible'] = [int(row['id'].endswith('/code/known-1'))]
    row['parent_packet'] = 0
assert observations['after', 'authority'] == expected_extra, 'complete supplemental authority population'
changed = sum(a != b for key in ('callbacks', 'branches', 'authority', 'symbolic')
              for a, b in zip(before[key], after[key]))
changed += sum(a != b for a, b in zip(observations['before', 'authority']['rows'], observations['after', 'authority']['rows']))
assert changed == 20
for owner, line in (('outer', 2550), ('inner', 3850)):
    native = {row['id']: row for row in before['symbolic']}
    for variant in ('glob', 'undefined', 'array', 'hash', 'name-object'):
        assert native[owner + '/' + variant]['error'].endswith(f'MethodLowering.pm line {line}.\n')
    effect = next(row for row in before['callbacks'] if row['id'] == owner + '/effect')
    assert effect['caller_after'] == ('COUNT' if owner == 'outer' else 'AST_SET')
    assert effect['args_after'] == ['item'] and effect['written'] and effect['unrelated'] == 1
    kind = [row for row in effect['trace'] if row['role'] == 'kind']
    assert kind and all(row['context'] == 'scalar' and row['readonly'] == 0
                        and row['caller_slot'] == row['parser_slot'] == row['target_slot'] == 0 for row in kind)
branches = {row['id']: row for row in before['branches']}
roles = lambda row: [item['role'] for item in row['trace'] if item['role'] in ('kind', 'replacement')]
assert roles(branches['outer/replace-in-trim']) == ['kind']
assert roles(branches['inner/replace-in-trim']) == ['replacement']
assert roles(branches['outer/function-present']) == [] and roles(branches['inner/function-present']) == ['kind']
paths = [SEED, MODULE, PROBE, EXTRA, PREFIX + 'observe.py', PREFIX + 'authority-observe.py']
paths += [PREFIX + mode + tail for mode in ('before', 'after')
          for tail in ('-native.json', '-reached.json', '-authority-native.json', '-authority-reached.json')]
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
          'inputs': {path: sha((ROOT / path).read_bytes()) for path in paths},
          'loaded_rows': 91, 'cold_rows': 6, 'supplemental_rows': 36, 'changed_complete_rows': changed,
          'scope': 'Both real injected invocation boundaries with explicit secondary controls. Complete native/cold/supplemental observations, exact original replay, source locations, lookup timing and known CODE eligibility with no parent donation. No full-helper/private/canonical admission.'}
target = ROOT / (PREFIX + 'native-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot review capture'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'native-review.json') == report
print('Method-kind native review PASS:91+36 loaded/6 cold;20 complete authority-row changes')
