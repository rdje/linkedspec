"""Independent IEEE-754 inputs and exact whole-number decimal targets."""
import json
import math
import struct
import common as c


def bits(value):
    return struct.unpack('>Q', struct.pack('>d', value))[0]


def main():
    values = [('zero', 0.0), ('negative-zero', -0.0), ('small-positive', 42.0),
        ('small-negative', -42.0), ('one', 1.0), ('negative-one', -1.0),
        ('fraction', 1.25), ('negative-fraction', -1.25), ('tenth', 0.1),
        ('large-positive', 1e20), ('large-negative', -1e20)]
    for name, boundary in [('i64-low', -float(2**63)), ('i64-high', float(2**63)),
                            ('u64-high', float(2**64)), ('negative-u64-high', -float(2**64))]:
        values += [(name+'-below', math.nextafter(boundary, -math.inf)),
                   (name, boundary), (name+'-above', math.nextafter(boundary, math.inf))]
    values += [('wide-positive', 1e30), ('wide-negative', -1e30),
        ('very-wide-positive', 1e100), ('very-wide-negative', -1e100),
        ('maximum-positive', float.fromhex('0x1.fffffffffffffp+1023')),
        ('maximum-negative', -float.fromhex('0x1.fffffffffffffp+1023')),
        ('minimum-normal', float.fromhex('0x1p-1022')),
        ('negative-minimum-normal', -float.fromhex('0x1p-1022')),
        ('minimum-subnormal', float.fromhex('0x0.0000000000001p-1022')),
        ('negative-minimum-subnormal', -float.fromhex('0x0.0000000000001p-1022')),
        ('positive-infinity', math.inf), ('negative-infinity', -math.inf), ('nan', math.nan)]
    rows = []
    for name, value in values:
        finite = math.isfinite(value)
        negative_zero = value == 0.0 and math.copysign(1.0, value) < 0.0
        whole = finite and value.is_integer()
        if not finite:
            kind = 'null'
        elif negative_zero:
            kind = 'negative_zero'
        elif whole and -(2**63) <= value < 2**63:
            kind = 'signed_integer'
        elif whole and 0 <= value < 2**64:
            kind = 'unsigned_integer'
        else:
            kind = 'finite_float'
        expected_text = str(int(value)) if whole else {
            'fraction': '1.25', 'negative-fraction': '-1.25', 'tenth': '0.1',
            'positive-infinity': 'inf', 'negative-infinity': '-inf', 'nan': 'NaN',
        }.get(name)
        rows.append(dict(id=name, bits=f'{bits(value):016x}', finite=finite,
            json_kind=kind, integer=str(int(value)) if kind.endswith('_integer') else None,
            expected_text=expected_text))
    assert len({row['id'] for row in rows}) == len(rows)
    result = dict(version=1, owner=c.OWNER, cases=rows,
        scope='Authored binary64 input population. Python integer conversion supplies exact mathematical decimal text for every whole finite input, independently of Rust formatting. JSON integers must retain exact identity inside signed/unsigned64; outside those ranges finite floating JSON must retain binary64 bits. Negative zero is a floating JSON value; nonfinite values retain null. Raw serde checks only numeric values, not arbitrary aggregate-kind round trips. Portable cat spelling remains separately owned.')
    path = c.ROOT/'tests/numeric-conversion/cases.json'
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x') as output:
        output.write(json.dumps(result, indent=2)+'\n')
    c.save('fixture-inputs.json.gz', dict(producer=c.read(c.PREFIX+'fixture.py'),
        helper=c.read(c.PREFIX+'common.py'), fixture=c.read('tests/numeric-conversion/cases.json')))
    print('Independent numeric fixture:', len(rows), 'binary64 inputs with exact integer/bit targets.')


if __name__ == '__main__':
    main()
