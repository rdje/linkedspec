"""Verify exact current normalization and reject one fixed owned-fragment edit."""
import importlib.util
import sys
import common as c

path=c.ROOT/'tests/language-readiness/verify_objectives.py'
spec=importlib.util.spec_from_file_location('drop_history_audit',path)
audit=importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)
source='t/phase0_regression.t'
current=(c.ROOT/source).read_bytes()
historical=audit.digest(audit.git('show',f'{audit.SIGNATURE_BEFORE}:{source}'))
audit.verify_signature_regression_evolution(source,current,historical)
if '--control' in sys.argv:
    fragment=audit.drop_generated_table(source)['hunks'][0]['after'].encode()
    assert current.count(fragment)==1
    changed=current.replace(fragment,fragment.replace(b'    plan tests => 4;',b'    plan tests => 3;',1),1)
    assert changed!=current
    try:
        audit.verify_signature_regression_evolution(source,changed,historical)
    except ValueError as error:
        assert str(error)=='drop regression registration mismatch: '+source,str(error)
    else:
        raise AssertionError('UNREVIEWED_DROP_MUTATION_ACCEPTED')
print('Exact drop/numeric/older historical normalization PASS; control='+str('--control' in sys.argv))
