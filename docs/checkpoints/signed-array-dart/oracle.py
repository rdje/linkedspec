"""Independent typed fixture oracle over actual Dart observer JSON channels."""
import json

ROUTES = ('native', 'spec_json', 'validated_engine_plan', 'generated_wrapper')


def same(actual, expected):
    if type(actual) is not type(expected):
        return False
    if isinstance(expected, dict):
        return actual.keys() == expected.keys() and all(
            same(actual[key], value) for key, value in expected.items())
    if isinstance(expected, list):
        return len(actual) == len(expected) and all(map(same, actual, expected))
    return actual == expected


def check(case, row):
    errors = []
    def require(condition, label):
        if not condition:
            errors.append(label)
    require('other_error' not in row, 'unexpected_error')
    require(same(row.get('effects'), case['effects']), 'effects')
    expected = case['expected']
    if 'ok' in expected:
        require('ok' in row and same(row['ok'], expected['ok']), 'value')
        require(not any(key in row for key in ('native_error', 'generated_error')), 'success_error')
        return errors
    require('ok' not in row, 'failure_result')
    target = expected['error']
    caller_failure = 'injection' in case and target['code'] == case['injection']['code']
    if row['route'] == 'generated_wrapper' and not caller_failure:
        error = row.get('generated_error', {})
        fields = dict(type='generated_source_error', stage='execute_generated',
            code='generated_execution_failed', source_identity='signed-array-dart/'+case['id']+'.spec')
        for key, value in fields.items():
            require(same(error.get(key), value), 'generated.'+key)
        require(isinstance(error.get('detail'), str) and error['detail'].endswith(target['message']),
            'generated.detail')
    else:
        error = row.get('native_error', {})
        diagnostic = error.get('diagnostic', {})
        for key, value in target.items():
            observed = diagnostic.get('detail' if key == 'message' else key)
            require(same(observed, value), 'native.'+key)
    if 'injection' in case:
        require(same(row.get('injected_identity'), caller_failure), 'injected_identity')
    return errors


def review(stdout, cases):
    sources, rows, compile_errors = [], [], []
    for line in stdout.decode().splitlines():
        tag, raw = line.split('\t', 1)
        {'DART_SIGNED_SOURCE': sources, 'DART_SIGNED_ROW': rows,
         'DART_SIGNED_COMPILE_ERROR': compile_errors}[tag].append(json.loads(raw))
    selected = {case['id']: case for case in cases}
    assert len(selected) == len(cases)
    assert not compile_errors, compile_errors
    assert len(sources) == len(cases) and {row['id'] for row in sources} == selected.keys()
    assert len(rows) == len(cases)*len(ROUTES)
    assert {(row['id'], row['route']) for row in rows} == {
        (identifier, route) for identifier in selected for route in ROUTES}
    for source in sources:
        assert source['source'] == selected[source['id']]['source']
        assert isinstance(json.loads(source['spec_json']), dict)
        assert isinstance(json.loads(source['compiled_json']), dict)
        assert source['plan']
    failures = [dict(id=row['id'], route=row['route'], fields=errors, actual=row)
        for row in rows if (errors := check(selected[row['id']], row))]
    return dict(programs=len(cases), observations=len(rows), failures=failures,
        failure_count=len(failures), sources=sources, observed=rows)
