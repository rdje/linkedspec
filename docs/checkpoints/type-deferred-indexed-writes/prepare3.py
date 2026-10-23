"""Remove a wrapper-name collision; retain and own the separate deferred-with gap."""
import common as c
plan=c.load('cases2.json')
for case in plan['cases']:
 if case['id'].startswith('deferred/'):
  body=case['body'];start=body.rfind('cb = {|| ')
  assert start>=0 and body.endswith('}; return(cb())')
  case['body']=body[:start]+'case_runner = {|| '+body[start+len('cb = {|| '):-len('}; return(cb())')]+'}; return(case_runner())'
with_case=next(case for case in plan['cases'] if case['id']=='deferred/with-null')
c.save('cases3.json',dict(cases=[case for case in plan['cases'] if case['id']!='deferred/with-null']))
run=c.observe(dict(cases=[with_case]))
c.save('deferred-with-intake.json.gz',dict(case=with_case,run=run,sources={p:c.read(p) for p in c.SOURCES},producer=c.read(c.PREFIX+'prepare3.py')))
print('Corrected wrapper; deferred with retained as separate intake')
