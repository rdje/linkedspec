"""Supplied independent input-composition acceptance and semantic fault captures."""
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
BASE = '4f0499d2634e9c04e6a3d07ee85f4159f5380834'
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.3'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
SEED = PREFIX.replace('.3-', '.2-') + 'final-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/SourceEmissions.pm'
TEST = 't/actionir_input_composition_acceptance.t'
assert sys.argv[1:] in (['fixture'], ['consumers'], ['inverses'])
mode = sys.argv[1]


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def census(directory):
    return {p.relative_to(directory).as_posix(): digest(p.read_bytes())
            for p in sorted(directory.rglob('*')) if p.is_file()}


def edit(source, name, old, new, count=1):
    start = source.index('sub ' + name + ' {')
    end = source.find('\nsub ', start + 1)
    if end < 0:
        end = len(source)
    body = source[start:end]
    assert body.count(old) == count, (name, old, body.count(old))
    return source[:start] + body.replace(old, new) + source[end:]


seed_raw = blob(SEED)
seed = json.loads(seed_raw)
files = {path: blob(path) for path in sorted(seed['inputs'])}
assert len(files) == 134
assert {path: digest(raw) for path, raw in files.items()} == seed['inputs']
assert all((ROOT / path).read_bytes() == raw for path, raw in files.items())
files[TEST] = (ROOT / TEST).read_bytes()
inputs = {path: digest(raw) for path, raw in sorted(files.items())}
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


def complete_tap(raw):
    plans = re.findall(rb'^1\.\.(\d+)$', raw, re.MULTILINE)
    numbers = [int(n) for n in re.findall(rb'^(?:not )?ok (\d+)', raw, re.MULTILINE)]
    return plans == [b'140'] and numbers == list(range(1, 141))


with tempfile.TemporaryDirectory(prefix='input-composition-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    if mode in ('fixture', 'consumers'):
        command = ['perl', '-Iperl', TEST] if mode == 'fixture' else seed['command'] + [TEST]
        row, result = capture(supplied, command, inputs)
        row['scope'] = 'Unchanged original134 supplied inputs plus independently authored nested event/input acceptance. Standard read-only interpreter/core/toolchain outputs reused. Factory/output/full private Phase0/mapped/canonical acceptance remains open.'
        retain(mode, row)
        assert row['unchanged'] and result.returncode == 0
        assert complete_tap(result.stdout) if mode == 'fixture' else b'All tests successful.' in result.stdout
        print('Supplied independent', mode, 'PASS; exact135-file input population unchanged')
    else:
        variants = [
            ('rebase', edit(source, '_rebase_input_frame', '$parent->{source_span}{start} + ', '', 2),
             'complete independently labelled cross-capture frame population'),
            ('occurrence', edit(source, '_native_input_for',
             '$capture->{native}, $capture->{callback}, $arguments, $index)',
             '$capture->{native}, $capture->{callback}, $arguments, 0)'),
             'complete independently labelled cross-capture frame population'),
            ('parent', edit(source, '_input_record', 'my $parent = _input_record($capture->{parent});',
             'my $parent = $_inputs->{grants}{Scalar::Util::refaddr($capture->{parent})};'),
             'delayed ancestor mutation revokes descendant'),
            ('cached-native', source[:source.index(" if ($record->{kind} ne 'event') {")]
             + source[source.index('\n return $record', source.index(" if ($record->{kind} ne 'event') {")):],
             'delayed CSV shape mutation revokes deep descendant'),
            ('append-event', edit(source, '_append_input', '_same_reference($record->{event}, $input->{event})', '1'),
             'equal-coordinate foreign event remains generated'),
            ('consume-event', edit(source, '_consume_input', '_same_reference($record->{event}, $input->{event})', '1'),
             'foreign event consumes nothing'),
            ('consume-child', edit(source, '_consume_input', '%{$input->{frame}{source_span}}', '%{$record->{origin}{source_span}}'),
             'exact deep child consumption ledger'),
            ('callback-once', edit(source, '_capture_source_input', 'my $native = $mode eq', '$callback->(@_);\n my $native = $mode eq'),
             'actual joined callback executes once in scalar context'),
            ('aliases', edit(edit(source, '_capture_source_input', 'my $source = @_ &&', 'my @arguments = @_;\n my $source = @_ &&'),
             '_capture_source_input', '($callback, @_)', '($callback, @arguments)', 3),
             'actual joined caller alias is written'),
            ('opaque-release', edit(source, '_capture_source_input',
             "&& ($mode ne 'ast' || _rebase_input_frame($root, $input->{frame}))", '&& 1'),
             'opaque destructor has executed before scope exit'),
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
            assert row['unchanged'] and syntax['unchanged'] and checked.returncode == 0
            assert result.returncode != 0 and failures and complete_tap(result.stdout), (name, reason)
            reports.append({'case': name, 'path': PREFIX + 'inverse-' + name + '.json',
                            'sha256': digest((ROOT / (PREFIX + 'inverse-' + name + '.json')).read_bytes()),
                            'source_sha256': digest(raw), 'reason': reason, 'observed': 'RED'})
            (supplied / MODULE).write_bytes(files[MODULE])
            assert census(supplied) == inputs
        retain('inverses', {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
                            'fixture_sha256': inputs[TEST], 'source_sha256': inputs[MODULE], 'rows': reports,
                            'scope': 'Ten syntax-valid effective faults; full140-assertion coherent plans and independently authored semantic ledger/callback reasons. Original supplied bytes/population restore after each fault.'})
        print('Independent composition inverses PASS10; complete140-assertion semantic REDs')
