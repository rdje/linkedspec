"""Use the existing capture scaffold to distinguish input-context and kind policy."""
import json
import common as c
import context


def main():
    path=c.PREFIX+'probe.pl'
    before=c.read(path)
    raw=c.decode(before['base64']).decode()
    old='my $source = ($case->{functions}'
    new='my $source = $case->{source} // ($case->{functions}'
    assert raw.count(old)==1
    after=raw.replace(old,new,1)
    c.write_new('diagnostic-instrument.json.gz',dict(before=before,after_base64=c.encode(after.encode()),
        scope='Add an explicit full source fixture; original accepted/candidate raw records remain intact.'))
    (c.ROOT/path).write_text(after)
    rows=[]
    values={'sum':12,'avg':4,'median':3,'range':7,'min':1,'max':8}
    for name in values:
        for mode in ('ordinary','deferred'):
            expression=name+'(items)'
            body='items = [entry_group(0),entry_group(1),entry_group(2)]; '+(
                'return('+expression+')' if mode=='ordinary' else
                'cb = {|items| return('+expression+') }; return(cb(items))')
            source='Top::\n -> Value .push\n LX { return(copy(Top)) }\n\nValue: /([0-9]+),([0-9]+),([0-9]+)/\n I { '+body+' }\n'
            rows.append(dict(id=mode+'/'+name+'/capture-scaffold',source=source,input='3,1,8',body=body))
    initial=c.load('cases.json')['cases']
    final=c.load('final-cases.json')['cases']
    for plan in (initial,final):
        for row in plan:
            if row['id'] in ('ordinary/min/receiver-arity','ordinary/max/receiver-arity',
                             'deferred/min/receiver-arity','deferred/max/receiver-arity'):
                clone=dict(row);clone['id']=('initial/' if plan is initial else 'final/')+row['id'];rows.append(clone)
    plan=dict(cases=rows)
    c.write_new('diagnostic-cases.json',plan)
    extras=[str(path.relative_to(c.ROOT)) for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    snapshot=context.snapshot(extras)
    snapshot['new_inputs']={path:c.read(path) for path in extras if not path.endswith('.gz')}
    c.write_new('diagnostic-inputs.json.gz',snapshot)
    run=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(plan).encode())
    stable=c.unchanged(snapshot['inputs'])
    c.write_new('diagnostic-run.json.gz',dict(run=run,inputs_unchanged=stable))
    assert run['returncode']==0 and not c.decode(run['stderr_base64']) and stable
    for row in json.loads(c.decode(run['stdout_base64']))['rows']:
        print(row['id'],json.dumps(row['native']['value']),json.dumps(row['native']['runtime_detail']),row['generated']['warnings'])


if __name__=='__main__':main()
