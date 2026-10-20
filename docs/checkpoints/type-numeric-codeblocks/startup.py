"""Close duplicate startup87.3 intake with its exact two authored lifecycle sources."""
import json
import common as c
import context
import oracle_final as oracle

PLAN = dict(cases=[dict(id='startup87.3/' + name,
    source='Top::\n I { f = {|| return(' + expression + ') }; out = f() }\n /x/ E { return(out) }\n',
    expected=7) for name, expression in [('named', 'div(14,2)'), ('symbol', '/(14,2)')]])


def main():
    extras = [c.PREFIX + name for name in ('common.py', 'context.py', 'startup.py', 'startup_probe.pl', 'oracle_final.py')]
    inputs = context.snapshot(extras)
    inputs['plan'] = PLAN
    inputs['limits'] = 'Current exact intake replay; original dated intake is preserved, not a reconstructed old process.'
    c.write_new('startup-inputs.json.gz', inputs)
    run = c.run(['perl', '-Iperl', c.PREFIX + 'startup_probe.pl'], input=json.dumps(PLAN).encode())
    c.write_new('startup-run.json.gz', dict(run=run, inputs_unchanged=c.unchanged(inputs['inputs'])))
    assert not oracle.mismatches(run, PLAN, inputs['inputs']) and c.unchanged(inputs['inputs'])
    print('Startup87.3 exact named/symbol lifecycle intake:2 descriptor/Get/fresh-generated GREEN')


if __name__ == '__main__':
    main()
