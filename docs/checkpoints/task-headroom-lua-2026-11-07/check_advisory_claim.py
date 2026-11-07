"""Run the actual validator on the one advisory record intersecting this edit."""
import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('advisory_claim_validator', ROOT / 'tools/check_claim_verification.py')
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)
files = validator.index_files()
snapshot = validator.InputSnapshot(files)
source = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.8.json'
validator.validate(validator.strict_json(snapshot.read(source)), source, snapshot.read, snapshot.check_owner)
validator.require(validator.index_files() == files, 'index changed during focused validation')
print('advisory-claim: PASS one affected record; no runtime or publication replay')
