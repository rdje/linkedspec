"""Supplied native/current AST array-end callback paths and exact semantic faults."""
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
BASE = 'b0099d9ade78623b38c2213867b84f1e32014fe7'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_ast_array_end_capture.t'
COLD = 't/actionir_method_ast_array_end_capture_cold.t'
PUBLIC_TEST = 't/uniform_binding_contract.t'
PUBLIC_CONTRACT = 'capability_conformance/uniform_binding_contract.json'
OWNER = '_lower_ast_array_end_mutation_method_statement'
METHODS = ('push_back', 'push_front', 'pop_back', 'pop_front')
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
assert len(files) == 160 and {p: digest(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items() if p != MODULE)
files[MODULE] = files[MODULE] if mode in ('native', 'before') else (ROOT / MODULE).read_bytes()
for path in (TEST, COLD, PUBLIC_TEST, PUBLIC_CONTRACT):
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
for path in (PUBLIC_TEST, PUBLIC_CONTRACT):
    assert files[path] == blob(path), 'unchanged public mutation contract: ' + path
assert len(files) == 164
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


with tempfile.TemporaryDirectory(prefix='ast-array-end-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    if mode != 'inverses':
        command = seed['command'] + [TEST, COLD, PUBLIC_TEST] if mode == 'consumers' else ['perl', '-Iperl', COLD if mode == 'cold' else TEST]
        if mode in ('native', 'observe'):
            command.append('observe')
        row, result = capture(supplied, command, inputs)
        row['scope'] = 'Original160 supplied accepted Git inputs with three JSON reader artifacts and Trace; only the AST array-end required resolver overlaid except native/before, plus two bounded fixtures and unchanged public uniform-binding test/contract. Four methods/one callback role;12 complete native-current callback rows and44 controlled branch rows. Actual pre-validation node/calls/method/arity guards, local receiver scalar copy, mutation-sensitive bare fallback, contexts/effects/errors/fatal/public maps and source/helper/node/span identities retained. Explicit source/payload/binding/assembly/receiver/unsupported helper controls admit no complete helper, AST grammar/language, optional/direct, other guarded owner, output/mapped/full-private/canonical/parent behavior. Read-only toolchain and repository-volume scratch.'
        retain(mode, row)
        assert row['unchanged']
        if mode in ('native', 'observe'):
            observed = json.loads(result.stdout)
            assert result.returncode == 0 and not result.stderr
            assert len(observed['callbacks']) == 12 and len(observed['branches']) == 44
        elif mode == 'before':
            count = tap_count(result.stdout)
            failures = [line.split(b' - ', 1)[1].decode() for line in result.stdout.splitlines() if line.startswith(b'not ok ')]
            expected = [name for method in METHODS for name in (
                OWNER + '/' + method + '/0 required dependency cannot donate nested publication',
                OWNER + '/' + method + '/0 actual callback has its own identity boundary',
                OWNER + '/' + method + '/1 required dependency cannot donate nested publication')]
            assert failures == expected and result.returncode == 12, (count, result.returncode, failures)
        elif mode == 'consumers':
            assert result.returncode == 0 and b'All tests successful.' in result.stdout and re.search(rb'Files=44,', result.stdout)
        else:
            count = tap_count(result.stdout)
            assert result.returncode == 0 and not re.search(rb'^not ok ', result.stdout, re.MULTILINE) and not result.stderr
            if mode == 'fixture':
                original = json.loads((ROOT / (PREFIX + 'before.json')).read_bytes())
                assert count == tap_count(base64.b64decode(original['stdout_base64']))
            else:
                assert count == 8
        print('Supplied AST array-end', mode, 'PASS; exact164-file population unchanged')
    else:
        positive = json.loads((ROOT / (PREFIX + 'fixture.json')).read_bytes())
        count = tap_count(base64.b64decode(positive['stdout_base64']))
        diagnostic = "  die \"(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'\"\n   unless ref($cb) eq 'CODE';"
        variants = [
            ('required', edit(source, ' return _bind_emission_dependency($cb);', ' return $cb;'),
             OWNER + '/push_back/0 required dependency cannot donate nested publication'),
            ('identity', edit(source, ' return _bind_emission_dependency($cb);',
                              ' return _bind_emission_dependency(sub { return $cb->(@_) });'),
             OWNER + '/pop_front/1 actual callback has its own identity boundary'),
            ('diagnostic', edit(source, diagnostic, ''),
             OWNER + '/push_back required dependency diagnostic remains exact'),
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
        print('AST array-end semantic faults PASS:', count, 'assertions; three complete source REDs')
