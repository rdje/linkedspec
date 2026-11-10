"""One-time current identity of every acquired source/resolved input."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
for tag in ('source', 'resolved'):
    rows = json.loads((BASE / 'qualified' / (tag + '-identities.json')).read_bytes())
    for name, expected in rows.items():
        if tag == 'source' and name == 'dart/.dart_tool/package_config.json':
            continue  # Historical pre-resolution image; resolved is the actual used routing.
        path = Path(name)
        assert path.is_file() and not path.is_symlink()
        assert hashlib.sha256(path.read_bytes()).hexdigest() == expected['sha256'], name
        assert path.stat().st_mode & 0o777 == expected['mode'], name
assert not Path('dart/specs/user_function_definition.spec').exists()
target = BASE / 'current-input-result.json'
assert not target.exists()
result = dict(current_inputs='PASS', metadata=['qualified/source-identities.json', 'qualified/resolved-identities.json'],
              producer_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
target.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result))
