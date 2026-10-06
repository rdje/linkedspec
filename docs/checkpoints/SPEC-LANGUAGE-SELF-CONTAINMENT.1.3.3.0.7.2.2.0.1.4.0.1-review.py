"""Independent literal boundary labels, public effects and complete-input review."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review.py')
REVISION = 'da5c8d1f66732f0989cecca745557005fe44e7c1'
OWNERS = ['perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm', 'perl/LinkedSpec/ActionIR/Contracts.pm']
MODULE = 'perl/LinkedSpec/ActionIR/BoundaryLabels.pm'
FIXTURE = 't/capture_boundary_quoted_labels.t'
TESTS = [FIXTURE, 't/typed_source_location_perl_contract.t', 't/actionir_helper_source_provenance.t', 't/actionir_statement_source_frames.t', 't/actionir_ast_parser.t', 't/canonical_event_occurrence_order.t', 't/actionir_nested_block_source_spans.t', 't/trace_actionir_method_lowering.t', 't/phase0_regression.t']
PLANS = [18, 4, 23, 28, 23, 15, 20, 4, 1034]
RED = [4, 5, 6, 7, 8, 9, 12, 13, 14]
BEFORE = {
    'comma': ['"a', 'b"', 'end'],
    'phantom': ['"a', 'b', 'c"', 'end'],
    'single-phantom': ["'a", 'b', "c'", 'end'],
    'escaped-quote': ['"a\\"b', 'c"', "'x\\'y", "z'", 'end'],
    'escaped-slash': ['"a\\\\b', 'c"', 'end'],
    'escaped-comma': ['"a\\', 'b"', 'end'],
    'only-unresolved': ['"a', 'b', 'c"'],
    'quoted-spaces': ['" a', 'b "', 'end'],
    'unicode-crlf': ['"λ', '界"', 'end'],
}


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def decode(value):
    assert value['encoding'] == 'gzip-base64', 'channel encoding'
    raw = gzip.decompress(base64.b64decode(value['data'], validate=True))
    assert len(raw) == value['bytes'] and sha(raw) == value['sha256'], 'complete channel bytes'
    return raw


def envelope(raw):
    return dict(encoding='gzip-base64', bytes=len(raw), sha256=sha(raw), data=base64.b64encode(gzip.compress(raw, mtime=0)).decode())


def check_inputs(manifest):
    epoch = manifest['epoch']
    assert epoch in ('before', 'after') and manifest['revision'] == REVISION, 'input boundary'
    original = {}
    excluded = []
    for row in filter(None, subprocess.check_output(['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT).split(b'\0')):
        metadata, path = row.split(b'\t', 1)
        mode, kind, oid, size = metadata.split()
        if kind == b'blob' and mode in (b'100644', b'100755'):
            original[path.decode()] = (mode.decode(), oid.decode(), int(size))
        else:
            excluded.append(dict(path=path.decode(), mode=mode.decode(), kind=kind.decode()))
    entries = {e['path']: e for e in manifest['entries']}
    assert len(entries) == len(manifest['entries']) and entries.keys() == original.keys(), 'complete unique original inputs'
    assert manifest['excluded_metadata'] == excluded, 'black-box metadata exclusions'
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT, stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for path, identity in original.items():
            e = entries[path]
            assert (e['mode'], e['oid'], e.get('baseline_bytes', e['bytes'])) == identity, 'original Git identity'
            process.stdin.write((e['oid']+'\n').encode()); process.stdin.flush()
            assert process.stdout.readline().split() == [e['oid'].encode(), b'blob', str(identity[2]).encode()], 'blob header'
            raw = process.stdout.read(identity[2]); assert process.stdout.read(1) == b'\n', 'blob framing'
            assert sha(raw) == e.get('baseline_sha256', e['sha256']), 'original content identity'
            replacement = epoch == 'after' and path in OWNERS
            assert bool(e.get('declared_owner_delta')) == replacement, 'exact owner replacements'
            if replacement:
                current = (ROOT/path).read_bytes()
                assert e['bytes'] == len(current) and e['sha256'] == sha(current), 'owner replacement bytes'
            elif path.startswith(('perl/', 'specs/', 't/')) and path not in OWNERS:
                assert raw == (ROOT/path).read_bytes(), 'unchanged existing consumers'
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0
    paths = [Path(PREFIX+n).relative_to(ROOT).as_posix() for n in ('cases.json', 'probe.pl')] + [FIXTURE]
    if epoch == 'after':
        paths.append(MODULE)
    assert [e['path'] for e in manifest['overlays']] == paths, 'exact new overlays'
    for e in manifest['overlays']:
        raw = (ROOT/e['path']).read_bytes()
        assert e['mode'] == '100644' and e['bytes'] == len(raw) and e['sha256'] == sha(raw), 'overlay byte identity'


def assignment(labels):
    quoted = ["'"+s.replace('\\', '\\\\').replace("'", "\\'")+"'" for s in labels]
    return 'my @__ls_boundary_labels = ('+', '.join(quoted)+');'


def check_rows(rows, cases, epoch):
    assert [r['id'] for r in rows] == [c['id'] for c in cases], 'complete literal case order'
    assert len(cases) == 18, 'authored case population'
    for row, case in zip(rows, cases):
        assert 'failure' not in row and row['stderr'] == '', 'successful probe channels'
        labels = BEFORE.get(case['id'], case['labels']) if epoch == 'before' else case['labels']
        expected = [] if labels is None else [dict(raw=case['raw'], args=dict(boundaries=labels)) for _ in case['intervals']]
        assert row['events'] == expected, 'literal whole-label event population'
        for start, end in case['intervals']:
            assert case['action'][start:end] == case['raw'], 'independent original scalar intervals'
        if labels is None:
            assert set(row) == {'id', 'events', 'stdout', 'stderr'} and row['stdout'] == '', 'excluded grammar remains excluded'
            continue
        assert row['built'] == 'CODE' and isinstance(row['parser_source'], str), 'complete public compiler channels'
        assert assignment(labels) in row['substitution'], 'exact public label emission'
        descriptor = row['action_rewriter']
        boundary = [e for e in descriptor['canonical_action_ir_events'] if e['contract_id'] == 'capture_until_boundary']
        assert len(boundary) == 1 and boundary[0]['args'] == dict(boundaries=labels) and boundary[0]['raw'] == case['raw'], 'literal public descriptor boundary'
        helpers = [e for e in descriptor['helper_action_ir_events'] if e['contract_id'] == 'capture_until_boundary']
        assert len(helpers) == 1 and helpers[0]['args'] == dict(boundaries=labels) and helpers[0]['raw'] == case['raw'], 'literal public helper descriptor boundary'
        if case['id'] == 'escaped-comma':
            error = row['runtime_error']
            assert row['value'] is None and error['type'] == 'runtime_handler' and error['stage'] == 'rule_handler_eval' and 'Undefined subroutine &LinkedSpec::SpecEntry::capture_until_boundary' in error['detail'], 'owned nested escape runtime exclusion'
            assert 'source_span_missing => TAKEN' in row['assignment_trace'] and 'contract_id=capture_until_boundary' in row['assignment_trace'], 'actual source-span-missing mechanism'
            assert 'capture_until_boundary("a\\\\,b", end)' in row['assignment_substitution'], 'actual earlier escape normalization'
            assert descriptor['unresolved_helper_count'] == 1, 'explicit unresolved escape descriptor'
        else:
            value = dict(body='', cursor=0, rest=case['input']) if epoch == 'before' and case['id'] in ('phantom', 'single-phantom', 'only-unresolved') else case['expected']
            assert row['value'] == value and row['runtime_error'] is None, 'literal public runtime cursor and value'
            assert assignment(labels) in row['parser_source'], 'actual generated whole-label emission'
            assert row['stdout'] == '' and descriptor['unresolved_helper_count'] == 0, 'quiet successful runtime readiness'


def check_report(report, manifest, cases):
    epoch = manifest['epoch']
    assert report['complete'] is True and report['epoch'] == epoch and report['revision'] == REVISION, 'complete runtime boundary'
    assert report['instrument_sha256'] == sha(Path(PREFIX+'capture.py').read_bytes()), 'actual capture producer'
    stream = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
    assert report['stream_instrument_sha256'] == sha((ROOT/stream).read_bytes()), 'actual guard producer'
    assert [(r['kind'], r['seed']) for r in report['runs']] == [('regression' if epoch == 'before' else 'fixtures', 0), ('legacy', 0), ('legacy', 1), ('legacy', 42)], 'complete command population'
    population = len(manifest['entries'])+len(manifest['overlays'])
    channels = []
    for run in report['runs']:
        fixture = run['kind'] != 'legacy'
        command = ['prove', '-v', '-Iperl']+([FIXTURE] if epoch == 'before' else TESTS) if fixture else ['perl', '-Iperl', Path(PREFIX+'probe.pl').relative_to(ROOT).as_posix()]
        assert run['command'] == ['bash', 'tools/project_data_run.sh']+command, 'actual command identity'
        assert run['exit'] == (1 if fixture and epoch == 'before' else 0) and run['inputs_before'] == run.get('inputs_after') == population, 'complete actual exit and guards'
        raw = decode(run['stdout']); stderr = decode(run['stderr'])
        if not fixture:
            assert stderr == b'', 'quiet outer probe channel'
            rows = json.loads(raw); check_rows(rows, cases, epoch); channels.append(rows)
        else:
            text = raw.decode()
            if epoch == 'before':
                assert re.findall(r'^not ok (\d+)\b', text, re.M) == list(map(str, RED)), 'actual nine distinguishing RED groups'
                assert re.findall(r'^ok (\d+)\b', text, re.M) == [str(i) for i in range(1,19) if i not in RED], 'unchanged positive RED controls'
                assert re.findall(r'^1\.\.(\d+)\s*$', text, re.M) == ['18'], 'complete original fixture plan'
            else:
                assert stderr == b'' and not re.search(r'^\s*not ok\b', text, re.M), 'all selected nested assertions pass'
                for test, plan in zip(TESTS, PLANS):
                    part = text.split(test+' ..',1)[1].split('\n1..'+str(plan),1)[0]
                    assert re.findall(r'^ok (\d+)\b', part, re.M) == list(map(str,range(1,plan+1))), 'complete ordered positive fixture reach'
                assert re.findall(r'^1\.\.(\d+)\s*$', text, re.M) == list(map(str,PLANS)), 'complete selected fixture plans'
                assert 'skip nested unknown-escape normalization is owned by .1.4.0.1.1' in text, 'explicit runtime exclusion disclosure'
    normalized = []
    for rows in channels:
        rows = copy.deepcopy(rows)
        for row in rows:
            row.pop('assignment_trace', None)
            row['stdout'] = re.sub(r'\[\d{4}-\d\d-\d\d \d\d:\d\d:\d\d\]', '[time]', row['stdout'])
        normalized.append(rows)
    assert normalized[0] == normalized[1] == normalized[2], 'seed-independent public effects excluding dynamic diagnostic trace'
    return channels[0]


def compare(before, after):
    for old, new in zip(before, after):
        old, new = copy.deepcopy(old), copy.deepcopy(new)
        for row in (old, new):
            row.pop('assignment_trace', None)
            row['stdout'] = re.sub(r'\[\d{4}-\d\d-\d\d \d\d:\d\d:\d\d\]', '[time]', row['stdout'])
            for event in row['events']:
                event['args']['boundaries'] = ['<whole labels>']
            if 'action_rewriter' in row:
                for key in ('canonical_action_ir_events', 'helper_action_ir_events'):
                    for event in row['action_rewriter'][key]:
                        if event['contract_id'] == 'capture_until_boundary':
                            event['args']['boundaries'] = ['<whole labels>']
                for key in ('substitution', 'parser_source'):
                    row[key] = re.sub(r'my @__ls_boundary_labels = \([^;]*\);', '<whole label emission>', row[key])
            if row['id'] in ('phantom', 'single-phantom', 'only-unresolved'):
                row['value'] = '<diagnosed phantom boundary correction>'
        assert old == new, 'only diagnosed label and phantom-runtime effects change'


def check_source_delta(path, current):
    original = subprocess.check_output(['git', 'show', REVISION+':'+path], cwd=ROOT).decode()
    anchor = "use LinkedSpec::ActionIR::MethodExpr ();\n" if path == OWNERS[0] else "use LinkedSpec::OwnerDispatch ();\n"
    expected = original.replace(anchor, anchor+'use LinkedSpec::ActionIR::BoundaryLabels ();\n', 1)
    if path == OWNERS[0]:
        start = expected.index(' my @boundaries;\n', expected.index('sub _scan_contract_capture_until_boundary'))
        end = expected.index('\n}', start)
        replacement = ' my $boundaries = LinkedSpec::ActionIR::BoundaryLabels::_decode_recognized_labels($+{boundaries});\n push @events, {raw => $&, args => {boundaries => $boundaries}};'
    else:
        start = expected.index('     for my $boundary (split(/\\s*,\\s*/, $+{boundaries})) {')
        end = expected.index('      $boundary =~ s/\\\\/\\\\\\\\/g;', start)
        replacement = '     for my $boundary (@{LinkedSpec::ActionIR::BoundaryLabels::_decode_recognized_labels($+{boundaries})}) {\n'
    expected = expected[:start]+replacement+expected[end:]
    assert current == expected, 'only shared tokenizer imports and exact original decode loops change'


def main():
    cases = json.loads(Path(PREFIX+'cases.json').read_bytes())
    manifests = [json.loads(Path(PREFIX+e+'-inputs.json').read_bytes()) for e in ('before','after')]
    reports = [json.loads(Path(PREFIX+e+'-observations.json').read_bytes()) for e in ('before','after')]
    for m in manifests:
        check_inputs(m)
    for path in OWNERS:
        check_source_delta(path, (ROOT/path).read_text())
    rows = [check_report(r,m,cases) for r,m in zip(reports,manifests)]
    compare(*rows)
    controls = []
    changes = [('omit case', lambda d:d['runs'][1].update(stdout=envelope(json.dumps(rows[1][:-1]).encode())), 'complete literal case order'),
               ('forge producer', lambda d:d.update(instrument_sha256='0'*64), 'actual capture producer'),
               ('erase command', lambda d:d['runs'].pop(), 'complete command population'),
               ('promote failed exit', lambda d:d['runs'][0].update(exit=1), 'complete actual exit and guards'),
               ('erase guard', lambda d:d['runs'][1].update(inputs_after=0), 'complete actual exit and guards'),
               ('forge channel', lambda d:d['runs'][1]['stdout'].update(sha256='0'*64), 'complete channel bytes'),
               ('drop positive reach', lambda d:d['runs'][0].update(stdout=envelope(decode(d['runs'][0]['stdout']).replace(b'\nok 18 -', b'\n# missing 18 -',1))), 'complete ordered positive fixture reach'),
               ('hide nested failure', lambda d:d['runs'][0].update(stdout=envelope(decode(d['runs'][0]['stdout']).replace(b'    ok 1 -', b'    not ok 1 -',1))), 'all selected nested assertions pass')]
    for index, case in enumerate(cases):
        if case['labels'] is not None:
            def change(d, index=index):
                altered = copy.deepcopy(rows[1]); altered[index]['events'][0]['args']['boundaries'] = ['fragment']
                d['runs'][1]['stdout'] = envelope(json.dumps(altered).encode())
            changes.append(('fragment '+case['id'], change, 'literal whole-label event population'))
    for index in (4, 5, 11):
        def change(d, index=index):
            altered = copy.deepcopy(rows[1]); altered[index]['value'] = rows[0][index]['value']
            d['runs'][1]['stdout'] = envelope(json.dumps(altered).encode())
        changes.append(('restore phantom runtime '+cases[index]['id'], change, 'literal public runtime cursor and value'))
    def erase_trace(d):
        altered = copy.deepcopy(rows[1]); altered[8]['assignment_trace'] = ''
        d['runs'][1]['stdout'] = envelope(json.dumps(altered).encode())
    changes.append(('hide nested source root', erase_trace, 'actual source-span-missing mechanism'))
    for name, key, reason in [('forge public emission', 'substitution', 'exact public label emission'), ('forge compiler tail', 'parser_source', 'only diagnosed label and phantom-runtime effects change')]:
        def change(d, key=key):
            for run in d['runs'][1:] if key == 'parser_source' else d['runs'][1:2]:
                altered = json.loads(decode(run['stdout']))
                altered[4][key] = 'forged emission' if key == 'substitution' else altered[4][key]+'\n# forged compiler tail\n'
                run['stdout'] = envelope(json.dumps(altered).encode())
        changes.append((name, change, reason))
    def forge_helper_descriptor(d):
        altered = copy.deepcopy(rows[1])
        boundary = next(e for e in altered[4]['action_rewriter']['helper_action_ir_events'] if e['contract_id'] == 'capture_until_boundary')
        boundary['args']['boundaries'] = ['fragment']
        d['runs'][1]['stdout'] = envelope(json.dumps(altered).encode())
    changes.append(('forge helper descriptor', forge_helper_descriptor, 'literal public helper descriptor boundary'))
    for name, change, reason in changes:
        candidate = copy.deepcopy(reports[1]); change(candidate)
        try:
            checked = check_report(candidate, manifests[1], cases)
            compare(rows[0], checked)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error), reason)
            controls.append(dict(name=name, observed='RED', reason=reason))
        else:
            raise AssertionError('accepted corruption: '+name)
    for name, change, reason in [
        ('omit original input', lambda d:d['entries'].pop(), 'complete unique original inputs'),
        ('erase module overlay', lambda d:d['overlays'].pop(), 'exact new overlays'),
        ('forge Git content', lambda d:d['entries'][0].update(sha256='0'*64), 'original content identity'),
        ('forge overlay bytes', lambda d:d['overlays'][0].update(sha256='0'*64), 'overlay byte identity'),
        ('alter metadata exclusions', lambda d:d.update(excluded_metadata=[]), 'black-box metadata exclusions'),
    ]:
        candidate = copy.deepcopy(manifests[1]); change(candidate)
        try:
            check_inputs(candidate)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error), reason)
            controls.append(dict(name=name, observed='RED', reason=reason))
        else:
            raise AssertionError('accepted input corruption: '+name)
    for path in OWNERS:
        try:
            check_source_delta(path, (ROOT/path).read_text()+'# forged recognition\n')
        except AssertionError as error:
            assert str(error) == 'only shared tokenizer imports and exact original decode loops change'
            controls.append(dict(name='alter owner '+path, observed='RED', reason=str(error)))
        else:
            raise AssertionError('accepted source alteration')
    result = dict(complete=True, revision=REVISION, regular_inputs=len(manifests[0]['entries']), cases=18, compiler_cases=14, runtime_successes=13, events_per_seed=28, seeds=3, commands=8, before_red_groups=9, after_green_groups=18, fixture_suites=len(TESTS), fixture_groups=sum(PLANS), runtime_exclusion='SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1', controls=controls, instrument_sha256=sha(Path(__file__).read_bytes()))
    Path(PREFIX+'verification.json').write_text(json.dumps(result,indent=2)+'\n')
    print('Quoted labels: RED9/GREEN18; 1169 focused groups; 13 successful runtimes and one explicitly owned exclusion; '+str(len(controls))+' evidence RED')


if __name__ == '__main__':
    main()
