"""Check original parser boundaries and callback identity against authored literals."""
from pathlib import Path
import copy
import importlib.util
import json
import re

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review.py')
REVISION = '6ce479842be85219990be889914f354f1a4aaa44'
BASE = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.0-'
spec = importlib.util.spec_from_file_location('original_guards', ROOT / (BASE + 'review.py'))
guards = importlib.util.module_from_spec(spec)
spec.loader.exec_module(guards)
spec = importlib.util.spec_from_file_location('literal_argument_author', PREFIX + 'oracle.py')
oracle = importlib.util.module_from_spec(spec)
spec.loader.exec_module(oracle)
guards.PREFIX = PREFIX
guards.REVISION = REVISION
TESTS = ['t/actionir_flow_direct_source_provenance.t', 't/actionir_helper_source_provenance.t',
         't/actionir_statement_source_frames.t', 't/actionir_ast_parser.t',
         't/canonical_event_occurrence_order.t', 't/actionir_nested_block_source_spans.t',
         't/trace_actionir_method_lowering.t']
PLANS = [21, 13, 28, 23, 15, 20, 4]


def check_inputs(manifest):
    # Original guard's overlay population includes its author; this diagnosis supplies
    # only runtime cases/probe. Validate original Git identities using that guard with
    # a separately checked author row, then retain the actual two-overlay population.
    assert [x['path'] for x in manifest['overlays']] == [
        Path(PREFIX + n).relative_to(ROOT).as_posix() for n in ('cases.json', 'probe.pl')], 'two actual overlays'
    adjusted = copy.deepcopy(manifest)
    raw = Path(PREFIX + 'oracle.py').read_bytes()
    adjusted['overlays'].append({'path': Path(PREFIX + 'oracle.py').relative_to(ROOT).as_posix(),
                                'mode': '100644', 'bytes': len(raw), 'sha256': guards.sha(raw)})
    guards.check_inputs(adjusted)


