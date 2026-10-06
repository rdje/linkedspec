"""Review original populations and real nested scanner composition independently."""
from pathlib import Path
import copy
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review.py')
BASE = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.'
REVISION = '37401f576c517a91f49942893c41af020bcbfda4'
STREAM = BASE + '1.1.0-capture.py'


def module(suffix):
    path = ROOT / (BASE + suffix)
    spec = importlib.util.spec_from_file_location('composition_' + suffix.replace('.', '_').replace('-', '_'), path)
    loaded = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(loaded)
    return loaded


basic = module('1.2.1-review.py')
pipeline = module('2.3-review.py')
flow = module('3.3-review.py')
legacy = module('4.7-review.py')
dedicated = module('5.4-review.py')
oracle = module('6.0-oracle.py')
sha, decode, envelope = dedicated.sha, dedicated.decode, dedicated.envelope
PACKAGES = [
    'LinkedSpec::ActionIR::StagedParseJob',
    'LinkedSpec::ActionIR::ProgressiveSpanDispatch',
    'LinkedSpec::ActionIR::Scanner::RecognitionTransactionRules',
    'LinkedSpec::ActionIR::Scanner::PrimitiveBasicRules',
    'LinkedSpec::ActionIR::Scanner::PrimitivePipelineRules',
    'LinkedSpec::ActionIR::Scanner::FlowRules',
    'LinkedSpec::ActionIR::Scanner::LegacyRules',
]
DEPENDENCIES = sorted(['build_array_pipeline_plan_from_expr',
    'normalize_method_args_with_optional_scope', 'parse_method_function_expr',
    'split_action_ir_statements', 'trim_action_ir_value'])
TEST_NAMES = [
    'actionir_statement_source_frames', 'actionir_basic_statement_source_provenance',
    'actionir_basic_regex_source_provenance', 'actionir_helper_source_provenance',
    'actionir_ast_parser', 'canonical_event_occurrence_order', 'actionir_raw_dependency_provenance',
    'actionir_nested_block_source_spans', 'uniform_binding_contract', 'codeblock_push_composition_perl',
    'trace_actionir_pipeline', 'actionir_pipeline_regex_source_provenance',
    'actionir_pipeline_split_source_metadata', 'actionir_pipeline_statement_source_provenance',
    'actionir_flow_recursive_source_provenance', 'actionir_flow_direct_source_provenance',
    'actionir_method_argument_source_frames', 'trace_actionir_method_lowering',
    'nested_boundary_quoted_labels', 'capture_boundary_quoted_labels',
    'typed_source_location_perl_contract', 'complete_named_mark_contract', 'generated_source_contract',
    'staged_ast_enrichment_perl_contract', 'progressive_span_dispatch_perl_contract',
    'progressive_span_dispatch_perl_authority', 'recognition_transaction_perl_authority',
    'recognition_transaction_perl_contract', 'recursive_observation_perl_contract',
]
TESTS = ['t/' + name + '.t' for name in TEST_NAMES]
PLANS = [28, 29, 10, 191, 23, 15, 6, 20, 12, 605, 5, 13, 8, 16, 7, 21,
         15, 4, 28, 18, 4, 3, 12, 143, 129, 9, 8, 51, 7]
PROBES = [
    ('basic', BASE + '1.2.0-probe.pl'), ('pipeline', BASE + '2.2-probe.pl'),
    ('flow', BASE + '3.2.1-probe.pl'), ('legacy', BASE + '4.6-probe.pl'),
    ('dedicated', BASE + '5.0-probe.pl'), ('foreign-source', BASE + '1.1.2-guard-probe.pl'),
    ('method-frames', BASE + '3.2.0.1-frames-probe.pl'),
]
PRIOR = {
    'basic': ('1.2.1', 'toolbox'), 'pipeline': ('2.3', 'toolbox'),
    'flow': ('3.3', 'flow'), 'legacy': ('4.7', 'legacy'),
    'dedicated': ('5.4', 'dedicated'), 'foreign-source': ('2.3', 'foreign-source'),
    'method-frames': ('3.3', 'method-frames'), 'identity-control': ('2.3', 'identity-control'),
}


def read(suffix):
    return json.loads((ROOT / (BASE + suffix)).read_bytes())


