"""Correct observation adapters and use standalone assignments in detachment cases."""
import common as c
plan=c.load('cases.json')
for case in plan['cases']:
 if case['id'].endswith('/copy'):
  case['body']=case['body'].replace('out = (chosen[0][0] = 2);','chosen[0][0] = 2; out = copy(chosen);')
c.save('cases2.json',plan)
run=c.observe(plan)
c.save('baseline2.json.gz',dict(base=c.BASE,source_inputs={p:c.read(p) for p in c.SOURCES+[c.PREFIX+'common.py',c.PREFIX+'probe.pl',c.PREFIX+'cases2.json',c.PREFIX+'prepare2.py']},whole_prior_epoch='baseline.json.gz',run=run,failures=c.failures(run,plan)))
print('Corrected baseline:',len(c.failures(run,plan)),'RED;',len(plan['cases']),'cases; original producer and run retained')
