"""Current numeric proof with exact predecessor and historical recurrence admission."""
import json
import sys
from pathlib import Path
import common as c
import review_numeric_recurrence as numeric
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'type-numeric-admission'/'recurrence'))
import prior_admission
import verify_recurrence


def check(fresh=True):
    result=numeric.review(fresh=fresh)
    result['admission']=prior_admission.verify()
    result['historical_recurrence']=verify_recurrence.verify()
    result['limits']+=(' Whole first and second uncommitted claims/actual readonly0 remain separate; canonical1 dual ownership '
        'and canonical2 overlapping historical regression failures are preserved. The exact auditor/proof successor adds22 '
        'numeric inverse fragments before old70, preserving578 controls and adding66; two actual auditor faults restore. '
        'Original hashes, archive134,22 recovery controls and zero healthy original-log/tracked-write boundary remain exact.')
    return result


if __name__=='__main__':
    assert sys.argv[1:] in ([],['--retained'])
    print(json.dumps(check(fresh=not sys.argv[1:]),sort_keys=True))