def check_inputs(manifest):
    overlays = [Path(PREFIX + name).relative_to(ROOT).as_posix() for name in ('cases.json', 'probe.pl')]
    assert manifest['revision'] == REVISION and manifest['overlays'] == overlays, 'exact observation-only overlay boundary'
    expected, excluded = {}, []
    for row in filter(None, subprocess.check_output(['git', 'ls-tree', '-rlz', REVISION], cwd=ROOT).split(b'\0')):
        metadata, path = row.split(b'\t', 1)
        mode, kind, oid, size = metadata.split()
        if kind == b'blob' and mode in (b'100644', b'100755'):
            expected[path.decode()] = (mode.decode(), oid.decode(), int(size))
        else:
            excluded.append({'path': path.decode(), 'mode': mode.decode(), 'kind': kind.decode()})
    entries = {entry['path']: entry for entry in manifest['entries']}
    assert len(entries) == len(manifest['entries']) and set(entries) == set(expected) | set(overlays), 'complete unique input population'
    assert manifest['regular_git_inputs'] == len(expected), 'exact committed input count'
    assert manifest['excluded_metadata'] == excluded, 'exact black-box metadata exclusions'
    process = subprocess.Popen(['git', 'cat-file', '--batch'], cwd=ROOT,
                               stdin=subprocess.PIPE, stdout=subprocess.PIPE)
    try:
        for path, (mode, oid, size) in expected.items():
            entry = entries[path]
            assert (entry['mode'], entry['oid'], entry['bytes']) == (mode, oid, size), 'exact immutable object and mode'
            process.stdin.write((oid + '\n').encode()); process.stdin.flush()
            assert process.stdout.readline().split() == [oid.encode(), b'blob', str(size).encode()], 'exact immutable blob header'
            raw = process.stdout.read(size)
            assert process.stdout.read(1) == b'\n', 'exact immutable blob framing'
            assert entry['sha256'] == sha(raw), 'exact immutable input bytes'
            assert not any(entry.get(key) for key in ('declared_authored_overlay', 'declared_fixture_overlay', 'declared_owner_delta')), 'no committed input replacement'
            if path.startswith(('perl/', 'specs/', 't/')):
                assert raw == (ROOT / path).read_bytes(), 'unchanged production and fixtures'
    finally:
        process.stdin.close(); process.stdout.close(); assert process.wait() == 0
    for path in overlays:
        raw = (ROOT / path).read_bytes()
        assert path not in expected and entries[path] == {
            'path': path, 'mode': '100644', 'bytes': len(raw), 'sha256': sha(raw),
            'declared_authored_overlay': True}, 'exact new authored observation input'


def check_observation(row, case, private):
    assert row['contract'] == case['contract'] and row['source'] == case['source'], 'independent representative source and contract'
    events = [{'raw': event['raw'], 'args': event['args']} for event in case['events']]
    assert row['result']['events'] == events, 'literal representative events and arguments'
    origins = [{'event': event, 'source': case['source'], 'source_span': authored['source_span']}
               for event, authored in zip(events, case['events'], strict=True)] if private else []
    assert row['result']['source_origins'] == origins, 'literal representative scalar origins'
    identity = [{'origin_event': True, 'constructed_event': True, 'constructed_args': True}] * len(events) if private else []
    assert row['identity'] == identity, 'actual returned constructor and origin identities'
    assert row['returned_array'] is True, 'actual first-defined returned-array identity'
    index = PACKAGES.index(case['package'])
    assert row['selected'] == case['package'] and row['visited'] == [
        {'package': package, 'defined': i == index} for i, package in enumerate(PACKAGES[:index + 1])
    ], 'exact first-defined dispatcher order'
    assert row['caller_error'] == row['expected_caller_error'] == 'caller sentinel: ' + case['contract'], 'actual caller error preservation'
    assert row['entry_recorder_restored'] is True, 'entry recorder restored'
    assert row['calls'] and all(set(call) == {'callback', 'args', 'result'} and call['callback'] in DEPENDENCIES for call in row['calls']), 'complete actual dependency callback channels'


