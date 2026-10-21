"""Capture a new epoch once, retaining complete supplied source context first."""
import json
import sys
import common as c
import context
import oracle

def main():
    epoch=sys.argv[1]
    assert epoch in ('candidate1','candidate2','candidate3','candidate4','accepted')
    extras=[p.relative_to(c.ROOT).as_posix() for p in (c.ROOT/c.PREFIX).rglob('*') if p.is_file() and '__pycache__' not in p.parts]
    snapshot=context.snapshot(extras)
    snapshot.update(plan=c.load('cases3.json'),new_inputs={p:c.read(p) for p in extras if not p.endswith(('.gz','.part'))})
    c.write_new(epoch+'-inputs.json.gz',snapshot)
    run=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(snapshot['plan']).encode())
    stable=c.unchanged(snapshot['inputs'])
    failures=oracle.failures(run,snapshot['plan'])
    c.write_new(epoch+'-run.json.gz',dict(run=run,inputs_unchanged=stable,failures=failures))
    assert stable
    print(epoch,len(snapshot['plan']['cases']),'cases;',len(failures),'failures;',len(snapshot['inputs']),'inputs')
    for item in failures:print(item['id'],item['reasons'],json.dumps(item.get('actual')))

if __name__=='__main__':main()
