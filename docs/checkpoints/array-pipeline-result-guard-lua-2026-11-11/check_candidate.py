"""One-time identity of every declared actual direct input before landing."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
metadata = BASE / 'direct/input-identities.json'
for name, expected in json.loads(metadata.read_bytes()).items():
    path = Path(name)
    assert path.is_file() and not path.is_symlink()
    assert hashlib.sha256(path.read_bytes()).hexdigest() == expected['sha256'], name
    assert path.stat().st_mode & 0o777 == expected['mode'], name
target = BASE / 'candidate-result.json'
assert not target.exists()
result = dict(candidate='PASS', actual_direct_input_metadata=str(metadata.relative_to(Path.cwd())),
              producer_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
target.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result))