def check_cross(document, authored):
    assert authored == oracle.author(), 'unchanged independent representative oracle'
    assert authored['packages'] == PACKAGES and len(authored['cases']) == 7, 'seven independent representatives'
    assert document['packages'] == PACKAGES and document['dependency_keys'] == DEPENDENCIES, 'actual registry and five dependencies'
    assert len(document['base']) == 7, 'complete public private representative population'
    for pair, case in zip(document['base'], authored['cases'], strict=True):
        for channel in ('public', 'private'):
            row = pair[channel]
            check_observation(row, case, channel == 'private')
            assert row['nested'] is None and row['nested_triggered'] is False and row['outer_recorder_restored'] is None, 'unnested baseline observation'
        assert pair['private']['calls'] == pair['public']['calls'], 'public private callback equality'
    expected_pairs = [(outer['contract'], inner['contract']) for outer in authored['cases'] for inner in authored['cases']]
    assert [(pair['outer'], pair['inner']) for pair in document['pairs']] == expected_pairs, 'complete ordered nested pair population'
    for index, pair in enumerate(document['pairs']):
        outer_index, inner_index = divmod(index, 7)
        outer, inner = authored['cases'][outer_index], authored['cases'][inner_index]
        row = pair['observation']
        check_observation(row, outer, True)
        assert row['nested_triggered'] is True and row['outer_recorder_restored'] is True, 'real nested scan and outer recorder restoration'
        assert row['calls'] == document['base'][outer_index]['private']['calls'], 'nested scan leaves outer callbacks unchanged'
        check_observation(row['nested'], inner, True)
        assert row['nested'] == document['base'][inner_index]['private'], 'complete inner baseline recurrence'
    assert [(pair['outer'], pair['inner']) for pair in document['fatal_pairs']] == [
        (case['contract'], authored['cases'][3]['contract']) for case in authored['cases']
    ], 'complete fatal nested pair population'
    for index, pair in enumerate(document['fatal_pairs']):
        row = pair['observation']
        check_observation(row, authored['cases'][index], True)
        assert row['nested_triggered'] is True and row['outer_recorder_restored'] is True, 'fatal nested outer recorder restoration'
        assert row['nested'] == {'completed': False, 'error': 'nested callback sentinel\n',
            'callback_count': 1, 'recorder_changed': True}, 'actual nested callback exception and recorder change'
        assert row['calls'] == document['base'][index]['private']['calls'], 'fatal nested leaves outer callbacks unchanged'
    assert document['opaque'] == {'result': {'events': {'opaque': ['sentinel']}, 'source_origins': []},
        'same_object': True, 'visited': [0, 1], 'caller_error': 'opaque caller sentinel'}, 'opaque first-defined identity and no invented origins'
    assert document['empty'] == {'result': {'events': [], 'source_origins': []},
        'visited': [0], 'caller_error': 'empty caller sentinel'}, 'empty first-defined stops and discards unselected records'
    assert document['final_recorder_inactive'] is True, 'final recorder inactive'


def check_original(kind, document):
    if kind == 'basic': basic.check_mixed(document)
    elif kind == 'pipeline': pipeline.check_mixed(document)
    elif kind == 'flow': flow.flow.check_data(document, 'after')
    elif kind == 'legacy': legacy.oracle.check(document, read('4.6-cases.json'), 'after')
    elif kind == 'dedicated': dedicated.check_document(document, read('5.0-cases.json'))
    elif kind == 'foreign-source': basic.check_foreign(document)
    elif kind == 'method-frames': flow.method.check_frames(document, 'after')
    elif kind == 'identity-control': pipeline.original.check_identity(document)
    else: raise AssertionError('undeclared original kind')


def check_tap(raw):
    text = raw.decode()
    assert not re.search(r'^\s*not ok\b', text, re.M), 'no nested fixture failure'
    sections = re.split(r'^([^\n]+\.t) \.{2,}[ \t]*\n', text, flags=re.M)
    assert sections[1::2] == TESTS, 'complete ordered fixture population'
    for body, plan in zip(sections[2::2], PLANS, strict=True):
        assert re.findall(r'^1\.\.(\d+)\s*$', body, re.M) == [str(plan)], 'complete fixture plan'
        assert [int(n) for n in re.findall(r'^ok (\d+)\b', body, re.M)] == list(range(1, plan + 1)), 'complete ordered positive TAP reach'
    assert 'All tests successful.' in text and 'Result: PASS' in text, 'complete fixture success'


