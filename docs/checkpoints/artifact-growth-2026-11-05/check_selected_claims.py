"""Run the actual claim validator on this slice's three affected records only."""
import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location(
    'selected_claim_validator', ROOT / 'tools/check_claim_verification.py')
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)
files = validator.index_files()
snapshot = validator.InputSnapshot(files)
selected = ('TYPE-REFERENCE-BOOK.1.2.23.4.3',
            'TYPE-REFERENCE-BOOK.1.2.23.4.7',
            'TYPE-REFERENCE-BOOK.1.2.23.4.8')
for owner in selected:
    source = 'docs/claims/' + owner + '.json'
    validator.validate(validator.strict_json(snapshot.read(source)), source,
                       snapshot.read, snapshot.check_owner)
validator.require(validator.index_files() == files, 'index changed during focused validation')
print('selected-claims: PASS ' + str(len(selected)) + ' affected records')
