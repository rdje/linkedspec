"""Author Dart's source-only intake; no peer observation is an expectation."""
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
(base/'cases.json').write_text(json.dumps(rows,indent=2)+'\n')
source=Path('dart/tool/probe_key_count_callable_results.dart').read_text()
source=source.replace('CALLABLE_KEY_COUNT_DART','HASH_VIEW_DART').replace('key_count_callable_dart_fresh','hash_view_dart_fresh').replace('key-count-callable','hash-view-result-guard')
p=Path('dart/tool/probe_hash_view_results.dart');assert not p.exists();p.write_text(source)
print('33 source-only Dart intake cases and explicit-grammar public probe authored')