def check_data(data, cases):
    assert data['failure'] is None and data['internal_stdout'] == data['internal_stderr'] == '', 'successful Toolbox channels'
    assert [r['id'] for r in data['rows']] == [c['id'] for c in cases], 'complete authored case population'
    for row, case in zip(data['rows'], cases, strict=True):
        for arg in case['arguments']:
            assert case['source'][arg['start']:arg['end']] == arg['raw'], 'literal original scalar intervals'
        expected = {'method': case['method'], 'source_method': case['method'],
                    'source': case['trimmed'], 'args': [a['raw'] for a in case['arguments']]}
        assert row['source'] == case['source'], 'original input identity'
        assert row['ordinary'] == row['observed'] == expected, 'literal original parser results'
        assert row['calls'] == [{'args': [case['payload'], ('.' if case['receiver'] else '') + case['method']],
                                  'result': expected['args']}], 'exact single CSV callback and receiver context'
        assert row['args_same'] is True, 'actual returned argument array reference'
    controls = data['controls']
    assert [r['kind'] for r in controls] == ['copy', 'changed', 'foreign', 'opaque', 'nested', 'exception',
        'invalid', 'caller-error', 'flow-default', 'flow-copy', 'flow-changed', 'flow-foreign', 'flow-nested',
        'flow-exception'], 'complete callback control population'
    lookup = {r['kind']: r for r in controls}
    expected_args = {'copy': ['same', 'same'], 'changed': ['changed', 'same'],
                     'foreign': ['foreign', 'foreign'], 'opaque': {'opaque': 'exact'},
                     'nested': ['same', 'same']}
    for kind, args in expected_args.items():
        row = lookup[kind]
        assert row['result'] == {'method': 'call', 'source_method': 'call',
                                 'source': 'call( same, same )', 'args': args}, 'original custom CSV values'
        assert row['error'] is None and row['args_same'] is True, 'custom returned identity and success'
        calls = [[' same, same ', 'call']]
        if kind == 'nested':
            calls.append([' "β" ', 'inner'])
            assert row['inner'] == {'method': 'inner', 'source_method': 'inner',
                                   'source': 'inner( "β" )', 'args': ['"β"']}, 'nested original parser result'
        else:
            assert row['inner'] is None, 'no unrequested nested parser'
        assert row['calls'] == calls, 'exact custom CSV callback order'
    assert lookup['exception']['result'] is None and lookup['exception']['error'] == 'controlled CSV failure\n', 'exact CSV exception'
    assert lookup['exception']['calls'] == [[' same, same ', 'call']], 'throwing CSV called once'
    assert lookup['invalid']['cases'] == [{'source': s, 'result': None}
        for s in (None, '', '  ', 'call', 'call(a', 'call(a))')], 'original rejected parser inputs'
    assert lookup['caller-error']['after'] == 'caller sentinel', 'caller error state preserved'
    normal = [{'raw': 'case("tail")', 'args': {'value': '"tail"'}},
              {'raw': 'case("x", case("nested"))', 'args': {'value': '"x"'}},
              {'raw': 'case("nested")', 'args': {'value': '"nested"'}}]
    for kind in ('default', 'copy', 'nested'):
        assert lookup['flow-' + kind]['events'] == normal, 'original marker-first inline-second traversal'
        assert lookup['flow-' + kind]['error'] is None, 'successful original Flow callback'
    flow_calls = [['case("x", case("nested"))'], ['case("tail")'],
                  ['switch(kind, case("x", case("nested")), default(default()))'],
                  ['case("x", case("nested"))'], ['case("nested")'], ['default(default())']]
    assert lookup['flow-copy']['calls'] == lookup['flow-default']['calls'] == lookup['flow-nested']['calls'] == flow_calls, 'unchanged parser callback occurrence sequence'
    assert lookup['flow-changed']['error'] is None and lookup['flow-foreign']['error'] is None, 'changed foreign ordinary results retained'
    assert lookup['flow-changed']['calls'] == flow_calls and lookup['flow-changed']['events'] == [
        {'raw': e['raw'], 'args': {'value': 'changed'}} for e in normal], 'exact transformed Flow callback results'
    assert lookup['flow-foreign']['calls'] == flow_calls[:3] and lookup['flow-foreign']['events'] == [
        {'raw': raw, 'args': {'value': '"foreign"'}}
        for raw in ('case("x", case("nested"))', 'case("tail")')], 'exact foreign Flow callback results'
    assert lookup['flow-exception']['events'] is None and lookup['flow-exception']['error'] == 'controlled parser failure\n', 'exact Flow parser exception'
    assert len(lookup['flow-exception']['calls']) == 1, 'throwing parser called once'
    assert isinstance(data['substitution'], str) and isinstance(data['descriptor'], dict) and isinstance(data['dump'], str), 'complete public compiler channels'


def check_report(report, manifest, cases):
    assert report['complete'] is True and report['revision'] == REVISION, 'complete immutable diagnosis'
    assert report['instrument_sha256'] == guards.sha(Path(PREFIX + 'capture.py').read_bytes()), 'actual capture producer'
    stream = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'
    assert report['stream_instrument_sha256'] == guards.sha((ROOT / stream).read_bytes()), 'actual stream producer'
    assert [(r['kind'], r['seed']) for r in report['runs']] == [('fixtures', 0), ('arguments', 0), ('arguments', 1), ('arguments', 42)], 'complete guarded commands'
    count = len(manifest['entries']) + len(manifest['overlays'])
    for row in report['runs']:
        tail = ['prove', '-v', '-Iperl'] + TESTS if row['kind'] == 'fixtures' else [
            'perl', '-Iperl', Path(PREFIX + 'probe.pl').relative_to(ROOT).as_posix()]
        assert row['command'] == ['bash', 'tools/project_data_run.sh'] + tail, 'actual command identity'
        assert row['exit'] == 0 and row['inputs_before'] == row['inputs_after'] == count, 'complete runtime input guards'
        assert guards.decode(row['stderr']) == b'', 'empty outer stderr'
    text = guards.decode(report['runs'][0]['stdout']).decode()
    sections = re.split(r'^([^\n]+\.t) \.{2,}[ \t]*\n', text, flags=re.M)
    assert sections[1::2] == TESTS, 'complete fixture population'
    for body, plan in zip(sections[2::2], PLANS, strict=True):
        assert re.findall(r'^1\.\.(\d+)\s*$', body, re.M) == [str(plan)], 'complete fixture plan'
        assert [int(n) for n in re.findall(r'^ok (\d+)\b', body, re.M)] == list(range(1, plan + 1)), 'positive fixture reach'
        assert not re.search(r'^\s*not ok\b', body, re.M), 'no nested fixture failure'
    assert 'All tests successful.' in text and 'Result: PASS' in text, 'actual fixture success'
    outputs = [guards.decode(r['stdout']) for r in report['runs'][1:]]
    for raw in outputs:
        check_data(json.loads(raw), cases)
    assert len(set(outputs)) == 1, 'complete seed channel recurrence'


