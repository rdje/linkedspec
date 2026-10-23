"""Check presence shared by separately invoked forwarded callable parameters."""
import common as c
plan=dict(cases=[dict(id='forwarded/present-null',functions='fn apply(first, second) { first(); return(second()) }\n',body='first = {|| document = undef }; second = {|| document["x"] = 2; return(document) }; return(apply(first, second))',error='nested_write_kind_conflict')])
run=c.observe(plan)
c.save('forwarded-presence.json.gz',dict(plan=plan,run=run,failures=c.failures(run,plan),sources={p:c.read(p) for p in c.SOURCES},producer=c.read(c.PREFIX+'forwarded_presence.py')))
print('Forwarded presence:',c.failures(run,plan))
