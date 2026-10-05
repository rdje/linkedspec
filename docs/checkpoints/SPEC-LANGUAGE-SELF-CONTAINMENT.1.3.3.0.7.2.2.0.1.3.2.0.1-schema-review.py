"""Validate the actual new record and live input bytes through the existing checker."""
from pathlib import Path
import importlib.util
import json
ROOT=Path(__file__).resolve().parents[2]
PREFIX=__file__.removesuffix('schema-review.py')
spec=importlib.util.spec_from_file_location('actual_claim_checker',ROOT/'tools/check_claim_verification.py')
checker=importlib.util.module_from_spec(spec);spec.loader.exec_module(checker)
path='docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0.1.json'
def read_input(source,revision):
    assert revision is None,'current new diagnosis is live'
    return (ROOT/source).read_bytes()
def owner(value):raise AssertionError('new diagnosis declares no unavailable leg')
claims,gaps=checker.validate(checker.strict_json((ROOT/path).read_bytes()),path,read_input,owner)
assert (claims,gaps)==(1,0)
result={'valid':True,'claims':claims,'gaps':gaps,'instrument_sha256':checker.hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        'scope':'Actual existing strict checker validates this live record and all input bytes. Full staged check and all commit hooks remain mandatory; no schema/checker changes.'}
Path(PREFIX+'schema-review.json').write_text(json.dumps(result,indent=2)+'\n')
print('Actual strict schema and new live input bytes PASS; one claim, no gaps')
