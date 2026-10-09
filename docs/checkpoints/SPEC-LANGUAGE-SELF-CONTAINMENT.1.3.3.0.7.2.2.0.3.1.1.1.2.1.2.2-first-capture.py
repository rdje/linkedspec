"""Retain supplied fixture, direct consumers and effective source inverses."""
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
BASE = '3dbe7b10a8b6cbe1f6ea92afcb235cc1a71cd59e'
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.2'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
SEED = 'docs/checkpoints/' + LEAF[:-1] + '1-consumers.json'
MODULE = 'perl/LinkedSpec/ActionIR/SourceEmissions.pm'
TEST = 't/actionir_event_input_grants.t'
assert sys.argv[1:] in (['fixture'], ['consumers'], ['inverses'])
mode = sys.argv[1]


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def blob(path):
    return subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)


def census(directory):
    return {p.relative_to(directory).as_posix(): digest(p.read_bytes())
            for p in sorted(directory.rglob('*')) if p.is_file()}


def sub_body(source, name):
    start = source.index('sub ' + name + ' {')
    end = source.find('\nsub ', start + 1)
    return start, len(source) if end == -1 else end


def edit(source, name, old, new, count=1):
    start, end = sub_body(source, name)
    body = source[start:end]
    assert body.count(old) == count, (name, old, body.count(old), count)
    return source[:start] + body.replace(old, new) + source[end:]


seed_raw = blob(SEED)
seed = json.loads(seed_raw)
original = {path: blob(path) for path in sorted(seed['inputs'])}
assert len(original) == 133
assert {path: digest(raw) for path, raw in original.items()} == seed['inputs']
files = {path: (ROOT / path).read_bytes() for path in original}
assert [path for path in files if files[path] != original[path]] == [MODULE]
files[TEST] = (ROOT / TEST).read_bytes()
inputs = {path: digest(raw) for path, raw in sorted(files.items())}
source = files[MODULE].decode()
environment = dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0',
                   LINKEDSPEC_MEMBERSHIP_BASELINE='0')


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
    assert row['unchanged'], 'consumer changed supplied files/population'
    return row, result


def retain(name, row):
    path = ROOT / (PREFIX + name + '.json')
    assert not path.exists(), 'one-shot capture already exists: ' + name
    path.write_text(json.dumps(row, indent=2) + '\n')


