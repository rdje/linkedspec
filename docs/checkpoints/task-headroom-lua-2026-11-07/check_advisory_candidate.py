"""Actual validator with explicit current-book/current-record candidate overlays."""
import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('advisory_candidate_validator', ROOT / 'tools/check_claim_verification.py')
validator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(validator)
files = validator.index_files()
snapshot = validator.InputSnapshot(files)
source = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.8.json'
book = 'docs/linkedspec-book/src/development/local-ci-and-regression.md'
material = {name: (ROOT / name).read_bytes() for name in (source, book)}


def read_input(name, revision=None):
    if revision is None and name in material:
        return material[name]
    return snapshot.read(name, revision)


validator.validate(validator.strict_json(material[source]), source, read_input, snapshot.check_owner)
validator.require(validator.index_files() == files, 'index changed during focused candidate validation')
assert all((ROOT / name).read_bytes() == raw for name, raw in material.items())
print('advisory-candidate: PASS actual validator; explicit book/record overlays only')
