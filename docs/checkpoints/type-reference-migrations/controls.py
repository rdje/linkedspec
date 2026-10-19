"""Distinct negative checks for the current module-identity predicate."""
import copy
import gzip
import json
import normalize_inc
import review_native as native


def review():
    inputs = native.load('entry-inputs.json.gz')['inputs']
    result, _ = native.observations(native.load('entry-run.json.gz'))
    loaded = result['inc']
    assert normalize_inc.verify(loaded, inputs)
    controls = []
    owned = next(key for key, value in loaded.items() if value.endswith('/perl/LinkedRE.pm'))
    for name in ('unsupplied-module', 'mismatched-suffix', 'unsafe-module-key', 'mixed-original-roots'):
        changed = copy.deepcopy(loaded)
        if name == 'unsupplied-module':
            changed['Unprovided.pm'] = '/' + 'foreign/perl/Unprovided.pm'
        elif name == 'mismatched-suffix':
            changed[owned] += '.different'
        elif name == 'unsafe-module-key':
            changed['../Escaped.pm'] = '/' + 'foreign/Escaped.pm'
        else:
            changed[owned] = '/' + 'different-original-root/perl/' + owned
        try:
            normalize_inc.verify(changed, inputs)
        except AssertionError as failure:
            controls.append(dict(name=name, observed_red=str(failure)))
        else:
            raise AssertionError(('ineffective module predicate control', name))
        assert normalize_inc.verify(loaded, inputs)
    return dict(result='PASS', controls=controls,
        scope='Original raw module observations and supplied source bytes stay unchanged. '
              'Actual isolated whole-draft replay supplies the relocation witness; these controls '
              'reject distinct missing, mismatched, unsafe and inconsistent module identities.')


if __name__ == '__main__':
    print(json.dumps(review(), sort_keys=True))
