"""Close scalar receiver wrong-arity coverage against the admitted signatures."""
import json
import common as c
from build_cases import CANONICAL


def build():
    rows = []
    for method in sorted(CANONICAL):
        if method in ('abs', 'floor', 'ceil', 'round'):
            args = '1'
        elif method in ('add', 'mul', 'min', 'max'):
            args = ''
        elif method == 'clamp':
            args = '1,2,3'
        else:
            args = '1,2'
        expression = 'read().' + method + '(' + args + ')'
        prefix = 'trace = ""; read = {|| trace = cat(trace,"r"); return(3) }; '
        for route in ('outside', 'deferred'):
            evaluation = 'out = ' + expression + '; ' if route == 'outside' else (
                'cb = {|| return(' + expression + ') }; out = cb(); ')
            rows.append(dict(id=route + '/receiver-arity/' + method,
                body=prefix + evaluation + 'return([out,trace])',
                expected=[None, 'r' if method in ('min', 'max') else '']))
    return dict(cases=rows)


if __name__ == '__main__':
    with (c.ROOT / 'tests/numeric-codeblocks/receiver-invalid.json').open('xb') as output:
        output.write((json.dumps(build(), sort_keys=True, separators=(',', ':')) + '\n').encode())
    print('Receiver wrong-arity fixture:', len(build()['cases']), 'cases')
