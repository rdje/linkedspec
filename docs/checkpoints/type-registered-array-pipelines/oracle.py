"""Compare public values with explicit scalar kinds, independent of Perl flags."""
import json
import math
import common as c


def typed(value):
    if value is None:
        return ('null',)
    if type(value) is bool:
        return ('boolean', value)
    if type(value) in (int, float):
        assert math.isfinite(value)
        return ('number', value)
    if type(value) is str:
        return ('string', value)
    if type(value) is list:
        return ('array', tuple(typed(item) for item in value))
    assert type(value) is dict
    return ('harray', tuple((key, typed(value[key])) for key in sorted(value)))


def failures(run, plan):
    if run['returncode'] != 0 or c.decode(run['stderr_base64']):
        return {'observer': ['nonzero exit or diagnostic stderr']}
    observed = json.loads(c.decode(run['stdout_base64']))
    rows = observed['rows']
    assert [row['id'] for row in rows] == [case['id'] for case in plan['cases']]
    failed = {}
    for row, case in zip(rows, plan['cases']):
        problems = []
        descriptor = row['descriptor']
        metadata = descriptor.get('value') or {}
        if not descriptor['completed'] or metadata.get('canonical_action_ir_fallback_count') != 0 or metadata.get('raw_perl_dependency_count') != 0:
            problems.append('descriptor')
        for route in ('descriptor', 'native', 'generated'):
            value = row[route]
            if value['warnings'] or value['stdout'] or value['last_error'] or value['exception']:
                problems.append(route + ' diagnostics')
            if route == 'descriptor':
                continue
            if not value['completed'] or typed(value['value']) != typed(case['expected']):
                problems.append(route + ' typed value')
        if problems:
            failed[row['id']] = problems
    return failed
