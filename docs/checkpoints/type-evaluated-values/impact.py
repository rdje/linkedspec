"""Observe adjacent public forms and independent host materialization mechanisms."""
import gzip
import json
import common as c

snapshot = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'source-inputs.json.gz')).read_bytes()))
assert c.unchanged(snapshot['inputs'])
cases = json.loads((c.ROOT / (c.PREFIX + 'impact-cases.json')).read_bytes())
for case in cases:
    case.update(spec=case.get('functions', '') + 'Top: /x/\n I { ' + case['body'] + ' }\n', input='x')
inputs = dict(snapshot['inputs'])
for name in ('impact.py', 'impact-cases.json', 'probe.pl', 'host.pl'):
    inputs[c.PREFIX + name] = c.read(c.PREFIX + name)
c.write_new(c.PREFIX + 'impact-inputs.json.gz', dict(inputs=inputs, cases=cases,
    scope='Complete current source plus exact public and host actors precede commands. These '
          'are observations, not accepted new expectations. Keep array-mutation interpretation '
          'and existing callable-body behavior qualified until contract/independent review.'), packed=True)
public = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(cases).encode())
host = c.run(['perl', c.PREFIX + 'host.pl'])
c.write_new(c.PREFIX + 'impact-run.json.gz', dict(public=public, host=host,
    inputs_unchanged=c.unchanged(inputs)), packed=True)
print('Public/host impact exits:', public['returncode'], host['returncode'], 'cases:', len(cases))
