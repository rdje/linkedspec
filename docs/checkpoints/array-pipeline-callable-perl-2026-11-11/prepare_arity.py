"""Minimal malformed terminal-helper discriminators; original178 untouched."""
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
target = BASE / 'arity-cases.json'
assert not target.exists()
rows = []
helpers = ('split_each', 'trim_each', 'filter_nonempty', 'lowercase_each', 'uppercase_each', 'uniq', 'filter_match')
source = 'supply({order=cat(order,"S");["head:tail"]})'


def add(identifier, expression):
    body = 'order="";out=' + expression + ';return([out,order])'
    rows.append(dict(id=identifier, body=body,
        source='fn supply(seed) {return(seed)}\n\nValue:: I {' + body + '}\n',
        input='x', rule='Value', profile_only=True, question='malformed-terminal-arity'))


for helper in helpers:
    arguments = ['":"'] if helper == 'split_each' else ['/^head/'] if helper == 'filter_match' else []
    extra = arguments + ['{order=cat(order,"X");1}']
    add('arity_extra_' + helper + '_free', helper + '(' + ','.join([source] + extra) + ')')
    add('arity_extra_' + helper + '_receiver', source + '.' + helper + '(' + ','.join(extra) + ')')
    if helper in ('split_each', 'filter_match'):
        add('arity_missing_' + helper + '_free', helper + '(' + source + ')')
        add('arity_missing_' + helper + '_receiver', source + '.' + helper + '()')
assert len(rows) == len({row['id'] for row in rows}) == 18
target.write_text(json.dumps(rows, indent=2) + '\n')
observer = (BASE / 'observer.pl').read_bytes()
(BASE / 'arity_observer.pl').write_bytes(observer.replace(b'/cases.json', b'/arity-cases.json'))
print('Eighteen terminal malformed-shape discriminators authored; no policy or production change')
