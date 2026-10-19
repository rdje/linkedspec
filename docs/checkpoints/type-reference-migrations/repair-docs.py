"""Preserve and reproduce the broad route matcher before a header-only writer."""
import gzip
import json
import common as c

old = c.PREFIX + 'prepare-docs.py'
preserved = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'preservation.json.gz')).read_bytes()))
paths = preserved['route_facts'] + ['docs/knowledge/retired-return-helpers-canonical-rewrite.md',
    'docs/knowledge/actionir-return-node-retired-to-return.md', old, c.PREFIX + 'common.py',
    c.PREFIX + 'preservation.json.gz', c.PREFIX + 'repair-docs.py']
inputs = {path: c.read(path) for path in paths}
original = c.decode(inputs[old]['base64']).decode()
needle = "    changed, count = re.subn(r'^reverify: .*$', lambda _: 'reverify: ' + json.dumps(route), text, flags=re.M)"
assert original.count(needle) == 1
replacement = "    header, body = text.split('\\n---\\n', 1)\n" + needle.replace(', text, flags=re.M)', ', header, flags=re.M)') + "\n    changed += '\\n---\\n' + body"
final = original.replace(needle, replacement, 1).replace("producer=c.read(c.PREFIX + 'prepare-docs.py')", "producer=c.read(c.PREFIX + 'prepare-docs-final.py')")
c.write_new(c.PREFIX + 'docs-repair-inputs.json.gz', dict(inputs=inputs,
    final_base64=c.encode(final.encode()), original_outer_failure=c.read('.linkedspec-data/verification/type-migrations-native-review.log')
    if False else 'Original tool session42510 retained exit1 and full assert-count traceback. No documentation writer artifact or documentation write occurred.'), packed=True)
run = c.run(['python3', old])
assert run['returncode'] == 1 and b'assert count == 1' in c.decode(run['stderr_base64'])
assert c.unchanged(inputs) and not (c.ROOT / (c.PREFIX + 'docs-proposals.json.gz')).exists()
c.write_new(c.PREFIX + 'docs-repair.json', dict(result='PASS', exact_recurrence=run,
    supplied_bytes_modes_unchanged=True, no_documentation_written=True,
    distinction='Six cards retain multiple historical reverify lines in their bodies. '
                'Only the single current front-matter field may be rerouted. Original writer remains unchanged.'))
with (c.ROOT / (c.PREFIX + 'prepare-docs-final.py')).open('x') as output:
    output.write(final)
print('Broad route matcher RED retained; distinct header-only writer prepared')
