"""Read-only native CLI projection; observed values and channels stay unchanged."""
import json
import re
import common as c


def project(run):
    stdout = c.decode(run['stdout_base64']).decode('utf-8')
    stderr = c.decode(run['stderr_base64']).decode('utf-8')
    result = dict(exit=run['returncode'],stdout=stdout,stderr=stderr)
    if run['returncode'] == 0:
        try:
            result['value'] = json.loads(stdout)
        except json.JSONDecodeError:
            result['status'] = 'non-json-success'
        else:
            result['status'] = 'value' if not stderr else 'value-with-diagnostic'
    else:
        result['status'] = 'rejected'
        result['nested_write_codes'] = sorted(set(re.findall(r'nested_write_[a-z_]+',stderr)))
    return result


def inspect(runtime):
    packet = c.load('native-'+runtime+'.json.gz')
    cases = c.load('cases.json')['cases']
    assert [row['id'] for row in packet['rows']] == [case['id'] for case in cases]
    result = []
    for case,row in zip(cases,packet['rows']):
        observed = project(row['run'])
        comparison = None
        if 'requested_value' in case:
            comparison = (observed['status'] == 'value' and
                json.dumps(observed['value'],sort_keys=True) == json.dumps(case['requested_value'],sort_keys=True))
        result.append(dict(id=case['id'],control=case['control'],comparison=comparison,observed=observed,
            qualification='The original dynamic-string control target is qualified for ordinary Perl; receiver-retention targets are Perl-specific. Comparison targets do not establish a new portable policy.'))
    return result


if __name__ == '__main__':
    import sys
    assert len(sys.argv) == 2
    for row in inspect(sys.argv[1]):
        print(json.dumps(row,sort_keys=True))
