"""Retain complete source identities and actual raw public execution before review."""
import json
import sys
import common as c
import context


def main():
    assert len(sys.argv)==2 and sys.argv[1] in ('baseline','red-final','candidate1')
    epoch=sys.argv[1]
    extras=[str(path.relative_to(c.ROOT)) for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    snapshot=context.snapshot(extras)
    # Untracked instrument and fixtures must remain recoverable after subsequent edits.
    snapshot['new_inputs']={path:c.read(path) for path in extras
        if not path.endswith('.gz')}
    c.write_new(epoch+'-inputs.json.gz',snapshot)
    plan=c.load('cases.json' if epoch=='baseline' else 'final-cases.json')
    run=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(plan).encode())
    stable=c.unchanged(snapshot['inputs'])
    c.write_new(epoch+'-run.json.gz',dict(run=run,inputs_unchanged=stable))
    assert run['returncode']==0,c.decode(run['stderr_base64']).decode()
    assert stable
    print(epoch,'raw aggregate execution retained:',len(plan['cases']),'cases;',len(snapshot['inputs']),'inputs')


if __name__=='__main__':main()
