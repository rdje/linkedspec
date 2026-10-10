"""Supplied native/current Generalized return required callback paths and exact semantic faults."""
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
BASE = '2c5f84092d91c808ab82b4b886b51e65fc1ac864'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1-complete-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_general_return_capture.t'
COLD = 't/actionir_method_general_return_capture_cold.t'
OWNERS = ['_lower_return_payload_expr', '_lower_return_general_statement']
assert sys.argv[1:] in ([m] for m in ('native', 'observe', 'before', 'fixture', 'cold', 'consumers', 'inverses'))
mode = sys.argv[1]
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def census(directory):
    return {p.relative_to(directory).as_posix(): digest(p.read_bytes())
            for p in sorted(directory.rglob('*')) if p.is_file()}


def edit(source, owner, old, new):
    start = source.index('sub ' + owner + ' {')
    end = source.index('\nsub ', start + 1)
    body = source[start:end]
    assert body.count(old) == 1
    return source[:start] + body.replace(old, new) + source[end:]


seed_raw = blob(SEED)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] is True
files = {p: blob(p) for p in sorted(seed['inputs'])}
assert len(files) == 170 and {p: digest(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items() if p != MODULE)
files[MODULE] = files[MODULE] if mode in ('native', 'before') else (ROOT / MODULE).read_bytes()
for path in (TEST, COLD):
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
assert len(files) == 172
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


with tempfile.TemporaryDirectory(prefix='method-general-return-', dir=os.environ['TMPDIR']) as temporary:
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
        row['scope'] = 'Original170 supplied accepted Git inputs, including three reader JSONs, Trace and the public uniform-binding contract. Only two generalized-return required resolver returns overlaid except native/before, plus two bounded fixtures. Three actual owner/role pairs in9 native-current string/undefined/fatal rows,52 bounded AST/method/bare/raw64/label/guard/alias/result branches and9 actual public Toolbox return-surface rows. Secondary helpers are explicit controls. Payload undefined guard precedes trim validation; parser is eager before AST fast path and label trim is lazy. No complete helpers/AST/language, optional/direct/output/mapped/full-private/canonical or parent admission. Read-only toolchain; repository-volume scratch.'
        retain(mode, row)
        assert row['unchanged']
        if mode in ('native', 'observe'):
            observed = json.loads(result.stdout)
            assert result.returncode == 0 and not result.stderr
            assert len(observed['callbacks']) == 9 and len(observed['branches']) == 52 and len(observed['public']) == 9
        elif mode == 'before':
            count = tap_count(result.stdout)
            failures = [line.split(b' - ', 1)[1].decode() for line in result.stdout.splitlines() if line.startswith(b'not ok ')]
            roles = [(OWNERS[0], 'trim_action_ir_value'), (OWNERS[1], 'parse_method_function_expr'), (OWNERS[1], 'trim_action_ir_value')]
            expected = [reason for owner, role in roles for reason in (
                owner + '/' + role + '/0 required dependency cannot donate nested publication',
                owner + '/' + role + '/0 actual callback has its own identity boundary',
                owner + '/' + role + '/1 required dependency cannot donate nested publication')]
            assert failures == expected and result.returncode == 9 and count == 574, (count, result.returncode, failures)
        elif mode == 'consumers':
            assert result.returncode == 0 and b'All tests successful.' in result.stdout and re.search(rb'Files=52,', result.stdout)
        else:
            count = tap_count(result.stdout)
            assert result.returncode == 0 and not re.search(rb'^not ok ', result.stdout, re.MULTILINE) and not result.stderr
            if mode == 'fixture':
                original = json.loads((ROOT / (PREFIX + 'before.json')).read_bytes())
                assert count == tap_count(base64.b64decode(original['stdout_base64']))
            else:
                assert count == 15
        print('Supplied Generalized return required', mode, 'PASS; exact172-file population unchanged')
    else:
        positive = json.loads((ROOT / (PREFIX + 'fixture.json')).read_bytes())
        count = tap_count(base64.b64decode(positive['stdout_base64']))
        variants = []
        for label, owner in zip(('payload', 'statement'), OWNERS):
            indentation = ' '
            role = 'trim_action_ir_value' if label == 'payload' else 'parse_method_function_expr'
            seam = indentation + ' return _bind_emission_dependency($cb);'
            diagnostic = indentation + ' die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback \'$name\'"\n' + indentation + "  unless ref($cb) eq 'CODE';"
            variants += [
                (label + '-required', edit(source, owner, seam, indentation + ' return $cb;'),
                 owner + '/' + role + '/0 required dependency cannot donate nested publication'),
                (label + '-identity', edit(source, owner, seam, indentation + ' return _bind_emission_dependency(sub { return $cb->(@_) });'),
                 owner + '/' + role + '/1 actual callback has its own identity boundary'),
                (label + '-diagnostic', edit(source, owner, diagnostic, ''),
                 owner + '/' + role + ' required diagnostic retains native selection'),
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
        print('Generalized return required semantic faults PASS:', count, 'assertions; six complete source REDs')
