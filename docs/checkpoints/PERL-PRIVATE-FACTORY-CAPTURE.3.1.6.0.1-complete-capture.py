"""Complete fixed-population fixture proof; original native and draft before remain immutable."""
import base64
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '770cffcccea44df8d0e578ed68ad6f9a4b5e0b0e'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_receiver_scalar_copy.t'
PROBE = 't/actionir_legacy_hash_kind_probe.pl'
COLD = 't/actionir_legacy_hash_kind_cold_probe.pl'
NATIVE = PREFIX + 'native.json'
OWNER = '_normalize_hash_receiver_value_chain_expr'
BIND = """ my $kind_callback = (ref($deps) eq 'HASH') ? $deps->{bare_symbol_kind} : undef;
 my $bare_symbol_kind = _bind_emission_dependency(
  ref($kind_callback) eq 'CODE' ? $kind_callback : sub { return undef },
 );
"""
digest = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([m] for m in ('current', 'before', 'fixture', 'consumers', 'inverses'))
mode = sys.argv[1]


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def census(directory):
    return {p.relative_to(directory).as_posix(): digest(p.read_bytes())
            for p in sorted(directory.rglob('*')) if p.is_file()}


def edit(source, old, new):
    start = source.index('sub ' + OWNER + ' {')
    end = source.index('\nsub ', start + 1)
    body = source[start:end]
    assert body.count(old) == 1
    return source[:start] + body.replace(old, new) + source[end:]


def tap(raw):
    plans = re.findall(rb'^1\.\.(\d+)$', raw, re.MULTILINE)
    assert len(plans) == 1 and int(plans[0]) > 0, 'incomplete top-level TAP plan'
    count = int(plans[0])
    assertions = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', raw, re.MULTILINE)
    assert [int(n) for failed, n, label in assertions] == list(range(1, count + 1))
    return count, [label.decode() for failed, n, label in assertions if failed]


