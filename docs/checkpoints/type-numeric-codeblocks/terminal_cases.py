"""Exercise numeric terminal boundaries with nonnumeric tails and separate values."""
import json
import common as c


def build():
    rows = []
    prefix = 'trace = ""; read = {|| trace = cat(trace,"r"); return(3) }; '
    expressions = [(method + '-cat', 'read().' + method + '(1).cat("x")')
                   for method in ('eq', 'ne', 'gt', 'ge', 'lt', 'le')]
    expressions.extend([
        ('gt-unknown-tail', 'read().gt(1).unavailable_numeric_tail()'),
        ('cat-prefix-gt-tail', 'read().cat("").gt(1).cat("x")'),
    ])
    for name, expression in expressions:
        for route in ('outside', 'deferred'):
            evaluation = 'out = ' + expression + '; ' if route == 'outside' else (
                'cb = {|| return(' + expression + ') }; out = cb(); ')
            rows.append(dict(id=route + '/mixed-terminal/' + name,
                body=prefix + evaluation + 'return([out,trace])', expected=[None, '']))
    for route in ('outside', 'deferred'):
        expression = 'result = read().gt(1); return(result.cat("x"))'
        evaluation = 'out = { ' + expression + ' }; ' if route == 'outside' else (
            'cb = {|| ' + expression + ' }; out = cb(); ')
        rows.append(dict(id=route + '/control/separate-comparison-value',
            body=prefix + 'result = undef; ' + evaluation + 'return([out,trace])', expected=['1x', 'r']))
    rows.extend([
        dict(id='deferred/control/unknown-receiver-valid-numeric',
            body='cb = {|| return(missing_numeric_input().add(1)) }; return(cb())',
            error=dict(code='unknown_helper', name='missing_numeric_input')),
        dict(id='deferred/control/unknown-method-valid-numeric',
            body='score = 3; cb = {|| return(score.unavailable_numeric_method().add(1)) }; return(cb())',
            error=dict(code='unknown_helper', name='unavailable_numeric_method')),
    ])
    return dict(cases=rows)


if __name__ == '__main__':
    with (c.ROOT / 'tests/numeric-codeblocks/terminals.json').open('xb') as output:
        output.write((json.dumps(build(), sort_keys=True, separators=(',', ':')) + '\n').encode())
    print('Numeric terminal boundary fixture:', len(build()['cases']), 'cases')
