"""Distinguish language scalar kinds from current host JSON's numeric dualvar choice."""
import json
import common as c
import context


def main():
    expressions={'array-min':'min(["2","1"])','array-max':'max(["0","1"])',
        'odd-median':'median(["0","1","2"])','scalar-min':'min(2,1)','scalar-add':'add(0,1)'}
    plan=dict(cases=[dict(id=name,expression=expression) for name,expression in expressions.items()])
    public=dict(cases=[dict(id=name,body='items = ["zero","one"]; index = '+expression+
        '; items[index] = "changed"; return(items)') for name,expression in expressions.items()])
    extras=[str(path.relative_to(c.ROOT)) for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    snapshot=context.snapshot(extras)
    snapshot.update(plan=plan,public=public,
        new_inputs={path:c.read(path) for path in extras if not path.endswith('.gz')})
    c.write_new('kind-flags-inputs.json.gz',snapshot)
    flags=c.run(['perl','-Iperl',c.PREFIX+'kind_flags.pl'],input=json.dumps(plan).encode())
    updates=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(public).encode())
    stable=c.unchanged(snapshot['inputs'])
    c.write_new('kind-flags-run.json.gz',dict(flags=flags,updates=updates,inputs_unchanged=stable))
    assert stable and flags['returncode']==updates['returncode']==0
    assert not c.decode(flags['stderr_base64']) and not c.decode(updates['stderr_base64'])
    print(c.decode(flags['stdout_base64']).decode())
    for row in json.loads(c.decode(updates['stdout_base64']))['rows']:
        print(row['id'],json.dumps(row['native']['value']),json.dumps(row['native']['runtime_detail']))


if __name__=='__main__':main()
