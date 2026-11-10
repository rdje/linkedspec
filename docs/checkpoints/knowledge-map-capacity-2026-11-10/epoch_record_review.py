"""Validate both changed claim records through the actual staged identity reader."""
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('selected_claim_gate', ROOT / 'tools/check_claim_verification.py')
gate = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gate)
snapshot = gate.InputSnapshot(gate.index_files())
for name in ('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.18.1.json',
             'docs/claims/TYPE-REFERENCE-BOOK.1.2.20.2.json'):
    gate.validate(gate.strict_json(snapshot.read(name)), name, snapshot.read, snapshot.check_owner)
assert gate.index_files() == snapshot.files
print(json.dumps({'result': 'PASS', 'scope': 'current infrastructure and historical epoch records; strict schema and staged source identities'}, sort_keys=True))
