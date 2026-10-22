"""Determine whether preliminary name/shape edits are necessary; no assumed RED."""
import common as c
import oracle

def main():
    path=c.SOURCES[0]
    saved=c.read(path)
    original=c.decode(saved['base64']).decode()
    implementation=c.load('implementation.json.gz')['replacements']
    refinement=c.load('refinement.json.gz')['replacements']
    name_block="  # Keep function-owned names in DSL form until the aggregate lowerer reads\n  # their scalar-backed typed value; reparsing $name loses that binding.\n  $current_expr = $receiver->{name}\n   if ($receiver->{kind} // '') eq 'variable'\n   && _user_function_scalar_value_name($deps, $receiver->{name});\n"
    skip="   && !_user_function_scalar_value_name($deps, $receiver->{name})\n"
    removed=[name_block,skip]
    shapes=["   return 'undef' if $method eq 'sorted' && @$aggregate_args;\n",
        "   return 'undef' if $method eq 'take' && @$aggregate_args > 1;\n"]
    plan=c.load('cases.json')
    tasks=[('names',removed,['ordinary/function/numbers','deferred/function/numbers',
        'ordinary/function/local','deferred/function/rest','ordinary/function/nested','deferred/function/harray']),
        ('names-and-shapes',removed+shapes,['ordinary/function/numbers','deferred/function/numbers',
        'ordinary/function/invalid-sort','deferred/function/invalid-sort','ordinary/function/invalid-take','deferred/function/invalid-take'])]
    for _,pieces,_ in tasks:
        assert all(original.count(piece)==1 for piece in pieces)
    c.write_new('ablation-before.json.gz',dict(source=saved,tasks=tasks,producer=c.read(c.PREFIX+'ablate.py')))
    summary={}
    for name,pieces,ids in tasks:
        mutant=original
        for piece in pieces:mutant=mutant.replace(piece,'',1)
        selected=dict(cases=[case for case in plan['cases'] if case['id'] in ids])
        assert len(selected['cases'])==len(ids)
        try:
            c.source(path).write_text(mutant)
            run=c.observe(selected)
            failures=oracle.failures(run,selected)
            c.write_new('ablation-'+name+'.json.gz',dict(source=c.read(path),plan=selected,run=run,failures=failures))
        finally:
            c.source(path).write_bytes(c.decode(saved['base64']))
        assert c.read(path)==saved
        summary[name]=dict(failures=failures,sources_restored=True)
        print(name, 'failures:',len(failures),flush=True)
    c.write_new('ablation-result.json',summary)

if __name__=='__main__':main()
