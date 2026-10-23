"""Independent existing CLI-protocol and public library oracle; read-only."""
import json
import sys
import common as c

PHASES = ['compile:start','compile:ok','input:start','input:ok','invoke:start']


def outcome(value):
    failed = not value['completed'] or value['exception'] or value['last_error']
    error = value['runtime_detail'] or value['exception'] or value['last_error'] or {}
    fields = error.get('fields',error)
    if fields.get('code') == 'generated_execution_failed':
        fields = fields.get('detail',fields)
    return dict(failed=bool(failed),value=value['value'],code=fields.get('code'))


def cli(rows):
    cases = c.load('cases2.json')['cases']
    assert set(rows) == {case['id'] for case in cases}
    failures = []
    for case in cases:
        failed = 'error' in case or 'exception' in case
        expected_stdout = b'' if failed else (json.dumps(case['value'],separators=(',',':'),sort_keys=True)+'\n').encode()
        expected_stderr = b'linkedspec: parser invocation failed\n' if failed else b''
        for route in ('quiet','routed'):
            observed = rows[case['id']][route]
            run = observed['run']
            target = (1 if failed else 0,expected_stdout,expected_stderr)
            actual = (run['returncode'],c.decode(run['stdout_base64']),c.decode(run['stderr_base64']))
            phases = PHASES+['invoke:error' if failed else 'invoke:ok']
            trace = ''.join('[linkedspec][low] '+phase+'\n' for phase in phases).encode()
            good_trace = observed['trace'] is None if route == 'quiet' else c.decode(observed['trace']) == trace
            if actual != target or not good_trace:
                failures.append(dict(id=case['id'],route=route,exit=run['returncode'],
                    stdout=c.decode(run['stdout_base64']).decode(),stderr=c.decode(run['stderr_base64']).decode(),trace_ok=good_trace))
    return dict(observations=2*len(cases),failures=failures)


def library(run):
    assert run['returncode']==0 and not c.decode(run['stderr_base64'])
    value = json.loads(c.decode(run['stdout_base64']))
    cases = c.load('cases2.json')['cases']
    assert [row['id'] for row in value['rows']] == [case['id'] for case in cases]
    for case,row in zip(cases,value['rows']):
        descriptor = row['descriptor']
        assert descriptor['completed'] and not descriptor['exception'] and not descriptor['last_error']
        assert descriptor['value']['canonical_action_ir_fallback_count']==0
        assert descriptor['value']['raw_perl_dependency_count']==0
        for route in ('native','generated'):
            observed = outcome(row[route])
            if 'error' in case:
                assert observed['failed'] and observed['code']==case['error'], (case['id'],route,observed)
            elif 'exception' in case:
                assert observed['failed'], (case['id'],route,observed)
                if route == 'native':
                    assert row[route]['exception']['class']==case['exception']
            else:
                assert not observed['failed'] and not row[route]['warnings'] and not row[route]['stdout']
                assert json.dumps(observed['value'],sort_keys=True)==json.dumps(case['value'],sort_keys=True)
    return dict(sources=len(cases),routes=3,typed_errors=3,thrown_errors=1,successful_controls=7)


if __name__ == '__main__':
    if len(sys.argv)==3 and sys.argv[1]=='--library':
        print(json.dumps(library(c.load(sys.argv[2]+'.json.gz')['library']),sort_keys=True))
        sys.exit(0)
    assert len(sys.argv)==2
    packet = c.load(sys.argv[1]+'.json.gz')
    result = cli(packet['cli'])
    print(json.dumps(result,sort_keys=True))
    sys.exit(1 if result['failures'] else 0)
