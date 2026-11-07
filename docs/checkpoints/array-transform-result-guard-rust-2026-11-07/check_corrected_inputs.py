"""Recheck the already sealed runtime/proof inputs after a task-only correction."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
manifest = BASE / 'readonly-review/input-identities.json'
rows = json.loads(manifest.read_bytes())
for name, row in rows.items():
    path = Path(name)
    assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'], name
    assert path.stat().st_mode & 0o777 == row['mode'], name
out = BASE / 'commit-correction/identity-check.json'
assert not out.exists()
out.write_text(json.dumps(dict(owner='TYPE-REFERENCE-BOOK.1.2.23.3.78.2',
    manifest_sha256=hashlib.sha256(manifest.read_bytes()).hexdigest(),
    checked=len(rows), all_sealed_runtime_and_proof_inputs_unchanged=True), indent=2) + '\n')
print('all already sealed runtime/proof input bytes and modes unchanged after task citation correction')
