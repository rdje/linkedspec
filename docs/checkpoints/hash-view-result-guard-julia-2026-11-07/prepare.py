"""Author Julia source-only fences and explicit-grammar public instruments."""
import json
from pathlib import Path
base=Path(__file__).resolve().parent
rows=json.loads(Path('tests/fixtures/hash_view_result_guard_cases.json').read_text())
for identifier,row in json.loads(Path('tests/fixtures/hash_view_result_guard_rust_profiles.json').read_text()).items():
 if identifier in {'arity_profile','free_values_arity_profile','keys_null_profile','values_array_error_profile','values_scalar_null_profile'}:
  rows.append(dict(id=identifier,source=row['source'],input=row['input'],profile_only=True))
for row in json.loads(Path('tests/fixtures/hash_view_receiver_policy_perl_cases.json').read_text()):
 rows.append(dict(id='initial_'+row['id'],source=row['source'],input=row['input'],profile_only=True))
assert len(rows)==33 and len({r['id'] for r in rows})==33
fixture=Path('tests/fixtures/hash_view_result_guard_julia_cases.json');assert not fixture.exists();fixture.write_text(json.dumps(rows,indent=2)+'\n')
source=Path('docs/checkpoints/key-count-callable-julia-2026-11-06/observer.jl').read_text()
source=source.replace('JuliaKeyCountCallableProbe','JuliaHashViewProbe').replace('KeyCountCallableGenerated','HashViewGenerated').replace('CALLABLE_KEY_COUNT_JULIA','HASH_VIEW_JULIA').replace('key-count-callable','hash-view-result-guard')
needle='    grammar_path = "specs/user_function_definition.spec"'
assert source.count(needle)==1
source=source.replace(needle,'''    output = ARGS[2]
    (isempty(output) || isabspath(output) ||
        any(part -> part in ("", ".", ".."), split(output, '/'; keepempty=true)) ||
        !startswith(output, "docs/checkpoints/hash-view-result-guard-julia-2026-11-07/") ||
        !isdir(output) || islink(output)) && error("output must be an existing owned repository-relative phase")
'''+needle,1)
source=source.replace('    output = ARGS[2]\n    mkpath','    mkpath',1)
(base/'observer.jl').write_text(source)
source=Path('julia/test/key_count_callable_result_guard_composition_test.jl').read_text()
source=source.replace('JuliaKeyCountCallableComposition','JuliaHashViewComposition').replace('KeyCountGuardGenerated','HashViewGenerated').replace('CALLABLE_KEY_COUNT_JULIA_NORMAL','HASH_VIEW_JULIA_NORMAL').replace('LINKEDSPEC_CALLABLE_KEY_COUNT_CAPTURE','LINKEDSPEC_HASH_VIEW_CAPTURE').replace('key-count-callable','hash-view-result-guard').replace('key_count_callable_julia_profiles.json','hash_view_result_guard_julia_profiles.json').replace('key_count_callable_result_cases.json','hash_view_result_guard_julia_cases.json').replace('Julia callable CountKeys preservation','Julia Hash-view result guards').replace('CountKeys fixture','Hash-view fixture')
p=Path('julia/test/hash_view_result_guard_composition_test.jl');assert not p.exists();p.write_text(source)
print('Julia33 source programs and explicit-grammar observer/normal authored; no peer observations imported')
