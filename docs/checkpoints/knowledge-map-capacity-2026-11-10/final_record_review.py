"""Check all changed records through the actual strict staged identity reader."""
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('final_selected_claim_gate', ROOT / 'tools/check_claim_verification.py')
gate = importlib.util.module_from_spec(spec); spec.loader.exec_module(gate)
snapshot = gate.InputSnapshot(gate.index_files())
records = ('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.18.1.json',
           'docs/claims/TYPE-REFERENCE-BOOK.1.2.20.2.json',
           'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.3.json')
for name in records:
    gate.validate(gate.strict_json(snapshot.read(name)), name, snapshot.read, snapshot.check_owner)
assert gate.index_files() == snapshot.files
print(json.dumps(dict(result='PASS', records=records, scope='Strict schema, staged input identities and historical capture owners'), sort_keys=True))
