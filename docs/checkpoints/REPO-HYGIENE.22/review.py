"""Read-only review of retained dated metadata, channels and supplied book proof."""
import json
import common as c
import metadata_review
import book


def parsed(run):
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    return json.loads(c.decode(run['stdout_base64']))


def check():
    value = c.load('metadata.json.gz')
    result = metadata_review.validate(value)
    assert result == c.load('metadata-result.json')
    supplied = c.load('capture-inputs.json.gz')
    assert value['context'] == supplied['context']
    assert value['runs'] == c.load('census-commands.json.gz')['runs']
    context = value['context']
    assert set(context['inputs']) == set(context['sources']) == set(metadata_review.PRODUCERS)
    for path, packet in context['sources'].items():
        assert packet == c.read(path), 'retained producer epoch: ' + path
        assert context['inputs'][path] == {key: packet[key] for key in ('sha256', 'mode')}
    git_run = context['git_run']
    assert git_run['returncode'] == 0 and not c.decode(git_run['stderr_base64'])
    assert context['gitlinks'] == sorted(row.split(b'\t', 1)[1].decode()
        for row in c.decode(git_run['stdout_base64']).split(b'\0') if row.startswith(b'160000 '))
    reasons = dict(aggregate='parent byte total', balanced='independent per-file lstat',
        omission='independent parent population', channel='producer exit/channels',
        producer='producer identity')
    controls = c.load('metadata-controls.json.gz')
    assert parsed(controls['healthy']) == parsed(controls['restored']) == result
    assert set(controls['faults']) == set(reasons)
    for name, reason in reasons.items():
        try:
            metadata_review.validate(c.load('fault-' + name + '.json.gz'))
        except AssertionError as error:
            assert str(error) == reason
        else:
            raise AssertionError('bad metadata admitted: ' + name)
        run = controls['faults'][name]
        assert run['returncode'] != 0
        assert ('AssertionError: ' + reason).encode() in c.decode(run['stderr_base64'])
    preflight = c.load('preflight.json.gz')
    assert preflight['producer'] == c.read(c.PREFIX + 'preflight.py')
    intersections = []
    for path, packet in preflight['claim_inputs'].items():
        assert c.sha(c.decode(packet['base64'])) == packet['sha256']
        for claim in json.loads(c.decode(packet['base64']))['claims']:
            leg = claim['durability']
            if leg['status'] == 'checked' and leg['mode'] == 'live':
                shared = sorted(set(preflight['planned']) & {item['path'] for item in leg['inputs']})
                if shared:
                    intersections.append(dict(record=path, claim=claim['name'], paths=shared))
    assert intersections == preflight['live_intersections'] == []
    inputs = c.load('book-inputs.json.gz')
    assert inputs['producer'] == c.read(c.PREFIX + 'book.py')
    for packet in inputs['inputs'].values():
        assert c.sha(c.decode(packet['base64'])) == packet['sha256']
    assert book.MARKER.encode() in c.decode(inputs['inputs'][book.BOOK]['base64'])
    docs = c.load('documentation.json.gz')
    before_docs = c.load('documentation-inputs.json.gz')
    assert before_docs['producer'] == c.read(c.PREFIX + 'document.py')
    assert docs['before'] == before_docs['before']
    assert docs['after'][book.BOOK] == inputs['inputs'][book.BOOK]
    card = 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md'
    assert c.decode(docs['before'][card]['base64']).split(b'\n---\n', 1)[1] == c.decode(
        docs['after'][card]['base64']).split(b'\n---\n', 1)[1]
    assert docs['knowledge_byte_delta'] <= 0
    assert result['at_utc'].encode() in c.decode(docs['after']['docs/ARTIFACT_CLEANUP.md']['base64'])
    runs = c.load('book-runs.json.gz')
    assert runs['inputs_unchanged']
    book.validate(runs['healthy'])
    try:
        book.validate(runs['changed'])
    except AssertionError as error:
        assert str(error) == 'maintenance marker'
    else:
        raise AssertionError('missing rendered maintenance example admitted')
    import publish
    artifact = c.load('artifact2-inputs.json.gz')
    actual = c.load('artifact2-run.json.gz')
    assert artifact['producer'] == c.read(c.PREFIX + 'publish.py')
    good = publish.controls()
    assert len(good) == 3 and all(row['rejected'] for row in good.values())
    assert parsed(actual['healthy']) == parsed(actual['restored']) == good
    assert all(not row['rejected'] for row in parsed(actual['fault']).values())
    assert actual['producer_restored']
    fault = c.load('artifact2-observed.json.gz')
    marker = b'def validate_inputs(declared, actual):\n'
    assert fault['run'] == actual['fault']
    assert c.decode(fault['producer']['base64']) == c.decode(artifact['producer']['base64']).replace(
        marker, marker + b'    return\n', 1)
    assert fault['producer']['mode'] == artifact['producer']['mode']
    return dict(metadata=result, metadata_denials=len(reasons), input_denials=3,
        book_inputs=len(inputs['inputs']), book_marker_denial=True,
        limits='Dated metadata only; artifact retention and zero removals. No content ownership, liveness, recovery/purge or concurrent-adversarial guarantee. Default review does not recapture filesystem state or rerun historical producers.')


if __name__ == '__main__':
    print(json.dumps(check(), sort_keys=True))
