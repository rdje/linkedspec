"""Author public source cases from independent binary64 and integer targets."""
import json
import math
import struct
import common as c


def main():
    numbers = json.loads(c.source('tests/numeric-conversion/cases.json').read_text())
    rows = []
    def add(name, action, expected, width=None):
        rows.append(dict(id=name, source='Top: /x/\n I { '+action+' }\n',
            input='x', expected=expected, pointer_width=width))
    for row in numbers['cases']:
        if not row['finite']:
            continue
        value = struct.unpack('>d', bytes.fromhex(row['bits']))[0]
        literal = ('-0.0' if row['id'] == 'negative-zero' else str(int(value))
            if value.is_integer() else format(value, '.1074f').rstrip('0'))
        target = {'binary64':row['bits'], 'json_kind':row['json_kind'], 'integer':row['integer']}
        add('value/'+row['id'], 'return('+literal+')', {'ok':target})
        if row['id'] in ('large-positive', 'large-negative', 'i64-high', 'u64-high-below'):
            add('nested/'+row['id'], 'return({"rows":['+literal+']})',
                {'ok':{'object':{'rows':{'array':[target]}}}})
            text = row['expected_text']
            assert text is not None
            add('text-consumer/'+row['id'], 'h={}; h['+literal+']=7; return([trim('
                +literal+'),length('+literal+'),h])',
                {'ok':{'exact':[text,len(text),{text:7}]}})
    for width in (32,64):
        upper = float(2**width)
        for suffix, value in [('below',math.nextafter(upper,-math.inf)),
                ('first-outside',upper),('above',math.nextafter(upper,math.inf))]:
            integer = int(value)
            expected = {'error':{'code':'nested_write_array_gap', 'index':integer, 'length':0}} \
                if integer < 2**width else {'error':{'code':'nested_write_segment_invalid',
                    'reason':'kind_not_path_selector'}}
            add('write/'+str(width)+'/'+suffix, 'items=[]; items['+str(integer)
                +']=9; return(items)', expected, width)
    add('write/append','items=[]; items[0]=9; return(items)',{'ok':{'exact':[9]}})
    add('write/gap','items=[]; items[1]=9; return(items)',
        {'error':{'code':'nested_write_array_gap','index':1,'length':0}})
    add('write/signed','items=[10,20]; items[-1]=9; return(items)',{'ok':{'exact':[10,9]}})
    # These existing count/read coercions are intentionally bounded by a real
    # container, unlike identity-bearing metadata and nested-write diagnostics.
    add('bounded/take','return(take([1,2],100000000000000000000))',{'ok':{'exact':[1,2]}})
    add('bounded/read','items=[1,2]; return(items[100000000000000000000])',{'ok':{'exact':None}})
    result = dict(version=1,owner=c.OWNER,cases=rows,
        scope='Independent authored scalar, nested, helper/key, dense/signed/bounded and architecture-specific positive-write cases. Source decimal expansions identify binary64 values, not arbitrary-precision integer promises. Native, textual AST/compiled reconstruction, generated-plan and independently compiled emitted routes consume this exact fixture.')
    name = 'tests/numeric-conversion/programs.json'
    with (c.ROOT/name).open('x') as output:
        output.write(json.dumps(result,indent=2)+'\n')
    c.save('programs-inputs.json.gz',dict(producer=c.read(c.PREFIX+'programs.py'),
        numbers=c.read('tests/numeric-conversion/cases.json'),fixture=c.read(name)))
    print('Authored',len(rows),'numeric program cases; select the actual pointer width.')


if __name__ == '__main__':
    main()
