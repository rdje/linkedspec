"""Finite existing pure-pipeline targets, authored before any SDK observation."""
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
cases = []


def add(identifier, body, expected=None, error=None):
    row = dict(id=identifier, body=body, source='Value:: I {' + body + '}\n',
               input='x', rule='Value')
    if error:
        row['expected_error'] = error
    else:
        row['expected'] = expected
    cases.append(row)


roles = (
    ('split_each', 'split_each(["head:tail"],":")', '["head:tail"].split_each(":")', ['head', 'tail']),
    ('trim_each', 'trim_each([" head "," tail "])', '[" head "," tail "].trim_each()', ['head', 'tail']),
    ('filter_nonempty', 'filter_nonempty(["head","","tail"])', '["head","","tail"].filter_nonempty()', ['head', 'tail']),
    ('lowercase_each', 'lowercase_each(["HEAD","TAIL"])', '["HEAD","TAIL"].lowercase_each()', ['head', 'tail']),
    ('uppercase_each', 'uppercase_each(["head","tail"])', '["head","tail"].uppercase_each()', ['HEAD', 'TAIL']),
    ('uniq', 'uniq(["head","tail","head"])', '["head","tail","head"].uniq()', ['head', 'tail']),
    ('filter_match', 'filter_match(["head","other"],/^h/)', '["head","other"].filter_match(/^h/)', ['head']),
)
consumer = '.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1})'
for name, free, receiver, result in roles:
    add(name + '_compatible', 'return([' + free + ',' + receiver + '])', [result, result])
    for form, expression in (('free', free), ('receiver', receiver)):
        add(name + '_' + form + '_hash_guard',
            'order="";out=' + expression + consumer + ';return([out,order])', [None, ''])
for identifier, expression, tail in (
    ('trim_later_with', 'trim_each([" tail "])', '.with(){order=cat(order,"W");return("ran")}'),
    ('uniq_copy_later_with', 'uniq(["tail","tail"])', '.copy().with(){order=cat(order,"W");return("ran")}'),
    ('lower_logical_later_with', 'lowercase_each(["TAIL"])', '.and({order=cat(order,"D");true}).with(){order=cat(order,"W");return("ran")}'),
):
    add(identifier, 'order="";out=' + expression + consumer + tail + ';return([out,order])', [None, ''])
add('selected_string_bridge', 'return([trim_each([" tail "]).last().uppercase(),filter_match(["head","other"],/^h/).join_values(",")])', ['TAIL', 'head'])
add('selected_numeric_kind', 'items=[2,"2","x"];out=uniq(items);indexed=["zero","one","two"];indexed[first(out)]="selected";return([out,items,indexed])', [[2, 'x'], [2, '2', 'x'], ['zero', 'one', 'selected']])
add('source_once', 'order="";out=trim_each({order=cat(order,"S");[" tail "]}).last().uppercase();return([out,order])', ['TAIL', 'S'])
add('source_snapshot', 'items=["head:tail"];out=split_each(items,{items=["changed"];":"});return([out,items])', [['head', 'tail'], ['changed']])
add('valid_empty_with', 'order="";out=filter_nonempty([""]).with(){order=cat(order,"W");return(value.count())};return([out,order])', [0, 'W'])
for identifier, expression in (
    ('needed_source_error', 'split_each({items="bad";items+=1;["head:tail"]},":")'),
    ('needed_delimiter_error', 'split_each(["head:tail"],{items="bad";items+=1;":"})'),
):
    add(identifier + '_terminal', 'return(' + expression + ')', error='binding_kind_mismatch')
    add(identifier + '_composed', 'order="";return(' + expression + consumer + '.coalesce("masked"))', error='binding_kind_mismatch')
add('constructor_array_guard', 'order="";out=array("head","tail")' + consumer + '.with(){order=cat(order,"W");return("ran")};return([out,order])', [None, ''])
add('value_source_preserved', 'items=[" a "," a "];out=trim_each(items);return([out,items])', [['a', 'a'], [' a ', ' a ']])
add('standalone_writeback', 'items=[" a "," a "];trim_each(items);return(items)', ['a', 'a'])
assert len(cases) == len({row['id'] for row in cases}) == 36
target = BASE / 'cases.json'
assert not target.exists()
target.write_text(json.dumps(cases, indent=2) + '\n')
print('36 finite existing-contract programs authored; no runtime verdict')
