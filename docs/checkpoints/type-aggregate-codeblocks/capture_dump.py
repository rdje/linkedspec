"""Capture small accepted public dump epoch before inspecting the identified owner."""
import json
import common as c
import context


def main():
    cases=c.load('cases.json')['cases']
    ids=['ordinary/sum/canonical','deferred/sum/canonical','deferred/min/receiver']
    plan=dict(cases=[row for row in cases if row['id'] in ids])
    assert len(plan['cases'])==3
    extras=[str(path.relative_to(c.ROOT)) for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    inputs=context.snapshot(extras)
    inputs['plan']=plan
    inputs['new_inputs']={path:c.read(path) for path in extras}
    c.write_new('dump-inputs.json.gz',inputs)
    run=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(plan).encode())
    c.write_new('dump-run.json.gz',dict(run=run,inputs_unchanged=c.unchanged(inputs['inputs'])))
    assert run['returncode']==0 and not c.decode(run['stderr_base64']) and c.unchanged(inputs['inputs'])
    rows=json.loads(c.decode(run['stdout_base64']))['rows']
    for row in rows:
        assert row['native']['dump'] and row['generated']['source']
        print(row['id'],json.dumps(row['native']['runtime_detail'],sort_keys=True))
        text=row['native']['dump']
        for line in text.splitlines():
            if 'CodeblockRuntime' in line or '__ls_num_sum' in line:print(line[:500])


if __name__=='__main__':main()
