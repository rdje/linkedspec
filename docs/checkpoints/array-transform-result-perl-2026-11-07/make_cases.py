"""Freeze own source/arity fences before any Array-result production edit."""
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
cases = json.loads(Path('tests/fixtures/array_transform_result_guard_cases.json').read_text())
profiles = []


def add(identifier, body):
    profiles.append(dict(id=identifier, body=body, source='Value:: I {' + body + '}\n',
                         input='x', rule='Value', profile_only=True))


for name in ('take', 'take_last', 'drop_front', 'drop_back', 'slice', 'sorted', 'reversed', 'concat_arrays'):
    operands = ['1', '1'] if name == 'slice' else ['["extra"]'] if name == 'concat_arrays' else [] if name in ('sorted', 'reversed') else ['1']
    for kind, source in (('number', '3'), ('null', 'undef'), ('hash', '{"k":"tail"}')):
        for route in ('free', 'receiver'):
            expr = name + '(' + ','.join(['source'] + operands) + ')' if route == 'free' else 'source.' + name + '(' + ','.join(operands) + ')'
            add('initial_' + kind + '_' + name + '_' + route, 'source=' + source + ';return(' + expr + ')')
    for route in ('free', 'receiver'):
        def expression(args):
            return name + '(' + ','.join(['source'] + args) + ')' if route == 'free' else 'source.' + name + '(' + ','.join(args) + ')'
        if name in ('take', 'take_last', 'drop_front', 'drop_back', 'slice'):
            args = ['1'] if name == 'slice' else []
            add('optional_' + name + '_' + route, 'source=["head","tail","end"];return(' + expression(args) + ')')
        extra = operands + ['{order=cat(order,"E");2}']
        add('extra_' + name + '_' + route, 'order="";source=["head","tail"];out=' + expression(extra) + ';return([out,order])')
for identifier, expr in (
    ('prior_constructor', 'array("tail").set_key({order=cat(order,"K");"k"},1)'),
    ('prior_view', 'sorted_values({"k":"tail"}).set_key({order=cat(order,"K");"k"},1)'),
    ('prior_copy', 'copy(["tail"]).set_key({order=cat(order,"K");"k"},1)'),
    ('prior_hash', 'set_key({"k":"tail"},"n",1).take({order=cat(order,"N");1})'),
):
    add(identifier, 'order="";out=' + expr + ';return([out,order])')
for name in ('take', 'take_last', 'drop_front', 'drop_back', 'slice'):
    add('optional_error_' + name, 'return(' + name + '({return(num_clamp(1,2))}' + (',1' if name == 'slice' else '') + ').with(){return("masked")})')
(BASE / 'cases.json').write_text(json.dumps(cases + profiles, indent=2) + '\n')
print('Authored unchanged targets and own preflight profiles:', len(cases), len(profiles))
