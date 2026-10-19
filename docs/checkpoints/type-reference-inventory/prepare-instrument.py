"""Retain the no-write first-writer failure and a distinct corrected producer."""
import gzip
import json
import common as c

inputs = {c.PREFIX + name: c.read(c.PREFIX + name) for name in
          ('prepare_docs.py', 'prepare_docs_final.py', 'common.py', 'prepare-instrument.py')}
preserved = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'preservation.json.gz')).read_bytes()))
inputs[c.OLD_CLAIM] = c.read(c.OLD_CLAIM)
c.write_new(c.PREFIX + 'writer-inputs.json.gz', dict(inputs=inputs,
    first_combined_log=c.read('.linkedspec-data/verification/type-inventory-prepare-docs.log'),
    limitation='First invocation retained combined shell channels only; exact distinct recurrence follows.'), packed=True)
red = c.run(['python3', c.PREFIX + 'prepare_docs.py'])
assert red['returncode'] == 1 and b'ValueError: not enough values to unpack' in c.decode(red['stderr_base64'])
assert c.unchanged(inputs)
for item in preserved['live'].values():
    assert all(c.read(path)['sha256'] == expected['sha256'] and c.read(path)['mode'] == expected['mode']
               for path, expected in item['inputs'].items())
assert not (c.ROOT / (c.PREFIX + 'docs-proposals.json.gz')).exists()
result = c.run(['python3', c.PREFIX + 'prepare_docs_final.py'])
c.write_new(c.PREFIX + 'writer-run.json', dict(first_distinct_recurrence=red, corrected=result,
    original_no_write_verified=True))
assert result['returncode'] == 0, result
print('Original no-write frontmatter RED retained; separate corrected writer PASS')
