"""Unchanged shared28 plus bounded initial-source and earlier-owner controls."""
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
rows = json.loads(Path('tests/fixtures/hash_value_result_guard_cases.json').read_bytes())


def add(identifier, body, **fields):
    rows.append(dict(id=identifier, body=body, source='Value:: I {' + body + '}\n',
                     rule='Value', input='x', **fields))


for helper, args, count in (('merge_hash', '{"b":2}', 1), ('set_key', '"b",2', 1),
                            ('rename_key', '"a","b"', 0), ('drop_keys', '"a"', 0), ('pick_keys', '"a"', 0)):
    add('initial_number_' + helper + '_with', 'order="";out=3.' + helper + '(' + args +
        ').with(){order=cat(order,"W");return(value.count_keys())};return([out,order])', expected=[count, 'W'])
    add('initial_array_' + helper + '_with', 'order="";out=[1].' + helper + '(' + args +
        ').with(){order=cat(order,"W");return("ran")};return([out,order])', expected_error='Not a HASH reference')
for name, source in (('view', 'sorted_keys({"a":1})'), ('copy', 'copy(3)'), ('constructor', 'array(1)')):
    add('earlier_' + name + '_source_guard', 'order="";out=' + source +
        '.merge_hash({order=cat(order,"A");{"b":2}}).with(){order=cat(order,"W");return("ran")};return([out,order])', expected=[None, ''])
assert len(rows) == 41 and len({r['id'] for r in rows}) == 41
target = Path('tests/fixtures/hash_value_result_guard_perl_cases.json')
assert not target.exists(), 'one-shot own source target freeze'
target.write_text(json.dumps(rows, indent=2) + '\n')
print('Unchanged28 plus13 own initial/earlier-source controls authored; no runtime verdict')
