"""Readonly diagnostic for the separately owned selected-string result-kind defect95."""
import json
import common as c
import oracle


def validate(flags,updates):
    assert flags['returncode']==0 and not c.decode(flags['stderr_base64'])
    value=json.loads(c.decode(flags['stdout_base64']))
    rows={row['id']:row for row in value['rows']}
    expected={'array-min','array-max','odd-median','scalar-min','scalar-add'}
    assert set(rows)==expected and len(value['rows'])==5
    actual=oracle.rows(updates)
    assert set(actual)==expected
    for name,row in rows.items():
        assert row['value_json']=='1' and row['last_error'] is None
        selected=name in ('array-min','array-max','odd-median')
        assert row['runtime_kind']==('string' if selected else 'integer')
        assert row['string_flag']==int(selected) and row['integer_flag']
        for route in ('native','generated'):
            item=actual[name][route]
            assert not item['warnings']
            if selected:
                if route=='native':
                    assert item['completed'] and item['value'] is None
                    detail=item['runtime_detail']
                    assert detail['class']=='LinkedSpec::BindingRuntime::NestedWriteError'
                    cause=detail['fields']
                else:
                    assert not item['completed'] and item['exception']['fields']['code']=='generated_execution_failed'
                    cause=item['exception']['fields']['detail']
                assert cause['code']=='nested_write_kind_conflict'
                assert cause['actual_kind']=='array' and cause['expected_kind']=='harray'
            else:
                assert item['completed'] and item['exception'] is None and item['last_error'] is None
                assert item['value']==['zero','changed'] and not item['stdout']
    return dict(known_kind_failures=3,scalar_controls=2,
        retained_host=dict(perl=value['perl_version'],json=value['json_version']),
        scope='Current JSON numbers do not prove internal numeric kinds.95 remains owned; no repair here.')


def check(fresh=True):
    saved=c.load('kind-flags-run.json.gz')
    assert saved['inputs_unchanged']
    result=validate(saved['flags'],saved['updates'])
    if fresh:
        inputs=c.load('kind-flags-inputs.json.gz')
        flags=c.run(['perl','-Iperl',c.PREFIX+'kind_flags.pl'],input=json.dumps(inputs['plan']).encode())
        updates=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(inputs['public']).encode())
        assert validate(flags,updates)==result
    return result


if __name__=='__main__':print(json.dumps(check(),sort_keys=True))
