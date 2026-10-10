"""Supplied native/current block-value calls and three exact semantic source faults."""
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
BASE = 'b50ce085a63c8777973bc4c4e4a999a8840c462b'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_ast_hash_key_capture.t'
COLD = 't/actionir_method_ast_hash_key_capture_cold.t'
OWNER = '_lower_ast_scalar_held_hash_index_assignment_value_node'
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
    assert body.count(old) == 1, (OWNER, old, body.count(old))
    return source[:start] + body.replace(old, new) + source[end:]


seed_raw = blob(SEED)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] is True
files = {path: blob(path) for path in sorted(seed['inputs'])}
assert len(files) == 156 and {p: digest(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items() if p != MODULE)
files[MODULE] = files[MODULE] if mode in ('native', 'before') else (ROOT / MODULE).read_bytes()
for path in (TEST, COLD):
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
assert len(files) == 158
inputs = {p: digest(raw) for p, raw in sorted(files.items())}
source = files[MODULE].decode()
environment = dict(os.environ, PERL5LIB='', PERL5OPT='',
                   LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')


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


def complete_tap(raw, count):
    return (re.findall(rb'^1\.\.(\d+)$', raw, re.MULTILINE) == [str(count).encode()]
            and [int(n) for n in re.findall(rb'^(?:not )?ok (\d+)', raw, re.MULTILINE)]
            == list(range(1, count + 1)))


with tempfile.TemporaryDirectory(prefix='ast-hash-key-capture-', dir=os.environ['TMPDIR']) as temporary:
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
        row['scope'] = 'Original156 supplied accepted Git files, only the guarded scalar-held hash-index key required resolver overlaid except native/before modes, plus two fixtures. Three native-current callback ledgers and15 bounded branch ledgers. Actual node/target guards precede required validation; source extraction, mutation payload and final assembly have explicit secondary controls. Actual source fallback, copied key scalar, callback maps/context/effects/errors/fatal identity and lowered value/reference/zero handoff retained. Read-only interpreter/core/toolchain reused with repository-volume scratch. No complete source/payload/assembly helper, AST grammar/language, other guarded owners, optional/direct, pipeline/output/mapped/full-private/canonical/parent admission.'
        retain(mode, row)
        assert row['unchanged']
        assert (result.returncode != 0) if mode == 'before' else (result.returncode == 0)
        if mode in ('native', 'observe'):
            assert len(json.loads(result.stdout)['callbacks']) == 3 and len(json.loads(result.stdout)['branches']) == 15 and not result.stderr
        elif mode == 'before':
            assert complete_tap(result.stdout, 171) and b'required dependency cannot donate nested publication' in result.stdout
        elif mode == 'consumers':
            assert b'All tests successful.' in result.stdout and re.search(rb'Files=39,', result.stdout)
        else:
            assert complete_tap(result.stdout, 4 if mode == 'cold' else 171)
            assert not re.search(rb'^not ok ', result.stdout, re.MULTILINE) and not result.stderr
        print('Supplied guarded hash key', mode, 'PASS; exact158-file input population unchanged')
    else:
        diagnostic = "  die \"(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback '$name'\"\n   unless ref($cb) eq 'CODE';"
        variants = [
            ('required', edit(source, ' return _bind_emission_dependency($cb);', ' return $cb;'),
             OWNER + '/0 required dependency cannot donate nested publication'),
            ('identity', edit(source, ' return _bind_emission_dependency($cb);',
                              ' return _bind_emission_dependency(sub { return $cb->(@_) });'),
             OWNER + '/1 actual callback has its own identity boundary'),
            ('diagnostic', edit(source, diagnostic, ''),
             OWNER + ' required dependency diagnostic remains exact'),
        ]
        reports = []
        for name, changed, reason in variants:
            raw = changed.encode()
            assert raw != files[MODULE], name
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
            assert result.returncode != 0 and complete_tap(result.stdout, 171) and failures
            reports.append({'case': name, 'path': PREFIX + 'inverse-' + name + '.json',
                            'sha256': digest((ROOT / (PREFIX + 'inverse-' + name + '.json')).read_bytes()),
                            'source_sha256': digest(raw), 'reason': reason, 'observed': 'RED'})
            (supplied / MODULE).write_bytes(files[MODULE])
            assert census(supplied) == inputs
        retain('inverses', {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
                            'source_sha256': inputs[MODULE], 'assertions': 171, 'rows': reports})
        print('Guarded hash key semantic faults PASS: three complete171-assertion source REDs')