def main():
    cases = oracle.author()
    assert cases == json.loads(Path(PREFIX + 'cases.json').read_bytes()), 'exact independent runtime case author'
    manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
    report = json.loads(Path(PREFIX + 'observations.json').read_bytes())
    check_inputs(manifest)
    check_report(report, manifest, cases)
    data = json.loads(guards.decode(report['runs'][1]['stdout']))
    controls = []

    def reject(name, changed, reason):
        try:
            check_data(changed, cases)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error), reason)
            controls.append({'name': name, 'observed': 'RED', 'reason': reason})
        else:
            raise AssertionError('corruption accepted: ' + name)

    for index, case in enumerate(cases):
        altered = copy.deepcopy(data)
        altered['rows'][index]['observed']['source'] += 'changed'
        reject(case['id'] + ' changed source', altered, 'literal original parser results')
    for name, edit, reason in [
        ('copied reference', lambda x: x['rows'][0].update(args_same=False), 'actual returned argument array reference'),
        ('omitted callback', lambda x: x['rows'][0]['calls'].clear(), 'exact single CSV callback and receiver context'),
        ('lost empty-slot distinction', lambda x: x['rows'][1]['observed']['args'].insert(0, ''), 'literal original parser results'),
        ('wrong traversal', lambda x: x['controls'][8]['events'].reverse(), 'original marker-first inline-second traversal'),
        ('lost caller error', lambda x: x['controls'][7].update(after=''), 'caller error state preserved'),
        ('changed exception', lambda x: x['controls'][5].update(error='wrong'), 'exact CSV exception'),
        ('changed foreign result', lambda x: x['controls'][11]['events'].clear(), 'exact foreign Flow callback results'),
        ('changed transformed result', lambda x: x['controls'][10]['events'].clear(), 'exact transformed Flow callback results'),
    ]:
        altered = copy.deepcopy(data)
        edit(altered)
        reject(name, altered, reason)
    for name, edit, reason in [
        ('omitted command', lambda x: x['runs'].pop(), 'complete guarded commands'),
        ('lost input guard', lambda x: x['runs'][0].update(inputs_after=0), 'complete runtime input guards'),
        ('forged channel', lambda x: x['runs'][0]['stdout'].update(sha256='0' * 64), 'complete channel bytes'),
        ('forged producer', lambda x: x.update(instrument_sha256='0' * 64), 'actual capture producer'),
    ]:
        altered = copy.deepcopy(report)
        edit(altered)
        try:
            check_report(altered, manifest, cases)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error), reason)
            controls.append({'name': name, 'observed': 'RED', 'reason': reason})
        else:
            raise AssertionError('report corruption accepted: ' + name)
    altered = copy.deepcopy(manifest)
    altered['entries'].pop()
    try:
        check_inputs(altered)
    except AssertionError as error:
        assert str(error) == 'complete unique original Git population'
        controls.append({'name': 'lost Git input', 'observed': 'RED', 'reason': str(error)})
    else:
        raise AssertionError('missing input accepted')
    summary = {'complete': True, 'revision': REVISION, 'regular_inputs': len(manifest['entries']),
               'overlays': len(manifest['overlays']), 'commands': len(report['runs']),
               'cases': len(cases), 'arguments': sum(len(c['arguments']) for c in cases),
               'seeds': 3, 'callback_controls': len(data['controls']),
               'fixture_suites': len(TESTS), 'fixture_groups': sum(PLANS), 'controls': controls,
               'instrument_sha256': guards.sha(Path(__file__).read_bytes()),
               'scope': 'Original result/reference/boundary diagnosis. Literal intervals are independently authored expectations for a future bridge, not current published frames. No production changes or arbitrary callback authority admission.'}
    Path(PREFIX + 'verification.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps({k: v for k, v in summary.items() if k not in ('controls', 'scope')}))


if __name__ == '__main__':
    main()
