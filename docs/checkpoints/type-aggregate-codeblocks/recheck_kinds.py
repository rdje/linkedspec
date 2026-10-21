"""Distinguish exact historical result-kind sources and real emitter boundaries."""
import json
import subprocess
import common as c
import context

SOURCE='perl/LinkedSpec/ActionIR/MethodLowering.pm'


def main():
    old=json.loads((c.ROOT/'docs/checkpoints/SESSION-STARTUP-READING.95-numeric-result-kinds.json').read_bytes())
    plan=dict(cases=[dict(id='catalog/'+str(index),source=row['source'],input=row['input'])
        for index,row in enumerate(old['observations'])])
    revisions=['c053c9dcf24a78cc8b551187f47cdb7aefb03eb3','2fca7d8489038c226fe0454a105f12a2af696a1f',c.BASE]
    sources={revision:dict(base64=c.encode(subprocess.check_output(['git','show',revision+':'+SOURCE],cwd=c.ROOT)),
        git_mode=subprocess.check_output(['git','ls-tree',revision,'--',SOURCE],cwd=c.ROOT).split()[0].decode())
        for revision in revisions}
    extras=[str(path.relative_to(c.ROOT)) for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    snapshot=context.snapshot(extras)
    snapshot['new_inputs']={path:c.read(path) for path in extras if not path.endswith('.gz')}
    snapshot.update(plan=plan,sources=sources,current=c.read(SOURCE),
        scope='Exact95 sources, direct JSON serializer independent of data projection. Controlled emitter '
              'replacement only; remaining actual candidate context is explicit, not a whole historical admission.')
    c.write_new('kind-history-before.json.gz',snapshot)
    results={}
    try:
        for revision,source in sources.items():
            (c.ROOT/SOURCE).write_bytes(c.decode(source['base64']))
            run=c.run(['perl','-Iperl',c.PREFIX+'kinds.pl'],input=json.dumps(plan).encode())
            stable=c.unchanged({path:item for path,item in snapshot['inputs'].items() if path!=SOURCE})
            result=dict(run=run,source=c.read(SOURCE),other_inputs_unchanged=stable)
            c.write_new('kind-history-'+revision[:9]+'.json.gz',result)
            results[revision]=result
            assert run['returncode']==0 and not c.decode(run['stderr_base64']) and stable
            actual=json.loads(c.decode(run['stdout_base64']))['rows']
            print(revision[:9],[(row['id'],row['native']['value_json'],row['generated']['value_json']) for row in actual])
    finally:
        (c.ROOT/SOURCE).write_bytes(c.decode(snapshot['current']['base64']))
        (c.ROOT/SOURCE).chmod(snapshot['current']['mode'])
        c.write_new('kind-history-restoration.json.gz',dict(source_restored=c.read(SOURCE)==snapshot['current'],
            inputs_restored=c.unchanged(snapshot['inputs'])))
    assert c.unchanged(snapshot['inputs'])


if __name__=='__main__':main()
