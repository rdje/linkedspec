"""Read-only projection of complete retained Perl observations; no reblessing."""
import json
import common as c


def outcome(value):
    failed = not value['completed'] or value['exception'] or value['last_error']
    error = value['runtime_detail'] or value['exception'] or value['last_error'] or {}
    fields = error.get('fields',error)
    if fields.get('code') == 'generated_execution_failed':
        fields = fields.get('detail',fields)
    return dict(status='error' if failed else 'value',value=value['value'],
        code=fields.get('code'),warnings=value['warnings'],stdout=value['stdout'])


def inspect():
    captured = c.load('perl-baseline.json.gz')
    run = captured['run']
    assert captured['inputs_unchanged'] and run['returncode'] == 0
    assert not c.decode(run['stderr_base64'])
    data = json.loads(c.decode(run['stdout_base64']))
    plan = c.load('cases.json')['cases']
    assert [row['id'] for row in data['rows']] == [row['id'] for row in plan]
    result = []
    for case,row in zip(plan,data['rows']):
        routes = {route:outcome(row[route]) for route in ('native','generated')}
        for route,value in routes.items():
            value['requested_match'] = None
            if 'requested_value' in case:
                value['requested_match'] = (value['status'] == 'value'
                    and not value['warnings'] and not value['stdout']
                    and json.dumps(value['value'],sort_keys=True) == json.dumps(case['requested_value'],sort_keys=True))
        result.append(dict(id=case['id'],control=case['control'],
            descriptor=outcome(row['descriptor']),routes=routes))
    return result


if __name__ == '__main__':
    for row in inspect():
        print(json.dumps(row,sort_keys=True))
