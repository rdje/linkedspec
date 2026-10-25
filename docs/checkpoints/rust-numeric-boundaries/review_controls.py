"""Read-only actual input-denial and discarded-validator evidence."""
import json
import common as c


def check():
    saved=c.load('input-controls.json.gz')
    assert set(saved['controls'])=={'missing','bytes','mode','required-omission'}
    assert saved['baseline']['returncode']==saved['restored']['returncode']==0
    assert json.loads(c.decode(saved['baseline']['stdout_base64']))==json.loads(c.decode(saved['restored']['stdout_base64']))
    assert saved['faulty_publisher']!=saved['original_publisher']
    for item in saved['controls'].values():
        assert item['rejected']['returncode']!=0 and item['restored_validator_rejected']['returncode']!=0
        assert item['bypass_admitted']['returncode']==0
        assert json.loads(c.decode(item['bypass_admitted']['stdout_base64']))=={'bypassed':True}
    assert saved['controls']['missing']['input'] is None
    assert saved['controls']['bytes']['input']['sha256']!=saved['original_input']['sha256']
    assert saved['controls']['mode']['input']['sha256']==saved['original_input']['sha256']
    assert saved['controls']['mode']['input']['mode']!=saved['original_input']['mode']
    assert saved['controls']['required-omission']['input'] is None
    assert 'core-after-complete-run.json.gz' not in saved['controls']['required-omission']['manifest']['inputs']
    return dict(input_denials=4,actual_bypasses=4,exact_restored_pass=True)


if __name__=='__main__':print(json.dumps(check(),sort_keys=True))