seed_raw = blob(SEED)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] is True
files = {p: blob(p) for p in sorted(seed['inputs'])}
assert len(files) == 184 and {p: digest(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items() if p not in (MODULE, TEST))
files[MODULE] = files[MODULE] if mode in ('native', 'before') else (ROOT / MODULE).read_bytes()
files[TEST] = (ROOT / TEST).read_bytes()
for path in (PROBE, COLD) if mode in ('native', 'current') else (PROBE, COLD, NATIVE):
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
inputs = {p: digest(raw) for p, raw in sorted(files.items())}
source = files[MODULE].decode()
environment = dict(os.environ, PERL5LIB='', PERL5OPT='',
                   LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)


def retain(name, row):
    target = ROOT / (PREFIX + name + '.json')
    assert not target.exists(), 'one-shot capture already exists: ' + name
    target.write_text(json.dumps(row, indent=2) + '\n')


def capture(directory, command, population):
    assert census(directory) == population
    result = subprocess.run(command, cwd=directory, env=environment,
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    row = {'base': BASE, 'seed': SEED, 'seed_sha256': digest(seed_raw),
           'producer_sha256': digest(Path(__file__).read_bytes()), 'inputs': population,
           'command': command, 'returncode': result.returncode,
           'stdout_base64': base64.b64encode(result.stdout).decode(),
           'stderr_base64': base64.b64encode(result.stderr).decode(),
           'unchanged': census(directory) == population}
    return row, result


with tempfile.TemporaryDirectory(prefix='legacy-hash-kind-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    if mode != 'inverses':
        command = seed['command'] if mode == 'consumers' else ['perl', '-Iperl', PROBE, 'observe'] if mode in ('native', 'current') else ['perl', '-Iperl', TEST]
        row, result = capture(supplied, command, inputs)
        row['scope'] = ('Accepted184 Git seed inputs, overlaid only with this bounded owner/test and retained new probes/native reader. '
                        'Native/current observations supply186 files; paired fixture and61 supplied suites supply187. '
                        'First native callback/branch/package-state and require-only cold observations precede assertions and production writes. '
                        'Ordinary selected-callback controls stay native; intended injected/default selection and nested publication repairs are distinct. '
                        'Prior public copy regression remains the unchanged first50 assertions. Required callback capture stays .6.3; '
                        'complete helper/AST/language, optional/direct siblings, output/mapped/full-private/canonical and parent admissions remain separate. '
                        'Read-only toolchain and repository-volume scratch.')
        retain('before-complete' if mode == 'before' else mode, row)
        assert row['unchanged']
        if mode in ('native', 'current'):
            observed = json.loads(result.stdout)
            assert result.returncode == 0 and not result.stderr
            assert len(observed['cases']) == 35 and observed['cold']['returncode'] == 0
        elif mode == 'consumers':
            count = len([p for p in command if p.endswith('.t')])
            assert result.returncode == 0 and b'All tests successful.' in result.stdout
            assert re.search(rb'Files=(\d+),', result.stdout).group(1) == str(count).encode()
        else:
            count, failures = tap(result.stdout)
            assert count > 50
            if mode == 'before':
                assert result.returncode != 0 and failures and all(label.startswith('legacy ') for label in failures)
                assert not re.search(rb'^not ok (?:[1-9]|[1-4][0-9]|50)\b', result.stdout, re.MULTILINE)
            else:
                assert result.returncode == 0 and not failures and not result.stderr
                original = json.loads((ROOT / (PREFIX + 'before-complete.json')).read_bytes())
                assert count == tap(base64.b64decode(original['stdout_base64']))[0]
        print('Supplied legacy hash kind', mode, 'PASS; exact supplied population unchanged')
    else:
        positive = json.loads((ROOT / (PREFIX + 'fixture.json')).read_bytes())
        count = tap(base64.b64decode(positive['stdout_base64']))[0]
        raw = """ my $kind_callback = (ref($deps) eq 'HASH') ? $deps->{bare_symbol_kind} : undef;
 my $bare_symbol_kind = ref($kind_callback) eq 'CODE' ? $kind_callback : sub { return undef };
"""
        copied = BIND.replace("? $kind_callback :", "? sub { my $name = $_[0]; return $kind_callback->($name) } :")
        late = edit(source, BIND, '')
        late = edit(late, ' my $trimmed = $trim_action_ir_value->($expr);\n', ' my $trimmed = $trim_action_ir_value->($expr);\n' + BIND)
        variants = [
            ('remove-binding', edit(source, BIND, ''), 'legacy map-over-undefined-package result'),
            ('raw-callback', edit(source, BIND, raw), 'legacy authority/0 separate publication'),
            ('copy-argument', edit(source, BIND, copied), 'legacy native-hash actual readonly match alias'),
            ('hash-default', edit(source, BIND, BIND.replace('sub { return undef }', "sub { return 'hash' }")), 'legacy missing-map-over-hash-package result'),
            ('late-selection', late, 'legacy native-map-replacement result'),
        ]
        reports = []
        for label, changed, reason in variants:
            target = supplied / MODULE
            target.write_text(changed)
            population = dict(inputs, **{MODULE: digest(changed.encode())})
            syntax, syntax_result = capture(supplied, ['perl', '-Iperl', '-c', MODULE], population)
            row, result = capture(supplied, ['perl', '-Iperl', TEST], population)
            observed_count, failures = tap(result.stdout)
            row.update(label=label, reason=reason, syntax=syntax,
                       module_source_base64=base64.b64encode(changed.encode()).decode())
            retain('inverse-' + label, row)
            assert syntax_result.returncode == 0 and b'syntax OK' in syntax_result.stderr
            assert result.returncode != 0 and observed_count == count and reason in failures
            reports.append({'label': label, 'reason': reason, 'failures': failures,
                            'artifact': PREFIX + 'inverse-' + label + '.json'})
        retain('inverses', {'producer_sha256': digest(Path(__file__).read_bytes()),
                           'positive': PREFIX + 'fixture.json', 'variants': reports})
        print('Legacy hash kind semantic faults PASS:', len(reports), 'syntax-valid effective variants')
