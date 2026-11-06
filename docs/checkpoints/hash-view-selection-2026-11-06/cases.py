"""Author the finite ordinary Hash-view Array-result selection controls."""
import json
from pathlib import Path

BASE = Path('docs/checkpoints/hash-view-selection-2026-11-06')
rows = []


def case(identifier, body, expected=None, **fields):
    row = dict(id=identifier, body=body, source='Value:: I {' + body + '}\n',
               input='x', rule='Value', **fields)
    if not fields.get('expected_error') and not fields.get('profile_only'):
        row['expected'] = expected
    rows.append(row)


case('keys_compatible', 'return([sorted_keys({"b":2,"a":1}).join_values(","),sorted_keys({}).count(),{"b":2,"a":1}.sorted_keys().last().uppercase()])', ['a,b', 0, 'B'])
case('values_compatible', 'return([sorted_values({"b":"tail","a":"head"}).last().uppercase(),sorted_values({}).count(),{"b":"tail","a":"head"}.sorted_values().join_values("|")])', ['TAIL', 0, 'head|tail'])
for helper in ('sorted_keys', 'sorted_values'):
    for form in ('free', 'receiver'):
        source = helper + '({"a":1})' if form == 'free' else '{"a":1}.' + helper + '()'
        case(form + '_' + helper + '_hash_guard', 'order="";out=' + source + '.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1});return([out,order])', [None, ''])
case('later_with', 'order="";out=sorted_keys({"a":1}).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).with(){order=cat(order,"W");return("ran")};return([out,order])', [None, ''])
case('copy_guard', 'order="";out=sorted_values({"a":1}).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).copy().with(){order=cat(order,"W");return("ran")};return([out,order])', [None, ''])
case('logical_guard', 'order="";out=sorted_keys({"a":1}).set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1}).and({order=cat(order,"D");true}).with(){order=cat(order,"W");return("ran")};return([out,order])', [None, ''])
case('explicit_bridges', 'return([sorted_keys({"b":2,"a":1}).join_values(",").uppercase().split(",").last(),sorted_values({"a":1}).with(){return({"k":1})}.count_keys()])', ['B', 1])
case('nested_kinds', 'return([sorted_values({"a":false,"b":{"n":[7]}})[0],sorted_values({"a":false,"b":{"n":[7]}})[1]["n"][-1].add(1)])', [False, 8])
case('source_once_snapshot', 'meta={"a":1};order="";out=sorted_keys({order=cat(order,"S");meta}).join_values({order=cat(order,"A");meta["b"]=2;","});return([out,count_keys(meta),order])', ['a', 2, 'SA'])
case('constructor_copy_oracle', 'order="";a=array("a").set_key({order=cat(order,"A");"k"},1).with(){order=cat(order,"W");return("ran")};b=copy(["a"]).set_key({order=cat(order,"B");"k"},1).with(){order=cat(order,"X");return("ran")};return([a,b,order])', [None, None, ''])
case('needed_source_error', 'return(sorted_keys({items="text";push(items,"x");{"a":1}}).coalesce("masked"))', expected_error='binding_kind_mismatch')
case('valid_empty_with', 'order="";out=sorted_keys({}).with(){order=cat(order,"W");return(value.count())};return([out,order])', [0, 'W'])
case('arity_profile', 'order="";out={"a":1}.sorted_keys({order=cat(order,"A");0}).with(){order=cat(order,"W");return("ran")};return([out,order])', profile_only=True)
path = BASE / 'cases.json'
assert not path.exists(), 'one-shot authored source population'
path.write_text(json.dumps(rows, indent=2) + '\n')
print('Finite authored Hash-view candidate and independent constructor/copy controls retained')
