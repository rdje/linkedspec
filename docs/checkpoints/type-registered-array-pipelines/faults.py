"""Install bounded actual source faults; preserve channels, then restore exactly."""
import json
from pathlib import Path
import common as c
import oracle

def loaded(run,path,packet):
    assert run['returncode']==0 and not c.decode(run['stderr_base64'])
    values=json.loads(c.decode(run['stdout_base64']))
    key=path.removeprefix('perl/')
    assert Path(values['inc'][key]).resolve()==c.ROOT/path
    assert c.read(path)==packet

def main():
    emitter,runtime=c.SOURCES
    implementation=c.load('implementation.json.gz')['replacements']
    refinement=c.load('refinement.json.gz')['replacements']
    tasks=[
      ('registered-name',emitter,
        '  $current_expr = $receiver->{name}\n   if ($receiver->{kind} // \'\') eq \'variable\'\n   && _user_function_scalar_value_name($deps, $receiver->{name});\n','',
        'ordinary/function/numbers'),
      ('composition-bridge',emitter,refinement[2][1],refinement[2][0],'ordinary/effect/length'),
      ('array-length',emitter,implementation[1][2],implementation[1][1],'ordinary/length/chain'),
      ('compiled-length-shape',emitter,"   return 'undef' if $method eq 'length' && (@$aggregate_args || $index < $#$calls);\n",'',
        'ordinary/effect/length-arity'),
      ('registered-sort-shape',emitter,"   return 'undef' if $method eq 'sorted' && @$aggregate_args;\n",'',
        'deferred/function/invalid-sort'),
      ('registered-take-shape',emitter,"   return 'undef' if $method eq 'take' && @$aggregate_args > 1;\n",'',
        'deferred/function/invalid-take'),
      ('deferred-length-shape',runtime,implementation[3][2],implementation[3][1],'deferred/effect/length-arity'),
      ('deferred-length-terminal',runtime,implementation[3][2],
        "  if ($method eq 'length') {\n   return undef if @$args;\n  }\n"+implementation[3][1],
        'deferred/effect/direct-terminal'),
    ]
    saved={p:c.read(p) for p in c.SOURCES}
    plan=c.load('cases.json')
    for name,path,old,new,case_id in tasks:
        assert c.decode(saved[path]['base64']).decode().count(old)==1,name
        assert sum(case['id']==case_id for case in plan['cases'])==1,case_id
    c.write_new('faults-before.json.gz',dict(sources=saved,tasks=tasks,producer=c.read(c.PREFIX+'faults.py')))
    result=[]
    for name,path,old,new,case_id in tasks:
        selected=dict(cases=[case for case in plan['cases'] if case['id']==case_id])
        try:
            c.source(path).write_text(c.decode(saved[path]['base64']).decode().replace(old,new,1))
            mutant=c.read(path)
            context=c.epoch()
            run=c.observe(selected)
            failures=oracle.failures(run,selected)
            c.write_new('fault-'+name+'.json.gz',dict(plan=selected,context=context,mutant=mutant,run=run,failures=failures))
            loaded(run,path,mutant)
        finally:
            c.source(path).write_bytes(c.decode(saved[path]['base64']))
        restored=c.observe(selected)
        restored_failures=oracle.failures(restored,selected)
        exact=all(c.read(p)==packet for p,packet in saved.items())
        c.write_new('restore-'+name+'.json.gz',dict(plan=selected,run=restored,failures=restored_failures,sources_restored=exact))
        loaded(restored,path,saved[path])
        assert failures and set(failures)=={case_id},name
        assert exact and not restored_failures,name
        result.append(name)
        print(name,'actual RED / exact restoration GREEN',flush=True)
    c.write_new('faults-result.json',dict(faults=result,sources_restored=True))

if __name__=='__main__':main()
