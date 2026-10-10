"""Supplied native/current Main method/value callback paths and exact semantic faults."""
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
BASE = '049e1ba537f2bde635b2c0fed31fe83f6b3c129b'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.4-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_value_capture.t'
COLD = 't/actionir_method_value_capture_cold.t'
OWNER = '_lower_method_value_expr'
assert sys.argv[1:] in ([m] for m in ('native', 'observe', 'before', 'fixture', 'cold', 'consumers', 'inverses'))
mode = sys.argv[1]
digest = lambda raw: hashlib.sha256(raw).hexdigest()


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


seed_raw = blob(SEED)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] is True
files = {p: blob(p) for p in sorted(seed['inputs'])}
assert len(files) == 166 and {p: digest(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items() if p != MODULE)
files[MODULE] = files[MODULE] if mode in ('native', 'before') else (ROOT / MODULE).read_bytes()
for path in (TEST, COLD):
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
assert len(files) == 168
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


def tap_count(raw):
    plans = re.findall(rb'^1\.\.(\d+)$', raw, re.MULTILINE)
    assert len(plans) == 1 and int(plans[0]) > 0, 'incomplete TAP plan'
    count = int(plans[0])
    assert [int(n) for n in re.findall(rb'^(?:not )?ok (\d+)', raw, re.MULTILINE)] == list(range(1, count + 1))
    return count


with tempfile.TemporaryDirectory(prefix='method-value-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    if mode != 'inverses':
        command = seed['command'] + [TEST, COLD] if mode == 'consumers' else ['perl', '-Iperl', COLD if mode == 'cold' else TEST]
        if mode in ('native', 'observe'):
            command.append('observe')
        row, result = capture(supplied, command, inputs)
        row['scope'] = 'Original166 supplied accepted Git inputs with three JSON reader artifacts, Trace and public uniform-binding test/contract; only the main method/value required resolver is overlaid except native/before, plus two bounded fixtures. Fourteen invoked required roles in42 native-current rows,23 controlled alias/lazy/arity/guard/result branches; one locally validated-only inference role. Explicit secondary controls admit no complete helper/AST/language, optional/direct, output/mapped/full-private/canonical/parent behavior. Read-only toolchain and repository-volume scratch.'
        retain(mode, row)
        assert row['unchanged']
        if mode in ('native', 'observe'):
            observed = json.loads(result.stdout)
            assert result.returncode == 0 and not result.stderr
            assert len(observed['callbacks']) == 42 and len(observed['branches']) == 23
        elif mode == 'before':
            count = tap_count(result.stdout)
            failures = [line.split(b' - ', 1)[1].decode() for line in result.stdout.splitlines() if line.startswith(b'not ok ')]
            roles = ['trim_action_ir_value', 'split_action_ir_statements', 'parse_method_function_expr',
                     'normalize_method_args_with_optional_scope', 'lower_direct_nested_access_value_expr',
                     'extract_array_symbol_name', 'extract_hash_symbol_name', 'extract_scalar_symbol_name',
                     'lower_scalar_access_key_expr', 'lower_primitive_literal_expr', 'split_top_level_csv',
                     'lower_array_pipeline_expr', 'strip_literal_delimiters', 'lower_declare_initializer_expr']
            expected = [reason for role in roles for reason in (
                role + '/0 required dependency cannot donate nested publication',
                role + '/0 actual callback has its own identity boundary',
                role + '/1 required dependency cannot donate nested publication')]
            assert failures == expected and result.returncode == 42 and count == 518, (count, result.returncode, failures)
        elif mode == 'consumers':
            assert result.returncode == 0 and b'All tests successful.' in result.stdout and re.search(rb'Files=48,', result.stdout)
        else:
            count = tap_count(result.stdout)
            assert result.returncode == 0 and not re.search(rb'^not ok ', result.stdout, re.MULTILINE) and not result.stderr
            if mode == 'fixture':
                original = json.loads((ROOT / (PREFIX + 'before.json')).read_bytes())
                assert count == tap_count(base64.b64decode(original['stdout_base64']))
            else:
                assert count == 10
        print('Supplied Main method/value', mode, 'PASS; exact168-file population unchanged')
    else:
        positive = json.loads((ROOT / (PREFIX + 'fixture.json')).read_bytes())
        count = tap_count(base64.b64decode(positive['stdout_base64']))
        diagnostic = "  die \"(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'\"\n   unless ref($cb) eq 'CODE';"
        variants = [
            ('required', edit(source, ' return _bind_emission_dependency($cb);', ' return $cb;'),
             'trim_action_ir_value/0 required dependency cannot donate nested publication'),
            ('identity', edit(source, ' return _bind_emission_dependency($cb);',
                              ' return _bind_emission_dependency(sub { return $cb->(@_) });'),
             'trim_action_ir_value/1 actual callback has its own identity boundary'),
            ('diagnostic', edit(source, diagnostic, ''),
             'trim_action_ir_value eager diagnostic precedes undefined-input guard'),
        ]
        reports = []
        for name, changed, reason in variants:
            raw = changed.encode()
            assert raw != files[MODULE]
            (supplied / MODULE).write_bytes(raw)
            population = dict(inputs, **{MODULE: digest(raw)})
            syntax, checked = capture(supplied, ['perl', '-Iperl', '-c', MODULE], population)
            row, result = capture(supplied, ['perl', '-Iperl', TEST], population)
            failures = [line.decode() for line in result.stdout.splitlines()
                        if line.startswith(b'not ok ') and reason.encode() in line]
            row.update(case=name, source_sha256=digest(raw), distinguishing_reason=reason,
                       syntax=syntax, semantic_failures=failures)
            retain('inverse-' + name, row)
            assert checked.returncode == 0 and b'syntax OK' in checked.stderr
            assert result.returncode != 0 and tap_count(result.stdout) == count and failures
            reports.append({'case': name, 'path': PREFIX + 'inverse-' + name + '.json',
                            'sha256': digest((ROOT / (PREFIX + 'inverse-' + name + '.json')).read_bytes()),
                            'source_sha256': digest(raw), 'reason': reason, 'observed': 'RED'})
            (supplied / MODULE).write_bytes(files[MODULE])
            assert census(supplied) == inputs
        retain('inverses', {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
                            'source_sha256': inputs[MODULE], 'assertions': count, 'rows': reports})
        print('Main method/value semantic faults PASS:', count, 'assertions; three complete source REDs')
