"""Author separate initial-receiver controls without importing a peer policy."""
import json
from pathlib import Path

BASE = Path('docs/checkpoints/hash-view-receiver-policy-perl-2026-11-06')
assert not (BASE / 'cases.json').exists(), 'one-shot policy source preparation'
rows = []


def add(identifier, body):
    rows.append(dict(id=identifier, body=body, source='Value:: I {' + body + '}\n',
                     rule='Value', input='x'))


for helper in ('sorted_keys', 'sorted_values'):
    for kind, source in (('number', '3'), ('null', 'undef'), ('array', '[1]')):
        add(helper + '_' + kind, 'return(' + source + '.' + helper + '())')
    add(helper + '_null_with', 'order="";out=undef.' + helper + '().with(){order=cat(order,"W");return(value.count())};return([out,order])')
    add(helper + '_hash_with', 'order="";out={"b":2,"a":1}.' + helper + '().with(){order=cat(order,"W");return(value.count())};return([out,order])')
for identifier, source in (
    ('produced_count', 'count([1]).sorted_values()'),
    ('produced_key_count', 'count_keys({"a":1}).sorted_keys()'),
    ('produced_length', '"abc".length().sorted_values()'),
):
    add(identifier, 'return(' + source + ')')
assert len(rows) == 13
(BASE / 'cases.json').write_text(json.dumps(rows, indent=2) + '\n')
source = Path('docs/checkpoints/hash-view-result-guard-perl-2026-11-06/observe_control.pl').read_text()
source = source.replace('hash-view-guard-control.spec', 'hash-view-receiver-policy.spec')
source = source.replace('HashViewGuardControlProbe', 'HashViewReceiverPolicyProbe')
source = source.replace('HASH_VIEW_CONTROL', 'HASH_VIEW_POLICY')
(BASE / 'observer.pl').write_text(source)
print('Thirteen independent Perl receiver/preserved-owner sources prepared; no expected peer values')
