"""Prepare distinct final instruments without rewriting any observed producer epoch."""
import ast
import common as c

def replace(text,old,new):
    assert text.count(old)==1,(old,text.count(old))
    return text.replace(old,new,1)

def main():
    files={}
    text=c.source(c.PREFIX+'focused.py').read_text()
    for old,new in [('focused-inputs.json.gz','focused2-inputs.json.gz'),('focused-run.json.gz','focused2-run.json.gz'),("c.PREFIX+'focused.py'","c.PREFIX+'focused2.py'")]:
        text=replace(text,old,new)
    files['focused2.py']=text
    text=c.source(c.PREFIX+'faults2.py').read_text()
    text=replace(text,"    tasks=[","    compiled_guard=c.load('compatibility-repair.json.gz')\n    tasks=[")
    old="      ('compiled-length-shape',emitter,\"   return 'undef' if $method eq 'length' && (@$aggregate_args || $index < $#$calls);\\n\",'',"
    text=replace(text,old,"      ('compiled-length-shape',emitter,compiled_guard['new']+'\\n','',")
    text=replace(text,"    saved={p:c.read(p) for p in c.SOURCES}","    tasks.append(('existing-selector-shape',emitter,compiled_guard['new'],compiled_guard['old'],\n        ['ordinary/count/effects/receiver/extra','ordinary/first/effects/receiver/extra']))\n    saved={p:c.read(p) for p in c.SOURCES}")
    text=replace(text,"    plan=c.load('cases.json')","    plan=dict(cases=c.load('cases.json')['cases']+c.load('compatibility-cases.json')['cases'])")
    text=replace(text,"        assert sum(case['id']==case_id for case in plan['cases'])==1,case_id","        ids=case_id if isinstance(case_id,list) else [case_id]\n        assert sum(case['id'] in ids for case in plan['cases'])==len(ids),case_id")
    text=replace(text,"        selected=dict(cases=[case for case in plan['cases'] if case['id']==case_id])","        ids=case_id if isinstance(case_id,list) else [case_id]\n        selected=dict(cases=[case for case in plan['cases'] if case['id'] in ids])")
    text=replace(text,"        assert failures and set(failures)=={case_id},name","        assert failures and set(failures)==set(ids),name")
    for old,new in [('faults2-before','faults3-before'),('faults2-result','faults3-result'),('fault2-','fault3-'),('restore2-','restore3-'),("c.PREFIX+'faults2.py'","c.PREFIX+'faults3.py'")]:
        text=replace(text,old,new)
    text=text.replace('Seven necessary final-source faults','Eight necessary final-source faults',1)
    files['faults3.py']=text
    text=c.source(c.PREFIX+'review.py').read_text()
    text=replace(text,'import focused\n','import focused2 as focused\n')
    for old,new in [('candidate3.json.gz','candidate4.json.gz'),('focused-run.json.gz','focused2-run.json.gz'),('focused-inputs.json.gz','focused2-inputs.json.gz'),("c.PREFIX+'focused.py'","c.PREFIX+'focused2.py'"),('book2-run.json.gz','book3-run.json.gz'),('faults2-result','faults3-result'),('faults2-before','faults3-before'),('fault2-','fault3-'),('restore2-','restore3-'),('artifact-run.json.gz','artifact2-run.json.gz'),('artifact-inputs.json.gz','artifact2-inputs.json.gz'),("c.PREFIX+'publish.py'","c.PREFIX+'publish2.py'"),('import publish\n','import publish2 as publish\n')]:
        text=replace(text,old,new)
    text=replace(text,"    assert c.read(c.SOURCES[0])==minimal['after']","    repair=c.load('compatibility-repair.json.gz')\n    assert minimal['after']==repair['before']\n    assert c.read(c.SOURCES[0])==repair['after']")
    text=replace(text,"set(failed)=={case_id}","set(failed)==set(case_id if isinstance(case_id,list) else [case_id])")
    marker="    supplied=c.load('book-inputs.json.gz')"
    extra="""    compatibility_plan=c.load('compatibility-cases.json')
    regression=c.load('compatibility-red.json.gz')
    assert c.read('tests/numeric-codeblocks/count-first.json')==regression['fixture']
    assert len(oracle.failures(regression['run'],compatibility_plan))==2
    prior=c.load('compatibility-prior-bridge.json.gz')
    assert not oracle.failures(prior['run'],compatibility_plan)
    reapplied=c.load('compatibility-reapplied.json.gz')
    assert reapplied['sources_restored'] and reapplied['source']==repair['before']
    assert oracle.failures(reapplied['run'],compatibility_plan)==regression['failures']
    assert not candidate['compatibility_failures']
    assert not oracle.failures(candidate['compatibility'],compatibility_plan)
    failed_direct=c.load('focused-run.json.gz')['run']
    assert failed_direct['returncode']!=0
    failed_log=c.decode(failed_direct['stderr_base64'])
    for method in ('count','first'):
        assert ('ordinary/'+method+'/effects/receiver/extra').encode() in failed_log
"""
    text=replace(text,marker,extra+marker)
    text=replace(text,"    runtime_inputs(final_book)","    runtime_inputs(final_book)\n    assert not final_book['inline_failures']\n    assert not oracle.failures(final_book['inline'],final_book['inline_plan'])")
    text=replace(text,"        faults=controls['faults']","        compatibility_controls=len(compatibility_plan['cases']),inline_examples=len(final_book['inline_plan']['cases']),faults=controls['faults']")
    files['review2.py']=text
    text=c.source(c.PREFIX+'publish.py').read_text()
    for old,new in [('publication-inputs.json.gz','publication2-inputs.json.gz'),('publication.json','publication2.json'),('artifact-inputs.json.gz','artifact2-inputs.json.gz'),("c.PREFIX+'publish.py'","c.PREFIX+'publish2.py'"),('import review\n','import review2 as review\n')]:
        expected=3 if old in ('publication-inputs.json.gz','publication.json') else 1
        assert text.count(old)==expected,(old,text.count(old))
        text=text.replace(old,new)
    text=replace(text,"{result['artifact_denials']} actual artifact denials.","{result['artifact_denials']} actual artifact denials;{result['compatibility_controls']} unchanged selector controls;{result['inline_examples']} exact inline routes.")
    text=replace(text,'Compiled and deferred length reject invalid receiver arity/continuations before effects.','Compiled and deferred length reject invalid receiver arity/continuations before effects; existing count/first receiver shapes remain protected.')
    text=replace(text,'Actual ablation identifies redundant preliminary name edits and required shape guards.','Actual ablation identifies redundant preliminary name edits and required shape guards. A single bridge rollback/reapply attributes the two original-selector regressions; untouched old fixture oracles govern their repair.')
    text=replace(text,'deferred length arity/terminal faults reject and restore.','deferred length arity/terminal and existing selector-shape faults reject and restore.')
    files['publish2.py']=text
    text=c.source(c.PREFIX+'artifacts.py').read_text()
    for old,new in [("c.PREFIX+'publish.py'","c.PREFIX+'publish2.py'"),('artifact-inputs.json.gz','artifact2-inputs.json.gz'),('artifact-run.json.gz','artifact2-run.json.gz'),("c.PREFIX+'artifacts.py'","c.PREFIX+'artifacts2.py'")]:
        text=replace(text,old,new)
    files['artifacts2.py']=text
    for name,text in files.items():
        assert not (c.ROOT/(c.PREFIX+name)).exists(),name
        ast.parse(text,filename=name)
    for name,text in files.items():
        with (c.ROOT/(c.PREFIX+name)).open('x') as stream:stream.write(text)
    c.write_new('final-instruments.json.gz',dict(producer=c.read(c.PREFIX+'prepare_final2.py'),files={n:c.read(c.PREFIX+n) for n in files}))
    print('Distinct final instruments prepared:',', '.join(files))

if __name__=='__main__':main()
