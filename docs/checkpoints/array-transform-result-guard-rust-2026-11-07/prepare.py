"""Author Rust controls and adapt the established public four-route instrument."""
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
PRIOR = BASE.parent / 'hash-value-result-guard-rust-2026-11-07'
profiles = []
targets = []


def add(identifier, body, expected=None, target=False):
    row = dict(id=identifier, body=body, source='Value:: I {' + body + '}\n',
               input='x', rule='Value')
    if target:
        row['expected'] = expected
        targets.append(row)
    else:
        row['profile_only'] = True
        profiles.append(row)


HELPERS = ('take', 'take_last', 'drop_front', 'drop_back', 'slice',
           'sorted', 'reversed', 'concat_arrays')
OPERANDS = {h: ['1'] for h in HELPERS[:4]}
OPERANDS.update(slice=['1', '1'], sorted=[], reversed=[], concat_arrays=['["z"]'])


def call(helper, source, receiver=False, operands=None):
    args = OPERANDS[helper] if operands is None else operands
    if receiver:
        return source + '.' + helper + '(' + ','.join(args) + ')'
    return helper + '(' + ','.join([source] + args) + ')'


for helper in HELPERS:
    for kind, source in (('number', '3'), ('null', 'undef'), ('hash', '{"k":1}')):
        for receiver in (False, True):
            form = 'receiver' if receiver else 'free'
            value = call(helper, source, receiver)
            add(f'initial_{kind}_{helper}_{form}', 'return(' + value + ')')
            add(f'initial_{kind}_{helper}_{form}_with',
                'order="";out=' + value + '.with(){order=cat(order,"W");'
                'return(value.count())};return([out,order])')
    for receiver in (False, True):
        form = 'receiver' if receiver else 'free'
        source = '{order=cat(order,"S");["b","a"]}'
        extra = OPERANDS[helper] + ['{order=cat(order,"X");1}']
        add(f'extra_{helper}_{form}', 'order="";out=' + call(helper, source, receiver, extra)
            + '.set_key({order=cat(order,"K");"k"},1).with(){'
            'order=cat(order,"W");return("ran")};return([out,order])')
    add(f'missing_{helper}_free', 'order="";out=' + helper + '().with(){'
        'order=cat(order,"W");return(value)};return([out,order])')
for helper in ('slice', 'concat_arrays'):
    add(f'missing_{helper}_receiver', 'order="";out=["b","a"].' + helper
        + '().with(){order=cat(order,"W");return(value)};return([out,order])')
for helper in HELPERS[:5]:
    args = ['1'] if helper == 'slice' else []
    for receiver in (False, True):
        form = 'receiver' if receiver else 'free'
        value = call(helper, '["b","a"]', receiver, args)
        add(f'optional_{helper}_{form}', 'return(' + value + ')')
        add(f'optional_{helper}_{form}_with', 'order="";out=' + value
            + '.with(){order=cat(order,"W");return(value.count())};return([out,order])')
        add(f'optional_{helper}_{form}_guard', 'order="";out=' + value
            + '.set_key({order=cat(order,"K");"k"},{order=cat(order,"V");1})'
            '.copy().with(){order=cat(order,"W");return("ran")};return([out,order])',
            [None, ''], target=True)
for identifier, source in (('count', '[1].count()'), ('key_count', '{"a":1}.count_keys()'),
                           ('length', '"abc".length()'), ('hash', 'set_key({},"a",1)'),
                           ('copy', 'copy(3)'), ('view', 'sorted_keys({"a":1})')):
    add('prior_' + identifier, 'order="";out=' + source
        + '.take({order=cat(order,"A");1}).with(){order=cat(order,"W");'
        'return(value)};return([out,order])')

assert len(profiles) == 148 and len(targets) == 10
for name, rows in (('profile-sources.json', profiles), ('additional-targets.json', targets)):
    assert not (BASE / name).exists()
    (BASE / name).write_text(json.dumps(rows, indent=2) + '\n')
observer = (PRIOR / 'observer.rs').read_text().replace('HASH_VALUE_RUST', 'ARRAY_TRANSFORM_RUST')
observer = observer.replace('hash_value_result_rust', 'array_transform_result_rust')
observer = observer.replace('hash-value-result', 'array-transform-result')
(BASE / 'observer.rs').write_text(observer)
print('148 independent policy controls and10 authored optional-result targets prepared')
