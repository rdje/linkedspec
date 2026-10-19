"""Independent payload/metadata/history review; no historical channel rewriting."""
import copy
import gzip
import json
from pathlib import Path
import common as c
import normalize_inc
import source_transport


def load(name):
    path = c.ROOT / (c.PREFIX + name)
    return json.loads(gzip.decompress(path.read_bytes()) if name.endswith('.gz') else path.read_bytes())


def observations(record):
    run = record['run']
    assert run['returncode'] == 0 and record['unchanged']
    assert not c.decode(run['stderr_base64'])
    raw = c.decode(run['stdout_base64'])
    positions = [position for position in range(len(raw)) if raw.startswith(b'{"cases":', position)
                 and (position == 0 or raw[position-1:position] == b'\n')]
    assert len(positions) == 1, 'one complete final JSON observation after retained diagnostic prelude'
    result = json.loads(raw[positions[0]:])
    assert len({case['id'] for case in result['cases']}) == len(result['cases'])
    return result, raw[:positions[0]]


EXPECTED = {
 'a-snapshot': ['?Top:', ['seed']], 'a-binding': ['?Top:', ['seed']],
 'a-extra': ['?Top:', 'extra', ['seed']],
 'm-nested': ['?Top:', ['ab', 'c']], 'm-flat': ['?Top:', 'ab', 'c'],
 'ma': ['?Top:', ['ab', 'c'], ['seed']],
 'imatch': ['tag', 'abc'], 'first-group': ['tag', 'ab'],
 'array-tag-payload': ['tag', 'payload'],
 'current-header': ['semantic_annotation', {'items': ['ab', 'c']}],
 'snapshot-mutation': [['seed'], ['seed', 'later']],
 'binding-mutation': [['seed'], ['seed', 'later']],
 'current-single-element': [['seed']], 'return-undef': None,
 'ma-flat': ['?Top:', 'ab', 'c', ['seed']],
 'm-empty': ['?Top:'], 'ma-empty': ['?Top:', ['seed']],
}


def value_check(case, expected):
    assert case['lower']['ok'] and case['descriptor']['ok']
    meta = case['descriptor']['value']
    assert 'RETURN' in meta['canonical_action_ir_nodes']
    assert meta['canonical_action_ir_fallback_count'] == 0
    assert not set(meta['canonical_action_ir_nodes']) & {'RAW_PERL', 'RETURN_A', 'RETURN_M', 'RETURN_MA'}
    assert case['execute'] == dict(ok=True, value=expected), ('parser payload', case['id'])
    assert case['generated']['ok'] and case['generated']['value']['value'] == expected, ('generated payload', case['id'])
    assert case['generated']['value']['source'], 'actual independently loaded generated source retained'


def review():
    combined, root = {}, None
    reports = []
    for stem in ('native', 'entry', 'flat-ma'):
        inputs = load(stem + '-inputs.json.gz')
        result, prelude = observations(load(stem + '-run.json.gz'))
        assert source_transport.unchanged(inputs['inputs']), ('current native input bytes/modes', stem)
        assert [case['id'] for case in result['cases']] == [case['id'] for case in inputs['cases']]
        normalize_inc.verify(result['inc'], inputs['inputs'])
        assert result['perl'] == 'v5.34.1', 'observed prerequisite identity, not a portable version requirement'
        reports.append(dict(epoch=stem, cases=len(result['cases']), diagnostic_prelude_bytes=len(prelude)))
        if stem == 'native':
            root = {case['id']: case for case in result['cases']}
            assert root['toolbox-before']['execute']['value'] is None
            assert root['toolbox-after']['execute'] == dict(ok=True, value=['hello', 'world'])
            assert root['toolbox-after']['generated']['value']['value'] == ['hello', 'world']
        else:
            combined.update({case['id']: case for case in result['cases']})
            by_id = {case['id']: case for case in inputs['cases']}
            for case in result['cases']:
                if case['id'].startswith('retired-'):
                    assert case['lower'] == dict(ok=True, value=by_id[case['id']]['body'])
                    meta = case['descriptor']['value']
                    assert 'RAW_PERL' in meta['canonical_action_ir_nodes'] and meta['canonical_action_ir_fallback_count'] == 1
                elif case['id'] in ('old-copy', 'old-header', 'bare-single-selector'):
                    assert not case['lower']['ok'] and 'aggregate_selector_removed' in case['lower']['error']
    for name, expected in EXPECTED.items():
        value_check(combined[name], expected)
    # The first root-I observation is retained, never substituted for incoming-match proof.
    assert root['imatch']['execute']['value'] == ['tag', None]
    assert root['m-nested']['execute']['value'] == ['?Top:', []]
    historical = load('historical-lowering.json')
    assert historical['run']['returncode'] == 0 and historical['unchanged']
    assert not c.decode(historical['run']['stderr_base64'])
    rows = json.loads(c.decode(historical['run']['stdout_base64']))
    assert [row['before'] for row in rows] == [EXPECTED['a-snapshot'], EXPECTED['a-extra'], EXPECTED['m-flat'], EXPECTED['ma-flat']]
    assert rows[0]['after'] == ['?Top:', ['seed', 'later']]
    assert rows[1]['after'] == ['?Top:', 'extra', ['seed', 'later']]
    assert rows[2]['after'] == rows[2]['before']
    assert rows[3]['after'] == ['?Top:', 'ab', 'c', ['seed', 'later']]
    assert rows[2]['lowered'] == "return ['?Top:', @IMATCH_LIST]"
    inputs = load('historical-lowering-inputs.json.gz')
    assert source_transport.unchanged(inputs['inputs'])
    source, function = c.decode(inputs['source_base64']), c.decode(inputs['function_base64'])
    assert function in source and function.startswith(b'sub _build_return_contracts {')
    history = load('history-current.json.gz')
    before, after = [history['inputs'][key] for key in ('fff219840212c26d78d75cda0ac9356f5f8d257c', '4e9250390785b9a36ae3c48abc17fabc97b75ac0')]
    for name, block in before['blocks'].items():
        assert c.decode(block) in c.decode(before['base64']) and after['blocks'][name] is None
    # Independent oracle rejects actual alternate native shapes, not arbitrary hash corruption.
    controls = []
    for target, alternate in [('m-flat', 'm-nested'), ('ma-flat', 'ma'), ('imatch', 'first-group'),
                              ('a-extra', 'a-snapshot'), ('array-tag-payload', 'imatch')]:
        changed = copy.deepcopy(combined[alternate])
        changed['id'] = target
        try:
            value_check(changed, EXPECTED[target])
        except AssertionError as failure:
            controls.append(dict(target=target, actual_alternate=alternate, observed_red=str(failure)))
        else:
            raise AssertionError(('ineffective actual native counterexample', target))
        value_check(combined[target], EXPECTED[target])
    return dict(result='PASS', epochs=reports, current_exact_payloads=len(EXPECTED),
                semantic_controls=controls, scope='Bounded named recipes and pure historical replacement callbacks; '
                'no retired compiler execution, deep-copy or full historical alias equivalence, corpus absence '
                'or complete operation inventory. Saved root observations and diagnostic preludes remain exact.')


if __name__ == '__main__':
    print(json.dumps(review(), sort_keys=True))
