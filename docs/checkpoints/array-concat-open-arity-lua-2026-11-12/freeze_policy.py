"""Freeze independently acquired host policies and author focused normal epochs."""
import copy
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
ACTIVATION='fb613736f68f7d1f90df5ade3c0e73c98160ca3f'
OLD=Path('docs/checkpoints/array-transform-callable-lua-2026-11-12')
assert subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()==ACTIVATION
assert (BASE/'launches/inspect-intake/exit.txt').read_text()=='0\n'
assessment=json.loads((BASE/'intake-assessment.json').read_bytes())
cases=json.loads((BASE/'cases.json').read_bytes())
profile=Path('tests/fixtures/array_concat_open_arity_lua_profiles.json')
normal=Path('lua/test/array_concat_open_arity_result_guard_composition_test.lua')
assert not profile.exists() and not normal.exists() and not (BASE/'baseline.json').exists()
baseline,profiles={},{}
for host,a in assessment.items():
 assert (len(a['targets']),len(a['compatibility']),a['preserved'],len(a['initial_policy_ids']),len(a['invalid_signature_ids']))==(20,4,484,80,8)
 assert not a['targets'].keys() & a['compatibility'].keys()
 expected=copy.deepcopy(a['observed']);expected.update(a['targets']);expected.update(a['compatibility'])
 failures=sum(json.dumps(a['observed'][k][r],sort_keys=True)!=json.dumps(expected[k][r],sort_keys=True) for k in expected for r in ('native','restored','plan','fresh'))
 assert failures==96
 baseline[host]=dict(observed=a['observed'],expected=expected,supported_targets=sorted(a['targets']),legacy_operand_compatibility=sorted(a['compatibility']),preserved=[r['id'] for r in cases if r['id'] not in a['targets'] and r['id'] not in a['compatibility']],initial_policies=a['initial_policy_ids'],invalid_signatures=a['invalid_signature_ids'],original_route_failures=failures)
 profiles[host]={r['id']:dict(source=r['source'],**expected[r['id']]) for r in cases}
profile.write_text(json.dumps(profiles,indent=2,sort_keys=True)+'\n')
(BASE/'baseline.json').write_text(json.dumps(baseline,indent=2,sort_keys=True)+'\n')
source=gzip.decompress((BASE/'template-7.gz').read_bytes()).decode()
source=source.replace(str(OLD),str(BASE)).replace('CALLABLE_TRANSFORM','ARRAY_CONCAT').replace('array_transform_callable_result_guard_lua','array_concat_open_arity_lua').replace('array%-transform%-callable%-lua','array%-concat%-open%-arity%-lua').replace('TYPE-REFERENCE-BOOK.1.2.23.3.78.6.5','TYPE-REFERENCE-BOOK.1.2.23.3.80.5').replace('installed-host callable transform guards','installed-host existing concat arity guards')
anchor='    local identity = "callable-array-transform/" .. row.id .. ".spec"'
assert source.count(anchor)==1
source=source.replace(anchor,'''    local prefix = row.origin == "legacy312" and "callable-array-transform" or
      row.origin == "ordinary4" and "array-transform-result-guard" or "array-concat-open-arity-result-guard"
    local identity = prefix .. "/" .. row.id .. ".spec"''')
normal.write_text(source)
path=OLD/'capture_epochs.py';raw=path.read_bytes()
assert raw==subprocess.check_output(['git','show',ACTIVATION+':'+str(path)])
(BASE/'freeze-template-capture.py.gz').write_bytes(gzip.compress(raw,mtime=0))
capture=raw.decode().replace(str(OLD),str(BASE)).replace('fff959ef7e8896b5b97f311a276cabc4f5034551',ACTIVATION).replace('CALLABLE_TRANSFORM','ARRAY_CONCAT')
start=capture.index('    source_paths = [Path(p) for p in subprocess.check_output(')
end=capture.index("    prefix = ''",start)
capture=capture[:start]+'''    source_paths = [Path(p) for p in json.loads((BASE / 'selected-inputs.json').read_bytes())]
    source_paths += [FIXTURE, NORMAL, PROFILE]
'''+capture[end:]
capture=capture.replace("'LINKEDSPEC_CALLABLE_PIPELINE_CAPTURE', 'LINKEDSPEC_CALLABLE_PIPELINE_INPUT_ROOT')}","'LINKEDSPEC_CALLABLE_PIPELINE_CAPTURE', 'LINKEDSPEC_CALLABLE_PIPELINE_INPUT_ROOT',\n                'LINKEDSPEC_CALLABLE_TRANSFORM_CAPTURE', 'LINKEDSPEC_CALLABLE_TRANSFORM_INPUT_ROOT')}")
capture=capture.replace('>= 30','>= 45').replace("(b'1872', b'124' if red else b'0')","(b'3048', b'96' if red else b'0')")
capture=capture.replace("tests += ['lua/test/array_transform_result_guard_composition_test.lua', 'lua/test/array_pipeline_callable_result_guard_composition_test.lua']","tests += ['lua/test/array_transform_callable_result_guard_composition_test.lua', 'lua/test/array_transform_result_guard_composition_test.lua', 'lua/test/array_pipeline_callable_result_guard_composition_test.lua']")
capture=capture.replace("assert b'ARRAY_TRANSFORM_LUA_SUMMARY 903 checks 0 failures' in result.stdout","assert b'CALLABLE_TRANSFORM_LUA_SUMMARY 1872 checks 0 failures' in result.stdout\n            assert b'ARRAY_TRANSFORM_LUA_SUMMARY 903 checks 0 failures' in result.stdout")
compile(capture,'capture_epochs.py','exec')
(BASE/'capture_epochs.py').write_text(capture)
for path,name in ((Path('lua/src/linkedspec/interpreter.lua'),'owner'),(Path('lua/test/run.lua'),'runner')):
 body=path.read_bytes();assert body==subprocess.check_output(['git','show',ACTIVATION+':'+str(path)])
 (BASE/(name+'-before.lua.gz')).write_bytes(gzip.compress(body,mtime=0))
print('Frozen own installed-host508:20 supported/four separately acquired legacy continuations/484 preserved/80 initial/eight signature controls; before must expose96 of3048 failures')
