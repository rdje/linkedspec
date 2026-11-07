"""Unchanged28 targets plus finite own initial-source and shape fences."""
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
rows = json.loads(Path('tests/fixtures/hash_value_result_guard_cases.json').read_bytes())
methods = {'merge_hash': ['{"b":2}'], 'set_key': ['"b"', '2'],
           'rename_key': ['"a"', '"b"'], 'drop_keys': ['"a"'], 'pick_keys': ['"a"']}


def expression(method, source, form, args):
    if form == 'free':
        return method + '(' + ','.join([source] + args) + ')'
    return source + '.' + method + '(' + ','.join(args) + ')'


def add(identifier, body):
    rows.append(dict(id=identifier, body=body, source='Value:: I {' + body + '}\n',
                     input='x', rule='Value', policy_profile=True))


for method, args in methods.items():
    for kind, source in (('number', '3'), ('null', 'undef'), ('array', '[1]')):
        for form in ('free', 'receiver'):
            add('initial_' + kind + '_' + method + '_' + form,
                'return(' + expression(method, source, form, args) + ')')
    add('initial_null_' + method + '_with', 'order="";out=' +
        expression(method, 'undef', 'receiver', args) +
        '.with(){order=cat(order,"W");return("ran")};return([out,order])')
    if method in ('merge_hash', 'set_key', 'rename_key'):
        for form in ('free', 'receiver'):
            source = '{order=cat(order,"S");{"a":1}}'
            extra = '{order=cat(order,"A");9}'
            add('extra_' + method + '_' + form, 'order="";out=' +
                expression(method, source, form, args + [extra]) +
                '.with(){order=cat(order,"W");return("ran")};return([out,order])')
for name, source in (('count', 'count([])'), ('count_keys', 'count_keys({"a":1})'),
                     ('length', 'length("abc")')):
    add('produced_' + name + '_merge_guard', 'order="";out=' + source +
        '.merge_hash({order=cat(order,"A");{"b":2}}).with(){order=cat(order,"W");return("ran")};return([out,order])')
original = json.loads(Path('docs/checkpoints/hash-value-result-selection-2026-11-07/cases.json').read_bytes())
for case in original:
    if case.get('profile_only'):
        rows.append(dict(case, policy_profile=True))
assert len(rows) == 76 and sum(c.get('policy_profile', False) for c in rows) == 48
assert len({c['id'] for c in rows}) == len(rows)
target = BASE / 'cases.json'
assert not target.exists(), 'one-shot authored source set'
target.write_text(json.dumps(rows, indent=2) + '\n')
print('Unchanged28 plus48 own initial-source/shape fences authored; no runtime verdict')
