"""One-time identity of the current candidate against actual direct-test inputs."""
import hashlib,json
from pathlib import Path
BASE=Path(__file__).resolve().parent
row=json.loads((BASE/'direct/custody.json').read_bytes())[0]
paths=['dart/lib/src/runtime/interpreter.dart','dart/test/hash_value_result_guard_composition_test.dart','dart/tool/probe_hash_value_results.dart','tests/fixtures/hash_value_result_guard_cases.json','tests/fixtures/hash_value_result_guard_dart_profiles.json','specs/user_function_definition.spec']
for name in paths:
    path=Path(name);expected=row['files'][name]
    assert hashlib.sha256(path.read_bytes()).hexdigest()==expected['sha256']
    assert path.stat().st_mode & 0o777==expected['mode']
assert not (BASE/'candidate-result.json').exists()
result=dict(candidate='PASS',actual_direct_inputs=paths)
(BASE/'candidate-result.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
