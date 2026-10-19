"""Independent value-kind, source-custody, model and current-document review."""
import gzip
import html
import json
import subprocess
import sys
from pathlib import Path
import common as c
import current
import replay_migrations

sys.path.insert(0, str(c.ROOT / 'docs/checkpoints/knowledge-fields'))
import metadata_oracle
sys.path.insert(0, str(c.ROOT / 'docs/checkpoints/type-reference-migrations'))
import normalize_inc


def load(name):
    raw = (c.ROOT / (c.PREFIX + name)).read_bytes()
    return json.loads(gzip.decompress(raw) if name.endswith('.gz') else raw)


def equal(actual, expected):
    """JSON numbers and booleans are different kinds, even when Python equates them."""
    kind = lambda value: ('null' if value is None else 'boolean' if isinstance(value, bool) else
        'number' if isinstance(value, (int, float)) else 'string' if isinstance(value, str) else
        'array' if isinstance(value, list) else 'harray' if isinstance(value, dict) else 'invalid')
    assert kind(actual) == kind(expected), (actual, expected)
    if isinstance(expected, dict):
        assert set(actual) == set(expected)
        for key in expected:
            equal(actual[key], expected[key])
    elif isinstance(expected, list):
        assert len(actual) == len(expected)
        for value, wanted in zip(actual, expected):
            equal(value, wanted)
    else:
        assert actual == expected, (actual, expected)


def deny(call):
    try:
        call()
    except AssertionError:
        return True
    raise AssertionError('distinguishing control did not reject')


def contains(population, required):
    assert required <= population, sorted(required - population)


def observations(run):
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    output = c.decode(run['stdout_base64'])
    marker = b'\nSOURCE_TYPE_MODEL_JSON '
    assert output.count(marker) == 1
    prelude, raw = output.split(marker)
    assert not prelude, ('unexpected diagnostic prelude', prelude)
    return json.loads(raw)


EXPECTED = {
    'primitive-values': ['text', 42, 3.5, True, False, None],
    'one-binding-rebound': 'called', 'containers': {'array': [1, 2], 'harray': {'key': 'v'}},
    'eager-block': ['eager', 7], 'deferred-caller-state': 'later',
    'deferred-effects': ['inside', 'inside', 'inside'],
    'boolean-scalar-receiver': '0q', 'boolean-generic-with': False,
    'yielded-array-receiver': ['a', 'b'], 'codeblock-generic-with': None,
    'codeblock-array-method-question': [],
    'numeric-input-boundaries': [42, 3.5, 8, None, None, '0q', 1, True],
}
DISTINGUISH = {
    'bare-scalar-across-call': ['inside', 'inside', 'inside'],
    'rvalue-across-call': ['before', 'inside', 'inside'],
    'separate-binding-control': ['before', 'inside', 'inside'],
    'array-helper-across-call': ['inside', 'inside', 'inside'],
    'named-function-arguments': ['before', 'inside'], 'codeblock-arguments': ['inside', 'inside'],
    'with-scoped-binding-direct': None, 'with-copy-to-name-control': 'yes',
    'with-known-outer-binding-control': 'yes', 'with-explicit-parameter': 'yes',
    'with-explicit-value-parameter': 'yes',
}


def values(data, expected, inputs):
    normalize_inc.verify(data['inc'], inputs)
    assert data['perl'].startswith('v5.')
    rows = data['rows']
    assert len(rows) == len(expected) and {row['id'] for row in rows} == set(expected)
    for row in rows:
        assert row['warnings'] == [], row['id']
        assert all(row[route]['ok'] is True for route in ('descriptor', 'live', 'generated')), row
        assert row['descriptor']['value']['canonical_action_ir_fallback_count'] == 0
        assert 'RETURN' in row['descriptor']['value']['canonical_action_ir_nodes']
        equal(row['live']['value'], expected[row['id']])
        equal(row['generated']['value']['value'], expected[row['id']])
        assert 'linkedspec-generated-source-v2' in row['generated']['value']['source']
    return {row['id']: row for row in rows}


def custody(inputs, proposals):
    for path, item in inputs.items():
        raw = c.decode(item['base64'])
        assert c.sha(raw) == item['sha256'], path
        assert c.read(path) == proposals.get(path, item), ('current source bytes/modes', path)


