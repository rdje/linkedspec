"""One-time current Lua candidate versus actual direct inputs."""
import hashlib,json
from pathlib import Path
base=Path(__file__).resolve().parent
rows=json.loads((base/'direct/input-identities.json').read_bytes());result={}
for path in ('lua/src/linkedspec/interpreter.lua','lua/test/run.lua','lua/test/hash_value_result_guard_composition_test.lua','specs/user_function_definition.spec','tests/fixtures/hash_value_result_guard_cases.json','tests/fixtures/hash_value_result_guard_lua_cases.json','tests/fixtures/hash_value_result_guard_lua_profiles.json'):
    p=Path(path);b=p.read_bytes();r=dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest(),mode=p.stat().st_mode&0o777)
    assert r==rows[path],path;result[path]=r
out=base/'candidate-result.json';assert not out.exists();out.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
print('one-time current/direct Lua candidate identity PASS')
