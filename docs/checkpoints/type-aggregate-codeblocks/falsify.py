"""Install six actual faults; require distinguishing RED and fresh restored GREEN."""
import json
import common as c
import context
import oracle


def main():
    runtime=c.SOURCE;numeric='perl/LinkedSpec/Numeric.pm';compiler='perl/LinkedSpec/ActionIR/MethodLowering.pm'
    tasks=[
        dict(name='call-dispatch',path=runtime,id='deferred/sum/canonical',hunks=[(
            ' my $aggregate = LinkedSpec::Numeric::array_helper_name($name);',' my $aggregate;')]),
        dict(name='receiver-dispatch',path=runtime,id='deferred/sum/receiver',hunks=[(
            "  my $aggregate = $method =~ /\\A[a-z]+\\z/ ? LinkedSpec::Numeric::array_helper_name($method) : undef;",
            '  my $aggregate;')]),
        dict(name='empty-sum-identity',path=numeric,id='deferred/sum/empty',hunks=[(
            '  my $total = 0;','  my $total = 1;')]),
        dict(name='terminal-effects',path=runtime,id='deferred/sum/terminal-effect',hunks=[(
            '   return undef if @$args || $index < $#$calls;','   return undef if @$args;')]),
        dict(name='scalar-overload-effects',path=runtime,id='deferred/min/receiver-arity',hunks=[(
            "  if (defined($aggregate) && ($method !~ /\\A(?:min|max)\\z/ || !@{$call->{args} || []})) {",
            "  if (defined($aggregate) && ($method !~ /\\A(?:min|max)\\z/ || ref($value) eq 'ARRAY')) {")]),
        dict(name='emitted-shape-fallthrough',path=compiler,id='ordinary/sum/receiver-arity',initial=True,hunks=[(
            "    return 'undef' if @$aggregate_args || $index < $#$calls;",
            "    return 'undef' if $index < $#$calls;"),(
            "    return ['undef', 'terminal'] unless @$arg_exprs == 0;",
            '    return undef unless @$arg_exprs == 0;')]),
    ]
    source={path:c.read(path) for path in (runtime,numeric,compiler)}
    for task in tasks:
        raw=c.decode(source[task['path']]['base64']).decode()
        for before,after in task['hunks']:assert raw.count(before)==1,(task['name'],before)
        fixture=c.load('cases.json' if task.get('initial') else 'cases2.json')
        task['plan']=dict(cases=[row for row in fixture['cases'] if row['id']==task['id']])
        assert len(task['plan']['cases'])==1
    extras=[str(path.relative_to(c.ROOT)) for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    snapshot=context.snapshot(extras)
    snapshot['new_inputs']={path:c.read(path) for path in extras if not path.endswith('.gz')}
    c.write_new('fault-inputs.json.gz',dict(context=snapshot,sources=source,tasks=tasks,
        producer=c.read(c.PREFIX+'falsify.py')))
    execute=lambda plan:c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(plan).encode())
    completed=[]
    for task in tasks:
        path=task['path'];original=source[path];raw=c.decode(original['base64']).decode();mutant=raw
        for before,after in task['hunks']:mutant=mutant.replace(before,after,1)
        try:
            (c.ROOT/path).write_text(mutant)
            run=execute(task['plan'])
            c.write_new('fault-'+task['name']+'-observed.json.gz',dict(mutant=c.read(path),run=run))
        finally:
            (c.ROOT/path).write_bytes(c.decode(original['base64']));(c.ROOT/path).chmod(original['mode'])
        assert c.unchanged(snapshot['inputs']) and c.read(path)==original
        failed=oracle.failures(run,task['plan'])
        assert failed,task['name']
        row=oracle.rows(run)[task['id']]
        if task['name'] in ('call-dispatch','receiver-dispatch'):
            assert row['native']['runtime_detail']['fields']['code']=='unknown_helper'
        elif task['name']=='empty-sum-identity':assert row['native']['value']==1
        elif task['name']=='terminal-effects':assert row['native']['value']==[None,'rx']
        elif task['name']=='scalar-overload-effects':assert row['native']['value']==[None,'']
        else:assert row['generated']['warnings'] and row['native']['last_error'] is not None
        restored=execute(task['plan'])
        assert not oracle.failures(restored,task['plan']),task['name']
        assert c.unchanged(snapshot['inputs'])
        c.write_new('fault-'+task['name']+'.json.gz',dict(run=run,restored=restored,failures=failed,
            source_restored=True,inputs_restored=True))
        completed.append(task['name']);print('Actual aggregate fault RED/restored:',task['name'],flush=True)
    c.write_new('fault-review.json.gz',dict(result='PASS',faults=completed,inputs_restored=True))


if __name__=='__main__':main()
