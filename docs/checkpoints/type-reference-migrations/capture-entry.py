"""Observe actual matched child-entry context, preserving root-init observations."""
import gzip
import json
import common as c

before = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'native-inputs.json.gz')).read_bytes()))
assert c.unchanged(before['inputs'])
cases = []
for case in before['cases'][:24]:
    selected = dict(case)
    selected['spec'] = 'Root::\n -> Top .push\n LX { return(first(Root)) }\n\n' + case['spec']
    cases.append(selected)
for name, body in [('retired-a-scoped', 'return_a(Top)'),
                   ('retired-a-scoped-extra', 'return_a(Top, "extra")'),
                   ('retired-m-scoped', 'return_m(Top)'),
                   ('retired-ma-scoped', 'return_ma(Top)'),
                   ('retired-im-scoped', 'return_im(Top, "tag")'),
                   ('retired-imatch-scoped', 'return_imatch(Top, "tag")'),
                   ('retired-array-unscoped', 'return_array("tag", "payload")')]:
    cases.append(dict(id=name, body=body, input='abc', spec='Root::\n -> Top .push\n LX { return(first(Root)) }\n\nTop: /(ab)(c)/\n I { set(Top, ["seed"]); ' + body + ' }\n'))
inputs = dict(before['inputs'])
inputs[c.PREFIX + 'capture-entry.py'] = c.read(c.PREFIX + 'capture-entry.py')
c.write_new(c.PREFIX + 'entry-inputs.json.gz', dict(inputs=inputs, cases=cases,
    distinction='Original root I executes before that root regex supplies a match. '
                'These separately retained child-entry probes receive the matched incoming edge. '
                'No original input or output is refreshed.'), packed=True)
run = c.run(['perl', '-Iperl', c.PREFIX + 'native.pl'], input=json.dumps(cases).encode())
c.write_new(c.PREFIX + 'entry-run.json.gz', dict(run=run, unchanged=c.unchanged(inputs)), packed=True)
print('Matched-entry observation exit:', run['returncode'], 'cases:', len(cases))
