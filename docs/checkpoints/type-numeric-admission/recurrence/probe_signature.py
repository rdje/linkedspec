"""Exercise the maintained historical signature verifier against an independent old hash."""
import gzip
import importlib.util
import json
import sys
from pathlib import Path
sys.path.insert(1,str(Path(__file__).resolve().parents[2]/'type-numeric-codeblocks'))
import common as c
AUDIT='tests/language-readiness/verify_objectives.py'


def main():
    assert sys.argv[1:] in ([],['--new-control'])
    old=json.loads(gzip.decompress((c.ROOT/'docs/checkpoints/type-values-signature/historical-final-run.json.gz').read_bytes()))
    actual=json.loads(c.decode(old['run']['stdout_base64']))
    historical=next(row['historical'] for row in actual['audit_report']['governance_updates'] if row['path']=='t/phase0_regression.t')
    spec=importlib.util.spec_from_file_location('numeric_signature_probe',c.ROOT/AUDIT)
    module=importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    source=(c.ROOT/'t/phase0_regression.t').read_bytes()
    result=module.verify_signature_regression_evolution('t/phase0_regression.t',source,historical)
    if sys.argv[1:]:
        fragment=module.scalar_numeric_table('t/phase0_regression.t')['hunks'][0]['after'].encode()
        assert source.count(fragment)==1
        try:
            module.verify_signature_regression_evolution('t/phase0_regression.t',source.replace(fragment,b'',1),historical)
        except ValueError:
            result['numeric_current_source_denial']=True
        else:
            raise AssertionError('numeric current-source mutation accepted')
    print(json.dumps(result,sort_keys=True))


if __name__=='__main__':
    main()