with tempfile.TemporaryDirectory(prefix='event-input-proof-', dir=os.environ['TMPDIR']) as temporary:
    supplied = Path(temporary)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for path, raw in files.items():
        target = supplied / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    if mode == 'fixture':
        row, result = capture(supplied, ['perl', '-Iperl', TEST], inputs)
        row['scope'] = 'Exact134-file supplied population; standalone actual event-input fixture only. Standard read-only Perl/core modules and same-volume managed scratch reused.'
        retain('after', row)
        assert result.returncode == 0 and re.search(rb'^1\.\.183$', result.stdout, re.MULTILINE)
        print('Supplied original-event fixture PASS183; exact134-file input population unchanged')
    elif mode == 'consumers':
        command = seed['command'] + [TEST]
        assert len(command) == len(seed['command']) + 1
        row, result = capture(supplied, command, inputs)
        row['scope'] = 'The complete corrected original fourteen-suite capsule plus the new fixture: fifteen direct suites in134 supplied files, including all three actual checkpoint JSON inputs. Full private Phase0 and mapped/canonical admission remain open.'
        retain('consumers', row)
        assert result.returncode == 0 and b'All tests successful.' in result.stdout
        print('Supplied fifteen-suite direct consumers PASS; exact134-file input population unchanged')
    else:
        variants = []

        def variant(name, changed, reason):
            assert changed != source
            variants.append((name, changed.encode(), reason))

        variant('source-token', edit(source, '_eligible_input_scope',
            '_same_reference($_inputs->{source_token}, _current_source_token())', '1'),
            'same actual event reselected in a different source token cannot borrow input scope')

        changed = edit(source, '_capture_input_record',
            'my $record = $_inputs->{captures}{Scalar::Util::refaddr($capture)};',
            'my $record = $_inputs->{captures}{Scalar::Util::refaddr($capture)}\n'
            '  || (grep { _same_reference($_->{callback}, $callback)\n'
            '      && _same_reference($_->{value}, $capture->{value}) } values %{$_inputs->{captures}})[0];')
        changed = edit(changed, '_capture_input_record', '_same_reference($record->{capture}, $capture)', '1')
        variant('copied-capture-selection', changed, 'copied outer capture denied')

        variant('callback-identity', edit(source, '_capture_input_record',
            '_same_reference($record->{callback}, $callback)', '1'), 'foreign callback denied')
        variant('event-identity', edit(source, '_capture_input_record',
            '_same_reference($record->{event}, $event)', '1'), 'copied event cannot borrow another event capture')
        variant('capture-value', edit(source, '_capture_input_record',
            '_same_reference($record->{value}, $capture->{value})', '1'),
            'changed capture return revokes an already selected grant')

        changed = edit(source, '_input_record',
            'my $record = $_inputs->{grants}{Scalar::Util::refaddr($grant)};',
            'my $record = $_inputs->{grants}{Scalar::Util::refaddr($grant)} || (values %{$_inputs->{grants}})[0];')
        changed = edit(changed, '_input_record', '_same_reference($record->{grant}, $grant)', '1')
        variant('copied-grant-selection', changed, 'copied opaque grant denied')

        start, end = sub_body(source, '_input_record')
        block_start = source.index(" if ($record->{kind} ne 'event') {", start, end)
        block_end = source.index('\n return $record', block_start, end)
        variant('cached-native-grant', source[:block_start] + source[block_end:],
            'changed AST ancestor revokes an already selected grant')

        variant('parent-revalidation', edit(source, '_input_record',
            'my $parent = _input_record($capture->{parent});',
            'my $parent = $_inputs->{grants}{Scalar::Util::refaddr($capture->{parent})};'),
            'changed retained parent revokes its descendant grant')
        variant('global-rebase', edit(source, '_rebase_input_frame',
            '$parent->{source_span}{start} + ', '', count=2),
            'actual AST argument joins original event interval')
        variant('argument-occurrence-index', edit(source, '_native_input_for',
            '$capture->{native}, $capture->{callback}, $arguments, $index)',
            '$capture->{native}, $capture->{callback}, $arguments, 0)'),
            'actual MethodExpr occurrence joins original event interval')
        variant('callback-once', edit(source, '_capture_source_input',
            'my $native = $mode eq', '$callback->(@_);\n my $native = $mode eq'),
            'actual callback called once')
        changed = edit(source, '_capture_source_input',
            'my $source = @_ &&', 'my @arguments = @_;\n my $source = @_ &&')
        changed = edit(changed, '_capture_source_input', '($callback, @_)', '($callback, @arguments)', count=3)
        variant('argument-aliases', changed, 'extra scalar alias preserved')
        variant('append-event-identity', edit(source, '_append_input',
            '_same_reference($record->{event}, $input->{event})', '1'),
            'invalid or foreign actual grant cannot copy original authority')
        variant('consume-event-identity', edit(source, '_consume_input',
            '_same_reference($record->{event}, $input->{event})', '1'),
            'invalid or foreign actual grant cannot consume source')
        variant('consume-child-interval', edit(source, '_consume_input',
            '%{$input->{frame}{source_span}}', '%{$record->{origin}{source_span}}'),
            'only actual selected child consumed')
        variant('transformed-text', edit(source, '_append_piece',
            '&& substr($origin->{source}, $start, $end - $start) eq $text', '&& 1'),
            'independent per-character original occurrence oracle')

        reports = []
        for name, raw, reason in variants:
            (supplied / MODULE).write_bytes(raw)
            population = dict(inputs, **{MODULE: digest(raw)})
            syntax, checked = capture(supplied, ['perl', '-Iperl', '-c', MODULE], population)
            assert checked.returncode == 0, (name, checked.stderr)
            row, result = capture(supplied, ['perl', '-Iperl', TEST], population)
            row.update(case=name, source_sha256=digest(raw), original_source_sha256=digest(files[MODULE]),
                       distinguishing_reason=reason, syntax=syntax,
                       scope='One valid source inverse; actual same authored183-assertion fixture, complete plan and semantic assertion RED required. No syntax/crash/absent-interface control counts as semantic falsification.')
            retain('inverse-' + name, row)
            semantic_failures = [line for line in result.stdout.splitlines()
                                 if line.startswith(b'not ok ') and reason.encode() in line]
            assert result.returncode != 0 and semantic_failures, (name, result.returncode, reason)
            assert re.search(rb'^1\.\.183$', result.stdout, re.MULTILINE), (name, 'incomplete fixture plan')
            reports.append({'case': name, 'path': PREFIX + 'inverse-' + name + '.json',
                            'sha256': digest((ROOT / (PREFIX + 'inverse-' + name + '.json')).read_bytes()),
                            'source_sha256': digest(raw), 'reason': reason,
                            'observed': 'RED', 'semantic_failures': len(semantic_failures)})
            (supplied / MODULE).write_bytes(files[MODULE])
            assert census(supplied) == inputs
        retain('inverses', {'result': 'PASS', 'source_sha256': digest(files[MODULE]),
                            'fixture_sha256': inputs[TEST], 'producer_sha256': digest(Path(__file__).read_bytes()),
                            'rows': reports, 'scope': 'Sixteen valid source inverses; complete183 fixture plan and reason-specific semantic RED for each. Exact source and entire supplied file population restore after each inverse.'})
        print('Effective source inverses PASS:', len(reports), 'complete reason-sensitive semantic RED observations')
