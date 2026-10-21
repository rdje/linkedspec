"""Replay corrected fixed214 with only the three real accepted execution owners installed."""
import json
import subprocess
import common as c
import context
import oracle


def main():
    paths=[c.SOURCE,'perl/LinkedSpec/Numeric.pm','perl/LinkedSpec/ActionIR/MethodLowering.pm']
    current={path:c.read(path) for path in paths}
    accepted={path:dict(base64=c.encode(subprocess.check_output(['git','show',c.BASE+':'+path],cwd=c.ROOT)),
        mode=current[path]['mode'],git_mode=subprocess.check_output(['git','ls-tree',c.BASE,'--',path],cwd=c.ROOT).split()[0].decode())
        for path in paths}
    c.write_new('accepted-before.json.gz',dict(current=current,accepted=accepted,base=c.BASE,
        producer=c.read(c.PREFIX+'accepted.py'),scope='Real accepted execution owners only; all other actual '
        'current metadata/instruments are explicit. This is a controlled fresh source replay, not an '
        'invented historical revision for the current draft. Recovery bytes precede installation.'))
    try:
        for path,item in accepted.items():(c.ROOT/path).write_bytes(c.decode(item['base64']))
        extras=[str(path.relative_to(c.ROOT)) for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
        snapshot=context.snapshot(extras)
        snapshot['new_inputs']={path:c.read(path) for path in extras if not path.endswith('.gz')}
        snapshot['plan']=c.load('cases2.json')
        c.write_new('accepted-inputs.json.gz',snapshot)
        run=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(snapshot['plan']).encode())
        stable=c.unchanged(snapshot['inputs'])
        c.write_new('accepted-run.json.gz',dict(run=run,inputs_unchanged=stable))
        assert run['returncode']==0 and not c.decode(run['stderr_base64']) and stable
    finally:
        for path,item in current.items():
            (c.ROOT/path).write_bytes(c.decode(item['base64']));(c.ROOT/path).chmod(item['mode'])
        restored=all(c.read(path)==item for path,item in current.items())
        c.write_new('accepted-restoration.json.gz',dict(sources_restored=restored))
    assert restored and c.unchanged({path:item for path,item in snapshot['inputs'].items() if path not in paths})
    failed=oracle.failures(run,snapshot['plan'])
    c.write_new('accepted-review.json.gz',dict(failures=failed,cases=len(snapshot['plan']['cases']),
        sources_restored=restored,oracle=c.read(c.PREFIX+'oracle.py')))
    assert failed
    print('Accepted-source fixed214 replay:',len(failed),'RED;',214-len(failed),'controls; candidate sources restored')


if __name__=='__main__':main()
