"""Run the actual strict claim validator only on this exact staged record."""
import gzip
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
spec = importlib.util.spec_from_file_location('claim_gate', ROOT / 'tools/check_claim_verification.py')
gate = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gate)
original = gzip.decompress((HERE / 'implementation-overbound-claim.json.gz').read_bytes())
try:
    gate.strict_json(original)
except ValueError as error:
    assert str(error) == 'claim record exceeds its 128 KiB bound'
else:
    raise AssertionError('original overbound declaration was accepted')
snapshot = gate.InputSnapshot(gate.index_files())
path = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.18.1.json'
record = gate.strict_json(snapshot.read(path))
gate.validate(record, path, snapshot.read, snapshot.check_owner)
assert gate.index_files() == snapshot.files
print(json.dumps({'result': 'PASS', 'original_bound_control': 'rejected',
                  'exact_staged_record': 'strict schema and all declared identities pass'}, sort_keys=True))
