"""One-time candidate identity against the actual direct-test inputs."""
import hashlib
import json
from pathlib import Path
BASE=Path(__file__).resolve().parent
ROOT=Path.cwd()
record=json.loads((BASE/'direct/custody.json').read_bytes())[0]
paths=['rust/linkedspec-runtime/src/engine.rs','rust/linkedspec-runtime/tests/hash_value_result_guard_composition.rs','tests/fixtures/hash_value_result_guard_cases.json','tests/fixtures/hash_value_result_guard_rust_profiles.json']
for name in paths:
    path=ROOT/name; row=record['files'][name]
    assert hashlib.sha256(path.read_bytes()).hexdigest()==row['sha256']
    assert path.stat().st_mode & 0o777==row['mode']
result=dict(candidate='PASS',actual_direct_inputs=paths)
assert not (BASE/'candidate-result.json').exists()
(BASE/'candidate-result.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