def review(fresh=True):
    source = load('source-inputs.json.gz')
    inputs = source['inputs']
    assert len(inputs) == 1300
    assert source['base_commit'] == c.BASE
    proposals = load('docs-proposals.json.gz')
    assert proposals['producer'] == c.read(c.PREFIX + 'prepare_docs_final.py')
    assert c.unchanged(proposals['proposals'])
    assert len(proposals['routes']) == 17
    custody(inputs, proposals['proposals'])
    # Independently require the authority families; dropping a record cannot pass a count alone.
    required = {path for path in subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', c.BASE,
        '--', 'capability_conformance', 'perl', 'docs/linkedspec-book/src'], cwd=c.ROOT, text=True).splitlines()
        if Path(path).suffix in ('.json', '.spec', '.pm', '.pl', '.md')}
    contains(set(inputs), required)
    missing = set(inputs) - {'capability_conformance/callable_codeblock_contract.json'}
    assert deny(lambda: contains(missing, required))
    for path, identity in source['git_entries'].items():
        raw = subprocess.check_output(['git', 'show', c.BASE + ':' + path], cwd=c.ROOT)
        assert c.sha(raw) == inputs[path]['sha256']

    expected = dict(EXPECTED)
    for name in ('scalar_text', 'scalar_numeric'):
        contract = json.loads(c.decode(inputs['capability_conformance/' + name + '_contract.json']['base64']))
        expected['neutral-' + name] = contract['expected']
    initial = load('model-run.json.gz')
    initial_inputs = load('model-inputs.json.gz')
    assert initial['inputs_unchanged'] and initial_inputs['inputs'].keys() >= inputs.keys()
    first = values(observations(initial['run']), expected, initial_inputs['inputs'])
    distinguishing = load('distinguish-run.json.gz')
    distinguishing_inputs = load('distinguish-inputs.json.gz')
    assert distinguishing['inputs_unchanged']
    controls = values(observations(distinguishing['run']), DISTINGUISH, distinguishing_inputs['inputs'])
    assert deny(lambda: equal(first['deferred-effects']['live']['value'], ['before', 'inside', 'inside']))
    assert deny(lambda: equal(controls['codeblock-arguments']['live']['value'], ['before', 'inside']))
    assert deny(lambda: equal(controls['with-scoped-binding-direct']['live']['value'], 'yes'))
    assert deny(lambda: equal(False, 0)) and deny(lambda: equal(True, 1))
    assert 'LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:value' in controls['with-scoped-binding-direct']['generated']['value']['source']
    assert 'my $__ls_user_fn_arg_0 = $marker;' in controls['named-function-arguments']['generated']['value']['source']
    assert '[$marker, do {' in controls['bare-scalar-across-call']['generated']['value']['source']
    vocab = load('vocabulary.json')
    assert vocab['inputs_unchanged'] and all(run['returncode'] == 0 for run in vocab['runs'])
    assert b'250 current call names' in c.decode(vocab['runs'][1]['stdout_base64'])
    assert b'126 public Perl contracts independently covered' in c.decode(vocab['runs'][1]['stdout_base64'])

    graph = load('graph-inputs.json.gz')['inputs']
    observed = load('graph-run.json.gz')
    assert observed['inputs_unchanged'] and c.unchanged(graph)
    assert all(run['returncode'] == 0 for run in observed['runs'])
    assert c.read('KNOWLEDGE_MAP.md') == observed['mapping']
    population = metadata_oracle.verify_graph(graph, c.decode(observed['mapping']['base64']), c.decode)
    knowledge_bytes = sum(len(c.decode(item['base64'])) for path, item in graph.items() if path.startswith('docs/knowledge/'))
    assert knowledge_bytes <= 8388608
    assert len(c.decode(observed['mapping']['base64']).splitlines()) <= 22500
    book = load('book-inputs.json.gz')
    assert current.book_population() == (book['inputs'], book['book_sources'])
    rendered = load('book-run.json.gz')
    if fresh:
        cases = initial_inputs['cases']
        values(observations(c.run(['perl', '-Iperl', c.PREFIX + 'model.pl'], input=json.dumps(cases).encode())), expected, inputs)
        values(observations(c.run(['perl', '-Iperl', c.PREFIX + 'model.pl'],
            input=json.dumps(distinguishing_inputs['cases']).encode())), DISTINGUISH, inputs)
        assert all(run['returncode'] == 0 for run in (
            c.run(['perl', 'tools/check_language_capability_coverage.pl']),
            c.run(['bash', 'knowledge-map/scripts/check_knowledge_map.sh'])))
        rendered = dict(healthy=current.render(book['inputs']), changed_heading=current.render(book['inputs'], True))
    for row in rendered.values():
        assert row['returncode'] == 0 and row['source_bytes_modes_unchanged']
    page = lambda row, name: html.unescape(c.decode(row['pages'][name]).decode()).split('<main>', 1)[1].rsplit('</main>', 1)[0]
    healthy = page(rendered['healthy'], current.PAGES[0])
    changed = page(rendered['changed_heading'], current.PAGES[0])
    anchor = 'id="value-kinds-numeric-notation-and-callable-results"'
    assert anchor in healthy and anchor not in changed
    assert 'id="deliberately-changed-model-heading"' in changed
    assert 'return(cb().sorted())' in healthy and 'returns null' in healthy and 'codeblock argument lists' in healthy
    assert 'id="type-inventory-and-execution-evidence"' in page(rendered['healthy'], current.PAGES[1])
    preserved = load('preservation.json.gz')
    frozen = json.loads(c.decode(preserved['original']['base64']))
    frozen['claims'][0]['durability'].update(mode='historical', revision=c.BASE)
    assert json.loads((c.ROOT / c.OLD_CLAIM).read_bytes()) == frozen
    for key, item in preserved['live'].items():
        if key != c.OLD_CLAIM + '#0':
            assert c.read(key.rsplit('#', 1)[0]) == item['original']
            for path, wanted in item['inputs'].items():
                assert all(c.read(path)[field] == wanted[field] for field in ('sha256', 'mode'))
    return dict(result='PASS', authority_inputs=len(inputs), initial_cases=len(first), distinguishing_cases=len(controls),
        neutral_scalar_fields=sum(len(expected['neutral-' + name]) for name in ('scalar_text', 'scalar_numeric')),
        graph=population, knowledge_bytes=knowledge_bytes, book_inputs=len(book['inputs']),
        original_replay=replay_migrations.replay() if fresh else load('migration-replay.json'),
        limits='Two runtime defects remain scheduled; vocabulary presence is not complete operations or semantics. '
               'No runtime change, cross-backend execution, private/parent or exhaustive book admission.')


if __name__ == '__main__':
    assert sys.argv[1:] in ([], ['--capture'])
    result = review()
    if sys.argv[1:]:
        c.write_new(c.PREFIX + 'review.json', result)
    print(json.dumps(result, sort_keys=True))
