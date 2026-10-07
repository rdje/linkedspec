"""Retain exact instrument adjudications and mode-only historical claim controls."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('supplement-review.py')
REVISION = '31395e440a38acec7a6712d470a90a90a6567863'
CLAIM = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0.json'
sha = lambda raw: hashlib.sha256(raw).hexdigest()


def decode(block):
    raw = gzip.decompress(base64.b64decode(block['data'], validate=True))
    assert block['encoding'] == 'gzip-base64' and len(raw) == block['bytes'] and sha(raw) == block['sha256']
    return raw


original = subprocess.check_output(['git', 'show', REVISION + ':' + CLAIM], cwd=ROOT)
assert Path(PREFIX + 'before-selector-claim.json').read_bytes() == original
before = json.loads(original)
expected = copy.deepcopy(before)
count = 0
for claim in expected['claims']:
    assert claim['durability']['mode'] == 'live'
    for item in claim['durability']['inputs']:
        raw = subprocess.check_output(['git', 'show', REVISION + ':' + item['path']], cwd=ROOT)
        assert sha(raw) == item['sha256'], 'original retained input identity'
        count += 1
    claim['durability'].update(mode='historical', revision=REVISION)


def check_freeze(candidate):
    assert candidate == expected, 'only original mode/revision changed'


check_freeze(json.loads((ROOT / CLAIM).read_bytes()))
controls = []
for name, mutate in [
    ('changed original statement', lambda x: x['claims'][0].update(statement='changed')),
    ('changed original input hash', lambda x: x['claims'][0]['durability']['inputs'][0].update(sha256='0' * 64)),
    ('missing original input', lambda x: x['claims'][0]['durability']['inputs'].pop()),
    ('wrong historical revision', lambda x: x['claims'][0]['durability'].update(revision='0' * 40)),
    ('live after compiler change', lambda x: x['claims'][0]['durability'].update(mode='live')),
]:
    candidate = copy.deepcopy(expected); mutate(candidate); assert candidate != expected
    try:
        check_freeze(candidate)
    except AssertionError as error:
        controls.append({'name': name, 'observed_red': str(error)})
    else:
        raise AssertionError('accepted historical corruption')

old_test = Path(PREFIX + 'initial-test.t').read_text()
corrected = old_test.replace(
    "['return(matches(\"ifXtrue\", /if(true)/))', 1],",
    "['return(matches(\"ifXtrue\", /if(true)/))', 0],\n        ['return(matches(\"if(true)\", /if\\\\(true\\\\)/))', 1],")
corrected = corrected.replace("source_identity => 'membership.spec');\n        my $input", "generated_source_identity => 'membership.spec');\n        my $input")
assert corrected == Path(PREFIX + 'pre-regression-test.t').read_text(), 'exact initial test corrections only'
root_tap = decode(json.loads(Path(PREFIX + 'initial-root-tap.json').read_bytes())).decode()
assert re.findall(r'^not ok \d+ - (.+)$', root_tap, re.M) == [
    'native and independently loaded generated parsers preserve quoted data'], 'initial actual-root failure scope'
assert 'public dump and emitted source agree' in root_tap and "got: '0'" in root_tap and "expected: '1'" in root_tap, 'actual test defects retained'

spec = importlib.util.spec_from_file_location('original_membership_book_reviewer', PREFIX + 'initial-book.py')
book = importlib.util.module_from_spec(spec); spec.loader.exec_module(book)
report = json.loads(Path(PREFIX + 'initial-book.json').read_bytes())
manifest = json.loads(Path(PREFIX + 'initial-book-inputs.json').read_bytes())
try:
    book.check(report, manifest)
except AssertionError as error:
    assert str(error) == "repair teaching: another backend's behavior", 'original book rejection reason'
    rejection = str(error)
else:
    raise AssertionError('original smart punctuation reviewer should reject')
rendered = decode(report['html']).decode()
assert 'another backend’s behavior' in rendered, 'actual rendered smart apostrophe'
assert "another backend's behavior" in rendered.replace('’', "'"), 'exact display normalization'

phase0 = 't/phase0_regression.t'
phase0_original = subprocess.check_output(['git', 'show', REVISION + ':' + phase0], cwd=ROOT).decode()
old_stub = 'local *LinkedSpec::ActionIR::Scanner::scan_contract_ir_events = sub {'
new_stub = 'local *LinkedSpec::ActionIR::Scanner::_scan_executable_contract_ir_events = sub {'
assert phase0_original.count(old_stub) == 1
assert (ROOT / phase0).read_text() == phase0_original.replace(old_stub, new_stub), 'only compiler seam mock changes'
tails = ['rx = q/;/', 'rx = qr/}/', 'rx = q|/;|', 'rx = s/a;b/c;d/']
bad_ranges = [[[6, 21]], [[6, 22]], [[6, 22]], [[6, 22]]]
good_ranges = [[[20, 23]], [[21, 24]], [[20, 24]], [[20, 29]]]
bad = json.loads(Path(PREFIX + 'regression-before.json').read_bytes())
good = json.loads(Path(PREFIX + 'regression-after.json').read_bytes())
assert len(bad) == len(good) == len(tails), 'complete root-cause probe population'
for i, (a, b, tail) in enumerate(zip(bad, good, tails)):
    assert a['source'] == b['source'] == 'out = /(14,2)\n' + tail + '; return(out)', 'original host source'
    assert a['numeric_slash'] == b['numeric_slash'] == 0, 'whole-tail slash policy unchanged'
    assert a['ranges'] == bad_ranges[i] and b['ranges'] == good_ranges[i], 'phantom slash versus host quote interval'
    assert a['value'] is None and 'Can\'t modify constant item' in a['compile_error'], 'actual original compile RED'
    assert b['compile_error'] == '' and b['value'] == 7, 'isolated existing host compatibility GREEN'
    assert [r['contract'] for r in a['scans']] == [r['contract'] for r in b['scans']], 'unchanged contract population'
    for x, y in zip(a['scans'], b['scans']):
        assert x['original'] == y['original'], 'original scanner source/event/argument/origin channels unchanged'
    assignment = next(r for r in b['scans'] if r['contract'] == 'scalar_assignment_operator')
    assert [e['raw'] for e in assignment['selected']['events']] == ['out = /(14,2)', tail], 'both real assignments retained'
assert Path(PREFIX + 'regression-after.stderr').read_bytes() == b'', 'quiet corrected root probe'

spec = importlib.util.spec_from_file_location('initial_public_membership_reviewer', PREFIX + 'initial-review.py')
initial_review = importlib.util.module_from_spec(spec); spec.loader.exec_module(initial_review)
public_channels = []
for epoch in ('initial-before', 'final-after'):
    retained = json.loads(Path(PREFIX + epoch + '-observations.json').read_bytes())
    public_channels.append({(r['kind'], r['seed']): json.loads(decode(r['stdout']))
                            for r in retained['runs'] if r['kind'].startswith('public:')})
try:
    initial_review.check_public(*public_channels)
except KeyError as error:
    assert error.args == ('expected',), 'original public reviewer rejection reason'
else:
    raise AssertionError('initial reviewer must reject the original no-value-oracle case')

schema_path = ROOT / 'tools/check_claim_verification.py'
spec = importlib.util.spec_from_file_location('claim_schema', schema_path)
schema = importlib.util.module_from_spec(spec); spec.loader.exec_module(schema)
initial_claim = schema.strict_json(Path(PREFIX + 'initial-claim.json').read_bytes())
def no_input(*args):
    raise AssertionError('schema rejection must precede input lookup')
try:
    schema.validate(initial_claim, 'docs/claims/' + initial_claim['owner'] + '.json', no_input, no_input)
except ValueError as error:
    assert str(error) == "durability: expected keys ['status', 'mode', 'inputs']"
    schema_rejection = str(error)
else:
    raise AssertionError('initial unsupported durability key accepted')

result = {'original_hashes': count, 'historical_controls': controls,
          'initial_root_failed_group': 'native and independently loaded generated parsers preserve quoted data',
          'original_book_observed_red': rejection,
          'phase0_update': 'exact one-line private compiler mock entry',
          'numeric_newline_root_cases': len(tails),
          'numeric_newline_scope': 'Auxiliary Toolbox root-cause channels preserve original scanner events and whole-tail numeric policy; source-bound full Phase0 and eight LF/CRLF fixture cases establish regression acceptance.',
          'initial_public_review_observed_red': "KeyError: 'expected'; unsupported_nested and raw_operand have no original successful-value oracle",
          'initial_claim_schema_observed_red': schema_rejection,
          'claim_schema_sha256': sha(schema_path.read_bytes()),
          'scope': 'Preserves original claims/results/input hashes. Only durability mode/revision change; failed test and display instruments are corrected, not product semantics.',
          'instrument_sha256': sha(Path(__file__).read_bytes())}
Path(PREFIX + 'supplement-verification.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result))
