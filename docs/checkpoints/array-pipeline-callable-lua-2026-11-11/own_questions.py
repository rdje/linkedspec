"""Author installed-Lua pipeline source questions without importing any peer outcomes."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
assert subprocess.check_output(['git', 'rev-parse', 'HEAD'], text=True).strip() == '9a6b229ce3f944ef3822e71935b1c40c109f74b9'
assert not (BASE / 'cases.json').exists()
rows = []
helpers = ('split_each', 'trim_each', 'filter_nonempty', 'lowercase_each', 'uppercase_each', 'uniq', 'filter_match')


def add(identifier, body, question):
    rows.append(dict(id=identifier, body=body, source='fn supply(seed) {return(seed)}\n\nValue:: I {' + body + '}\n',
                     input='x', rule='Value', profile_only=True, question=question))


def call(helper, source, receiver=False, excess=False):
    source = 'supply(' + source + ')'
    arguments = ['":"'] if helper == 'split_each' else ['/^head/'] if helper == 'filter_match' else []
    if excess:
        arguments.append('{order=cat(order,"X");1}')
    return (source + '.' + helper + '(' + ','.join(arguments) + ')' if receiver
            else helper + '(' + ','.join([source] + arguments) + ')')


for helper in helpers:
    for kind, source in (('number', '3'), ('null', 'undef'), ('hash', '{"k":"head"}')):
        for receiver in (False, True):
            form = 'receiver' if receiver else 'free'
            expression = call(helper, source, receiver)
            add(f'initial_{kind}_{helper}_{form}', 'return(' + expression + ')', 'initial-source')
            add(f'initial_{kind}_{helper}_{form}_with', 'order="";out=' + expression
                + '.with(){order=cat(order,"W");return(value.count())};return([out,order])', 'initial-source-with')
    for receiver in (False, True):
        form = 'receiver' if receiver else 'free'
        expression = call(helper, '{order=cat(order,"S");["head:tail"]}', receiver, excess=True)
        add('extra_' + helper + '_' + form, 'order="";out=' + expression
            + '.set_key({order=cat(order,"K");"k"},1).with(){order=cat(order,"W");return("ran")};return([out,order])', 'excluded-extra-arity')
        expression = call(helper, '{items="bad";items+=1;["head"]}', receiver)
        add('needed_source_' + helper + '_' + form, 'order="";return(' + expression
            + '.set_key({order=cat(order,"K");"k"},1).coalesce("masked"))', 'needed-source-error')
    add('missing_' + helper + '_free', 'order="";out=' + helper
        + '().with(){order=cat(order,"W");return(value)};return([out,order])', 'excluded-missing-arity')
for helper in ('split_each', 'filter_match'):
    for form, expression in (('free', helper + '(supply(["head"]))'), ('receiver', 'supply(["head"]).' + helper + '()')):
        add('missing_operand_' + helper + '_' + form, 'order="";out=' + expression
            + '.with(){order=cat(order,"W");return(value)};return([out,order])', 'excluded-missing-arity')
for name, source in (('count', 'supply([1]).count()'), ('key_count', 'supply({"a":1}).count_keys()'),
                     ('length', 'supply("abc").length()'), ('hash', 'set_key(supply({}),"k",1)'),
                     ('copy', 'copy(supply(3))'), ('view', 'sorted_keys(supply({"a":1}))')):
    add('prior_' + name, 'order="";out=' + source
        + '.trim_each().with(){order=cat(order,"W");return(value)};return([out,order])', 'earlier-owner')
for receiver in (False, True):
    form = 'receiver' if receiver else 'free'
    expression = ('supply(["head:tail"]).split_each({items="bad";items+=1;":"})' if receiver
                  else 'split_each(supply(["head:tail"]),{items="bad";items+=1;":"})')
    add('needed_delimiter_' + form, 'order="";return(' + expression
        + '.set_key({order=cat(order,"K");"k"},1).coalesce("masked"))', 'needed-delimiter-error')
    expression = ('supply(["head"]).filter_match({items="bad";items+=1;"^head"})' if receiver
                  else 'filter_match(supply(["head"]),{items="bad";items+=1;"^head"})')
    for composed in (False, True):
        add('needed_pattern_' + form + ('_composed' if composed else '_terminal'), 'order="";return(' + expression
            + ('.set_key({order=cat(order,"K");"k"},1).coalesce("masked")' if composed else '') + ')', 'needed-pattern-error')
add('nested_scalar_kinds', 'source=[false,0,undef,"0",""];out=uniq(supply(source));return([out,source])', 'nested-kinds')
add('numeric_array_source', 'source=[3];return([trim_each(supply(source)),filter_nonempty(supply(source)),uniq(supply(source)),source])', 'numeric-kind')
assert len(rows) == 137
(BASE / 'profile-sources.json').write_text(json.dumps(rows, indent=2) + '\n')
print('Authored137 own Lua callable source questions with safe pattern-operand errors')
