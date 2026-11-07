"""Small scalar/overlay and key-effect controls for the changing dereferences."""
import json
from pathlib import Path

rows = []


def add(identifier, body, expected):
    rows.append(dict(id=identifier, body=body, source='Value:: I {' + body + '}\n',
                     rule='Value', input='x', expected=expected))


add('merge_string_source', 'return(merge_hash("3",{"b":2}))', {'b': 2})
add('merge_number_overlay', 'return(merge_hash({"a":1},3))', {'a': 1})
for kind, value, order in (('number', '3', 'SK'), ('null', 'undef', 'S')):
    add('pick_' + kind + '_key_effect', 'order="";out=pick_keys({order=cat(order,"S");' + value +
        '},{order=cat(order,"K");"a"});return([out,order])', [{}, order])
    add('drop_' + kind + '_key_effect', 'order="";other={||order=cat(order,"K");return("a")};'
        'out=drop_keys({order=cat(order,"S");' + value + '},other());return([out,order])', [{}, order])
target = Path('tests/fixtures/hash_helper_source_isolation_perl_extra_cases.json')
assert len(rows) == 6 and not target.exists(), 'one-shot authored controls'
target.write_text(json.dumps(rows, indent=2) + '\n')
print('Six finite scalar/overlay/key-effect controls authored; no runtime verdict')
