"""Author finite existing-contract Array transform candidates, no defect verdict."""
import json
from pathlib import Path
BASE=Path(__file__).resolve().parent
cases=[]
def add(identifier,body,expected=None,error=None):
    row=dict(id=identifier,body=body,source='Value:: I {'+body+'}\n',input='x',rule='Value')
    if error is not None:row['expected_error']=error
    else:row['expected']=expected
    cases.append(row)
roles=[
    ('take','take(["head","tail"],1)','["head","tail"].take(1)',['head']),
    ('take_last','take_last(["head","tail"],1)','["head","tail"].take_last(1)',['tail']),
    ('drop_front','drop_front(["head","tail"],1)','["head","tail"].drop_front(1)',['tail']),
    ('drop_back','drop_back(["head","tail"],1)','["head","tail"].drop_back(1)',['head']),
    ('slice','slice(["head","tail"],1,1)','["head","tail"].slice(1,1)',['tail']),
    ('sorted','sorted(["tail","head"])','["tail","head"].sorted()',['head','tail']),
    ('reversed','reversed(["head","tail"])','["head","tail"].reversed()',['tail','head']),
    ('concat_arrays','concat_arrays(["head"],["tail"])','["head"].concat_arrays(["tail"])',['head','tail']),
]
consumer='.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1})'
for name,free,receiver,result in roles:
    add(name+'_compatible','return(['+free+','+receiver+'])',[result,result])
    for form,expression in (('free',free),('receiver',receiver)):
        add(name+'_'+form+'_hash_guard','order="";out='+expression+consumer+';return([out,order])',[None,''])
for identifier,expression,tail in (
    ('take_later_with','take(["tail"],1)','.with(){order=cat(order,"W");return("ran")}'),
    ('reverse_copy_later_with','reversed(["tail"])','.copy().with(){order=cat(order,"W");return("ran")}'),
    ('sort_logical_later_with','sorted(["tail"])','.and({order=cat(order,"D");true}).with(){order=cat(order,"W");return("ran")}'),
):add(identifier,'order="";out='+expression+consumer+tail+';return([out,order])',[None,''])
add('explicit_selected_bridges','return([take(["head","tail"],1).last().uppercase(),reversed([{"k":"tail"}]).last().pick_keys("k").count_keys(),sorted(["b","a"]).join_values(",")])',['HEAD',1,'a,b'])
add('nested_kinds_and_source','items=[false,0,undef,{"k":"tail"}];out=reversed(items);return([out,items])',[[{'k':'tail'},None,0,False],[False,0,None,{'k':'tail'}]])
add('source_once','order="";out=take({order=cat(order,"S");["head","tail"]},1).last().uppercase();return([out,order])',['HEAD','S'])
add('source_snapshot','items=["head","tail"];out=take(items,{items=["changed"];1});return([out,items])',[['head'],['changed']])
add('valid_empty_with','order="";out=take(["tail"],0).with(){order=cat(order,"W");return(value.count())};return([out,order])',[0,'W'])
for identifier,expression in (
    ('needed_source_error','take({items="bad";items+=1;["tail"]},1)'),
    ('needed_count_error','take(["tail"],{items="bad";items+=1;1})'),
):
    add(identifier+'_terminal','return('+expression+')',error='binding_kind_mismatch')
    add(identifier+'_composed','order="";return('+expression+consumer+'.coalesce("masked"))',error='binding_kind_mismatch')
add('constructor_array_guard','order="";out=array("head","tail")'+consumer+'.with(){order=cat(order,"W");return("ran")};return([out,order])',[None,''])
assert len(cases)==len({row['id'] for row in cases})==37
out=BASE/'cases.json';assert not out.exists();out.write_text(json.dumps(cases,indent=2)+'\n')
print('37 finite source/target programs authored; no runtime verdict')
