"""Readonly independent review of the finite value-order repair and rejected epochs."""
import gzip
import html
import json
import sys
import common as c
import current
import replay_inventory

sys.path.insert(0, str(c.ROOT / 'docs/checkpoints/knowledge-fields'))
import metadata_oracle
import metadata_current
sys.path.insert(0, str(c.ROOT / 'docs/checkpoints/type-reference-migrations'))
import normalize_inc


def load(name):
    raw = (c.ROOT / (c.PREFIX + name)).read_bytes()
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)


def observed(run):
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    output = c.decode(run['stdout_base64'])
    marker = b'\nSOURCE_TYPE_MODEL_JSON '
    assert output.count(marker) == 1
    prelude, raw = output.split(marker)
    assert not prelude, ('unexpected diagnostic prelude', prelude)
    return json.loads(raw)


def mismatches(run, cases, inputs):
    value = observed(run)
    normalize_inc.verify(value['inc'], inputs)
    expected = {case['id']: case['expected'] for case in cases}
    assert len(value['rows']) == len(expected)
    assert {row['id'] for row in value['rows']} == set(expected)
    encode = lambda item: json.dumps(item, sort_keys=True, separators=(',', ':'))
    failed = []
    for row in value['rows']:
        assert all(row[route]['ok'] is True for route in ('descriptor', 'live', 'generated'))
        assert row['warnings'] == []
        descriptor = row['descriptor']['value']
        assert descriptor['canonical_action_ir_fallback_count'] == 0
        assert 'RETURN' in descriptor['canonical_action_ir_nodes']
        generated = row['generated']['value']
        assert 'linkedspec-generated-source-v2' in generated['source']
        native = encode(row['live']['value'])
        assert native == encode(generated['value'])
        if native != encode(expected[row['id']]):
            failed.append(row['id'])
    return set(failed)


