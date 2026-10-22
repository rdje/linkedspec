"""Read-only dated metadata, source custody, book, and focused-proof review."""
import json
from pathlib import Path
import common as c
import metadata_review
import custody_final as custody
import book
import document


def check(artifacts=True):
    metadata = c.load('metadata.json.gz')
    result = metadata_review.validate(metadata)
    assert result == c.load('metadata-result.json')
    assert c.load('census-commands.json.gz')['runs'] == metadata['runs']
    assert c.load('capture-inputs.json.gz')['context'] == metadata['context']
    for row in metadata_review.rows(metadata['data']):
        path = Path(row['path'])
        assert not path.is_absolute() and '..' not in path.parts
        assert path.name.endswith(row['suffix']) and row['suffix'] in ('.log','.bin','.DS_Store')
    for row in metadata['data']['rows']:
        assert not any(row['path'] == item or row['path'].startswith(item+'/')
            for item in metadata['data']['excluded_paths'])
    controls = c.load('metadata-controls.json.gz')
    for run in (controls['healthy'],controls['restored']):
        assert run['returncode']==0 and not c.decode(run['stderr_base64'])
        assert json.loads(c.decode(run['stdout_base64'])) == result
    reasons = dict(aggregate='parent byte total',balanced='independent per-file lstat',
        channel='producer exit/channels',producer='producer identity')
    assert set(controls['faults']) == set(reasons)
    for name,reason in reasons.items():
        try:
            metadata_review.validate(c.load('fault-'+name+'.json.gz'))
        except AssertionError as error:
            assert str(error) == reason
        else:
            raise AssertionError('metadata corruption admitted: '+name)
        run = controls['faults'][name]
        assert run['returncode'] != 0 and ('AssertionError: '+reason).encode() in c.decode(run['stderr_base64'])
    prior = c.load('prior10.json.gz')
    preserved = custody.validate(prior)
    custody_runs = c.load('custody2-controls.json.gz')
    for run in (custody_runs['healthy'],custody_runs['restored']):
        assert run['returncode']==0 and not c.decode(run['stderr_base64'])
        assert json.loads(c.decode(run['stdout_base64'])) == preserved
    for name,reason in dict(missing='complete image population',mode='owned full-mode packet',permission='accepted byte/mode declaration',baseline='actual clean baseline').items():
        try:
            custody.validate(c.load('custody2-fault-'+name+'.json.gz'))
        except AssertionError as error:
            assert str(error)==reason
        else:
            raise AssertionError('custody corruption admitted: '+name)
        run = custody_runs['faults'][name]
        assert run['returncode'] != 0 and ('AssertionError: '+reason).encode() in c.decode(run['stderr_base64'])
    docs = c.load('documentation.json.gz')
    activation = c.load('activation.json.gz')
    for path in (document.BOOK,document.ARTIFACT_CARD,document.HELPER_CARD):
        assert docs['before'][path] == activation['before'][path]
    old = c.decode(docs['before'][document.ARTIFACT_CARD]['base64'])
    new = c.decode(docs['after'][document.ARTIFACT_CARD]['base64'])
    assert old.split(b'\n---\n',1)[1] == new.split(b'\n---\n',1)[1]
    assert docs['knowledge_byte_delta'] == -1
    inputs = c.load('book-inputs.json.gz')
    assert inputs['producer'] == c.read(c.PREFIX+'book.py')
    assert inputs['inputs'][document.BOOK] == docs['after'][document.BOOK]
    for packet in inputs['inputs'].values():
        assert c.sha(c.decode(packet['base64'])) == packet['sha256']
    builds = c.load('book-runs.json.gz')
    assert builds['inputs_unchanged']
    book.validate(builds['healthy'])
    try:
        book.validate(builds['changed'])
    except AssertionError as error:
        assert str(error)=='maintenance marker'
    else:
        raise AssertionError('missing rendered maintenance guidance admitted')
    focused = c.load('focused.json.gz')
    assert focused['inputs_unchanged'] and focused['run']['returncode']==0
    assert not c.decode(focused['run']['stderr_base64'])
    assert focused['producer'] == c.read(c.PREFIX+'focused.py')
    supplied = c.load('focused-inputs.json.gz')['inputs']
    for path in c.SOURCES+['t/scalar_numeric_contract.t','tests/numeric-codeblocks/count-first.json']:
        assert supplied[path] == {key:prior['images'][path][key] for key in ('sha256','mode')}
    # Source-bound original errors remain observations, never product falsifier credit.
    refused = c.load('documentation-preflight.json.gz')
    assert refused['observed_wrapper_exit']==1
    assert b'AssertionError: (51741, 51789)' in c.decode(refused['merged_log']['base64'])
    repaired = c.load('documentation-header-repair.json.gz')
    assert repaired['before'] == refused['producer'] and repaired['after'] == c.read(c.PREFIX+'document.py')
    original = c.load('custody-refusal.json.gz')
    assert original['before']['custody.py'] == c.read(c.PREFIX+'custody.py')
    assert original['before']['custody_controls.py'] == c.read(c.PREFIX+'custody_controls.py')
    assert original['failed']['custody-healthy.json.gz']['run']['returncode'] != 0
    assert b'committed full mode' in c.decode(original['failed']['custody-healthy.json.gz']['run']['stderr_base64'])
    groups = {}
    for row in original['differences']:
        key = (row['filesystem_mode'],row['git_mode'])
        groups[key] = groups.get(key,0)+1
    assert groups == {(0o640,'100644'):35,(0o750,'100755'):1}
    repair = c.load('custody-repair.json.gz')
    for name in ('custody_final.py','custody_controls2.py'):
        assert repair['after'][name] == c.read(c.PREFIX+name)
    card = c.load('mode-card.json.gz')
    wording = c.load('mode-card-wording.json.gz')
    assert card['after'] == wording['before']
    assert c.decode(card['before']['base64']).split(b'\n---\n',1)[1] == c.decode(wording['after']['base64']).split(b'\n---\n',1)[1]
    if artifacts:
        import publish
        supplied = c.load('artifact2-inputs.json.gz')
        actual = c.load('artifact2-run.json.gz')
        assert supplied['producer'] == c.read(c.PREFIX+'publish.py') and actual['producer_restored']
        good = publish.controls()
        assert len(good)==3 and all(row['rejected'] for row in good.values())
        for key in ('healthy','restored'):
            run = actual[key]
            assert run['returncode']==0 and not c.decode(run['stderr_base64'])
            assert json.loads(c.decode(run['stdout_base64']))==good
        bad = actual['fault']
        assert bad['returncode']==0 and not c.decode(bad['stderr_base64'])
        assert all(not row['rejected'] for row in json.loads(c.decode(bad['stdout_base64'])).values())
        changed = c.load('artifact2-observed.json.gz')
        assert changed['run'] == bad
        marker = b'def validate_inputs(declared, actual):\n'
        assert c.decode(changed['producer']['base64']) == c.decode(supplied['producer']['base64']).replace(marker,marker+b'    return\n',1)
        assert changed['producer']['mode'] == supplied['producer']['mode']
    return dict(metadata=result,custody=preserved,metadata_denials=len(reasons),custody_denials=4,
        book_inputs=len(inputs['inputs']),book_marker_denial=True,focused_core='PASS',
        limits='Dated metadata/custody and supplied-book proof; zero removals. No content ownership, liveness/purge or current filesystem stability. Defaults do not rerun historical runtime producers or compare future mutable continuity.')


if __name__ == '__main__':
    print(json.dumps(check(),sort_keys=True))
