"""Project the frozen targets into executable Dart source, independently of its AST."""
import copy
import json
import re
from pathlib import Path
import common as c

AUTHORITY='capability_conformance/signed_array_selector_contract.json'
DESTINATION='tests/signed-array-dart/cases.json'


def literal(value):
    if value is None:return 'undef'
    if isinstance(value,bool):return 'true' if value else 'false'
    if isinstance(value,(int,float)):return str(value)
    if isinstance(value,str):return json.dumps(value,ensure_ascii=False)
    if isinstance(value,list):return '['+','.join(map(literal,value))+']'
    if isinstance(value,dict):
        return '{'+','.join(literal(key)+':'+literal(item) for key,item in value.items())+'}'
    raise AssertionError(type(value))


def source(body):return 'Top::\n /x/\n E { '+body+' }\n'


def wrap(body,context):
    if context=='ordinary':return body,0
    assert context=='callable'
    prefix='cb={|| '
    return prefix+body+' }; return(cb())',len(prefix)


def initial(row):
    binding=row['initial_binding']
    return ([row['binding']+'='+literal(binding['value'])] if binding['present'] else [])


def read_case(row,context):
    setup=initial(row)
    for segment in row['segments']:
        name=segment['source']
        if re.fullmatch('[A-Za-z_][A-Za-z_0-9]*',name):
            setup.append(name+'='+literal(segment['value']))
    setup+=['observed='+row['source'],'return(['+row['binding']+',observed])']
    body,_=wrap('; '.join(setup),context)
    return dict(id='read/'+row['id']+'/'+context,kind='read',neutral_id=row['id'],
        context=context,source=source(body),body=body,effects=[],
        expected=dict(ok=[row['expected_binding'].get('value'),row['expected_result']]))


def operand(part,marker,binding,setup):
    failure=part.get('evaluation_error')
    name=part['source']
    if failure:
        expression='undef'
    elif re.fullmatch('[A-Za-z_][A-Za-z_0-9]*',name) and name not in ('true','false','null','undef'):
        setup.append(name+'='+literal(part['value']));expression=name
    else:
        expression=literal(part['value'])
    statements=['say('+literal(marker)+')']
    if 'same_binding_after' in part:
        statements.append(binding+'='+literal(part['same_binding_after']))
    statements.append(expression)
    return '{ '+ '; '.join(statements)+' }',failure


def write_case(row,context,padding=''):
    binding=row['binding'];setup=initial(row)
    if padding:setup.insert(0,padding)
    expressions=[];injection=None
    for index,part in enumerate(row['segments']):
        marker='segment:'+str(index)
        expression,failure=operand(part,marker,binding,setup)
        expressions.append(expression)
        if failure:injection=dict(marker=marker,**failure)
    rhs,failure=operand(row['rhs'],'rhs',binding,setup)
    if failure:injection=dict(marker='rhs',**failure)
    path=binding;spans=[]
    for expression in expressions:
        path+='[';start=len(path);path+=expression
        spans.append(dict(start=start,end=len(path)));path+=']'
    assignment=path+' = '+rhs
    expected=row['expected'];error=copy.deepcopy(expected['error'])
    prefix='; '.join(setup)+'; ' if setup else ''
    guard=row.get('guard')
    if guard and guard['active_identity']==guard['target_identity']:
        prefix+=binding+'.map_leaves!() { '
        body=prefix+assignment+' }; return(undef)'
        assignment_start=len(prefix)
    elif guard:
        prefix+='worker={|'+binding+'| '
        body=(prefix+assignment+'; return('+binding+') }; '
            'outer='+binding+'.map_leaves!() { return(worker([value])) }; '
            'return([outer[0],outer[0]])')
        assignment_start=len(prefix)
    elif error is None:
        prefix+='updated = ('
        body=prefix+assignment+'); return(['+binding+',updated])'
        assignment_start=len(prefix)
    else:
        body=prefix+assignment+'; return(undef)'
        assignment_start=len(prefix)
    body,offset=wrap(body,context)
    if error and 'source_span' in error:
        if error['code']=='receiver_mutation_reentrant':
            start=assignment_start+offset;end=start+len(binding)
        else:
            span=spans[error['segment_index']]
            start=assignment_start+offset+span['start'];end=assignment_start+offset+span['end']
        error['source_span']=dict(start=start,end=end,unit='unicode_scalar',provenance='authored')
    result=dict(id='write/'+row['id']+'/'+context,kind='write',neutral_id=row['id'],
        context=context,source=source(body),body=body,effects=expected['effects'],
        expected=dict(error=error) if error else dict(ok=[expected['binding']['value'],expected['result']]),
        private_expected=expected,
        geometry='Constructed Unicode-scalar offsets in the authored action source; no backend AST supplies the target.')
    if injection:result['injection']=injection
    return result


def extended_case(identifier,initial_value,values,code,segment_index,path,*,actual_kind=None,reason=None):
    expressions=[literal(value) for value in values]
    text='tree';spans=[]
    for expression in expressions:
        text+='[';start=len(text);text+=expression
        spans.append(dict(start=start,end=len(text)));text+=']'
    text+=' = 99'
    error=dict(code=code,operation='nested_write_vivification',binding='tree',
        segment_index=segment_index,path=path)
    if code=='nested_write_segment_invalid':
        error.update(actual_kind=actual_kind,reason=reason,
            message=f"nested write segment {segment_index} for binding 'tree' must evaluate to a string or nonnegative integer; got {actual_kind} ({reason})")
    else:raise AssertionError(code)
    error['source_span']=dict(source_id='contract:'+identifier,**spans[segment_index],
        unit='unicode_scalar',provenance='authored')
    return dict(id=identifier,binding='tree',initial_binding=dict(present=True,value=initial_value),
        segments=[dict(source=expression,kind='string' if isinstance(value,str) else 'integer' if type(value) is int else 'boolean',value=value)
            for expression,value in zip(expressions,values)],rhs=dict(source='99',value=99),
        guard=None,source=text,expected=dict(binding=dict(present=True,value=initial_value),result=None,
            error=error,effects=['segment:'+str(index) for index in range(len(values))]+['rhs']))


