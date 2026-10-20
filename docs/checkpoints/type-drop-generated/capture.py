"""Capture the accepted public drop warning/FATAL matrix before emission changes."""
import json
import subprocess
import common as c
import context


def main():
    fixture='tests/drop-generated/cases.json'
    plan=json.loads((c.ROOT/fixture).read_bytes())
    extras=[c.PREFIX+path.name for path in (c.ROOT/c.PREFIX).iterdir() if path.suffix in ('.py','.pl')]
    extras.append(fixture)
    snapshot=context.snapshot(extras)
    source=c.read(c.SOURCE)
    assert c.decode(source['base64'])==subprocess.check_output(['git','show',c.BASE+':'+c.SOURCE],cwd=c.ROOT)
    snapshot.update(plan=plan,source=source,
        scope=snapshot['scope']+' Accepted actual descriptor/Get/lowering/dump/fresh normal and caller-FATAL syntax routes precede classification. Diagnostic controls have no invented numeric/key contract.')
    c.write_new('red-inputs.json.gz',snapshot)
    run=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(plan).encode())
    c.write_new('red-run.json.gz',dict(run=run,inputs_unchanged=c.unchanged(snapshot['inputs'])))
    assert run['returncode']==0 and not c.decode(run['stderr_base64']) and c.unchanged(snapshot['inputs'])
    actual=json.loads(c.decode(run['stdout_base64']))
    assert len(actual['rows'])==len(plan['cases'])
    print('Accepted drop routes captured:',len(actual['rows']),'; complete inputs',len(snapshot['inputs']),'; no classification yet')


if __name__=='__main__':
    main()
