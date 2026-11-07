"""Freeze actual independent Rust policies and prepare the unchanged-target normal."""
import gzip
import json
from pathlib import Path

BASE=Path(__file__).resolve().parent
ROOT=Path.cwd()
def rows(name,prefix):
    result={}
    for line in gzip.decompress((BASE/'intake'/(name+'-stdout.log.gz')).read_bytes()).decode().splitlines():
        if line.startswith(prefix+' '):
            _,identifier,value=line.split(' ',2)
            assert identifier not in result
            result[identifier]=json.loads(value)
    return result
native=rows('native','HASH_VALUE_RUST')
fresh=rows('fresh','HASH_VALUE_RUST_FRESH')
cases=json.loads((BASE/'intake/cases.json').read_bytes())
assert list(native)==list(fresh)==[case['id'] for case in cases]
profiles={}
for case in cases:
    key=case['id']
    assert set(native[key])=={'native','restored','plan'}
    assert native[key]['native']==native[key]['restored']
    if case.get('expected_error'):
        assert all(case['expected_error'] in row['error'] for row in [*native[key].values(),fresh[key]])
        assert native[key]['plan']==fresh[key]
        assert fresh[key]['error']=='Generated Rust parser execution failed: '+native[key]['native']['error']
    else:
        assert all(row==native[key]['native'] for row in [*native[key].values(),fresh[key]])
    if case.get('profile_only') or case.get('expected_error'):
        profiles[key]=dict(source=case['source'],input=case['input'],profile_only=bool(case.get('profile_only')),**native[key],fresh=fresh[key])
assert len(profiles)==65
fixture=ROOT/'tests/fixtures/hash_value_result_guard_rust_profiles.json'
normal=ROOT/'rust/linkedspec-runtime/tests/hash_value_result_guard_composition.rs'
assert not fixture.exists() and not normal.exists()
fixture.write_text(json.dumps(profiles,indent=2,sort_keys=True)+'\n')
source=(ROOT/'rust/linkedspec-runtime/tests/hash_view_result_guard_composition.rs').read_text()
source=source.replace('TYPE-REFERENCE-BOOK.1.2.23.3.76.2','TYPE-REFERENCE-BOOK.1.2.23.3.77.2').replace('Hash-view','Hash-valued helper').replace('hash-view-result','hash-value-result').replace('hash_view_result_guard','hash_value_result_guard').replace('HASH_VIEW_RUST_NORMAL','HASH_VALUE_RUST_NORMAL').replace('hash_view_cases','hash_value_cases')
start=source.index('hash_value_cases! {')
source=source[:start]+'hash_value_cases! {\n'+''.join('    '+case['id']+',\n' for case in cases)+'}\n'
normal.write_text(source)
print('89 unchanged targets/policies;65 independently acquired profiles frozen')
