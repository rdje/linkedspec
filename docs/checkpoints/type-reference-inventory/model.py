"""Observe named public type/value probes and neutral scalar fixtures before assertions."""
import gzip
import json
import common as c

snapshot = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'source-inputs.json.gz')).read_bytes()))
assert c.unchanged(snapshot['inputs'])
cases = json.loads((c.ROOT / (c.PREFIX + 'model-cases.json')).read_bytes())
for case in cases:
    case.update(spec='Top: /x/\n I { ' + case['body'] + ' }\n', input='x')
for name in ('scalar_text', 'scalar_numeric'):
    contract = json.loads((c.ROOT / ('capability_conformance/' + name + '_contract.json')).read_bytes())
    cases.append(dict(id='neutral-' + name, spec=contract['spec_source'], input='xx'))
inputs = dict(snapshot['inputs'])
for name in ('model.py', 'model.pl', 'model-cases.json'):
    inputs[c.PREFIX + name] = c.read(c.PREFIX + name)
c.write_new(c.PREFIX + 'model-inputs.json.gz', dict(inputs=inputs, cases=cases,
    source_snapshot_sha256=c.sha((c.ROOT / (c.PREFIX + 'source-inputs.json.gz')).read_bytes()),
    scope='Named current public Get/descriptor and independently loaded generated-source observations. '
          'All owned source/test/contract/book inputs precede commands. System Perl is an external '
          'read-only prerequisite. Question cases are observations, not prior acceptance assertions.'), packed=True)
run = c.run(['perl', '-Iperl', c.PREFIX + 'model.pl'], input=json.dumps(cases).encode())
c.write_new(c.PREFIX + 'model-run.json.gz', dict(run=run, inputs_unchanged=c.unchanged(inputs)), packed=True)
print('Public type/model observation exit:', run['returncode'], 'named cases:', len(cases))
