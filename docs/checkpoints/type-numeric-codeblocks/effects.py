"""Capture a distinct accepted-source effect population and saved-binding controls."""
import json
import common as c
import oracle

FIXTURE = 'tests/numeric-codeblocks/effects.json'


def cases():
    rows = []
    for method, expected in [('add', 5), ('mul', 6), ('min', 2), ('max', 3)]:
        prefix = 'value = 2; change = {|| value = 9; return(3) }; '
        for form, expression in [('call', 'num_' + method + '(value,change())'),
                                 ('receiver', 'value.' + method + '(change())')]:
            for route in ('outside', 'deferred'):
                evaluation = 'out = ' + expression + '; ' if route == 'outside' else (
                    'cb = {|| return(' + expression + ') }; out = cb(); ')
                rows.append(dict(id=route + '/snapshot/' + form + '/' + method,
                    body=prefix + evaluation + 'return([out,value])', expected=[expected, 9]))
        rows.append(dict(id='control/saved-slot/' + method,
            body='value = 2; saved = value; change = {|| value = 9; return(3) }; '
                 'out = num_' + method + '(saved,change()); return([out,value,saved])',
            expected=[expected, 9, 2]))
    return dict(cases=rows)


def main():
    plan = cases()
    with (c.ROOT / FIXTURE).open('xb') as output:
        output.write((json.dumps(plan, sort_keys=True, separators=(',', ':')) + '\n').encode())
    paths = set(c.load('red-inputs.json')['inputs'])
    paths.update((FIXTURE, c.PREFIX + 'effects.py', c.PREFIX + 'red-inputs.json',
                  c.PREFIX + 'red-run.json.gz'))
    inputs = {path: c.identity(path) for path in sorted(paths)}
    c.write_new('effect-inputs.json', dict(inputs=inputs, plan=plan,
        runtime=c.read(c.SOURCE), lowering=c.read('perl/LinkedSpec/ActionIR/MethodLowering.pm'),
        scope='Distinct extension; original230-case epoch remains byte-identical. '
              'All four variadic numeric producers get ordinary/deferred function/receiver probes '
              'and independent saved-slot controls before production edits.'))
    original = json.loads(c.decode(c.load('red-run.json.gz')['run']['stdout_base64']))
    row = next(row for row in original['rows'] if row['id'] == 'outside/effect/early-read')
    emitted = row['generated']['source']
    start = emitted.index('my @__ls_num_add_terms')
    end = emitted.index("LinkedSpec::Numeric::evaluate('num_add', @__ls_num_add_terms)", start)
    excerpt = emitted[start:end + len("LinkedSpec::Numeric::evaluate('num_add', @__ls_num_add_terms)")]
    c.write_new('diagnosis.json', dict(producer=c.read(c.PREFIX + 'effects.py'),
        source_line=emitted[:start].count('\n') + 1, emitted_excerpt=excerpt,
        observed={route: row[route]['value'] for route in ('native', 'generated')},
        mechanism='Variadic numeric emission leaves the caller scalar on the Perl operand stack '
                  'while a later invocation rebinds it. Deferred calls/receivers separately miss dispatch.'))
    print('Emitted mechanism:', excerpt)
    run = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(plan).encode())
    c.write_new('effect-red-run.json.gz', dict(run=run, inputs_unchanged=c.unchanged(inputs)))
    assert c.unchanged(inputs)
    failures = oracle.mismatches(run, plan, inputs)
    controls = [case['id'] for case in plan['cases'] if case['id'] not in failures]
    c.write_new('effect-red-review.json', dict(failures=failures, controls=controls,
        producer=c.read(c.PREFIX + 'effects.py'), oracle=c.read(c.PREFIX + 'oracle.py')))
    print('Effect baseline:', len(failures), 'RED;', len(controls), 'healthy controls')
    print('Failures:', failures)
    print('Controls:', controls)


if __name__ == '__main__':
    main()
