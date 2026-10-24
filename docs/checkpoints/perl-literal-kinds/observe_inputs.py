"""Execute the supplied physical read-only inventory validator on exact input variants."""
from pathlib import Path
import hashlib
import json
import sys

source = Path(sys.argv[1]).read_bytes()
prefix = Path(__file__).resolve().parent
sys.path.insert(0, str(prefix))
namespace = dict(__file__=str(prefix / 'read.py'), __name__='literal_supplied_inventory_validator')
exec(compile(source, str(prefix / 'read.py'), 'exec'), namespace)
plan = json.load(sys.stdin)
rows = []
for case in plan['cases']:
    try:
        result = namespace['verify_inventory'](plan['expected'], case['supplied'], plan['required'])
    except AssertionError as error:
        rows.append(dict(id=case['id'], accepted=False, reason=str(error)))
    else:
        assert result is True
        rows.append(dict(id=case['id'], accepted=True))
print(json.dumps(dict(validator_sha256=hashlib.sha256(source).hexdigest(), rows=rows), sort_keys=True))
