"""Grade exact replacement diagnosis; passing review does not claim a product repair."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import importlib.util
import json
import re

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review.py')
REVISION = 'fa9b7608ed9e49712129bb5456d75d118e7207a0'
INPUT_CHECKER = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.2-review.py'
RED = ['quoted_before', 'interleaved_equal', 'distinct_twins', 'double_quoted_before',
       'unicode_crlf', 'generated_data', 'set_before']
TESTS = ['t/' + name + '.t' for name in (
    'actionir_ast_parser', 'canonical_event_occurrence_order',
    'actionir_nested_block_source_spans', 'actionir_compiler_source_membership',
    'actionir_executable_source_membership', 'trace_emit_context_bridge')]
# Six compile failures plus set's runtime failure; fourteen sources include seven healthy controls.


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def decode(block):
    assert block['encoding'] == 'gzip-base64', 'channel encoding'
    raw = gzip.decompress(base64.b64decode(block['data'], validate=True))
    assert len(raw) == block['bytes'] and sha(raw) == block['sha256'], 'complete channel identity'
    return raw


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def read(suffix):
    return json.loads(Path(PREFIX + suffix).read_bytes())


def check_inputs(manifest, prefix, trace=False):
    spec = importlib.util.spec_from_file_location('retained_git_input_checker', ROOT / INPUT_CHECKER)
    checker = importlib.util.module_from_spec(spec); spec.loader.exec_module(checker)
    # Reuse the unchanged byte/population checker at this explicit new boundary.
    checker.REVISION = REVISION
    committed = copy.deepcopy(manifest)
    committed['entries'] = [entry for entry in manifest['entries'] if not entry.get('overlay')]
    committed['overlays'] = []
    count = checker.check_inputs(committed)
    expected = [prefix + suffix for suffix in ('cases.json', 'probe.pl', 'red-fixture.t')]
    if trace:
        expected.append(prefix + 'trace.pl')
    assert manifest['overlays'] == expected, 'exact diagnosis overlays'
    overlays = [entry for entry in manifest['entries'] if entry.get('overlay')]
    assert [entry['path'] for entry in overlays] == expected, 'unique overlay population'
    for entry in overlays:
        raw = (ROOT / entry['path']).read_bytes()
        assert entry['bytes'] == len(raw) and entry['sha256'] == sha(raw) and entry['mode'] == '100644', 'exact authored overlay'
    return count + len(overlays)


def nodes(value):
    if isinstance(value, dict):
        yield value
        for child in value.values():
            yield from nodes(child)
    elif isinstance(value, list):
        for child in value:
            yield from nodes(child)


def check_public(data, case, seed, corrected):
    assert data['id'] == case['id'] and data['seed'] == str(seed), 'exact source seed'
    assert data['source'] == case['source'] and data['action'] == case['action'], 'exact authored source'
    assert data['source_sha256'] == sha(case['source'].encode()), 'source byte identity'
    assert data['ast']['source'] == case['action'], 'original AST source'
    if corrected:
        assert data['unobserved_substitution'] == data['substitution'], 'same-facade observer equivalence'
    if not corrected and case['id'] == 'deferred_body':
        assert 'observer changed actual substitution' in data['native']['compile_exception'], 'retained wrong-context guard'
        assert data['fresh'] is None and data['metadata'] is None, 'honest incomplete initial deferred channels'
        return
    assert data['native']['compile_exception'] is None and data['fresh'] is not None, 'complete public execution channels'
    assert data['dump'] == data['emitted'], 'dump and emitted source agreement'
    assert data['fresh']['emitted_sha256'] == sha(data['emitted'].encode()), 'actual fresh emitted bytes'
    if not corrected and case['id'] == 'generated_data':
        assert data['native']['value'] == data['fresh']['value'] == [None, 1], 'original invalid-cat result'
        assert data['metadata']['unresolved_helper_hits'] == {'cat': 1}, 'original invalid-cat blocker'
    elif case['id'] in RED:
        assert data['native']['value'] is None and data['fresh']['value'] is None, 'actual failed route values'
        assert data['native']['context_error'] and data['fresh']['exception'], 'actual failed route errors'
        marker = 'Undefined subroutine' if case['id'] == 'set_before' else "Can't modify constant item"
        assert marker in data['native']['context_error']['detail'], 'native distinguishing failure'
        fresh_error = data['fresh']['exception']
        assert marker in (fresh_error['detail'] if isinstance(fresh_error, dict) else fresh_error), 'fresh distinguishing failure'
    else:
        assert data['native']['value'] == data['fresh']['value'] == case['expected_value'], 'healthy authored route oracle'
        assert not data['native']['context_error'] and not data['fresh']['exception'], 'healthy route errors'
    # Validate real producer coordinates independently of replacement text lookup.
    if case['id'] not in ('nested_if', 'deferred_body'):
        wanted = [{'raw': span['raw'], 'start': span['start'], 'end': span['end']}
                  for span in case['spans'] if span['role'] == 'real']
        watched = {span['raw'] for span in case['spans']}; found = []
        for scan in data['scans']:
            if scan['source'] != case['action']:
                continue
            origins = {origin['event_id']: origin for origin in scan['origins']}
            for event in scan['events']:
                if event['selected'] and event['event']['raw'] in watched:
                    assert event['event_id'] in origins, 'original event-bound origin present'
                    origin = origins[event['event_id']]
                    assert origin['source'] == case['action'], 'original event-bound source'
                    found.append(dict(raw=event['event']['raw'], **origin['source_span']))
        assert found == wanted, 'independent selected real intervals/order'
        parsed = [{'raw': node['source'], **node['source_span']} for node in nodes(data['ast'])
                  if node.get('kind') == 'assign_scalar' and node.get('source') in watched]
        # set has its existing call AST rather than assignment AST.
        if case['contract'] == 'scalar_assignment_operator':
            assert parsed == wanted, 'independent typed assignment intervals/order'
    selected = [event for scan in data['scans'] if scan['source'] == case['action']
                for event in scan['events'] if event['selected']]
    collected = data['collection']['events']
    for event in collected:
        candidates = [original for original in selected if original['args_id'] == event['args_id']
                      and original['event']['raw'] == event['event']['raw']]
        assert len(candidates) == 1 and candidates[0]['event_id'] != event['event_id'], 'collector copy/argument identity'
        assert 'source_span' not in event['event'] and 'source_origins' not in event['event'], 'no public origin fields'
    by_id = {event['event_id']: event for event in collected}
    for pair in data['canonicalization']:
        assert pair['helper_id'] in by_id and pair['helper'] == by_id[pair['helper_id']]['event'], 'actual canonical producer input'
        assert pair['canonical_id'] != pair['helper_id'] and pair['canonical_args_id'] != pair['helper_args_id'], 'canonical copy identity'
        assert pair['canonical']['raw'] == pair['helper']['raw'], 'canonical raw identity'
    if case['id'] == 'quoted_before':
        raw = case['spans'][0]['raw']
        lookups = [lookup for lookup in data['lookups'] if lookup['raw'] == raw]
        assert len(lookups) == 2, 'two reached original/rewritten lookups'
        assert lookups[0]['text'] == case['action'] and lookups[0]['position'] == 32, 'correct original real frame'
        expected_text = "$quoted = '" + raw + "'; " + raw + '; return([quoted,out])'
        assert lookups[1]['text'] == expected_text and lookups[1]['position'] == 11, 'actual rewritten quoted-twin location'
        assert len("$quoted = '" + raw + "'; ") == 35 and lookups[1]['position'] != 35, 'distinguishing real rewritten interval'
        assert all(lookup['caller'].endswith('/perl/LinkedSpec/ActionIR/RewritePipeline.pm') for lookup in lookups), 'reached replacement source owner'


def check_report(report, manifest, prefix, corrected):
    assert report['complete'] is True and report['revision'] == REVISION, 'complete capture'
    assert report['instrument_sha256'] == sha((ROOT / (prefix + 'capture.py')).read_bytes()), 'actual capture producer'
    count = len(manifest['entries']); cases = json.loads((ROOT / (prefix + 'cases.json')).read_bytes())
    expected = [('public:' + case['id'], seed) for seed in (0, 1, 42) for case in cases]
    expected += [('diagnostic-tap', 0), ('consumers', 0)]
    assert [(run['kind'], run['seed']) for run in report['runs']] == expected, 'complete ordered command population'
    for run in report['runs']:
        assert run['inputs_before'] == run['inputs_after'] == count, 'whole input byte/mode guards'
        stdout = decode(run['stdout']); decode(run['stderr'])
        if run['kind'].startswith('public:'):
            assert run['exit'] == 0, 'complete observer exit'
            name = run['kind'].split(':', 1)[1]; case = next(case for case in cases if case['id'] == name)
            assert run['command'] == ['bash', 'tools/project_data_run.sh', 'perl', '-Iperl', prefix + 'probe.pl', name], 'actual observer command'
            check_public(json.loads(stdout), case, run['seed'], corrected)
        elif run['kind'] == 'diagnostic-tap':
            assert run['command'] == ['bash', 'tools/project_data_run.sh', 'prove', '-v', '-Iperl', prefix + 'red-fixture.t'], 'actual RED command'
            text = stdout.decode(); groups = re.findall(r'^(not ok|ok) (\d+) - (.+)$', text, re.M)
            assert run['exit'] == 1 and re.findall(r'^1\.\.(\d+)$', text, re.M) == ['14'], 'complete actual RED plan'
            assert [(number, name) for _, number, name in groups] == [(str(i), case['id']) for i, case in enumerate(cases, 1)], 'complete ordered RED reach'
            failed = [name for state, _, name in groups if state == 'not ok']
            assert failed == RED, 'exact RED and healthy guard groups'
            assert 'Result: FAIL' in text, 'actual RED harness result'
        else:
            assert run['command'] == ['bash', 'tools/project_data_run.sh', 'prove', '-v', '-Iperl'] + TESTS, 'actual consumer command'
            text = stdout.decode(); plans = [int(n) for n in re.findall(r'^1\.\.(\d+)$', text, re.M)]
            assert run['exit'] == 0 and 'Result: PASS' in text and 'All tests successful.' in text, 'complete consumer success'
            assert not re.search(r'^\s*not ok ', text, re.M), 'all nested consumer assertions'
            assert plans == [23, 15, 20, 41, 41, 4], 'unchanged complete consumer plans'
            assert len(re.findall(r'^ok \d+ - ', text, re.M)) == sum(plans), 'complete consumer reach'
    return len(cases)


def check_traces(report, manifest, prefix, publics):
    assert report['complete'] and report['revision'] == REVISION, 'complete actual traces'
    assert report['producer_sha256'] == sha((ROOT / (prefix + 'trace-capture.py')).read_bytes()), 'actual trace producer'
    assert [run['id'] for run in report['runs']] == ['quoted_before', 'interleaved_equal', 'generated_data'], 'complete ordered trace population'
    for run in report['runs']:
        assert run['seed'] == 0 and run['command'] == ['bash', 'tools/project_data_run.sh', 'perl', '-Iperl', prefix + 'trace.pl', run['id']], 'actual trace command/seed'
        assert run['exit'] == 0 and run['inputs_before'] == run['inputs_after'] == len(manifest['entries']), 'trace exit/input guards'
        data = json.loads(decode(run['stdout'])); decode(run['stderr'])
        trace = base64.b64decode(data['trace_base64'], validate=True)
        assert len(trace) == data['trace_bytes'] and sha(trace) == data['trace_sha256'], 'complete actual trace bytes'
        assert data['action'] == publics[run['id']]['action'] and data['substitution'] == publics[run['id']]['substitution'], 'source-identical actual trace/substitution'
        assert b'actionir:rewrite_pipeline:lower_action_code_from_canonical_ir:Top:statement_rewritten' in trace, 'actual reached rewrite decision'


def change_public(report, name, mutate):
    run = next(run for run in report['runs'] if run['kind'] == 'public:' + name and run['seed'] == 0)
    data = json.loads(decode(run['stdout'])); mutate(data)
    run['stdout'] = envelope((json.dumps(data) + '\n').encode())


def main():
    relative = Path(PREFIX).relative_to(ROOT).as_posix(); corrected = relative + 'corrected-'
    initial_manifest, current_manifest = read('inputs.json'), read('corrected-inputs.json')
    assert check_inputs(initial_manifest, relative) == check_inputs(current_manifest, corrected)
    initial, current = read('observations.json'), read('corrected-observations.json')
    check_report(initial, initial_manifest, relative, False); check_report(current, current_manifest, corrected, True)
    for middle, prefix, report in [('', relative, initial), ('corrected-', corrected, current)]:
        manifest = read(middle + 'trace-inputs.json'); check_inputs(manifest, prefix, True)
        publics = {run['kind'].split(':', 1)[1]: json.loads(decode(run['stdout']))
                   for run in report['runs'] if run['kind'].startswith('public:') and run['seed'] == 0}
        check_traces(read(middle + 'traces.json'), manifest, prefix, publics)
    controls = []
    mutations = [
        ('missing command', lambda r: r['runs'].pop()),
        ('reordered commands', lambda r: r['runs'].reverse()),
        ('incomplete capture', lambda r: r.update(complete=False)),
        ('wrong producer', lambda r: r.update(instrument_sha256='0' * 64)),
        ('observer exit', lambda r: r['runs'][0].update(exit=1)),
        ('wrong observer command', lambda r: r['runs'][0].update(command=['false'])),
        ('lost input guard', lambda r: r['runs'][0].update(inputs_after=0)),
        ('forged channel', lambda r: r['runs'][0]['stdout'].update(sha256='0' * 64)),
        ('changed source', lambda r: change_public(r, 'quoted_before', lambda d: d.update(action='changed'))),
        ('lost AST source', lambda r: change_public(r, 'quoted_before', lambda d: d['ast'].update(source='changed'))),
        ('wrong original frame', lambda r: change_public(r, 'quoted_before', lambda d: d['lookups'][2].update(position=8))),
        ('forged repaired replacement', lambda r: change_public(r, 'quoted_before', lambda d: d['lookups'][3].update(position=35))),
        ('lost real origin', lambda r: change_public(r, 'quoted_before', lambda d: d['scans'][-1]['origins'].pop())),
        ('forged collector identity', lambda r: change_public(r, 'quoted_before', lambda d: d['collection']['events'][-1].update(args_id=-1))),
        ('forged canonical identity', lambda r: change_public(r, 'quoted_before', lambda d: d['canonicalization'][-1].update(helper_id=-1))),
        ('false native success', lambda r: change_public(r, 'quoted_before', lambda d: d['native'].update(value=['claimed', 1]))),
        ('lost native error', lambda r: change_public(r, 'quoted_before', lambda d: d['native'].update(context_error=None))),
        ('lost fresh error', lambda r: change_public(r, 'quoted_before', lambda d: d['fresh'].update(exception=None))),
        ('broken healthy value', lambda r: change_public(r, 'quoted_after', lambda d: d['fresh'].update(value=None))),
        ('lost observer equivalence', lambda r: change_public(r, 'deferred_body', lambda d: d.update(unobserved_substitution='changed'))),
    ]
    for name, mutate in mutations:
        candidate = copy.deepcopy(current); mutate(candidate); assert candidate != current, 'effective control'
        try:
            check_report(candidate, current_manifest, corrected, True)
        except (AssertionError, KeyError) as error:
            controls.append({'name': name, 'observed_red': str(error)})
        else:
            raise AssertionError('unrejected evidence control: ' + name)
    summary = {'complete': True, 'revision': REVISION, 'regular_git_inputs': initial_manifest['regular_git_inputs'],
               'overlays_per_capture': 3, 'commands_per_capture': len(current['runs']),
               'authored_sources': 14, 'source_seed_pairs_per_capture': 42, 'actual_red_groups': RED,
               'healthy_groups': 14 - len(RED), 'consumer_plans': [23, 15, 20, 41, 41, 4],
               'actual_traces_per_population': 3, 'controls': controls, 'producer_sha256': sha(Path(__file__).read_bytes())}
    Path(PREFIX + 'verification.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary))


if __name__ == '__main__':
    main()