def review(fresh=True):
    prepared = load('final-inputs.json.gz')
    inputs, cases = prepared['inputs'], prepared['cases']
    assert len(cases) == 23
    proposals = load('docs-proposals.json.gz')
    assert proposals['producer'] == c.read(c.PREFIX + 'prepare_docs.py')
    assert c.unchanged(proposals['proposals']) and len(proposals['routes']) == 17
    for path, item in inputs.items():
        assert c.sha(c.decode(item['base64'])) == item['sha256']
        assert c.read(path) == proposals['proposals'].get(path, item), path
    supplement = load('test-inputs.json.gz')
    assert len(supplement['inputs']) == 277 and len(supplement['selected']) == 7
    assert set(supplement['selected']) <= set(inputs)
    assert all(inputs[path] == item for path, item in supplement['inputs'].items())
    assert supplement['observed_fixture_data_gap'] in inputs

    controls = {'rvalue-control', 'saved-binding-control', 'named-function-control', 'nested-codeblock-body'}
    bad = {case['id'] for case in cases} - controls
    baseline, green = load('final-baseline.json.gz'), load('final-green.json.gz')
    assert baseline['syntax']['returncode'] == 0 and baseline['tap']['returncode'] != 0
    assert baseline['source_bytes_modes_unchanged']
    assert mismatches(baseline['public'], cases, inputs) == bad and len(bad) == 19
    assert all(run['returncode'] == 0 for run in green['syntax'] + green['runs'])
    assert green['inputs_unchanged'] and not mismatches(green['public'], cases, inputs)
    correction = load('oracle-correction.json.gz')
    before = json.loads(c.decode(correction['before']['base64']))['cases']
    after = json.loads(c.decode(correction['after']['base64']))['cases']
    assert [row['id'] for row, old in zip(after, before) if row != old] == ['array-mutation-question']
    first = load('green-run.json.gz')
    assert [run['returncode'] for run in first['runs']] == [0, 1, 1]
    assert mismatches(first['public'], before, inputs) == {'array-mutation-question'}
    incomplete = load('corrected-baseline.json.gz')
    assert [incomplete[key]['returncode'] for key in ('syntax', 'tap')] == [2, 2]
    assert b'No such file' in c.decode(incomplete['syntax']['stderr_base64'])
    writer = load('source-writer-run.json')
    assert writer['original_red']['returncode'] == 1 and writer['original_no_write_verified']
    assert writer['corrected']['returncode'] == 0

    inverse_inputs, inverses = load('inverse-inputs.json.gz'), load('inverse-run.json.gz')
    assert inverses['main_inputs_unchanged'] and len(inverses['runs']) == 8
    counts = {}
    for row in inverses['runs']:
        assert row['all_supplied_bytes_modes_unchanged']
        failures = mismatches(row['run'], cases, inverse_inputs['inputs'])
        if row['name'].startswith('healthy-'):
            assert not failures
        else:
            wanted = inverse_inputs['variants'][row['name']]
            assert row['source_sha256'] == wanted['sha256']
            assert failures == set(wanted['expected_mismatches'])
            counts[row['name']] = len(failures)
    assert counts == dict(zip(('identity-template', 'array-members', 'hash-members',
        'array-constructors', 'hash-constructors', 'callable-arguments'), (19, 14, 2, 1, 1, 1)))
    host = load('host-list-run.json')['run']
    assert host['returncode'] == 0 and not c.decode(host['stderr_base64'])
    values = json.loads(c.decode(host['stdout_base64']))['values']
    assert values['materialized_operand'] == values['same_name_array_initializer'] == ['before', 'inside', 'inside']
    assert values['initializer_caller_reference'] == ['inside', 'inside']
    assert values['splice_shape'] == ['tag', 'a', 'b', 'tail'] and values['reference_identity'] == 1
    assert values['reference_contents'] == ['old', 'changed']
    assert json.dumps(values['primitive_kinds']) == json.dumps([False, None, '007', 42, 3.5])

    graph, graph_run = load('graph-inputs.json.gz')['inputs'], load('graph-run.json.gz')
    assert c.unchanged(graph) and graph_run['inputs_unchanged']
    assert all(run['returncode'] == 0 for run in graph_run['runs'])
    assert c.read('KNOWLEDGE_MAP.md') == graph_run['mapping']
    population = metadata_current.verify(graph, c.decode(graph_run['mapping']['base64']), c.decode)
    knowledge_bytes = sum(len(c.decode(item['base64'])) for path, item in graph.items()
                          if path.startswith('docs/knowledge/'))
    assert knowledge_bytes <= 8388608
    book = load('book-inputs.json.gz')
    actual, source_count = current.book_population()
    assert actual == book['inputs'] and source_count == book['book_sources']
    builds = load('book-run.json.gz')
    if fresh:
        assert not mismatches(c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'],
            input=json.dumps(cases).encode()), cases, inputs)
        assert c.run(['bash', 'knowledge-map/scripts/check_knowledge_map.sh'])['returncode'] == 0
        builds = dict(healthy=current.render(actual), changed_heading=current.render(actual, True))
    for name, build in builds.items():
        assert build['returncode'] == 0 and build['source_bytes_modes_unchanged']
        page = c.decode(build['pages'][current.PAGES[0]]).decode()
        anchor = 'id="evaluated-values-and-later-side-effects"'
        assert (anchor in page) == (name == 'healthy')
        assert 'num_add' in html.unescape(page)
    chapter = c.decode(actual[current.CHAPTER]['base64']).decode()
    example = next(case['spec'] for case in cases if case['id'] == 'array-literal')
    assert example in chapter

    preserved = load('preservation.json.gz')
    old = json.loads(c.decode(preserved['original']['base64']))
    old['claims'][0]['durability'].update(mode='historical', revision=c.BASE)
    assert json.loads((c.ROOT / c.OLD_CLAIM).read_bytes()) == old
    for key, item in preserved['live'].items():
        if key != c.OLD_CLAIM + '#0':
            assert c.read(key.rsplit('#', 1)[0]) == item['original']
            assert all(c.read(path)['sha256'] == wanted['sha256'] and c.read(path)['mode'] == wanted['mode']
                       for path, wanted in item['inputs'].items())
    prior = replay_inventory.replay() if fresh else load('prior-after-run.json')
    assert prior['result'] == 'PASS' and prior['whole_original_inputs'] == 388
    assert prior['whole_original_bytes'] == 68814 and prior['bytes_modes_unchanged']
    return dict(result='PASS', cases=23, accepted_baseline_red=19, healthy_controls=4,
        source_inverses=counts, test_input_supplement=277, selected_suites=7,
        graph=population, knowledge_bytes=knowledge_bytes, book_inputs=len(actual),
        book_sources=source_count, prior=prior,
        limits='Finite Perl value-order repair; scoped-with, deferred numeric helpers and boolean '
               'literal kind retain their owners. No exhaustive method or cross-backend admission.')


if __name__ == '__main__':
    assert sys.argv[1:] in ([], ['--retained'])
    print(json.dumps(review(fresh=not sys.argv[1:]), sort_keys=True))
