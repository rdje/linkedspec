"""Retain the original mistaken control and probe actual post-match alternatives."""
import json
import common as c
import context


def main():
    epoch = context.snapshot()
    c.write_new('qualification-inputs.json.gz',dict(context=epoch,
        producer=c.read(c.PREFIX+'qualify.py'),original_oracle=c.read(c.PREFIX+'oracle.py'),
        original_test=c.read('t/trace_cli.t'),original_plan=c.read(c.PREFIX+'cases.json'),
        canonical={path:c.read(path) for path in (
            'docs/knowledge/top-rule-reads-own-match-with-match-family.md',
            'docs/knowledge/rust-lifecycle-i-return-dispatch-parity.md')}))
    original = {}
    for name,args in dict(cli=['baseline'],library=['--library','baseline']).items():
        original[name] = c.run(['bash','tools/run_python_project_data.sh',c.PREFIX+'oracle.py']+args)
    c.write_new('original-oracle-runs.json.gz',original)
    probes = dict(cases=[
        dict(id='bare-no-match',source='Top: /x/\n',input='y'),
        dict(id='post-no-match',source='Top::AND\n /x/ -> Top[0] { return(42) }\n',input='y'),
        dict(id='post-match',source='Top::AND\n /x/ -> Top[0] { return(42) }\n',input='x')])
    c.write_new('no-match-probes.json',probes)
    run = c.run(['bash','tools/project_data_run.sh','perl','-Iperl',c.PREFIX+'perl_probe.pl'],
        input=(json.dumps(probes)+'\n').encode())
    stable = c.unchanged(epoch['inputs'])
    c.write_new('no-match-probes.json.gz',dict(run=run,inputs_unchanged=stable,plan=probes))
    assert stable and run['returncode']==0 and not c.decode(run['stderr_base64'])
    value = json.loads(c.decode(run['stdout_base64']))
    for row in value['rows']:
        print(json.dumps(dict(id=row['id'],routes={route:{key:row[route][key]
            for key in ('completed','value','exception','last_error','warnings')}
            for route in ('native','generated')}),sort_keys=True))


if __name__ == '__main__':
    main()
