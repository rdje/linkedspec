"""Retain distinguishing public controls for the two surprising initial model values."""
import gzip
import json
import common as c

snapshot = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'source-inputs.json.gz')).read_bytes()))
assert c.unchanged(snapshot['inputs'])
cases = json.loads((c.ROOT / (c.PREFIX + 'distinguish-cases.json')).read_bytes())
for case in cases:
    case.update(spec=case.get('functions', '') + 'Top: /x/\n I { ' + case['body'] + ' }\n', input='x')
inputs = dict(snapshot['inputs'])
for name in ('distinguish.py', 'distinguish-cases.json', 'model.pl'):
    inputs[c.PREFIX + name] = c.read(c.PREFIX + name)
c.write_new(c.PREFIX + 'distinguish-inputs.json.gz', dict(inputs=inputs, cases=cases,
    scope='Exact unchanged owned source and public actor before new distinguishing observations. '
          'No original model result is refreshed and no runtime behavior is modified.'), packed=True)
run = c.run(['perl', '-Iperl', c.PREFIX + 'model.pl'], input=json.dumps(cases).encode())
c.write_new(c.PREFIX + 'distinguish-run.json.gz', dict(run=run, inputs_unchanged=c.unchanged(inputs)), packed=True)
print('Distinguishing public observations exit:', run['returncode'], 'cases:', len(cases))
