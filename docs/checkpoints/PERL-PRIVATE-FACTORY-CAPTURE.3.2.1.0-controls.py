"""Retain actual compiled-source and binding-membership RED controls once."""
import base64
import copy
import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0-'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
BASE = '91e972cfa0d214784b0172828f7baa378c25f23e'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
b64 = lambda raw: base64.b64encode(raw).decode()
TARGET = ROOT / (PREFIX + 'controls.json')
assert not TARGET.exists(), 'one-shot controls'
source = (ROOT / MODULE).read_bytes()
inventory = json.loads((ROOT / (PREFIX + 'inventory.json')).read_bytes())
native = json.loads((ROOT / (PREFIX + 'native.json')).read_bytes())
optree = json.loads((ROOT / (PREFIX + 'optree.json')).read_bytes())
seed = json.loads(subprocess.check_output(['git', 'show', BASE + ':docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0-consumers-final.json'], cwd=ROOT))
files = {p: subprocess.check_output(['git', 'show', BASE + ':' + p], cwd=ROOT) for p in seed['inputs']}
for label in ('native', 'optree'):
    p = PREFIX + label + '-probe.pl'
    files[p] = (ROOT / p).read_bytes()
assert all(sha(raw) == seed['inputs'][p] for p, raw in files.items() if p in seed['inputs'])
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)


def run(command, directory):
    process = subprocess.run(command, cwd=directory, env=environment, capture_output=True)
    return {'command': command, 'returncode': process.returncode,
            'stdout_base64': b64(process.stdout), 'stderr_base64': b64(process.stderr)}


rows = []
for name, reason in (
        ('omitted-direct-call', 'dynamic invocation population'),
        ('added-formal-call', 'independent deparsed/optree variable population'),
        ('unbound-required-resolver', 'required resolver binding return'),
        ('omitted-member', 'complete invocation membership'),
        ('shadow-binding-conflation', 'lexical binding identity'),
        ('wrong-ingress-family', 'remaining ingress families and lexical declarations')):
    mutated = source
    changed_inventory = copy.deepcopy(inventory)
    replacements = {
        'omitted-direct-call': (b"(($deps->{bare_symbol_kind}->($name) // '') eq 'scalar')", b"((undef // '') eq 'scalar')"),
        'added-formal-call': (b'my ($expr, $trim_action_ir_value) = @_;', b'my ($expr, $trim_action_ir_value) = @_; $trim_action_ir_value->($expr);'),
        'unbound-required-resolver': (b'return _bind_emission_dependency($cb);', b'return $cb;'),
    }
    if name in replacements:
        old, new = replacements[name]
        assert old in source
        mutated = source.replace(old, new, 1)
        selected = dict(files)
        selected[MODULE] = mutated
        with tempfile.TemporaryDirectory(prefix='inventory-control-', dir=os.environ['TMPDIR']) as directory:
            supplied = Path(directory)
            assert supplied.stat().st_dev == ROOT.stat().st_dev
            for p, raw in selected.items():
                target = supplied / p
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(raw)
            syntax = run(['perl', '-Iperl', '-c', MODULE], supplied)
            actual = {label: run(['perl', '-Iperl', './' + PREFIX + label + '-probe.pl', 'observe'], supplied)
                      for label in ('native', 'optree')}
            unchanged = {p.relative_to(supplied).as_posix(): sha(p.read_bytes()) for p in supplied.rglob('*') if p.is_file()} == {p: sha(raw) for p, raw in selected.items()}
        record = {'name': name, 'replacement': {'old_base64': b64(old), 'new_base64': b64(new)},
                  'source_base64': b64(mutated), 'syntax': syntax, **actual,
                  'inputs': {p: sha(raw) for p, raw in sorted(selected.items())}, 'unchanged': unchanged,
                  'inventory': changed_inventory}
    else:
        if name == 'omitted-member':
            changed_inventory['calls'].pop()
        elif name == 'shadow-binding-conflation':
            row = next(row for row in changed_inventory['calls'] if row['line'] == 3850)
            row['binding'] = '_lower_method_value_expr:pad:44'
        else:
            row = next(row for row in changed_inventory['calls'] if row['line'] == 2066)
            row['class'] = 'remaining-optional-kind'
        record = {'name': name, 'source_base64': b64(source), 'native': native,
                  'optree': optree, 'inventory': changed_inventory, 'inputs': {}, 'unchanged': True}
    artifact = PREFIX + 'control-' + name + '.json'
    assert not (ROOT / artifact).exists()
    (ROOT / artifact).write_text(json.dumps(record, indent=2) + '\n')
    # Store full compiler products before asserting their interpretation.
    if 'syntax' in record:
        assert record['syntax']['returncode'] == 0 and record['unchanged']
        assert all(record[label]['returncode'] == 0 and not base64.b64decode(record[label]['stderr_base64']) for label in ('native', 'optree'))
    denied = run(['python3', PREFIX + 'control-oracle.py', artifact], ROOT)
    rows.append({'name': name, 'artifact': artifact, 'artifact_sha256': sha((ROOT / artifact).read_bytes()),
                 'expected_reason': reason, 'denied': denied})
    TARGET.write_text(json.dumps({'result': 'pending', 'rows': rows}, indent=2) + '\n')
    assert denied['returncode'] != 0 and reason.encode() in base64.b64decode(denied['stderr_base64'])
    restored = run(['python3', PREFIX + 'review.py'], ROOT)
    rows[-1]['restored'] = restored
    assert restored['returncode'] == 0 and not base64.b64decode(restored['stderr_base64'])
report = {'result': 'PASS', 'rows': rows,
    'producer_sha256': sha(Path(__file__).read_bytes()),
    'oracle_sha256': sha((ROOT / (PREFIX + 'control-oracle.py')).read_bytes()),
    'review_sha256': sha((ROOT / (PREFIX + 'review.py')).read_bytes()),
    'scope': 'Three actual syntax-valid full-source variants with both independent compiler products and complete213-input capsules; three reason-sensitive inventory mutations. Each actual independent oracle returns nonzero with its named semantic reason, followed by actual restored readonly PASS. No runtime callback behavior or changed native observation is inferred.'}
TARGET.write_text(json.dumps(report, indent=2) + '\n')
print('Inventory controls PASS: three compiled-source and three member/binding/family REDs; six restored reviews')
