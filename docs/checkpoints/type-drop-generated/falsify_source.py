"""Install four actual drop-producer faults and require distinguishing REDs."""
import json
import common as c
import context
import oracle


def main():
    fixture=json.loads((c.ROOT/'tests/drop-generated/cases.json').read_bytes())
    tasks=[
        dict(name='scalar-slice-warning',id='call/one',
             before=b'delete @__ls_drop{@__ls_drop_keys};',after=b'delete @__ls_drop{"debug"};'),
        dict(name='late-key-read',id='call/key-value-snapshot',
             before=b'   push @lowered_keys, _materialize_list_operand_expr($key_lowered);',
             after=b'   push @lowered_keys, $key_lowered;'),
        dict(name='missing-flat-lowering',id='call/flat-two',
             before=b'   my $key_lowered = $lower_flat_list_value_expr->($key_expr);',
             after=b'   my $key_lowered;'),
        dict(name='raw-hash-key',id='diagnostic/call/hash-key',
             before=b'   $key_lowered = $lower_shape_literal_value_expr->($key_expr)\n    unless defined($key_lowered) && length($key_lowered);\n',
             after=b''),
    ]
    original=c.read(c.SOURCE)
    raw=c.decode(original['base64'])
    for task in tasks:
        assert raw.count(task['before'])==1,task['name']
        task['plan']=dict(cases=[case for case in fixture['cases'] if case['id']==task['id']])
        assert len(task['plan']['cases'])==1
    extras=[c.PREFIX+path.name for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file()]
    extras+=['tests/drop-generated/cases.json','t/drop_keys_generated.t',
             'tests/language-readiness/drop-generated-regression-evolution.json.gz']
    snapshot=context.snapshot(extras)
    c.write_new('source-fault-inputs.json.gz',dict(inputs=snapshot,source=original,
        tasks=[dict(task,before=c.encode(task['before']),after=c.encode(task['after'])) for task in tasks],
        producer=c.read(c.PREFIX+'falsify_source.py')))
    execute=lambda plan:c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(plan).encode())
    results=[]
    for task in tasks:
        target=c.ROOT/c.SOURCE
        try:
            target.write_bytes(raw.replace(task['before'],task['after'],1))
            mutant=c.read(c.SOURCE)
            run=execute(task['plan'])
            c.write_new('fault-'+task['name']+'-observed.json.gz',dict(run=run,mutant=mutant))
        finally:
            target.write_bytes(raw)
            target.chmod(original['mode'])
        assert c.read(c.SOURCE)==original and c.unchanged(snapshot['inputs'])
        row=oracle.rows(run)[task['id']]
        if task['name']=='scalar-slice-warning':
            assert row['native']['value']==task['plan']['cases'][0]['expected']
            assert not row['generated_fatal']['completed']
            assert 'Scalar value @__ls_drop{' in row['generated_fatal']['exception']['text']
        elif task['name']=='late-key-read':
            assert row['native']['value']==row['generated']['value']==[{'kind':'node'},'stage']
        elif task['name']=='missing-flat-lowering':
            assert 'Undefined subroutine' in row['native']['last_error']['detail']
            assert '::flat_array called' in row['native']['last_error']['detail']
        else:
            assert row['native']['last_error']['stage']=='rule_handler_compile'
            assert 'syntax error' in row['generated_fatal']['exception']['text']
        if task['name']!='raw-hash-key':
            assert oracle.failures(run,task['plan'])
        restored=execute(task['plan'])
        assert not oracle.failures(restored,task['plan'])
        if task['name']=='raw-hash-key':
            oracle.diagnostics(restored,c.load('red-run.json.gz')['run'])
        assert c.read(c.SOURCE)==original and c.unchanged(snapshot['inputs'])
        c.write_new('fault-'+task['name']+'.json.gz',dict(run=run,restored=restored,
            source_restored=True,inputs_restored=True,scope='Actual producer fault, observed mechanism-specific RED and fresh restored GREEN.'))
        results.append(task['name'])
        print('Actual drop-producer RED restored:',task['name'],flush=True)
    c.write_new('source-fault-review.json.gz',dict(result='PASS',faults=results,source_restored=True))


if __name__=='__main__':main()
