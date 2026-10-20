"""Independent fixed values and preserved underlying diagnostic controls."""
import json
import re
import common as c

ROUTES = ('native','generated','generated_fatal')


def rows(run):
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    value = json.loads(c.decode(run['stdout_base64']))
    assert len(value['rows']) == len({row['id'] for row in value['rows']})
    return {row['id']:row for row in value['rows']}


def failures(run, plan):
    actual = rows(run)
    assert set(actual) == {case['id'] for case in plan['cases']}
    bad = []
    for case in plan['cases']:
        row = actual[case['id']]
        if 'expected' not in case:
            continue
        for route in ('lowered','descriptor')+ROUTES:
            result = row[route]
            healthy = (result['completed'] and result['exception'] is None
                       and result['last_error'] is None and not result['warnings'] and not result['stdout'])
            if route in ROUTES:
                healthy = healthy and result['value'] == case['expected']
            if route == 'descriptor':
                healthy = healthy and result['value']['canonical_action_ir_fallback_count'] == 0
                healthy = healthy and result['value']['raw_perl_dependency_count'] == 0
            if not healthy:
                bad.append(dict(id=case['id'],route=route))
    return bad


def normalize(value):
    if isinstance(value,str):
        value = re.sub(r'\(eval \d+\)', '(eval N)', value)
        value = re.sub(r'(?m)^\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\]', '[TIME]', value)
        return re.sub(r' line \d+', ' line N', value)
    if isinstance(value,dict):
        return {key:normalize(item) for key,item in value.items()}
    if isinstance(value,list):
        return [normalize(item) for item in value]
    return value


def diagnostics(run, baseline):
    actual, old = rows(run), rows(baseline)
    checked = []
    for name,row in actual.items():
        if not name.startswith('diagnostic/'):
            continue
        for route in ROUTES:
            previous_route = 'native' if route == 'native' else 'generated'
            expected_output = '' if name.endswith('/hash-key') else old[name][previous_route]['stdout']
            assert normalize(row[route]['stdout']) == normalize(expected_output), (name,route)
            expected_warnings = [] if route == 'native' else [
                item for item in old[name]['generated']['warnings']
                if not item.startswith('Scalar value @__ls_drop{')]
            # Preserve the existing uninitialized-key diagnostic, including its
            # severity/count. Only the compiler's new private carrier changes.
            warnings = lambda items: [normalize(re.sub(
                r'\$DropGeneratedProbe\d+::null|\$__ls_drop_keys\[0\]', '<key-slot>', item)) for item in items]
            assert warnings(row[route]['warnings']) == warnings(expected_warnings), (name,route)
        if name.endswith('/hash-key'):
            # The typed hash shape is emitted correctly; no portable key coercion
            # contract is inferred from Perl's reference-key representation.
            for route in ROUTES:
                result = row[route]
                assert result['completed'] and result['exception'] is None and result['last_error'] is None
                assert result['value'] == {
                    'kind':'node','debug':1,'stage':'parse'}
        else:
            assert row['native']['completed'] == old[name]['native']['completed']
            for key in ('value','exception','last_error'):
                assert normalize(row['native'][key]) == normalize(old[name]['native'][key]), (name,key)
            for route in ('generated','generated_fatal'):
                # The prior normal route exposes the underlying execution
                # diagnostic that was masked by FATAL syntax loading.
                previous = old[name]['generated']
                for key in ('value','exception','last_error','completed'):
                    assert normalize(row[route][key]) == normalize(previous[key]), (name,route,key)
        checked.append(name)
    return checked


def verify(name='green2'):
    snapshot = c.load(name+'-inputs.json.gz')
    captured = c.load(name+'-run.json.gz')
    assert captured['inputs_unchanged'] and not failures(captured['run'],snapshot['plan'])
    controls = diagnostics(captured['run'],c.load('red-run.json.gz')['run'])
    return dict(value_cases=sum('expected' in case for case in snapshot['plan']['cases']),
                diagnostic_controls=len(controls),quiet_value_routes=5,
                scope='Fixed desired values and descriptor/Get/lowered/fresh normal/FATAL syntax routes; '
                      'diagnostic controls compare the accepted underlying normal route, excluding only '
                      'dynamic eval/line coordinates and the named uninitialized-key carrier. Hash-key raw shape leakage is repaired without '
                      'a portable reference-key coercion admission.')


if __name__ == '__main__':
    print(json.dumps(verify(),sort_keys=True))
