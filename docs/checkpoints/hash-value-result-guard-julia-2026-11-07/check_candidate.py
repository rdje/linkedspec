"""One-time current Julia candidate/direct-input identity boundary."""
import hashlib,json
from pathlib import Path
BASE=Path(__file__).resolve().parent
rows=json.loads((BASE/'direct/input-identities.json').read_bytes())
paths=['julia/src/runtime/Interpreter.jl','julia/test/runtests.jl','julia/test/hash_value_result_guard_composition_test.jl','specs/user_function_definition.spec','tests/fixtures/hash_value_result_guard_cases.json','tests/fixtures/hash_value_result_guard_julia_cases.json','tests/fixtures/hash_value_result_guard_julia_profiles.json']
result={}
for path in paths:
    p=Path(path);body=p.read_bytes();row=dict(bytes=len(body),sha256=hashlib.sha256(body).hexdigest(),mode=p.stat().st_mode&0o777)
    assert row==rows[path],path;result[path]=row
out=BASE/'candidate-result.json';assert not out.exists()
out.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print('one-time current Julia candidate equals actual direct inputs')
