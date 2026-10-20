"""Keep the original numeric review intact and add the distinct admission epoch."""
import json
import sys
from pathlib import Path
import common as c
import review
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'type-numeric-admission'))
import numeric_admission


def check(fresh=True):
    result = review.review(fresh=fresh)
    result['admission'] = numeric_admission.verify()
    result['limits'] += (' Canonical1 rejects dual verification ownership; a distinct metadata-only correction '
                         'delegates duplicate startup87.3 to numeric5. Whole first10142-input draft/actual readonly0, '
                         'exact rejected candidate and actual owner RED/GREEN controls remain separately bound.')
    return result


if __name__ == '__main__':
    assert sys.argv[1:] in ([], ['--retained'])
    print(json.dumps(check(fresh=not sys.argv[1:]), sort_keys=True))
