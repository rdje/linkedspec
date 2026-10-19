"""Observe the historical-shape ma replacement after the source-bound discovery."""
import gzip
import json
import common as c

earlier = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'entry-inputs.json.gz')).read_bytes()))
assert c.unchanged(earlier['inputs'])
cases = []
for name, body, pattern, text in [
 ('ma-flat', 'return(array("?Top:", flat_array(entry_groups()), copy(Top)))', '(ab)(c)', 'abc'),
 ('m-empty', 'return(array("?Top:", flat_array(entry_groups())))', 'abc', 'abc'),
 ('ma-empty', 'return(array("?Top:", flat_array(entry_groups()), copy(Top)))', 'abc', 'abc'),
]:
 cases.append(dict(id=name, body=body, input=text, spec='Root::\n -> Top .push\n LX { return(first(Root)) }\n\nTop: /' + pattern + '/\n I { set(Top, ["seed"]); ' + body + ' }\n'))
inputs = dict(earlier['inputs'])
inputs[c.PREFIX + 'capture-flat-ma.py'] = c.read(c.PREFIX + 'capture-flat-ma.py')
c.write_new(c.PREFIX + 'flat-ma-inputs.json.gz', dict(inputs=inputs, cases=cases), packed=True)
run = c.run(['perl', '-Iperl', c.PREFIX + 'native.pl'], input=json.dumps(cases).encode())
c.write_new(c.PREFIX + 'flat-ma-run.json.gz', dict(run=run, unchanged=c.unchanged(inputs)), packed=True)
print('Flat ma and empty-groups native exit:', run['returncode'])