def main():
    contract=json.loads(c.file(AUTHORITY).read_bytes())
    examples={
        'examples/negative-array-current-perl.spec':[30,[10,20,30]],
        'examples/negative-array-current-callable-perl.spec':[30,[10,20,30]],
        'examples/negative-array-write-perl.spec':[30,[10,99,30]],
        'examples/negative-array-write-callable-perl.spec':{'rows':[[1],[99,3]]},
    }
    c.save('fixture-inputs.json.gz',dict(authority=c.read(AUTHORITY),
        producer=c.read(c.PREFIX+'fixtures.py'),helper=c.read(c.PREFIX+'common.py'),
        examples={path:c.read(path) for path in examples},
        scope='Frozen14 reads/33 writes remain unchanged. Source projection uses '
            'ordinary effect blocks and caller-owned sink failures, with independent '
            'authored Unicode geometry. Private binding targets are retained separately; '
            'a public exception does not expose post-failure stores.'))
    cases=[]
    for context in ['ordinary','callable']:
        cases += [read_case(row,context) for row in contract['read_cases']]
        cases += [write_case(row,context) for row in contract['write_cases']]
    extended=[
        extended_case('partial_creation_then_negative',{},['new',0,-1],
            'nested_write_segment_invalid',2,['new',0],actual_kind='integer',reason='negative_integer'),
        extended_case('negative_prefix_then_creation',[{}],[-1,'new',0,-2],
            'nested_write_segment_invalid',3,[-1,'new',0],actual_kind='integer',reason='negative_integer'),
        extended_case('invalid_after_negative_wrong_root','scalar',[-1,True],
            'nested_write_segment_invalid',1,[-1],actual_kind='boolean',reason='kind_not_path_selector'),
    ]
    for context in ['ordinary','callable']:
        cases += [write_case(row,context) for row in extended]
        unicode=next(row for row in contract['write_cases'] if row['id']=='unicode_span')
        case=write_case(unicode,context,'pad="🧭"')
        case.update(id='write/astral_prefix/'+context,neutral_id='unicode_span+astral_prefix')
        cases.append(case)
    for path,expected in examples.items():
        cases.append(dict(id='book/'+Path(path).stem,kind='book',source=c.file(path).read_text(),
            expected=dict(ok=expected),effects=[]))
    functions=[
        ('read', 'fn tail(items) { return(items[-2]) }',
         'return(tail([10,20,30]))',20),
        ('write','fn update(items) { items[-1]=99; return(items) }',
         'initial=[10,20,30]; updated=update(initial); return([initial,updated])',[[10,20,30],[10,20,99]]),
        ('nested','fn update(items) { items[-1][-2]=99; return(items) }',
         'return(update([[1],[2,3]]))',[[1],[99,3]]),
    ]
    for name,definition,body,expected in functions:
        cases.append(dict(id='function/'+name,kind='function',source=definition+'\n\n'+source(body),
            expected=dict(ok=expected),effects=[]))
    controls=[
        ('read-coercions','items=[10,20,30]; return([items[-1.0],items[-1.5],items["-1"],items[true],items[-0.0]])',[None,None,None,None,10]),
        ('map-coercion','tree={"-1":"key"}; return([tree[-1],tree["-1"]])',['key','key']),
        ('retained-read-receiver','tree=[10,20]; got=tree[{ tree=[30,40,50]; -1 }]; return([got,tree])',[20,[30,40,50]]),
        ('detached-copy','original=[{"keep":[1]}]; tree=original; payload=[2]; updated=(tree[-1]["new"]=payload); original[0]["keep"][0]=11; payload[0]=22; tree[-1]["new"][0]=33; updated[-1]["keep"][0]=44; return([original,payload,tree,updated])',
         [[{'keep':[11]}],[22],[{'keep':[1],'new':[33]}],[{'keep':[44],'new':[2]}]]),
    ]
    for name,body,expected in controls:
        cases.append(dict(id='control/'+name,kind='control',source=source(body),
            expected=dict(ok=expected),effects=[]))
    assert len(cases)==113 and len({row['id'] for row in cases})==len(cases)
    result=dict(version=1,owner=c.OWNER,authority=AUTHORITY,authority_sha256=c.identity(AUTHORITY)['sha256'],
        cases=cases,private_extended=extended,
        limits='Native/spec/validated-engine paths compare declared typed fields; the '
            'existing public generated wrapper exposes generic metadata/detail. '
            'Public failures do not establish post-failure binding state; private '
            'boundary observation is separate. No portable admission or numeric-range expansion.')
    path=c.ROOT/DESTINATION;path.parent.mkdir(parents=True,exist_ok=True)
    assert not path.exists()
    path.write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    c.save('fixture-result.json.gz',dict(file=c.read(DESTINATION),programs=len(cases),
        frozen_reads=len(contract['read_cases']),frozen_writes=len(contract['write_cases']),
        private_extended=len(extended)))
    print('Dart public fixture:',len(cases),'programs; frozen14/33, extra boundary/control/function/book cases.')


if __name__=='__main__':main()
