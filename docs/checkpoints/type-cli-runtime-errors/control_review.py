"""Read-only validation of actual artifact-validator fault and restoration channels."""
import json
import common as c
import publish


def check():
    supplied = c.load('artifact-controls-inputs.json.gz')
    assert supplied['producer'] == c.read(c.PREFIX+'publish.py')
    assert supplied['controller'] == c.read(c.PREFIX+'artifact_controls.py')
    values = c.load('artifact-controls.json.gz')
    assert values['producer_restored']
    original = c.decode(supplied['producer']['base64'])
    def producer(row,expected,argument):
        raw = c.decode(row['producer']['base64'])
        assert raw == expected and c.sha(raw) == row['producer']['sha256']
        assert row['producer']['mode'] == supplied['producer']['mode']
        assert row['run']['command'] == ['bash','tools/run_python_project_data.sh',c.PREFIX+'publish.py',argument]
    identity = values['identity']
    for phase,row in identity.items():
        marker = b'def validate_inputs(declared, actual):\n'
        expected = original.replace(marker,marker+b'    return\n',1) if phase == 'bypass' else original
        producer(row,expected,'--identity-controls')
        run = row['run']
        assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
        observed = json.loads(c.decode(run['stdout_base64']))
        if phase == 'bypass':
            assert all(not item['rejected'] for item in observed.values())
        else:
            assert row['producer'] == supplied['producer']
            assert observed == publish.controls()
            assert observed['missing'] == dict(rejected=True,reason='input population')
            for name in ('bytes','mode'):
                assert observed[name] == dict(rejected=True,reason='input '+name+': '+c.PREFIX+'cases2.json')
    assert set(values['scope']) == {'cases2.json','green.json.gz'}
    for name,control in values['scope'].items():
        assert control['omitted_path'] == c.PREFIX+name
        population = b'return sorted((owned | set(WRAPPERS)) - {MANIFEST,PUBLICATION,CLAIM})'
        faulty = original.replace(population,b'return sorted((owned | set(WRAPPERS)) - {MANIFEST,PUBLICATION,CLAIM,'+repr(control['omitted_path']).encode()+b'})',1)
        for phase in ('healthy','omitted','bypass','validator_restored','restored'):
            row = control[phase]
            expected = original if phase in ('healthy','restored') else faulty
            if phase == 'bypass':
                marker = b'def validate_scope(actual, controls_ready=True):\n'
                expected = expected.replace(marker,marker+b'    return\n',1)
            producer(row,expected,'--scope-check')
            run = row['run']
            if phase in ('omitted','validator_restored'):
                assert run['returncode'] == 1 and not c.decode(run['stdout_base64'])
                assert c.decode(run['stderr_base64']).decode().endswith('AssertionError: required input: '+control['omitted_path']+'\n')
            else:
                assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
                assert c.decode(run['stdout_base64']) == b'Required-input scope PASS\n'
            if phase in ('healthy','restored'):
                assert row['producer'] == supplied['producer']
        assert control['omitted']['producer'] == control['validator_restored']['producer']
    return dict(identity_denials=3,identity_bypass_admissions=3,
        required_input_omissions=2,scope_bypass_admissions=2,exact_restoration=True)


if __name__ == '__main__':
    print(json.dumps(check(),sort_keys=True))
