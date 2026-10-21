"""Typed public values and diagnostic causes, with explicit unrelated pipeline owner."""
import json
import common as c

equal=lambda a,b:json.dumps(a,sort_keys=True,separators=(',',':'))==json.dumps(b,sort_keys=True,separators=(',',':'))


def rows(run):
    assert run['returncode']==0,c.decode(run['stderr_base64']).decode()
    assert not c.decode(run['stderr_base64'])
    value=json.loads(c.decode(run['stdout_base64']))
    result={row['id']:row for row in value['rows']}
    assert len(result)==len(value['rows'])
    return result


def failures(run,plan,dump=True):
    actual=rows(run)
    expected={case['id']:case for case in plan['cases']}
    assert len(expected)==len(plan['cases']) and set(expected)==set(actual)
    failures=[]
    for name,case in expected.items():
        row=actual[name]
        reasons=[]
        if 'source_error' in case:
            for route in ('descriptor','native'):
                item=row[route];detail=item['runtime_detail'];error=item['last_error']
                if not (not item['completed'] and item['value'] is None and error is not None
                    and error.get('stage')=='function_registry' and detail is not None
                    and case['source_error'] in detail.get('text','') and not item['warnings']):
                    reasons.append(route+'-registry-rejection')
            item=row['generated'];error=item['exception']
            if not (not item['completed'] and item['value'] is None and error is not None
                and error.get('fields',{}).get('code')=='generated_source_emit_failed'
                and case['source_error'] in str(error['fields'].get('detail','')) and not item['warnings']):
                reasons.append('generated-registry-rejection')
            if reasons:failures.append(dict(id=name,reasons=reasons,actual=row))
            continue
        descriptor=row['descriptor']
        if not (descriptor['completed'] and descriptor['exception'] is None and not descriptor['warnings']
            and not descriptor['stdout'] and descriptor['value']['canonical_action_ir_fallback_count']==0
            and descriptor['value']['raw_perl_dependency_count']==0):reasons.append('descriptor')
        if dump and not row['native'].get('dump'):reasons.append('missing-native-dump')
        if 'linkedspec-generated-source-v2' not in row['generated'].get('source',''):reasons.append('missing-generated-source')
        if 'expected' in case:
            for route in ('native','generated'):
                item=row[route]
                if not (item['completed'] and item['exception'] is None and item['last_error'] is None
                    and not item['warnings'] and not item['stdout'] and equal(item['value'],case['expected'])):
                    reasons.append(route+'-value-or-diagnostic')
        else:
            native=row['native'];generated=row['generated']
            error=native['runtime_detail'];envelope=generated['exception']
            typed=(native['completed'] and native['value'] is None and error is not None
                and error['class']=='LinkedSpec::CodeblockRuntime::Error' and not generated['completed']
                and envelope is not None and envelope.get('fields',{}).get('code')=='generated_execution_failed')
            causes=[error['fields'],envelope['fields'].get('detail')] if typed else []
            if not (typed and all(isinstance(cause,dict) and all(equal(cause.get(key),value)
                for key,value in case['error'].items()) for cause in causes)
                and not native['warnings'] and not generated['warnings']):reasons.append('typed-cause')
        if reasons:failures.append(dict(id=name,reasons=reasons,
            expected=case.get('expected'),error=case.get('error'),
            actual={route:{key:row[route][key] for key in ('value','completed','exception','runtime_detail','warnings')}
                for route in ('native','generated')}))
    return failures
