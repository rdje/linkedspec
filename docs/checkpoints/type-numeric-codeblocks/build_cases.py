"""Build finite public-call fixtures from the neutral contract and authored controls."""
import json
from pathlib import Path
import common as c

CONTRACT = 'capability_conformance/scalar_numeric_contract.json'
FIXTURE = 'tests/numeric-codeblocks/cases.json'
SYMBOLS = {'+': 'num_add', '-': 'num_sub', '*': 'num_mul', '/': 'num_div', '%': 'num_mod',
           '==': 'num_eq', '!=': 'num_ne', '>': 'num_gt', '>=': 'num_ge', '<': 'num_lt', '<=': 'num_le'}
CANONICAL = set('abs floor ceil round add sub mul div mod clamp min max eq ne gt ge lt le'.split())


def literal(value):
    if value is None:
        return 'undef'
    if isinstance(value, list):
        return '[' + ', '.join(map(literal, value)) + ']'
    if isinstance(value, dict):
        return '{' + ', '.join(json.dumps(key) + ': ' + literal(item) for key, item in value.items()) + '}'
    return json.dumps(value)


def build():
    contract = json.loads((c.ROOT / CONTRACT).read_bytes())
    names = {case['helper'] for case in contract['cases']}
    assert names == {'num_' + name for name in CANONICAL}
    rows = []

    def add_pair(name, helper, args, expected):
        values = ', '.join(map(literal, args))
        params = ['arg' + str(index) for index in range(len(args))]
        rows.append(dict(id='outside/' + name, body='return(' + helper + '(' + values + '))', expected=expected))
        rows.append(dict(id='deferred/' + name,
            body='cb = {|' + ', '.join(params) + '| return(' + helper + '(' + ', '.join(params)
                 + ')) }; return(cb(' + values + '))', expected=expected))

    for case in contract['cases']:
        add_pair('canonical/' + case['id'], case['helper'], case['args'], case['expected'])
    words = {name.removeprefix('num_'): name for name in sorted(names)}
    for alias, helper in sorted({**words, **SYMBOLS}.items()):
        case = next(case for case in contract['cases'] if case['helper'] == helper and case['expected'] is not None)
        add_pair('alias/' + alias, alias, case['args'], case['expected'])
    for method, helper in sorted(words.items()):
        case = next(case for case in contract['cases'] if case['helper'] == helper and case['expected'] is not None)
        prefix = 'score = ' + literal(case['args'][0]) + '; '
        call = 'score.' + method + '(' + ', '.join(map(literal, case['args'][1:])) + ')'
        for route in ('outside', 'deferred'):
            body = prefix + ('return(' + call + ')' if route == 'outside' else
                'cb = {|| return(' + call + ') }; return(cb())')
            rows.append(dict(id=route + '/receiver/' + method, body=body, expected=case['expected']))

    effects = [
        ('ordered-operands', 'order = ""; left = {|| order = cat(order,"L"); return(2) }; '
         'right = {|| order = cat(order,"R"); return(3) }; ', 'num_sub(left(),right())',
         'return([out,order])', [-1, 'LR']),
        ('early-read', 'value = 2; change = {|| value = 9; return(3) }; ', 'num_add(value,change())',
         'return([out,value])', [5, 9]),
        ('once-each', 'trace = ""; tick = {|| trace = cat(trace,"x"); return(length(trace)) }; ',
         'num_add(tick(),tick(),tick())', 'return([out,trace])', [6, 'xxx']),
        ('invalid-arity-skips-operands', 'trace = ""; tick = {|| trace = cat(trace,"x"); return(2) }; ',
         'num_sub(tick())', 'return([out,trace])', [None, '']),
        ('invalid-value-eager-operands', 'trace = ""; tick = {|| trace = cat(trace,"x"); return(2) }; ',
         'num_add([1],tick())', 'return([out,trace])', [None, 'x']),
        ('typed-comparison', '', 'num_gt(2,1)', 'return(out)', 1),
        ('receiver-continuation', 'score = -3.2; ', 'score.abs().ceil().add(2).mul(3)', 'return(out)', 18),
        ('comparison-terminal', 'score = 3; ', 'score.gt(1).add(2)', 'return(out)', None),
    ]
    for name, prefix, expression, suffix, expected in effects:
        for route in ('outside', 'deferred'):
            evaluation = 'out = ' + expression + '; ' if route == 'outside' else (
                'cb = {|| return(' + expression + ') }; out = cb(); ')
            rows.append(dict(id=route + '/effect/' + name, body=prefix + evaluation + suffix, expected=expected))
    rows.extend([
        dict(id='deferred/repeated-side-effects', body='counter = 0; cb = {|| counter = num_add(counter,1); '
             'return(counter) }; first = cb(); second = cb(); return([first,second,counter])', expected=[1, 2, 2]),
        dict(id='deferred/parameter-restoration', body='arg = 9; cb = {|arg| return(num_add(arg,1)) }; '
             'out = cb(2); return([out,arg])', expected=[3, 9]),
        dict(id='deferred/helper-precedence', body='num_add = {|| return(99) }; cb = {|| return(num_add(2,3)) }; '
             'return(cb())', expected=5),
        dict(id='control/registered-function', functions='fn plus(a,b) { return(num_add(a,b)) }\n',
             body='cb = {|| return(plus(2,3)) }; return(cb())', expected=5),
        dict(id='control/boolean-literal-owned-startup35', body='cb = {|| return(true) }; return(cb())', expected=1),
    ])
    for name in ('unavailable_numeric_helper', 'num_not_admitted'):
        rows.append(dict(id='control/unknown/' + name, body='cb = {|| return(' + name + '(2,3)) }; return(cb())',
                         error=dict(code='unknown_helper', name=name)))
    for expression, name in [('num_sum([1,2])', 'num_sum'), ('num_min([2,1])', 'num_min'),
                             ('[2,1].min()', 'min')]:
        rows.append(dict(id='separate-aggregate/' + name, body='cb = {|| return(' + expression + ') }; return(cb())',
                         error=dict(code='unknown_helper', name=name)))
    assert len(rows) == len({row['id'] for row in rows})
    return dict(contract=CONTRACT, canonical=sorted(names), words=words, symbols=SYMBOLS, cases=rows)


if __name__ == '__main__':
    target = c.ROOT / FIXTURE
    target.parent.mkdir(parents=True, exist_ok=True)
    raw = (json.dumps(build(), sort_keys=True, separators=(',', ':')) + '\n').encode()
    with target.open('xb') as output:
        output.write(raw)
    print('Numeric fixture:', len(build()['cases']), 'cases; 18 canonical/18 word/11 symbol/18 receiver spellings')
