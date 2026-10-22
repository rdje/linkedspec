"""Declare literal expectations and repair the observed preparer warning before runtime edits."""
import ast
import json
import re
import shutil
import sys
import warnings
import common as c
import context


def warning_control():
    path = c.PREFIX+'record_findings.py'
    before = c.read(path)
    assert before == c.load('findings-inputs.json.gz')['overrides'][path]
    text = c.decode(before['base64']).decode()
    marker = ',line,1)'
    assert text.count(marker) == 1
    repaired = text.replace(marker,',line,count=1)',1)
    row = next(line for line in c.source('docs/tasks/TYPE-REFERENCE-BOOK.md').read_text().splitlines()
        if line.startswith('| 8 |'))
    results = []
    for name,source in (('original',text),('keyword',repaired)):
        tree = ast.parse(source)
        nodes = [node for node in ast.walk(tree) if isinstance(node,ast.Assign)
            and isinstance(node.value,ast.Call) and isinstance(node.value.func,ast.Attribute)
            and isinstance(node.value.func.value,ast.Name) and node.value.func.value.id == 're'
            and node.value.func.attr == 'sub' and isinstance(node.targets[0],ast.Subscript)]
        assert len(nodes) == 1
        namespace = dict(re=re,lines=[row],index=0,order=8,line=row)
        with warnings.catch_warnings(record=True) as observed:
            warnings.simplefilter('always')
            exec(compile(ast.Module(body=nodes,type_ignores=[]),path,'exec'),namespace)
        results.append(dict(name=name,value=namespace['lines'][0],warnings=[dict(
            category=type(item.message).__name__,message=str(item.message),
            filename=item.filename,line=item.lineno) for item in observed]))
    assert results[0]['value'] == results[1]['value'] == row
    assert len(results[0]['warnings']) == 1
    assert results[0]['warnings'][0]['category'] == 'DeprecationWarning'
    assert "'count' is passed as positional argument" in results[0]['warnings'][0]['message']
    assert not results[1]['warnings']
    c.source(path).write_text(repaired)
    c.source(path).chmod(before['mode'])
    return dict(before=before,after=c.read(path),results=results,python=sys.version,
        scope='Actual executed original source survives in findings-inputs. Its row-renumbering statement reproduces the Python3.14 warning; the sole count= keyword correction preserves the exact row without warnings. The full one-shot writer is not rerun against already changed metadata.')


