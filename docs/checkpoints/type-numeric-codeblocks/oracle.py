"""Compare actual routes to fixed contract-derived values and typed diagnostics."""
import json
from pathlib import PurePosixPath
import common as c


def observed(run, inputs):
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    value = json.loads(c.decode(run['stdout_base64']))
    for module, actual in value['inc'].items():
        key = PurePosixPath(module)
        assert not key.is_absolute() and '..' not in key.parts
        owned = module if module.startswith('perl/') else 'perl/' + module
        if owned in inputs:
            assert actual == owned or actual.endswith('/' + owned), (module, actual)
        else:
            assert actual.startswith('/System/Library/Perl/'), (module, actual)
    return value['rows']


def mismatches(run, plan, inputs):
    rows = observed(run, inputs)
    expected = {case['id']: case for case in plan['cases']}
    assert len(rows) == len(expected) == len({row['id'] for row in rows})
    assert {row['id'] for row in rows} == set(expected)
    failures = []
    equal = lambda a, b: json.dumps(a, sort_keys=True) == json.dumps(b, sort_keys=True)
    for row in rows:
        case = expected[row['id']]
        descriptor = row['descriptor']
        assert descriptor['completed'] and descriptor['exception'] is None, row['id']
        assert descriptor['value']['canonical_action_ir_fallback_count'] == 0
        assert descriptor['value']['raw_perl_dependency_count'] == 0
        assert 'RETURN' in descriptor['value']['canonical_action_ir_nodes']
        assert all(not row[route]['warnings'] for route in ('descriptor', 'native', 'generated'))
        native, generated = row['native'], row['generated']
        assert 'linkedspec-generated-source-v2' in generated.get('source', '')
        if 'expected' in case:
            healthy = all(row[route]['completed'] and row[route]['exception'] is None
                          and row[route]['last_error'] is None
                          and not row[route].get('stdout', '')
                          and equal(row[route]['value'], case['expected'])
                          for route in ('native', 'generated'))
        else:
            detail = native['runtime_detail']
            exception = generated['exception']
            typed = (detail is not None and detail['class'] == 'LinkedSpec::CodeblockRuntime::Error'
                     and exception is not None
                     and exception.get('fields', {}).get('code') == 'generated_execution_failed')
            actual = [detail['fields'], exception['fields'].get('detail')] if typed else []
            healthy = (typed and native['completed'] and native['value'] is None
                       and not generated['completed']
                       and all(isinstance(error, dict)
                               and all(key in error and equal(error[key], value)
                                       for key, value in case['error'].items())
                               for error in actual))
        if not healthy:
            failures.append(row['id'])
    return failures
