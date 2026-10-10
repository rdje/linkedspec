"""Supplied native/current Regex/undefined-return required callback paths and exact semantic faults."""
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
BASE = 'ae65603bc5bee1f3abeab4d7a028546ddbc8da93'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2-'
SEED = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
TEST = 't/actionir_method_regex_undef_required_capture.t'
COLD = 't/actionir_method_regex_undef_required_capture_cold.t'
PROBE = 't/actionir_method_regex_undef_required_probe.pl'
NATIVE = PREFIX + 'native.json'
OWNERS = ['_lower_regex_subst_statement','_lower_return_undef_statement']
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
    end = source.find('\nsub ', start + 1)
    end = len(source) if end < 0 else end
    body = source[start:end]
    assert body.count(old) == 1
    return source[:start] + body.replace(old, new) + source[end:]


seed_raw = blob(SEED)
assert (ROOT / SEED).read_bytes() == seed_raw
seed = json.loads(seed_raw)
assert seed['returncode'] == 0 and seed['unchanged'] is True
files = {p: blob(p) for p in sorted(seed['inputs'])}
assert len(files) == 178 and {p: digest(raw) for p, raw in files.items()} == seed['inputs']
assert all((ROOT / p).read_bytes() == raw for p, raw in files.items() if p != MODULE)
files[MODULE] = files[MODULE] if mode in ('native', 'before') else (ROOT / MODULE).read_bytes()
for path in (PROBE,) if mode in ('native','observe') else (PROBE,TEST,COLD,NATIVE):
    assert path not in files
    files[path] = (ROOT / path).read_bytes()
assert len(files) == (179 if mode in ('native','observe') else 182)
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


with tempfile.TemporaryDirectory(prefix='method-regex-undef-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    if mode != 'inverses':
        command = seed['command'] + [TEST, COLD] if mode == 'consumers' else ['perl', '-Iperl', COLD if mode == 'cold' else PROBE if mode in ('native','observe') else TEST]
        if mode in ('native', 'observe'):
            command.append('observe')
        row, result = capture(supplied, command, inputs)
        row['scope'] = ('Accepted178 supplied Git seed inputs. Immutable native probe plus seed has179 files; '
                        'paired main/cold/consumer proof also supplies both tests and the retained native JSON reader,182 files. '
                        'Only two regex/undefined-return required resolver returns overlaid except native/before. '
                        'Five invoked roles across three paths in24 native outcomes,32 branches/four public rows. '
                        'Regex local copies/defined-default flags and repeated stripping, actual normalizer arrays/readonly zero arities. '
                        'Undefined-return AST is an explicit secondary control. Existing quoted-flags/callback/receiver repairs stay separate. '
                        'No complete helper/AST/language, optional/direct/output/mapped/full-private/canonical or parent admission. '
                        'Read-only toolchain; repository-volume scratch.')
        retain(mode, row)
        assert row['unchanged']
        if mode in ('native', 'observe'):
            observed = json.loads(result.stdout)
            assert result.returncode == 0 and not result.stderr
            assert len(observed['callbacks']) == 24 and len(observed['branches']) == 32 and len(observed['public']) == 4
        elif mode == 'before':
            count = tap_count(result.stdout)
            failures = [line.split(b' - ', 1)[1].decode() for line in result.stdout.splitlines() if line.startswith(b'not ok ')]
            paths = [('_lower_regex_subst_statement',mode,['extract_scalar_symbol_name','strip_literal_delimiters','trim_action_ir_value']) for mode in ('defined','default')]
            paths.append(('_lower_return_undef_statement','plain',['parse_method_function_expr','normalize_method_args_with_optional_scope']))
            expected = [reason for owner,path,roles in paths for role in roles for reason in (
                owner + '/' + path + '/' + role + '/0 required dependency cannot donate nested publication',
                owner + '/' + path + '/' + role + '/0 actual callback has its own identity boundary',
                owner + '/' + path + '/' + role + '/1 required dependency cannot donate nested publication')]
            assert failures == expected and result.returncode == 24, (count,result.returncode,failures)
        elif mode == 'consumers':
            assert result.returncode == 0 and b'All tests successful.' in result.stdout and re.search(rb'Files=60,', result.stdout)
        else:
            count = tap_count(result.stdout)
            assert result.returncode == 0 and not re.search(rb'^not ok ', result.stdout, re.MULTILINE) and not result.stderr
            if mode == 'fixture':
                original = json.loads((ROOT / (PREFIX + 'before.json')).read_bytes())
                assert count == tap_count(base64.b64decode(original['stdout_base64']))
            else:
                assert count > 0
        print('Supplied Regex/undefined-return required', mode, 'PASS; exact supplied population unchanged')
    else:
        positive = json.loads((ROOT / (PREFIX + 'fixture.json')).read_bytes())
        count = tap_count(base64.b64decode(positive['stdout_base64']))
        variants = []
        for label, owner in zip(('regex','undef'), OWNERS):
            indentation = ' '
            role = 'extract_scalar_symbol_name' if label == 'regex' else 'parse_method_function_expr'
            path = 'defined' if label == 'regex' else 'plain'
            seam = '  return _bind_emission_dependency($cb);'
            diagnostic = indentation + ' die "(LinkedSpec::ActionIR::MethodLowering::_require_dep) -E- missing dependency callback \'$name\'"\n' + indentation + "  unless ref($cb) eq 'CODE';"
            variants += [
                (label + '-required', edit(source, owner, seam, '  return $cb;'),
                 owner + '/' + path + '/' + role + '/0 required dependency cannot donate nested publication'),
                (label + '-identity', edit(source, owner, seam, '  return _bind_emission_dependency(sub { return $cb->(@_) });'),
                 owner + '/' + path + '/' + role + '/1 actual callback has its own identity boundary'),
                (label + '-diagnostic', edit(source, owner, diagnostic, ''),
                 owner + '/' + path + '/' + role + ' required diagnostic retains native selection'),
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
        print('Regex/undefined-return required semantic faults PASS:', count, 'assertions; six complete source REDs')
