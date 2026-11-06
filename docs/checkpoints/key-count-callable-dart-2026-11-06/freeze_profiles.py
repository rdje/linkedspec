"""Freeze Dart's own function-result profiles from its actual first intake."""
import json
from pathlib import Path
base=Path(__file__).resolve().parent
native={};fresh={}
for name,tag,out in [('native-stdout.log','CALLABLE_KEY_COUNT_DART',native),('fresh-stdout.log','CALLABLE_KEY_COUNT_DART_FRESH',fresh)]:
 for line in (base/'intake'/name).read_text().splitlines():
  if line.startswith(tag+' '):
   _,i,body=line.split(' ',2);out[i]=json.loads(body)
assert len(native)==len(fresh)==16
cases=json.loads(Path('tests/fixtures/key_count_callable_result_cases.json').read_text())
profiles={}
for case in cases:
 i=case['id'];row={**native[i],'fresh':fresh[i]};assert 'preparation_error' not in row
 if case.get('expected_error'):
  assert all(case['expected_error'] in value['error'] for value in row.values())
  assert row['native']==row['restored'] and row['plan']==row['fresh']
  assert row['native']['class']=='RuntimeInterpreterException' and row['plan']['class']=='GeneratedSourceException'
 else:
  expected=None if i in ['boolean_receiver_profile','boolean_terminal_profile'] else ([None,''] if case.get('profile_only') else case['expected'])
  assert all(json.dumps(value,sort_keys=True)==json.dumps({'value':expected},sort_keys=True) for value in row.values())
 if i in ['boolean_receiver_profile','boolean_terminal_profile','malformed_receiver_profile','needed_argument_error']:
  profiles[i]={'source':case['source'],**row}
with Path('tests/fixtures/key_count_callable_dart_profiles.json').open('x') as output:output.write(json.dumps(profiles,indent=2,sort_keys=True)+'\n')
print('Dart compatible targets/profile population16 PASS/four routes; Boolean receiver null and own full error profiles frozen.')