def commands():
    probe = Path(PREFIX + 'probe.pl').relative_to(ROOT).as_posix()
    rows = [('cross-family', seed, ['perl', '-Iperl', probe]) for seed in (0, 1, 42)]
    rows += [('fixtures', 0, ['prove', '-v', '-Iperl'] + TESTS)]
    rows += [(kind, seed, ['perl', '-Iperl', path]) for kind, path in PROBES for seed in (0, 1, 42)]
    rows += [('identity-control', 0, ['perl', '-Iperl', BASE + '2.2-identity-probe.pl'])]
    return rows


def check_report(report, manifest, authored):
    assert report['complete'] is True and report['revision'] == REVISION, 'complete actual composition capture'
    assert report['instrument_sha256'] == sha(Path(PREFIX + 'capture.py').read_bytes()), 'actual composition capture producer'
    assert report['stream_instrument_sha256'] == sha((ROOT / STREAM).read_bytes()), 'actual retained stream producer'
    expected = commands()
    assert [(row['kind'], row['seed']) for row in report['runs']] == [(kind, seed) for kind, seed, _ in expected], 'complete actual command population'
    channels = {}
    for row, (kind, seed, tail) in zip(report['runs'], expected, strict=True):
        assert row['command'] == ['bash', 'tools/project_data_run.sh'] + tail, 'actual declared observation command'
        assert row['exit'] == 0 and row.get('inputs_before') == row.get('inputs_after') == len(manifest['entries']), 'complete before after runtime guards'
        assert decode(row['stderr']) == b'', 'empty actual outer stderr'
        raw = decode(row['stdout'])
        if kind == 'fixtures': check_tap(raw); continue
        document = json.loads(raw)
        if kind == 'cross-family': check_cross(document, authored)
        else:
            check_original(kind, document)
            suffix, old_kind = PRIOR[kind]
            previous = next(old for old in read(suffix + '-observations.json')['runs'] if old['kind'] == old_kind and old['seed'] == seed)
            assert raw == decode(previous['stdout']), 'complete original family channel recurrence'
        channels.setdefault(kind, []).append(raw)
    assert all(len(set(rows)) == 1 for rows in channels.values()), 'complete three-seed channel equality'


def measured_populations(report):
    documents = {row['kind']: json.loads(decode(row['stdout'])) for row in report['runs'] if row['seed'] == 0 and row['kind'] != 'fixtures'}
    result, all_ids = {}, []
    for kind in ('basic', 'pipeline', 'flow', 'legacy', 'dedicated'):
        document = documents[kind]
        if kind in ('basic', 'pipeline'): rows = document['rows']; frames = len(document['statement_frames']); cases = 1
        elif kind in ('flow', 'legacy'): rows = [row for case in document for row in case['rows']]; frames = sum(len(case['statement_frames']) for case in document); cases = len(document)
        else: rows = [row for case in document['cases'] for row in case['rows']]; frames = sum(len(case['statement_frames']) for case in document['cases']); cases = len(document['cases'])
        ids = sorted({row['contract'] for row in rows})
        events, origins = 0, 0
        for row in rows:
            private = row['private']['result'] if kind == 'dedicated' else row['private_result']
            events += len(private['events']); origins += len(private['source_origins'])
        result[kind] = {'selected_contract_ids': ids, 'contracts': len(ids), 'authored_source_cases': cases,
                        'selected_events_per_seed': events, 'selected_origins_per_seed': origins,
                        'physical_statement_frames_per_seed': frames}
        all_ids += ids
    assert len(all_ids) == len(set(all_ids)), 'disjoint selected family contract identifiers'
    assert [result[kind]['contracts'] for kind in result] == [20, 19, 16, 112, 7], 'exact original family partitions'
    assert all(item['selected_events_per_seed'] == item['selected_origins_per_seed'] for item in result.values()), 'every selected original event retains origin'
    method_frames = sum(len(row['result']['source_frames']) + len(row['csv']['source_frames']) for row in documents['method-frames'])
    return result, len(all_ids), method_frames


