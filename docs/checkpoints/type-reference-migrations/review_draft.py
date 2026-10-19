"""Review the complete uncommitted draft and its distinct supplied replay outcomes."""
import gzip
import json
import common as c
import normalize_inc
import controls


def load(name):
    value = (c.ROOT / (c.PREFIX + name)).read_bytes()
    return json.loads(gzip.decompress(value) if name.endswith('.gz') else value)


def review():
    raw = (c.ROOT / (c.PREFIX + 'first-draft.json.gz')).read_bytes()
    draft = json.loads(gzip.decompress(raw))
    baseline = load('first-baseline.json')
    assert baseline['snapshot_sha256'] == c.sha(raw) and baseline['all_supplied_bytes_modes_unchanged']
    original = draft['original']
    assert c.sha(c.decode(original['base64'])) == original['sha256']
    claim = json.loads(c.decode(original['base64']))
    bindings = claim['claims'][0]['durability']['inputs']
    assert len(bindings) == 355 and len(c.decode(original['base64'])) == 60395
    preflight = json.loads(c.decode(draft['preflight']['base64']))
    assert preflight['draft_base64'] == original['base64'] and preflight['draft_sha256'] == original['sha256']
    for binding in bindings:
        item = draft['inputs'][binding['path']]
        assert c.sha(c.decode(item['base64'])) == item['sha256'] == binding['sha256']
        assert item['mode'] == preflight['input_modes'][binding['path']]
    expected = b'Current migration publication PASS: 355 inputs; 60395 bytes;17 payloads;five controls;prior208/full39111\n'
    observed = baseline['readonly_baseline']
    assert observed['returncode'] == 0 and c.decode(observed['stdout_base64']) == expected
    assert not c.decode(observed['stderr_base64'])
    red = baseline['distinguishing_public_red']
    assert red['returncode'] == 1 and b'42 occurrences, expected 40' in c.decode(red['stderr_base64'])
    first = load('first-replay.json')
    assert first['unchanged'] and first['run']['returncode'] == 1
    assert b'declared external read-only Perl prerequisite' in c.decode(first['run']['stderr_base64'])
    partial = load('normalized-draft-run.json')
    assert partial['unchanged'] and partial['run']['returncode'] == 1
    assert b'FileNotFoundError' in c.decode(partial['run']['stderr_base64'])
    preparation = load('complete-draft-inputs.json.gz')
    assert preparation['snapshot_sha256'] == c.sha(raw)
    assert preparation['normalizer'] == c.read(c.PREFIX + 'normalize_inc.py')
    source = c.decode(draft['inputs'][c.PREFIX + 'review_native.py']['base64']).decode()
    old = preparation['exact_removed_predicate']
    assert source.count(old) == 1
    replacement = "        draft_normalizer.verify(result['inc'], inputs['inputs'])\n"
    assert source.replace(old, replacement, 1).encode() == c.decode(preparation['changed_reader_base64'])
    assert preparation['original_native_reader'] == draft['inputs'][c.PREFIX + 'review_native.py']
    complete = load('complete-draft-run.json')
    assert complete['unchanged'] and complete['run']['returncode'] == 0
    assert c.decode(complete['run']['stdout_base64']) == expected and not c.decode(complete['run']['stderr_base64'])
    # The omitted materialized files were already recoverable in the original bound capsule.
    nested = json.loads(gzip.decompress(c.decode(draft['inputs'][c.PREFIX + 'graph-inputs.json.gz']['base64'])))['inputs']
    for path, item in nested.items():
        assert c.sha(c.decode(item['base64'])) == item['sha256']
        if path in draft['inputs']:
            assert draft['inputs'][path] == item
    assert len([path for path in nested if path.startswith(('docs/knowledge/', 'docs/decisions/'))]) == 1487
    return dict(result='PASS', old_inputs=355, old_claim_bytes=60395, module_controls=controls.review(),
        scope='Original healthy main-context baseline, actual isolated INC-predicate RED, distinct incomplete '
              'materialization RED, then complete supplied replay with only the module predicate adapted in memory. '
              'Every original on-disk input and whole target remain unchanged; original raw observations are never refreshed.')


if __name__ == '__main__':
    print(json.dumps(review(), sort_keys=True))
