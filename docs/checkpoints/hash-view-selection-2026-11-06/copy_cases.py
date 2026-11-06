"""Minimal independent free-copy rejection/null qualification before any repair."""
import json
from pathlib import Path
BASE=Path('docs/checkpoints/hash-view-selection-2026-11-06')
rows=[]
def case(identifier,body,expected):
 rows.append(dict(id=identifier,body=body,source='Value:: I {'+body+'}\n',input='x',rule='Value',expected=expected))
case('copy_without_with','order="";out=copy(["a"]).set_key({order=cat(order,"K");"k"},1);return([out,order])',[None,''])
case('copy_rejected_with','order="";out=copy(["a"]).set_key({order=cat(order,"K");"k"},1).with(){order=cat(order,"W");return("ran")};return([out,order])',[None,''])
case('copy_valid_null_with','order="";out=copy(undef).with(){order=cat(order,"W");return("valid-null")};return([out,order])',['valid-null','W'])
case('constructor_rejected_with','order="";out=array("a").set_key({order=cat(order,"K");"k"},1).with(){order=cat(order,"W");return("ran")};return([out,order])',[None,''])
case('copy_rejected_default','order="";out=copy(["a"]).set_key({order=cat(order,"K");"k"},1).coalesce({order=cat(order,"D");{"x":1}}).count_keys();return([out,order])',[None,''])
case('receiver_copy_control','order="";out=["a"].copy().set_key({order=cat(order,"K");"k"},1).with(){order=cat(order,"W");return("ran")};return([out,order])',[None,''])
path=BASE/'copy-controls.json';assert not path.exists();path.write_text(json.dumps(rows,indent=2)+'\n')
print('Minimal copy/null qualification authored separately; original16 untouched')
