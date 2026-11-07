"""Freeze independent actual Julia preservation/error policies before production."""
import gzip,json
from pathlib import Path
BASE=Path(__file__).resolve().parent
rows={}
for line in gzip.decompress((BASE/'intake/normal-stdout.log.gz').read_bytes()).decode().splitlines():
    if line.startswith('HASH_VALUE_JULIA '):
        _,key,value=line.split(' ',2);assert key not in rows;rows[key]=json.loads(value)
cases=json.loads((BASE/'cases.json').read_bytes());assert list(rows)==[r['id'] for r in cases]
profiles={};bad=[]
for case in cases:
    key=case['id'];actual=rows[key]
    assert set(actual)=={'native','restored','plan','fresh'}
    assert actual['native']==actual['restored'] and actual['plan']==actual['fresh']
    if case.get('expected_error'):
        assert all(case['expected_error'] in value.get('error','') for value in actual.values())
        assert actual['native']['class']=='RuntimeInterpreterException' and actual['plan']['class']=='GeneratedSourceException'
    if case.get('profile_only') or case.get('expected_error'):
        profiles[key]=dict(source=case['source'],input=case['input'],**actual)
    elif any(value!={'value':case['expected']} for value in actual.values()):bad.append(key)
assert len(profiles)==65
profile=Path('tests/fixtures/hash_value_result_guard_julia_profiles.json');assert not profile.exists()
profile.write_text(json.dumps(profiles,indent=2,sort_keys=True)+'\n')
normal=Path('julia/test/hash_value_result_guard_composition_test.jl');assert not normal.exists()
source=Path('julia/test/hash_view_result_guard_composition_test.jl').read_text()
source=source.replace('JuliaHashViewComposition','JuliaHashValueComposition').replace('Hash-view','pure Hash-helper').replace('HASH_VIEW_JULIA','HASH_VALUE_JULIA').replace('LINKEDSPEC_HASH_VIEW_CAPTURE','LINKEDSPEC_HASH_VALUE_CAPTURE').replace('HashViewGenerated','HashValueGenerated').replace('hash-view-result-guard','hash-value-result-guard').replace('hash_view_result_guard','hash_value_result_guard')
normal.write_text(source)
print(json.dumps(dict(programs=89,profiles=65,shared_target_failures=bad),indent=2))
