"""Correct one rejected expectation using an independent saved-binding control and existing contract."""
import gzip
import json
import common as c

path = 'tests/evaluated-values/cases.json'
before = c.read(path)
authority = json.loads((c.ROOT / (c.PREFIX + 'case-authority.json')).read_bytes())
assert before == authority['fixture']
original_green = json.loads(gzip.decompress((c.ROOT / (c.PREFIX + 'green-run.json.gz')).read_bytes()))
assert original_green['inputs_unchanged'] and original_green['runs'][1]['returncode'] != 0
oracle = json.loads((c.ROOT / (c.PREFIX + 'push-oracle-run.json')).read_bytes())
assert oracle['inputs_unchanged'] and oracle['run']['returncode'] == 0
output = c.decode(oracle['run']['stdout_base64'])
assert output.count(b'\nSOURCE_TYPE_MODEL_JSON ') == 1
prelude, raw = output.split(b'\nSOURCE_TYPE_MODEL_JSON ')
assert not prelude
rows = {row['id']: row for row in json.loads(raw)['rows']}
for name, expected in (
    ('saved-binding-push-control', [['old'], ['old', 'new']]),
    ('saved-binding-without-push', [['old'], ['old']]),
):
    row = rows[name]
    assert row['live']['value'] == row['generated']['value']['value'] == expected
document = json.loads(c.decode(before['base64']))
matched = [case for case in document['cases'] if case['id'] == 'array-mutation-question']
assert len(matched) == 1
assert matched[0]['expected'] == [['old', 'new'], 'changed', ['old', 'new']]
matched[0]['expected'] = [['old'], 'changed', ['old', 'new']]
document['scope'] = ('Evaluated-value regressions. push creates an updated binding, so the earlier value '
    'remains old. The rejected first plan confused late scalar-slot observation with shared-reference '
    'mutation. Independent saved-binding controls and the existing copy-on-write fact justify this '
    'one correction. Pure host reference-identity controls are separate. Boolean arguments avoid '
    'the existing literal-kind defect; cat state avoids the owned numeric-body helper gap.')
after_raw = (json.dumps(document, sort_keys=True, indent=1) + '\n').encode()
after = dict(base64=c.encode(after_raw), sha256=c.sha(after_raw), mode=before['mode'])
c.write_new(c.PREFIX + 'oracle-correction.json.gz', dict(before=before, after=after,
    producer=c.read(c.PREFIX + 'correct_oracle.py'), helper=c.read(c.PREFIX + 'common.py'),
    canonical_fact=c.read('docs/knowledge/perl-uniform-binding-runtime.md'),
    independent_oracle=c.read(c.PREFIX + 'push-oracle-run.json'),
    first_candidate_run_sha256=c.sha((c.ROOT / (c.PREFIX + 'green-run.json.gz')).read_bytes()),
    scope='One expected early value and its scope description change. Every original case, '
          'wrong expectation, producer, syntax-valid RED and first candidate failure remain '
          'recoverable. A distinct corrected baseline must reject at the real accepted runtime.'), packed=True)
(c.ROOT / path).write_bytes(after_raw)
print('One mistaken alias oracle corrected from independent saved-binding/copy-on-write evidence')
