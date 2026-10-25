"""Author the Rust-specific target fixture from retained public cases and explicit controls."""
import json
from pathlib import Path
import common as c

PLAN = 'docs/checkpoints/signed-array-selectors/cases.json'
TARGET = 'tests/signed-array-rust/cases.json'


def main():
    rows = json.loads(c.decode(c.read(PLAN)['base64']))['cases']
    errors = {
        'write-underflow': dict(code='nested_write_array_underflow', index=-4, length=3, resolved_index=-1),
        'write-empty': dict(code='nested_write_array_underflow', index=-1, length=0, resolved_index=-1),
        'write-absent': dict(code='nested_write_segment_invalid', reason='negative_integer'),
        'write-null': dict(code='nested_write_kind_conflict', expected_kind='array', actual_kind='null'),
        'write-fractional': dict(code='nested_write_segment_invalid', reason='fractional_number'),
        'write-string-negative-on-array': dict(code='nested_write_kind_conflict', expected_kind='harray', actual_kind='array'),
    }
    overrides = {'read-underflow': [None, [10, 20, 30]], 'read-empty': [None, []],
        'read-receiver-retention': [92, [91, 92]],
        'read-positive-receiver-retention': [91, [91, 92]], 'read-dynamic-quoted-key': None}
    cases = []
    for row in rows:
        if row['id'] in errors:
            expected = dict(error=errors[row['id']])
        elif row['id'] in overrides:
            expected = dict(ok=overrides[row['id']])
        else:
            assert 'requested_value' in row, row['id']
            expected = dict(ok=row['requested_value'])
        cases.append(dict(id=row['id'], source=row['source'], input=row['input'], expected=expected))
    extra = [
        ('rhs-resize', 'items=[10,20]; items[-1]={ items.push_back(30); 99 }; return(items)',
            dict(ok=[10, 20, 99])),
        ('selector-resize', 'items=[10,20]; items[{ items.push_back(30); -1 }]=99; return(items)',
            dict(ok=[10, 20, 99])),
        ('negative-then-create', 'document=[{}]; document[-1]["new"][0]=99; return(document)',
            dict(ok=[{'new': [99]}])),
        ('underflow-after-negative', 'document=[[1]]; document[-1][-2]=99; return(document)',
            dict(error=dict(code='nested_write_array_underflow', segment_index=1, path=[-1], index=-2, length=1, resolved_index=-1))),
        ('missing-after-negative', 'document=[{}]; document[-1]["missing"][-1]=99; return(document)',
            dict(error=dict(code='nested_write_segment_invalid', segment_index=2, path=[-1, 'missing'], reason='negative_integer'))),
        ('global-invalid-before-underflow', 'items=[10]; items[-2][true]=99; return(items)',
            dict(error=dict(code='nested_write_segment_invalid', segment_index=1, path=[-2], actual_kind='boolean'))),
        ('signed-minimum-underflow', 'items=[10,20,30]; items[-9223372036854775808]=99; return(items)',
            dict(error=dict(code='nested_write_array_underflow', index=-9223372036854775808, length=3, resolved_index=-9223372036854775805))),
        ('unsigned-magnitude-underflow', 'items=[10,20,30]; items[-18446744073709549568]=99; return(items)',
            dict(error=dict(code='nested_write_array_underflow', index=-18446744073709549568, length=3, resolved_index=-18446744073709549565))),
    ]
    for name, body, expected in extra:
        row = dict(id=name, source='Top: /x/\n I { ' + body + ' }\n', input='x', expected=expected)
        if name in ('signed-minimum-underflow', 'unsigned-magnitude-underflow'):
            row['pointer_width'] = 64
        cases.append(row)
    value = dict(authority='capability_conformance/signed_array_selector_contract.json',
        scope='Rust signed selectors; explicit existing read-order/coercion adjudications. Exact signed diagnostic expectations do not promise arbitrary-precision DSL arithmetic.',
        adjudications={
            'read-receiver-retention': 'Single IndexedVar preserves post-selector binding lookup; negative last selects92.',
            'read-positive-receiver-retention': 'Preserve post-selector lookup and index0 result91.',
            'read-dynamic-quoted-key': 'Preserve unrelated single-index hash coercion, returning null.'},
        cases=cases)
    target = c.ROOT / TARGET
    target.parent.mkdir(exist_ok=False)
    with target.open('x') as output:
        output.write(json.dumps(value, ensure_ascii=False, indent=2) + '\n')
    c.write_new('fixture-inputs.json.gz', dict(producer=c.read(c.PREFIX + 'fixture.py'),
        original=c.read(PLAN), target=c.read(TARGET)))
    print('Authored Rust target retained; runtime unchanged.')


if __name__ == '__main__':
    main()
