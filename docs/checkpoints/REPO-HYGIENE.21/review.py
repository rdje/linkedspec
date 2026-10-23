"""Read-only review of the dated retained metadata and accepted12 custody."""
import json
import common as c
import metadata_review
import custody
import book
import document


def parsed(run):
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    return json.loads(c.decode(run['stdout_base64']))


def check():
    metadata = c.load('metadata.json.gz')
    result = metadata_review.validate(metadata)
    assert result == c.load('metadata-result.json')
    assert metadata['runs'] == c.load('census-commands.json.gz')['runs']
    assert metadata['context'] == c.load('capture-inputs.json.gz')['context']
    for name,reader,source,reasons in [
        ('metadata',metadata_review.validate,metadata,dict(aggregate='parent byte total',
            balanced='independent per-file lstat',channel='producer exit/channels',producer='producer identity')),
        ('custody',custody.validate,c.load('prior12.json.gz'),dict(missing='complete image population',
            mode='owned full-mode packet',permission='accepted byte/mode declaration',baseline='actual clean baseline'))]:
        controls = c.load(name+'-controls.json.gz')
        expected = reader(source)
        assert parsed(controls['healthy']) == parsed(controls['restored']) == expected
        assert set(controls['faults']) == set(reasons)
        for fault,reason in reasons.items():
            stem = 'fault-' if name == 'metadata' else 'custody-fault-'
            try:
                reader(c.load(stem+fault+'.json.gz'))
            except AssertionError as error:
                assert str(error) == reason
            else:
                raise AssertionError('corruption admitted: '+name+'/'+fault)
            run = controls['faults'][fault]
            assert run['returncode'] != 0
            assert ('AssertionError: '+reason).encode() in c.decode(run['stderr_base64'])
    preserved = custody.validate(c.load('prior12.json.gz'))
    docs = c.load('documentation.json.gz')
    assert docs['knowledge_byte_delta'] <= 0
    assert c.load('documentation-inputs.json.gz')['producer'] == c.read(c.PREFIX+'document.py')
    original_docs = c.load('prior12.json.gz')['planned_before']
    for path,packet in docs['before'].items():
        assert packet == original_docs[path]
    for path in docs['before']:
        if path.startswith('docs/knowledge/'):
            before = c.decode(docs['before'][path]['base64'])
            after = c.decode(docs['after'][path]['base64'])
            assert before.split(b'\n---\n',1)[1] == after.split(b'\n---\n',1)[1]
    card = 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md'
    assert ('dated'+str(result['parent_files'])+' parent rows').encode() in c.decode(docs['after'][card]['base64'])
    assert result['at_utc'].encode() in c.decode(docs['after']['docs/ARTIFACT_CLEANUP.md']['base64'])
    inputs = c.load('book-inputs.json.gz')
    assert inputs['producer'] == c.read(c.PREFIX+'book.py')
    for packet in inputs['inputs'].values():
        assert c.sha(c.decode(packet['base64'])) == packet['sha256']
    assert document.MARKER.encode() in c.decode(inputs['inputs'][document.BOOK]['base64'])
    assert inputs['inputs'][document.BOOK] == docs['after'][document.BOOK]
    builds = c.load('book-runs.json.gz')
    assert builds['inputs_unchanged']
    book.validate(builds['healthy'])
    try:
        book.validate(builds['changed'])
    except AssertionError as error:
        assert str(error) == 'maintenance marker'
    else:
        raise AssertionError('missing rendered maintenance example admitted')
    focused = c.load('focused.json.gz')
    assert focused['run']['returncode'] == 0 and not c.decode(focused['run']['stderr_base64'])
    assert focused['inputs_unchanged'] and focused['producer'] == c.read(c.PREFIX+'focused.py')
    original = c.load('prior12.json.gz')['images']
    measured = c.load('focused-inputs.json.gz')['inputs']
    for path in c.SOURCES+['t/scalar_numeric_contract.t']:
        assert measured[path] == {key:original[path][key] for key in ('sha256','mode')}
    import publish
    supplied = c.load('artifact2-inputs.json.gz')
    actual = c.load('artifact2-run.json.gz')
    assert supplied['producer'] == c.read(c.PREFIX+'publish.py') and actual['producer_restored']
    good = publish.controls()
    assert len(good) == 3 and all(row['rejected'] for row in good.values())
    assert parsed(actual['healthy']) == parsed(actual['restored']) == good
    assert all(not row['rejected'] for row in parsed(actual['fault']).values())
    changed = c.load('artifact2-observed.json.gz')
    marker = b'def validate_inputs(declared, actual):\n'
    assert changed['run'] == actual['fault']
    assert c.decode(changed['producer']['base64']) == c.decode(supplied['producer']['base64']).replace(marker,marker+b'    return\n',1)
    assert changed['producer']['mode'] == supplied['producer']['mode']
    return dict(metadata=result,custody=preserved,metadata_denials=4,custody_denials=4,
        input_denials=3,book_inputs=len(inputs['inputs']),book_marker_denial=True,focused_core='PASS',
        limits='Dated metadata and supplied source/book custody; zero removals. No content ownership, liveness/purge or future filesystem stability. Default review runs no historical runtime producer.')


if __name__ == '__main__':
    print(json.dumps(check(),sort_keys=True))
