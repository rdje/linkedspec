"""Eight necessary final-source faults, with actual observations and exact restoration."""
import json
from pathlib import Path
import common as c
import oracle

def loaded(run,path,packet):
    assert run['returncode']==0 and not c.decode(run['stderr_base64'])
    values=json.loads(c.decode(run['stdout_base64']))
    assert Path(values['inc'][path.removeprefix('perl/')]).resolve()==c.ROOT/path
    assert c.read(path)==packet

def main():
    emitter,runtime=c.SOURCES
    edits=c.load('implementation.json.gz')['replacements']
    refinement=c.load('refinement.json.gz')['replacements']
    compiled_guard=c.load('compatibility-repair.json.gz')
    tasks=[
      ('composition-bridge',emitter,refinement[2][1],refinement[2][0],'ordinary/effect/length'),
      ('array-length',emitter,edits[1][2],edits[1][1],'ordinary/length/chain'),
      ('compiled-length-shape',emitter,compiled_guard['new']+'\n','',
        'ordinary/effect/length-arity'),
      ('registered-sort-shape',emitter,"   return 'undef' if $method eq 'sorted' && @$aggregate_args;\n",'',
        'deferred/function/invalid-sort'),
      ('registered-take-shape',emitter,"   return 'undef' if $method eq 'take' && @$aggregate_args > 1;\n",'',
        'deferred/function/invalid-take'),
      ('deferred-length-shape',runtime,edits[3][2],edits[3][1],'deferred/effect/length-arity'),
      ('deferred-length-terminal',runtime,edits[3][2],
        "  if ($method eq 'length') {\n   return undef if @$args;\n  }\n"+edits[3][1],
        'deferred/effect/direct-terminal'),
    ]
    tasks.append(('existing-selector-shape',emitter,compiled_guard['new'],compiled_guard['old'],
        ['ordinary/count/effects/receiver/extra','ordinary/first/effects/receiver/extra']))
    saved={p:c.read(p) for p in c.SOURCES}
    plan=dict(cases=c.load('cases.json')['cases']+c.load('compatibility-cases.json')['cases'])
    for name,path,old,new,case_id in tasks:
        assert c.decode(saved[path]['base64']).decode().count(old)==1,name
        ids=case_id if isinstance(case_id,list) else [case_id]
        assert sum(case['id'] in ids for case in plan['cases'])==len(ids),case_id
    c.write_new('faults3-before.json.gz',dict(sources=saved,tasks=tasks,producer=c.read(c.PREFIX+'faults3.py')))
    result=[]
    for name,path,old,new,case_id in tasks:
        ids=case_id if isinstance(case_id,list) else [case_id]
        selected=dict(cases=[case for case in plan['cases'] if case['id'] in ids])
        try:
            c.source(path).write_text(c.decode(saved[path]['base64']).decode().replace(old,new,1))
            mutant=c.read(path)
            context=c.epoch()
            run=c.observe(selected)
            failures=oracle.failures(run,selected)
            c.write_new('fault3-'+name+'.json.gz',dict(plan=selected,context=context,mutant=mutant,run=run,failures=failures))
            loaded(run,path,mutant)
        finally:
            c.source(path).write_bytes(c.decode(saved[path]['base64']))
        restored=c.observe(selected)
        restored_failures=oracle.failures(restored,selected)
        exact=all(c.read(p)==packet for p,packet in saved.items())
        c.write_new('restore3-'+name+'.json.gz',dict(plan=selected,run=restored,failures=restored_failures,sources_restored=exact))
        loaded(restored,path,saved[path])
        assert failures and set(failures)==set(ids),name
        assert exact and not restored_failures,name
        result.append(name)
        print(name,'actual RED / exact restoration GREEN',flush=True)
    c.write_new('faults3-result.json',dict(faults=result,sources_restored=True))

if __name__=='__main__':main()
