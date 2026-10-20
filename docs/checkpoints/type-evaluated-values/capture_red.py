"""Retain syntax-valid baseline RED before changing any runtime implementation."""
import gzip
import json
import common as c

snapshot = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'source-inputs.json.gz')).read_bytes()))
regression = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'regression-inputs.json.gz')).read_bytes()))
inputs = dict(snapshot['inputs'])
for path in inputs:
    if path == 't/callable_codeblock_literal_contract.t':
        assert c.read(path) == regression['after']
        inputs[path] = regression['after']
    else:
        assert c.read(path) == inputs[path], path
for path in ('tests/evaluated-values/cases.json', c.PREFIX + 'capture_red.py',
             c.PREFIX + 'probe.pl', 'docs/knowledge/hash-literal-dynamic-key-contract.md',
             'docs/knowledge/perl-callable-codeblock-dynamic-invocation.md',
             'docs/knowledge/perl-codeblock-boolean-literal-kind-drift.md'):
    inputs[path] = c.read(path)
cases = json.loads((c.ROOT / 'tests/evaluated-values/cases.json').read_bytes())['cases']
for case in cases:
    case.update(spec=case.get('functions', '') + 'Top: /x/\n I { ' + case['body'] + ' }\n', input='x')
c.write_new(c.PREFIX + 'red-inputs.json.gz', dict(inputs=inputs, cases=cases,
    scope='All current runtime/authority/test inputs plus the authored regression source precede '
          'the unchanged-runtime baseline. Only the declared test subtest and new fixture differ '
          'from accepted runtime sources. Original impact questions/results remain unchanged.'), packed=True)
syntax = c.run(['perl', '-c', '-Iperl', 't/callable_codeblock_literal_contract.t'])
tap = c.run(['prove', '-v', '-Iperl', 't/callable_codeblock_literal_contract.t'])
public = c.run(['perl', '-Iperl', c.PREFIX + 'probe.pl'], input=json.dumps(cases).encode())
c.write_new(c.PREFIX + 'red-run.json.gz', dict(syntax=syntax, tap=tap, public=public,
    inputs_unchanged=c.unchanged(inputs)), packed=True)
assert syntax['returncode'] == 0 and tap['returncode'] != 0 and public['returncode'] == 0
assert b'constructed values and callable arguments retain evaluated values' in c.decode(tap['stdout_base64'])
assert c.unchanged(inputs)
print('Syntax-valid unchanged-runtime regression RED retained with complete public observations')
