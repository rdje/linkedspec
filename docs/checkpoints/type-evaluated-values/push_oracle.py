"""Distinguish stored-value rebinding from shared-reference mutation before correcting an oracle."""
import gzip
import json
import common as c

prepared = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'green-inputs.json.gz')).read_bytes()))
inputs = dict(prepared['inputs'])
for path in ('docs/knowledge/perl-uniform-binding-runtime.md', c.PREFIX + 'push_oracle.py'):
    inputs[path] = c.read(path)
assert c.unchanged(inputs)
cases = [dict(id='saved-binding-push-control', body='slot = ["old"]; saved = slot; change = {|| push(slot,"new"); return("changed") }; change(); return([saved, slot])'),
         dict(id='saved-binding-without-push', body='slot = ["old"]; saved = slot; return([saved, slot])')]
for case in cases:
    case.update(spec='Top: /x/\n I { ' + case['body'] + ' }\n', input='x')
c.write_new(c.PREFIX + 'push-oracle-inputs.json.gz', dict(inputs=inputs, cases=cases,
    scope='Calls finish before the constructor in both controls, so sibling expression timing '
          'cannot influence them. The accepted uniform-binding fact and unchanged BindingRuntime '
          'producer establish independent updated values. Original question/incorrect expectation '
          'and the actual first candidate failure remain retained without alteration.'), packed=True)
run = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(cases).encode())
c.write_new(c.PREFIX + 'push-oracle-run.json', dict(run=run, inputs_unchanged=c.unchanged(inputs)))
assert run['returncode'] == 0 and c.unchanged(inputs)
print('Independent saved-binding controls retained before any expected-value correction')
