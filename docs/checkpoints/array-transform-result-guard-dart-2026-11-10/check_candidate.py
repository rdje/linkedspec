"""One-time current candidate identity against the actual direct-test inputs."""
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
row = json.loads((BASE / 'direct/custody.json').read_bytes())[0]
paths = ['dart/lib/src/runtime/interpreter.dart',
         'dart/test/array_transform_result_guard_composition_test.dart',
         'dart/tool/probe_array_transform_results.dart',
         'tests/fixtures/array_transform_result_guard_cases.json',
         'tests/fixtures/array_transform_result_guard_dart_profiles.json',
         'specs/user_function_definition.spec']
for name in paths:
    path = Path(name)
    expected = row['files'][name]
    assert hashlib.sha256(path.read_bytes()).hexdigest() == expected['sha256']
    assert path.stat().st_mode & 0o777 == expected['mode']
target = BASE / 'candidate-result.json'
assert not target.exists()
result = dict(candidate='PASS', actual_direct_inputs=paths,
              producer_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
target.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result))
