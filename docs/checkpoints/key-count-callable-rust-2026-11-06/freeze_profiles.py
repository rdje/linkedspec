"""Freeze only independently observed Rust source/error profiles from actual intake."""
import json
from pathlib import Path
b=Path(__file__).resolve().parent
rows={};fresh={}
for name,tag,out in [('native-stdout.log','CALLABLE_KEY_COUNT_RUST',rows),('fresh-stdout.log','CALLABLE_KEY_COUNT_RUST_FRESH',fresh)]:
 for line in (b/'intake'/name).read_text().splitlines():
  if line.startswith(tag+' '):
   _,i,body=line.split(' ',2);out[i]=json.loads(body)
assert len(rows)==len(fresh)==16
cases=json.loads(Path('tests/fixtures/key_count_callable_result_cases.json').read_text())
profiles={}
for c in cases:
 i=c['id'];r={**rows[i],'fresh':fresh[i]};assert 'preparation_error' not in r
 if i=='needed_argument_error':
  assert all(c['expected_error'] in value['error'] for value in r.values())
 else:
  expected=[None,''] if c.get('profile_only') else c['expected']
  assert all(json.dumps(value,sort_keys=True)==json.dumps({'value':expected},sort_keys=True) for value in r.values())
 if i in ['needed_argument_error','malformed_receiver_profile','boolean_receiver_profile','boolean_terminal_profile']:
  profiles[i]={'source':c['source'],**r}
assert profiles['boolean_terminal_profile']['native']=={'value':0}
assert profiles['boolean_receiver_profile']['native']=={'value':1}
with Path('tests/fixtures/key_count_callable_rust_profiles.json').open('x') as f:f.write(json.dumps(profiles,indent=2,sort_keys=True)+'\n')
print('Independent Rust16 already PASS/four routes; terminal0/composed1 and error/arity profiles frozen.')
