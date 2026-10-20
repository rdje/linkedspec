"""Author independent splice and invalid-call evaluation controls before repair."""
import json
import common as c


def build():
    rows = []
    for method, args, expected in [('add', '[1,2]),3', 6), ('mul', '[2,3]),4', 24),
                                   ('min', '[8,2]),3', 2), ('max', '[8,2]),3', 8)]:
        rows.append(dict(id='control/splice/' + method,
            body='return(num_' + method + '(flat(' + args + '))', expected=expected))
    prefix = 'trace = ""; read = {|| trace = cat(trace,"r"); return(3) }; '
    for name, expression, expected in [
        ('terminal-skips-receiver', 'read().gt(1).add(2)', [None, '']),
        ('receiver-arity-skips-receiver', 'read().sub(1,2)', [None, '']),
        ('single-min-evaluates', 'num_min(read())', [None, 'r']),
        ('single-receiver-min-evaluates', 'read().min()', [None, 'r']),
    ]:
        for route in ('outside', 'deferred'):
            evaluation = 'out = ' + expression + '; ' if route == 'outside' else (
                'cb = {|| return(' + expression + ') }; out = cb(); ')
            rows.append(dict(id=route + '/stability/' + name,
                body=prefix + evaluation + 'return([out,trace])', expected=expected))
    return dict(cases=rows)


if __name__ == '__main__':
    target = c.ROOT / 'tests/numeric-codeblocks/stability.json'
    with target.open('xb') as output:
        output.write((json.dumps(build(), sort_keys=True, separators=(',', ':')) + '\n').encode())
    print('Stability fixture:', len(build()['cases']), 'cases')
