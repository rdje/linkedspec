"""Author installed Lua source-only fences and explicit-grammar instruments."""
import json
from pathlib import Path
base=Path(__file__).resolve().parent
rows=json.loads(Path('tests/fixtures/hash_view_result_guard_cases.json').read_bytes())
for identifier,row in json.loads(Path('tests/fixtures/hash_view_result_guard_rust_profiles.json').read_bytes()).items():
 if identifier in {'arity_profile','free_values_arity_profile','keys_null_profile','values_array_error_profile','values_scalar_null_profile'}:rows.append(dict(id=identifier,source=row['source'],input=row['input'],profile_only=True))
for row in json.loads(Path('tests/fixtures/hash_view_receiver_policy_perl_cases.json').read_bytes()):rows.append(dict(id='initial_'+row['id'],source=row['source'],input=row['input'],profile_only=True))
assert len(rows)==33 and len({r['id'] for r in rows})==33
p=Path('tests/fixtures/hash_view_result_guard_lua_cases.json');assert not p.exists();p.write_text(json.dumps(rows,indent=2)+'\n')
source=Path('docs/checkpoints/key-count-callable-lua-2026-11-06/observer.lua').read_text().replace('CALLABLE_KEY_COUNT_LUA','HASH_VIEW_LUA').replace('key-count-callable/','hash-view-result-guard/')
source='''assert(#arg == 2, "cases and owned output paths required")
assert(arg[1]:match("^docs/checkpoints/hash%-view%-result%-guard%-lua%-2026%-11%-07/[a-z]+/cases%.json$"), "owned cases path required")
assert(arg[2]:match("^docs/checkpoints/hash%-view%-result%-guard%-lua%-2026%-11%-07/[a-z]+/[a-z]+$"), "owned output path required")
'''+source
(base/'observer.lua').write_text(source)
source=Path('lua/test/key_count_callable_result_guard_composition_test.lua').read_text()
source=source.replace('75.6.5 — installed-host callable CountKeys preservation.','76.5 — installed-host Hash-view result guards.').replace('CALLABLE_KEY_COUNT_LUA','HASH_VIEW_LUA').replace('key-count-callable/','hash-view-result-guard/').replace('LINKEDSPEC_CALLABLE_KEY_COUNT_CAPTURE','LINKEDSPEC_HASH_VIEW_CAPTURE').replace('key_count_callable_lua_profiles.json','hash_view_result_guard_lua_profiles.json').replace('key_count_callable_result_cases.json','hash_view_result_guard_lua_cases.json')
needle='  if not ok then return json.harray({compile_error=tostring(prepared)}) end'
# Reject unsafe optional capture paths before any of the observation's writes.
start='local function observe(identifier, source, input, output)\n'
assert source.count(start)==1
source=source.replace(start,start+'''  if output ~= nil and output ~= "" then
    assert(output:match("^docs/checkpoints/hash%-view%-result%-guard%-lua%-2026%-11%-07/[a-z]+/[a-z]+$"), "owned capture path required")
  end
''',1)
p=Path('lua/test/hash_view_result_guard_composition_test.lua');assert not p.exists();p.write_text(source)
print('Lua33 source-only programs and explicit-grammar observer/normal authored; no peer outcomes imported')
