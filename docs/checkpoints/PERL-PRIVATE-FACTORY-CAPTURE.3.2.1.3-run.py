"""One-shot identical regression, full-source variants and all predecessor consumers."""
import base64
import hashlib
import json
import os
import re
import stat
import subprocess
import sys
import tempfile
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
BASE = '61a73324f06238418301eac88fd3f908665ecbe3'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_kind_capture.t'
ADDED = ['t/actionir_method_kind_probe.pl', 't/actionir_method_kind_authority_probe.pl', TEST,
    PREFIX + 'before-native.json', PREFIX + 'before-authority-native.json']
OUTER_OLD = b'return $base_bare_symbol_kind->($name)'
OUTER_NEW = b"return _bind_emission_dependency(ref($base_bare_symbol_kind) eq 'CODE' ? $base_bare_symbol_kind : sub { return $base_bare_symbol_kind->(@_) })->($name)"
INNER_OLD = b"$target_sigil = '$' if (($bare_symbol_kind->($target_name) // '') eq 'scalar');"
INNER_NEW = b"$target_sigil = '$' if ((_bind_emission_dependency(ref($bare_symbol_kind) eq 'CODE' ? $bare_symbol_kind : sub { return $bare_symbol_kind->(@_) })->($target_name) // '') eq 'scalar');"
sha = lambda raw: hashlib.sha256(raw).hexdigest()
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
variants = ('inverse-outer', 'inverse-inner', 'opaque-code', 'direct-noncode', 'outer-late', 'inner-early', 'inner-copy', 'list-context', 'no-first-refusal')
assert len(sys.argv) == 2 and sys.argv[1] in ('before', 'green', 'consumers') + variants
mode = sys.argv[1]
target = ROOT / (PREFIX + mode + '.json')
assert not target.exists(), 'one-shot capture'
seed_raw = old(SEED)
seed = json.loads(seed_raw)
files = {path: old(path) for path in seed['inputs']}
assert len(files) == 225 and {path: sha(raw) for path, raw in files.items()} == seed['inputs']
assert all((ROOT / path).read_bytes() == raw for path, raw in files.items() if path != MODULE)
source = files[MODULE]
assert source.count(OUTER_OLD) == source.count(INNER_OLD) == 1
accepted = source.replace(OUTER_OLD, OUTER_NEW).replace(INNER_OLD, INNER_NEW)
if mode == 'before':
    assert (ROOT / MODULE).read_bytes() == source
else:
    assert (ROOT / MODULE).read_bytes() == accepted, 'only the two injected invocation boundaries'
    source = accepted
if mode == 'inverse-outer': source = source.replace(OUTER_NEW, OUTER_OLD)
elif mode == 'inverse-inner': source = source.replace(INNER_NEW, INNER_OLD)
elif mode == 'opaque-code':
    for name in (b'base_bare_symbol_kind', b'bare_symbol_kind'):
        term = b"ref($" + name + b") eq 'CODE' ? $" + name + b" : sub { return $" + name + b"->(@_) }"
        assert source.count(term) == 1
        source = source.replace(term, b'sub { return $' + name + b'->(@_) }')
elif mode == 'direct-noncode':
    for name in (b'base_bare_symbol_kind', b'bare_symbol_kind'):
        term = b"ref($" + name + b") eq 'CODE' ? $" + name + b" : sub { return $" + name + b"->(@_) }"
        assert source.count(term) == 1
        source = source.replace(term, b'$' + name)
elif mode == 'outer-late':
    source = source.replace(OUTER_NEW, OUTER_NEW.replace(b'$base_bare_symbol_kind', b"$deps->{bare_symbol_kind}"))
elif mode == 'inner-early':
    source = source.replace(INNER_NEW, INNER_NEW.replace(b'$bare_symbol_kind', b'$base_bare_symbol_kind'))
elif mode == 'inner-copy':
    source = source.replace(INNER_NEW, INNER_NEW.replace(b'->($target_name)', b"->($target_name . '')"))
elif mode == 'list-context':
    for name in (b'base_bare_symbol_kind', b'bare_symbol_kind'):
        term = b"ref($" + name + b") eq 'CODE' ? $" + name + b" : sub { return $" + name + b"->(@_) }"
        source = source.replace(term, b'sub { my @result = $' + name + b'->(@_); return $result[0] }')
elif mode == 'no-first-refusal':
    term = b"  return 'scalar' if _user_function_scalar_value_name($deps, $name);"
    assert source.count(term) == 1
    source = source.replace(term, b'')
files[MODULE] = source
for path in ADDED:
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
inputs = {path: sha(raw) for path, raw in sorted(files.items())}
modes = {path: stat.S_IMODE((ROOT / path).stat().st_mode) for path in files}
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0')
environment.pop('LINKEDSPEC_TRACE_LEVEL', None)
with tempfile.TemporaryDirectory(prefix='method-kind-run-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        destination = supplied / path
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(raw)
        destination.chmod(modes[path])
    syntax_command = ['perl', '-c', '-Iperl', MODULE]
    syntax = subprocess.run(syntax_command, cwd=supplied, env=environment, capture_output=True)
    command = seed['command'] + [TEST] if mode == 'consumers' else ['perl', '-Iperl', TEST]
    process = subprocess.run(command, cwd=supplied, env=environment, capture_output=True)
    actual = {path.relative_to(supplied).as_posix(): sha(path.read_bytes()) for path in supplied.rglob('*') if path.is_file()}
    actual_modes = {path: stat.S_IMODE((supplied / path).stat().st_mode) for path in actual}
channels = lambda result: {'returncode': result.returncode,
    'stdout_base64': base64.b64encode(result.stdout).decode(), 'stderr_base64': base64.b64encode(result.stderr).decode()}
record = {'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()), 'mode': mode,
    'seed': SEED, 'seed_sha256': sha(seed_raw), 'inputs': inputs, 'modes': modes,
    'module_base64': base64.b64encode(source).decode(), 'syntax_command': syntax_command,
    'syntax': channels(syntax), 'command': command, **channels(process),
    'unchanged': actual == inputs and actual_modes == modes,
    'scope': 'All225 accepted predecessor inputs plus two diagnostic producers, unchanged regression and two native ledgers. Identical fixture and complete source/modes/channels retained. Complete original70 consumer commands append the new suite. Variants alter supplied complete source only; original native observations/producers remain unchanged. No full-helper/private/canonical admission.'}
target.write_text(json.dumps(record, indent=2) + '\n')
assert record['unchanged'] and syntax.returncode == 0
red = mode == 'before' or mode in variants
assert (process.returncode != 0 and b'not ok ' in process.stdout) if red else process.returncode == 0
if mode == 'consumers':
    assert b'All tests successful.' in process.stdout and b'Result: PASS' in process.stdout
    assert process.stderr == base64.b64decode(seed['stderr_base64'])
    print('Method-kind supplied consumers PASS:', len(command[3:]), 'suites;', len(inputs), 'inputs')
else:
    plans = re.findall(rb'^1\.\.(\d+)$', process.stdout, re.M)
    rows = re.findall(rb'^(not )?ok (\d+)(?: - (.*))?$', process.stdout, re.M)
    assert len(plans) == 1 and [int(row[1]) for row in rows] == list(range(1, int(plans[0]) + 1))
    print('Method-kind', mode, 'complete TAP:', int(plans[0]), 'assertions;', sum(bool(row[0]) for row in rows), 'RED')
