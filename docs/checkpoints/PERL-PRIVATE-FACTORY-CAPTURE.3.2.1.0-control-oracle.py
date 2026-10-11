"""Apply the readonly inventory audit to one retained counterfactual."""
import base64
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0-'
spec = importlib.util.spec_from_file_location('inventory_review', ROOT / (PREFIX + 'review.py'))
review = importlib.util.module_from_spec(spec)
spec.loader.exec_module(review)
row = json.loads((ROOT / sys.argv[1]).read_bytes())
source = base64.b64decode(row['source_base64']).decode()
native = json.loads(base64.b64decode(row['native']['stdout_base64']))
optree = json.loads(base64.b64decode(row['optree']['stdout_base64']))
review.audit(source, native, optree, row['inventory'])
print('Independent counterfactual audit PASS')
