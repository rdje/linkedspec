"""Actual index validator for the preserved advisory and this slice's new record."""
import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('final_scoped_validator', ROOT / 'tools/check_claim_verification.py')
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)
files = validator.index_files()
snapshot = validator.InputSnapshot(files)
for owner in ('TYPE-REFERENCE-BOOK.1.2.23.4.8', 'TYPE-REFERENCE-BOOK.1.2.23.4.16'):
    source = 'docs/claims/' + owner + '.json'
    validator.validate(validator.strict_json(snapshot.read(source)), source, snapshot.read, snapshot.check_owner)
validator.require(validator.index_files() == files, 'index changed during scoped final validation')
print('scoped-final-claims: PASS 2 records; actual staged validator, no recorded-command execution')