def main():
    authored = json.loads(Path(PREFIX + 'cases.json').read_bytes())
    manifest = json.loads(Path(PREFIX + 'inputs.json').read_bytes())
    report = json.loads(Path(PREFIX + 'observations.json').read_bytes())
    assert read('1.2.0-cases.json') == basic.oracle.author(), 'unchanged original basic oracle'
    assert read('2.0-cases.json') == pipeline.oracle.author(), 'unchanged original pipeline oracle'
    assert read('3.0-cases.json') == flow.flow.CASES, 'unchanged original flow oracle'
    legacy.check_cases(read('4.6-cases.json'))
    check_inputs(manifest); check_report(report, manifest, authored)
    populations, contracts, method_frames = measured_populations(report)
    document = json.loads(decode(report['runs'][0]['stdout']))
    controls = []
    def reject(name, target, mutation, validator, reason):
        changed = copy.deepcopy(target); mutation(changed)
        assert changed != target, 'effective corruption: ' + name
        try: validator(changed)
        except AssertionError as error:
            assert str(error) == reason, (name, str(error), reason)
            controls.append({'name': name, 'observed': 'RED', 'reason': reason}); return
        raise AssertionError('accepted corruption: ' + name)
    validate = lambda value: check_cross(value, authored)
    for index, pair in enumerate(document['pairs']):
        for field, mutate, reason in (
            ('outer origins', lambda row: row['result']['source_origins'].pop(), 'literal representative scalar origins'),
            ('outer reference', lambda row: row['identity'][0].update(constructed_event=False), 'actual returned constructor and origin identities'),
            ('caller error', lambda row: row.update(caller_error='lost'), 'actual caller error preservation'),
            ('recorder restoration', lambda row: row.update(outer_recorder_restored=False), 'real nested scan and outer recorder restoration'),
            ('inner origin', lambda row: row['nested']['result']['source_origins'].pop(), 'literal representative scalar origins'),
        ):
            reject(pair['outer'] + '/' + pair['inner'] + '/' + field, document,
                   lambda value, index=index, mutate=mutate: mutate(value['pairs'][index]['observation']), validate, reason)
    for index, pair in enumerate(document['fatal_pairs']):
        reject(pair['outer'] + '/fatal restoration', document, lambda value, index=index: value['fatal_pairs'][index]['observation'].update(outer_recorder_restored=False), validate, 'fatal nested outer recorder restoration')
        reject(pair['outer'] + '/actual fatal callback', document, lambda value, index=index: value['fatal_pairs'][index]['observation']['nested'].update(callback_count=0), validate, 'actual nested callback exception and recorder change')
    for index, case in enumerate(authored['cases']):
        for name, mutate, reason in (
            ('equal raw swapped scalar', lambda row: row['result']['source_origins'][1].update(source_span=row['result']['source_origins'][0]['source_span']), 'literal representative scalar origins'),
            ('cloned arguments', lambda row: row['identity'][0].update(constructed_args=False), 'actual returned constructor and origin identities'),
            ('lost returned array', lambda row: row.update(returned_array=False), 'actual first-defined returned-array identity'),
            ('dispatcher reorder', lambda row: row['visited'].reverse() if len(row['visited']) > 1 else row['visited'][0].update(defined=False), 'exact first-defined dispatcher order'),
            ('changed callback result', lambda row: row['calls'][0].update(result=['forged']), 'public private callback equality'),
        ):
            reject(case['contract'] + '/' + name, document, lambda value, index=index, mutate=mutate: mutate(value['base'][index]['private']), validate, reason)
    for name, mutation, reason in (
        ('lost nested pair', lambda value: value['pairs'].pop(), 'complete ordered nested pair population'),
        ('opaque invented origin', lambda value: value['opaque']['result']['source_origins'].append({}), 'opaque first-defined identity and no invented origins'),
        ('empty falls through', lambda value: value['empty']['visited'].append(1), 'empty first-defined stops and discards unselected records'),
        ('recorder leaks', lambda value: value.update(final_recorder_inactive=False), 'final recorder inactive'),
    ): reject(name, document, mutation, validate, reason)
    report_check = lambda value: check_report(value, manifest, authored)
    for name, mutation, reason in (
        ('capture incomplete', lambda value: value.update(complete=False), 'complete actual composition capture'),
        ('lost command', lambda value: value['runs'].pop(), 'complete actual command population'),
        ('forged command', lambda value: value['runs'][0]['command'].append('forged'), 'actual declared observation command'),
        ('failed exit', lambda value: value['runs'][0].update(exit=1), 'complete before after runtime guards'),
        ('lost guard', lambda value: value['runs'][0].pop('inputs_after'), 'complete before after runtime guards'),
        ('forged capture', lambda value: value.update(instrument_sha256='0' * 64), 'actual composition capture producer'),
        ('forged stream', lambda value: value.update(stream_instrument_sha256='0' * 64), 'actual retained stream producer'),
        ('forged channel', lambda value: value['runs'][0]['stdout'].update(sha256='0' * 64), 'complete channel bytes'),
        ('outer stderr', lambda value: value['runs'][0].update(stderr=envelope(b'forged')), 'empty actual outer stderr'),
    ): reject(name, report, mutation, report_check, reason)
    tap = decode(report['runs'][3]['stdout'])
    reject('short positive TAP', report, lambda value: value['runs'][3].update(stdout=envelope(tap.replace(b'ok 191 - ', b'ok 192 - ', 1))), report_check, 'complete ordered positive TAP reach')
    reject('hidden nested TAP failure', report, lambda value: value['runs'][3].update(stdout=envelope(tap.replace(b'    ok 1 - ', b'    not ok 1 - ', 1))), report_check, 'no nested fixture failure')
    for kind in ('basic', 'pipeline', 'flow', 'legacy', 'dedicated'):
        index = next(i for i, row in enumerate(report['runs']) if row['kind'] == kind)
        def alter(value, index=index, kind=kind):
            row = value['runs'][index]; current = json.loads(decode(row['stdout']))
            if kind in ('basic', 'pipeline'): current['diagnostics']['forged_extra'] = True
            elif kind in ('flow', 'legacy'): current[0]['diagnostics']['forged_extra'] = True
            else: current['toolbox'][0]['descriptor']['forged_extra'] = True
            row['stdout'] = envelope(json.dumps(current).encode())
        reject(kind + '/changed full compiler channel', report, alter, report_check, 'complete original family channel recurrence')
    for name, mutation, reason in (
        ('lost committed member', lambda value: value['entries'].pop(0), 'complete unique input population'),
        ('extra runtime overlay', lambda value: value['overlays'].append('perl/forged.pm'), 'exact observation-only overlay boundary'),
        ('forged object bytes', lambda value: value['entries'][0].update(sha256='0' * 64), 'exact immutable input bytes'),
        ('forged executable mode', lambda value: value['entries'][0].update(mode='100755' if value['entries'][0]['mode'] == '100644' else '100644'), 'exact immutable object and mode'),
        ('lost black-box exclusion', lambda value: value['excluded_metadata'].pop(), 'exact black-box metadata exclusions'),
    ): reject(name, manifest, mutation, check_inputs, reason)
    result = {'complete': True, 'revision': REVISION, 'regular_git_inputs': manifest['regular_git_inputs'],
              'authored_runtime_overlays': 2, 'commands': len(report['runs']), 'seeds': 3,
              'original_populations': populations, 'unique_selected_contract_ids': contracts,
              'selected_events_per_seed': sum(row['selected_events_per_seed'] for row in populations.values()),
              'selected_origins_per_seed': sum(row['selected_origins_per_seed'] for row in populations.values()),
              'method_expression_and_csv_frames_per_seed': method_frames,
              'cross_family_representatives': 7, 'nested_pairs_per_seed': 49,
              'off_diagonal_pairs_per_seed': 42, 'fatal_nested_routes_per_seed': 7,
              'representative_events_per_scan': 2, 'fixture_suites': len(TESTS), 'fixture_groups': sum(PLANS),
              'controls': controls, 'instrument_sha256': sha(Path(__file__).read_bytes()),
              'scope': 'Original independently authored syntactic populations measured once per seed; all seven dispatcher families represented across five retained corpora. Nested composition uses seven representatives, not every selected contract. Full prior compiler/callback/origin channels recur byte-for-byte. All 49 ordered nested pairs, seven caught fatal routes, opaque/empty first-defined and actual returned constructor/origin references observed per seed. Two new observation inputs overlay immutable Git, with no production or fixture replacements. Physical statement frames are per authored source, distinct from selected origins and MethodExpr/CSV frames. No global lexical reorder, executable quoted/comment membership, precise replacement, arbitrary callback admission or private parent closeout. Phase0 reserved for canonical .1.6.1 boundary.'}
    Path(PREFIX + 'verification.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: value for key, value in result.items() if key not in ('controls', 'original_populations')}))
    print(str(len(controls)) + ' effective reason-specific composition evidence controls RED')


if __name__ == '__main__': main()
