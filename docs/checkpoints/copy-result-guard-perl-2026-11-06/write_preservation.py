"""Author bounded direct copy-result preservation controls before first normal use."""
import json
from pathlib import Path

rows = []


def case(identifier, body, expected=None, **fields):
    row = dict(id=identifier, body=body, source='Value:: I {' + body + '}\n',
               input='x', rule='Value', **fields)
    if not fields.get('expected_error'):
        row['expected'] = expected
    rows.append(row)


case('numeric_domain_null', 'return([copy(1).add("bad").with(){return("valid-null")},copy(1).add("bad").coalesce(7)])', ['valid-null', 7])
case('empty_copy_with', 'order="";out=copy([]).with(){order=cat(order,"W");return(value.count())};return([out,order])', [0, 'W'])
case('repeated_copy_rejection', 'order="";out=copy(["a"]).set_key({order=cat(order,"K");"k"},1).copy().copy().with(){order=cat(order,"W");return("ran")};return([out,order])', [None, ''])
case('logical_rejection', 'order="";out=copy(["a"]).set_key({order=cat(order,"K");"k"},1).and({order=cat(order,"D");true}).with(){order=cat(order,"W");return("ran")};return([out,order])', [None, ''])
case('bridge_rejection', 'order="";out=copy(false).cat("x").split(",").set_key({order=cat(order,"K");"k"},1).with(){order=cat(order,"W");return("ran")};return([out,order])', [None, ''])
case('needed_copy_source_error', 'return(copy({items="text";push(items,"x");["a"]}).coalesce("masked"))', expected_error='binding_kind_mismatch')
target = Path('tests/fixtures/copy_result_guard_perl_preservation_cases.json')
assert not target.exists(), 'one-shot authored preservation controls'
target.write_text(json.dumps(rows, indent=2) + '\n')
print('Bounded copy null/empty/repeated/logical/bridge/error sources authored before execution')