def fixed_plan():
    grid = c.load('contract-grid-cases.json')
    counts = {'integers':3,'strings':2,'null-first':2,'nested-array':2,
        'nested-harray':2,'booleans':2,'empty':0,'undefined':0,'number':0,'text':0,'harray':0}
    first = {'integers':2,'strings':'b','null-first':None,'nested-array':[2,1],
        'nested-harray':{'k':'v'},'booleans':True,'empty':None,'undefined':None,
        'number':None,'text':None,'harray':None}
    cases = []
    for case in grid['cases']:
        mode,helper,*parts = case['id'].split('/')
        if helper == 'sentinel':
            continue
        if len(parts) == 2 and parts[0] in ('free','receiver') and parts[1] in counts:
            expected = (counts if helper == 'count' else first)[parts[1]]
        elif parts[0] == 'effects':
            expected = [3 if helper == 'count' else 2,'r'] if parts[-1] == 'once' else [None,'']
        elif parts[0] == 'receiver' or parts[-1] in ('no-args','extra-arg'):
            expected = None
        else:
            expected = {'abs':3,'comparison':1,'cat':'2!','array-continuation':[1,10,2]}[parts[-1]]
        cases.append(dict(**case,expected=expected))
    def add(name,setup,expression,expected,mode='ordinary'):
        body = setup+' '
        if mode == 'deferred':
            body += 'cb = {|| return('+expression+') }; return(cb());'
        else:
            body += 'return('+expression+');'
        cases.append(dict(id=name,body=body,expected=expected))
    # Exact original pipeline failures, with literal lexical/count expectations.
    for case in c.load('baseline-observed.json.gz')['plan']['cases']:
        clean = {key:value for key,value in case.items() if key not in ('error','expected','id')}
        cases.append(dict(**clean,id='pipeline/'+case['id'],
            expected=2 if case['id'].endswith('/count') else 1))
    arrays = {'integers':'[2,10,1]','strings':'["b","a"]','null-first':'[undef,2]',
        'nested-array':'[[2,1],3]','nested-harray':'[{"k":"v"},3]',
        'booleans':'[true,false]','empty':'[]'}
    # Existing length and indexed-read paths are independent of the new helpers.
    for mode in ('ordinary','deferred'):
        for kind,source in arrays.items():
            for helper,expression,expected in (('count','length(items)',counts[kind]),
                    ('first','items[0]',first[kind])):
                add('proxy/'+mode+'/'+helper+'/'+kind,'items = '+source+';',expression,expected,mode)
        for style in ('free','receiver'):
            for name,source,expected in (('zero','0',0),('string-zero','"0"','0'),
                    ('empty-text','""',''),('false','false',False),('decimal','-1.5',-1.5)):
                expression = 'first(items)' if style == 'free' else 'items.first()'
                add('kind/'+mode+'/'+style+'/'+name,'items = ['+source+',9];',expression,expected,mode)
            for helper,expected in (('count',0),('first',None)):
                expression = helper+'(items)' if style == 'free' else 'items.'+helper+'()'
                add('harray-zero/'+mode+'/'+helper+'/'+style,
                    'items = {"0":"field"};',expression,expected,mode)
    supplement = c.load('supplement-cases.json')
    for case in supplement['cases']:
        if case['id'].startswith('registered/'):
            continue
        if case['id'].startswith('binding/'):
            expected = 3 if case['id'].endswith('/count') else 2
        elif case['id'].startswith('alias/'):
            expected = [[9,1],[[2,1],[]]]
        else:
            expected = 'picked'
        cases.append(dict(**{key:value for key,value in case.items() if key != 'id'},id='supplement/'+case['id'],expected=expected))
    for style in ('free','receiver'):
        for boundary in ('capture','parameter'):
            setup = 'items = [[2,1],[]]; '
            binding = 'items' if boundary == 'capture' else 'values'
            expression = 'first('+binding+')' if style == 'free' else binding+'.first()'
            setup += ('cb = {|| return('+expression+') }; chosen = cb(); ' if boundary == 'capture'
                else 'cb = {|values| return('+expression+') }; chosen = cb(items); ')
            body = setup+'chosen[0] = 9; return([chosen,items]);'
            cases.append(dict(id='alias/deferred/'+style+'/'+boundary,body=body,
                expected=[[9,1],[[2,1],[]]]))
        setup = 'maker = {|| return("picked") }; items = [maker]; '
        expression = 'first(items)' if style == 'free' else 'items.first()'
        body = setup+'cb = {|| return('+expression+') }; chosen = cb(); return(chosen());'
        cases.append(dict(id='callable/deferred/'+style,body=body,expected='picked'))
    # Return/argument containers retain selected scalar kinds after cloning.
    for mode in ('ordinary','deferred'):
        for style in ('free','receiver'):
            for kind,source,expected in (('number','[2,1]',2),('text','["2","1"]','2'),
                    ('boolean','[false,true]',False),('array','[[2,1],[]]',[2,1]),
                    ('harray','[{"k":"v"},{}]',{'k':'v'})):
                selected = 'first(items)' if style == 'free' else 'items.first()'
                setup = 'items = '+source+'; keep = {|value| return([value]) }; '
                add('copy/'+mode+'/'+style+'/'+kind,setup,'keep('+selected+')',[expected],mode)
    ids = [case['id'] for case in cases]
    assert len(ids) == len(set(ids))
    return dict(cases=cases,scope='Literal fixed typed values, arity/terminal/effect behavior, free harray guards, helper precedence, independent length/index controls and caller-visible copy/alias behavior. The original140-case observation grid, all14 supplements including four reserved-name source rejections, and separate last14 intake remain exact. No last,11/12 or backend admission.')


def main():
    for name in ('contract-grid','supplement'):
        assert c.load(name+'-result.json.gz')['inputs_unchanged']
    supplied = context.snapshot()
    c.write_new('preparation-inputs.json.gz',supplied)
    warning = warning_control()
    plan = fixed_plan()
    c.write_new('cases.json',plan)
    shutil.copy2(c.source('docs/checkpoints/type-sort-copy-kinds/oracle.py'),c.ROOT/c.PREFIX/'oracle.py')
    c.write_new('preparation.json.gz',dict(producer=c.read(c.PREFIX+'prepare.py'),
        warning_correction=warning,plan=c.read(c.PREFIX+'cases.json'),oracle=c.read(c.PREFIX+'oracle.py'),
        cases=len(plan['cases']),before_runtime={path:c.read(path) for path in c.SOURCES},
        before_tests={path:c.read(path) for path in ('t/scalar_numeric_contract.t','t/callable_codeblock_literal_contract.t')},
        scope='Fixed expectations precede runtime edits; values are authored literals, not copied observer output. Ordinary receiver/type controls define neutral nonarrays; actual accepted length/index routes independently constrain new helpers. The Python warning correction is source-closed and changes no helper or metadata result.'))
    print('Fixed count/first plan:',len(plan['cases']),'cases; original preparer warning RED / keyword GREEN retained')


if __name__ == '__main__':
    main()
