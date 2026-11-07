"""Finite documented Hash-valued helper composition candidates; no verdict."""
import json
from pathlib import Path
base=Path(__file__).resolve().parent;rows=[]
def add(identifier,body,**fields):
 rows.append(dict(id=identifier,body=body,source='Value:: I {'+body+'}\n',input='x',rule='Value',**fields))
methods=[
 ('merge_hash','merge_hash({"a":1},{"b":2})','{"a":1}.merge_hash({"b":2})',2,'a,b'),
 ('set_key','set_key({"a":1},"b",2)','{"a":1}.set_key("b",2)',2,'a,b'),
 ('rename_key','rename_key({"a":1},"a","b")','{"a":1}.rename_key("a","b")',1,'b'),
 ('drop_keys','drop_keys({"a":1,"b":2},"a")','{"a":1,"b":2}.drop_keys("a")',1,'b'),
 ('pick_keys','pick_keys({"a":1,"b":2},"b")','{"a":1,"b":2}.pick_keys("b")',1,'b'),
]
for method,free,receiver,count,csv in methods:
 add(method+'_compatible','return(['+free+'.count_keys(),'+receiver+'.sorted_keys().join_values(",")])',expected=[count,csv])
 for form,source in [('free',free),('receiver',receiver)]:
  add(method+'_'+form+'_array_guard','order="";out='+source+'.take({order=cat(order,"A");1});return([out,order])',expected=[None,''])
add('merge_later_with','order="";out=merge_hash({"a":1},{"b":2}).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])',expected=[None,''])
add('set_copy_later_with','order="";out=set_key({"a":1},"b",2).take({order=cat(order,"A");1}).copy().with(){order=cat(order,"W");return("ran")};return([out,order])',expected=[None,''])
add('rename_logical_later_with','order="";out=rename_key({"a":1},"a","b").take({order=cat(order,"A");1}).and({order=cat(order,"D");true}).with(){order=cat(order,"W");return("ran")};return([out,order])',expected=[None,''])
add('explicit_bridges','return([pick_keys({"b":"tail","a":"head"},"b").sorted_values().last().uppercase(),drop_keys({"a":1,"b":2},"a").with(){return([value.count_keys(),"tail"])}.last().uppercase()])',expected=['TAIL','TAIL'])
add('nested_kinds_and_source','meta={"off":false,"nil":undef,"nested":{"n":[7]}};out=set_key(meta,"new",[false,0]);return([out["off"],out["nil"],out["nested"]["n"][-1].add(1),has_key(meta,"new"),out["new"][0]])',expected=[False,None,8,0,False])
add('variadic_key_preservation','meta={"a":0,"b":false,"c":undef};a=drop_keys(meta,"a","b");b=pick_keys(meta,"c","b");return([a,b,meta])',expected=[{'c':None},{'b':False,'c':None},{'a':0,'b':False,'c':None}])
add('source_once_snapshot','order="";meta={"a":1};out=merge_hash({order=cat(order,"S");meta},{order=cat(order,"A");meta={"z":2};{"b":3}});return([out,count_keys(meta),order])',expected=[{'a':1,'b':3},1,'SA'])
add('empty_pick_with','order="";out=pick_keys({"a":1},"missing").with(){order=cat(order,"W");return(value.count_keys())};return([out,order])',expected=[0,'W'])
source_error='merge_hash({items="text";push(items,"x");{"a":1}},{"b":2})'
value_error='set_key({"a":1},"b",{items="text";push(items,"x");2})'
for kind,expression in [('source',source_error),('value',value_error)]:
 for suffix,consumer in [('terminal',''),('composed','.take(1).coalesce("masked")')]:
  add('needed_'+kind+'_error_'+suffix,'return('+expression+consumer+')',expected_error='binding_kind_mismatch')
for helper in ('drop_keys','pick_keys'):
 for form,expression in [('free',helper+'({"a":1})'),('receiver','{"a":1}.'+helper+'()')]:
  add(helper+'_'+form+'_zero_keys_profile','return('+expression+')',profile_only=True)
add('constructor_hash_guard','order="";out=hash("a",1).take({order=cat(order,"A");1}).with(){order=cat(order,"W");return("ran")};return([out,order])',expected=[None,''])
assert len(rows)==32 and len({r['id'] for r in rows})==32
(base/'cases.json').write_text(json.dumps(rows,indent=2)+'\n')
print('32 finite full-source candidate/preservation programs authored; no runtime or peer verdict')
