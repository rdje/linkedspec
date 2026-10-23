"""Source-bound current/accepted calibration with an explicit raw host subject."""
import json,os
import common as c
old=c.read(c.PREFIX+'probe_legacy_regex.pl')
raw_plan=c.load('escaped-regex-before.json.gz')['plan']
public=json.loads((c.ROOT/'tests/numeric-codeblocks/indexed-writes.json').read_bytes())
life_plan=dict(cases=[case for case in public['cases'] if case['id'].startswith('compiled-assignment/')])
assert len(life_plan['cases'])==10
intake_plan=dict(cases=[dict(id='payload-original',input='x14,2 }\ntail'),
 dict(id='payload-inserted-semicolon',input='x14,2 };\ntail')])
for case in intake_plan['cases']:
 case['source']='Top::\n -> Done { rx = /(14,2) \\}\ntail/; return(rx) }\nDone:\n /x/\n'
def observe(plan):
 return c.run(['bash','tools/project_data_run.sh','perl','-Iperl',c.PREFIX+'probe_legacy_regex.pl'],input=json.dumps(plan).encode())
current={path:c.read(path) for path in c.SOURCES}
assert current==c.load('compatibility-repair.json.gz')['sources']
context=c.epoch()
runs=dict(lifecycle=c.observe(life_plan),regex=observe(raw_plan),intake=observe(intake_plan),
 oracle=c.run(['bash','tools/project_data_run.sh','perl',c.PREFIX+'raw_regex_oracle.pl'],input=json.dumps(intake_plan).encode()))
accepted={path:c.run(['git','show',c.BASE+':'+path]) for path in c.SOURCES}
assert all(run['returncode']==0 for run in accepted.values())
baseline_context=None
baseline=None
try:
 for path in c.SOURCES:(c.ROOT/path).write_bytes(c.decode(accepted[path]['stdout_base64']))
 baseline_context=c.epoch()
 baseline=dict(regex=observe(raw_plan),intake=observe(intake_plan))
finally:
 for path,image in current.items():
  (c.ROOT/path).write_bytes(c.decode(image['base64']))
  os.chmod(c.ROOT/path,image['mode'])
 restored={path:c.read(path) for path in c.SOURCES}==current
 assert restored
failures=dict(lifecycle=c.failures(runs['lifecycle'],life_plan),regex={})
for epoch,run in [('current',runs['regex']),('accepted',baseline['regex'])]:
 assert run['returncode']==0
 for row in json.loads(c.decode(run['stdout_base64']))['rows']:
  expected=None if row['id'].endswith('/unescaped') else 7
  errors=[]
  for route in ('native','generated'):
   value=row[route]
   if not value['completed'] or value['exception'] or value['last_error'] or value['warnings'] or value['stdout'] or value['value']!=expected:errors.append(route)
  if errors:failures['regex'][epoch+'/'+row['id']]=errors
result=dict(context=context,sources=current,runs=runs,accepted=accepted,
 baseline_context=baseline_context,baseline=baseline,restored=restored,failures=failures,
 plans=dict(lifecycle=life_plan,regex=raw_plan,intake=intake_plan),legacy_probe=old,
 oracle_producer=c.read(c.PREFIX+'raw_regex_oracle.pl'),producer=c.read(c.PREFIX+'compare_compatibility2.py'))
c.save('compatibility2.json.gz',result)
print('Compatibility failures:',json.dumps(failures,sort_keys=True))
print('Oracle:',c.decode(runs['oracle']['stdout_base64']).decode().strip())
for epoch,run in [('current',runs['intake']),('accepted',baseline['intake'])]:
 rows=json.loads(c.decode(run['stdout_base64']))['rows']
 print(epoch,json.dumps([{**{'id':row['id']},**{route:{key:row[route][key] for key in ('completed','value','last_error','exception','warnings')} for route in ('native','generated')}} for row in rows],sort_keys=True))
assert not any(failures.values())
