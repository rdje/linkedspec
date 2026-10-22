"""Observe the actual historical Phase0 normalizer and loaded source/table identities."""
import importlib.util
import json
import traceback
import common as c

AUDITOR = 'tests/language-readiness/verify_objectives.py'
TABLE = 'tests/language-readiness/count-first-regression-evolution.json'
SOURCE = 't/phase0_regression.t'


def main():
    spec = importlib.util.spec_from_file_location('count_first_historical_auditor',c.source(AUDITOR))
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    assert c.source(AUDITOR).resolve() == __import__('pathlib').Path(module.__file__).resolve()
    result = dict(identities={path:c.identity(path) for path in (AUDITOR,TABLE,SOURCE)})
    try:
        historical = module.digest(module.git('show',module.SIGNATURE_BEFORE+':'+SOURCE))
        result['report'] = module.verify_signature_regression_evolution(
            SOURCE,c.source(SOURCE).read_bytes(),historical)
        result['completed'] = True
    except Exception as error:
        result.update(completed=False,error_type=type(error).__name__,error=str(error),traceback=traceback.format_exc())
    print(json.dumps(result,sort_keys=True))
    raise SystemExit(0 if result['completed'] else 1)


if __name__ == '__main__':
    main()
