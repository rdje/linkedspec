"""Install distinguishing runtime faults, observe RED, restore exact bytes/modes."""
import json
import common as c
import context
import oracle

def main():
    plan=c.load('cases3.json')
    tasks=[
      ('call-dispatch','deferred/sorted/free'," if ($name eq 'sorted' || $name eq 'take') {"," if (0 && ($name eq 'sorted' || $name eq 'take')) {"),
      ('numeric-sort','deferred/sorted/free',"  return LinkedSpec::BindingRuntime::array_transform($value, '<value>', 'sorted')","  return [sort { $a <=> $b } @$value]"),
      ('default-two','deferred/take/default',"  my $count = @$args == 2 ? _eval_expr($args->[1], $ctx) : 1;","  my $count = @$args == 2 ? _eval_expr($args->[1], $ctx) : 2;"),
      ('eager-count','deferred/effect/nonarray-free',"  return [] unless ref($value) eq 'ARRAY';","  unless (ref($value) eq 'ARRAY') { _eval_expr($args->[1], $ctx) if @$args == 2; return [] }"),
      ('receiver-arity','deferred/effect/sorted-receiver-arity',"  return undef if $method eq 'sorted' && @$args;","  # Fault: accept surplus sorted operands."),
      ('source-mutation','deferred/sorted/copy',"  return LinkedSpec::BindingRuntime::array_transform($value, '<value>', 'sorted')","  @$value = sort { $a cmp $b } @$value; return $value"),
    ]
    source=c.read(c.SOURCE)
    extras=[p.relative_to(c.ROOT).as_posix() for p in (c.ROOT/c.PREFIX).rglob('*') if p.is_file() and '__pycache__' not in p.parts]
    saved=context.snapshot(extras)
    saved.update(source=source,tasks=tasks,producer=c.read(c.PREFIX+'faults.py'),new_inputs={p:c.read(p) for p in extras if not p.endswith(('.gz','.part'))})
    c.write_new('fault-inputs.json.gz',saved)
    outcomes=[]
    for name,case_id,before,after in tasks:
        text=c.decode(source['base64']).decode();assert text.count(before)==1
        mutant=text.replace(before,after,1).encode()
        selected=dict(cases=[case for case in plan['cases'] if case['id']==case_id])
        assert len(selected['cases'])==1
        try:
            (c.ROOT/c.SOURCE).write_bytes(mutant)
            run=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(selected).encode())
            red=oracle.failures(run,selected)
            c.write_new('fault-'+name+'-observed.json.gz',dict(plan=selected,mutant=c.read(c.SOURCE),run=run,failures=red))
        finally:
            (c.ROOT/c.SOURCE).write_bytes(c.decode(source['base64']))
            (c.ROOT/c.SOURCE).chmod(source['mode'])
        restored=c.run(['perl','-Iperl',c.PREFIX+'probe.pl'],input=json.dumps(selected).encode())
        c.write_new('fault-'+name+'.json.gz',dict(restored=restored,source_restored=c.read(c.SOURCE)==source))
        assert len(red)==1 and not oracle.failures(restored,selected) and c.read(c.SOURCE)==source
        outcomes.append(name)
        print(name,'RED/restored',flush=True)
    assert c.unchanged(saved['inputs'])
    c.write_new('fault-result.json',dict(faults=outcomes,inputs_restored=True))

if __name__=='__main__':main()
