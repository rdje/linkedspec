"""Confirm count/first at their own dispatch boundary after sorted/take is available."""
import json
import common as c
import context
import oracle

def main():
    cases=[]
    for method,value in [('count',2),('first',1)]:
        expr='items.sorted().take(2).'+method+'()'
        cases.append(dict(id='ordinary/'+method,body='items = [2,10,1]; return('+expr+')',expected=value))
        cases.append(dict(id='deferred/'+method,body='items = [2,10,1]; cb = {|| return('+expr+') }; return(cb())',error=dict(code='unknown_helper',name=method)))
    plan=dict(cases=cases)
    extras=[p.relative_to(c.ROOT).as_posix() for p in (c.ROOT/c.PREFIX).rglob('*') if p.is_file() and '__pycache__' not in p.parts]
    inputs=context.snapshot(extras)
    inputs.update(plan=plan,new_inputs={p:c.read(p) for p in extras if not p.endswith(('.gz','.part'))})
    c.write_new('followup-inputs.json.gz',inputs)
    run=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(plan).encode())
    stable=c.unchanged(inputs['inputs'])
    c.write_new('followup-confirmation.json.gz',dict(run=run,plan=plan,inputs_unchanged=stable,producer=c.read(c.PREFIX+'confirm_followups.py'),source=c.read(c.SOURCE)))
    assert stable and not oracle.failures(run,plan)
    print('Actual post-repair count/first: two ordinary values/two exact deferred unknown-helper causes confirmed')

if __name__=='__main__':main()
