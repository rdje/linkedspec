"""Capture corrected fixed214 epoch with complete actual context before execution."""
import json
import sys
import common as c
import context


def main():
    epoch=sys.argv[1] if len(sys.argv)>1 else "candidate2"
    assert epoch in ("candidate2","candidate3")
    extras=[str(path.relative_to(c.ROOT)) for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    snapshot=context.snapshot(extras)
    snapshot['new_inputs']={path:c.read(path) for path in extras if not path.endswith('.gz')}
    snapshot['plan']=c.load('cases2.json')
    c.write_new(epoch+'-inputs.json.gz',snapshot)
    run=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(snapshot['plan']).encode())
    stable=c.unchanged(snapshot['inputs'])
    c.write_new(epoch+'-run.json.gz',dict(run=run,inputs_unchanged=stable))
    assert run['returncode']==0 and not c.decode(run['stderr_base64']) and stable
    print('Corrected214 public execution captured; classification separate;',len(snapshot['inputs']),'inputs')


if __name__=='__main__':main()
