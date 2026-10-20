"""One-shot observation with a closed input set for each distinct epoch."""
import json
import re
import sys
import common as c
import oracle


def main():
    epoch, *fixtures = sys.argv[1:]
    assert re.fullmatch('[a-z][a-z0-9-]+', epoch) and fixtures
    assert len(fixtures) == len(set(fixtures))
    plan = dict(cases=[])
    for path in fixtures:
        plan['cases'].extend(json.loads((c.ROOT / path).read_bytes())['cases'])
    assert len(plan['cases']) == len({case['id'] for case in plan['cases']})
    paths = set(c.load('red-inputs.json')['inputs'])
    paths.update(fixtures)
    paths.add(c.PREFIX + 'red-inputs.json')
    paths.update(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / c.PREFIX).iterdir()
                 if path.suffix in ('.py', '.pl'))
    inputs = {path: c.identity(path) for path in sorted(paths)}
    c.write_new(epoch + '-inputs.json', dict(inputs=inputs, plan=plan, fixtures=fixtures,
        sources={path: c.read(path) for path in (c.SOURCE, 'perl/LinkedSpec/Numeric.pm',
                                               'perl/LinkedSpec/ActionIR/MethodLowering.pm')},
        scope='All owned Perl sources, neutral JSON contracts, fixture bytes and supplied proof producers '
              'precede descriptor/Get/fresh emitted execution. System Perl/core modules are read-only prerequisites.'))
    run = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(plan).encode())
    c.write_new(epoch + '-run.json.gz', dict(run=run, inputs_unchanged=c.unchanged(inputs)))
    assert c.unchanged(inputs)
    failures = oracle.mismatches(run, plan, inputs)
    c.write_new(epoch + '-review.json', dict(failures=failures,
        producer=c.read(c.PREFIX + 'observe.py'), oracle=c.read(c.PREFIX + 'oracle.py')))
    print(epoch, ':', len(plan['cases']), 'cases;', len(failures), 'mismatches;', len(inputs), 'inputs')
    print('Mismatches:', failures)


if __name__ == '__main__':
    main()
