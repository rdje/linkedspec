"""Read-only review of the dated historical-audit and fresh Rust admission proof."""
import gzip
import hashlib
import io
import json
import sys
import zipfile
import admission_common as a

ENGINE = 'rust/linkedspec-runtime/src/engine.rs'
AUDIT = 'tests/language-readiness/verify_objectives.py'
BEFORE = '5d1c572c2c310f5dd0aa4f62bb07020cf5c416a8483799cd1c85f13ffeb68009'
AFTER = '0a5a6e7091e2daef5f84942db839829ce98e5a60f62c3d83ce204538c95a5772'


def packets(value):
    if isinstance(value, dict):
        if 'base64' in value and 'sha256' in value:
            assert a.sha(a.decode(value['base64'])) == value['sha256'], 'retained packet identity'
            assert type(value['mode']) is int
        for child in value.values():
            packets(child)
    elif isinstance(value, list):
        for child in value:
            packets(child)


def binary(artifact):
    digest = hashlib.sha256()
    size = 0
    # The closed manifest gates each compressed part before decompression.
    stream = b''.join(a.source(row['path']).read_bytes() for row in artifact['parts'])
    with gzip.GzipFile(fileobj=io.BytesIO(stream)) as source:
        for raw in iter(lambda: source.read(1024*1024), b''):
            digest.update(raw)
            size += len(raw)
    assert digest.hexdigest() == artifact['sha256'] and size == artifact['bytes']


def channel(run, key='stdout'):
    return a.decode(run[key+'_base64']).decode()


def check():
    manifest = a.load('publication.json')
    required = {'canonical1-candidate.json.gz', 'historical-producer-inputs.json.gz',
        'historical-read-inputs.json.gz', 'historical-run.json.gz', 'historical-result.json.gz',
        'readiness-inputs.json.gz', 'readiness-build.json.gz', 'readiness-parent-binary.json',
        'readiness-run.json.gz', 'auditor-fault-inputs.json.gz', 'auditor-direct-controls.json.gz',
        'auditor-accepted-rollback.json.gz', 'auditor-actual-hash-guard-bypass.json.gz',
        'auditor-restored.json.gz', 'auditor-bypass-admission.json.gz', 'auditor-fault-result.json.gz',
        'book-inputs.json.gz', 'book-runs.json.gz', 'documentation-inputs.json.gz',
        'review.py', 'admission_common.py', 'seal.py', 'claim.py', 'input_controls.py', 'README.md'}
    assert required <= set(manifest['inputs']), 'required admission input omitted'
    for name, expected in manifest['inputs'].items():
        assert a.identity(a.PREFIX+name) == expected, 'admission input identity: '+name
        if name.endswith(('.json', '.json.gz')):
            packets(a.load(name))
    candidate = a.load('canonical1-candidate.json.gz')
    assert len(candidate['overlays']) == 17 and len(candidate['sealed_inputs']) == 198
    assert candidate['actual_gate']['returncode'] == 1
    log = a.decode(candidate['actual_gate']['log']['base64'])
    assert b'current executable evidence drift: '+ENGINE.encode() in log
    for path, item in candidate['sealed_inputs'].items():
        assert a.identity(path) == {key: item[key] for key in ('sha256', 'mode')}
    for item in candidate['overlays'].values():
        raw = a.decode(item['base64'])
        assert hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest() == item['git_oid']

    historical = a.load('historical-result.json.gz')
    run = a.load('historical-run.json.gz')
    assert run['returncode'] == 0 and run['producer_inputs_unchanged']
    assert not channel(run, 'stderr') and json.loads(channel(run)) == historical
    assert historical['restored_inputs'] == len(historical['restored_hashes']) == 134
    assert historical['restored_bytes'] == 84613241 and len(historical['controls']) == 22
    assert historical['healthy_audit_guard'] == dict(original_log_attempts=0, tracked_write_attempts=0)
    assert historical['isolated_deterministic_capture']
    report = historical['audit_report']
    assert report['latest_source_inputs'][ENGINE]['sha256'] == BEFORE
    assert report['runtime_source_updates'] == [dict(path=ENGINE, historical=BEFORE, current=AFTER,
        owner='TYPE-REFERENCE-BOOK.1.2.17.3',
        scope='exact signed-selector source image; historical runtime results unchanged; fresh Rust readiness compatibility is separately retained')]
    assert historical['audit_controls']['runtime_source_mutations_by_source'] == {ENGINE: 3}
    reads = a.load('historical-read-inputs.json.gz')
    assert reads['files'][ENGINE]['sha256'] == AFTER
    archive = a.decode(reads['files'][historical['archive']['path']]['base64'])
    assert a.sha(archive) == historical['archive']['sha256'] and len(archive) == historical['archive']['bytes']
    # Independently decode every original stream; the instrument's scratch read
    # identities must equal the actual ZIP population, not just its total.
    with zipfile.ZipFile(io.BytesIO(archive)) as source:
        recovered = {row.filename: source.read(row) for row in source.infolist()}
    expected = report['retained_log_hashes']
    assert len(recovered) == len(expected) == 134
    assert sorted((a.sha(raw), len(raw)) for raw in recovered.values()) == sorted(
        (row['sha256'], row['bytes']) for row in reads['isolated_reads'].values())
    assert sorted(a.sha(raw) for raw in recovered.values()) == sorted(expected.values())
    assert sum(map(len, recovered.values())) == 84613241
    assert historical['restored_hashes'] == expected
    for path, sha in historical['tracked_inputs'].items():
        assert reads['files'][path]['sha256'] == sha

    faults = a.load('auditor-fault-result.json.gz')
    assert all(value is True for key, value in faults.items() if key != 'direct_rejections')
    assert faults['direct_rejections'] == 4
    for label, reason in [('accepted-rollback', 'current executable evidence drift: '+ENGINE),
                          ('actual-hash-guard-bypass', 'runtime corruption control did not reject')]:
        item = a.load('auditor-'+label+'.json.gz')
        assert item['run']['returncode'] != 0 and reason in channel(item['run'], 'stderr')
        assert item['all_supplied_inputs_unchanged']
    restored = a.load('auditor-restored.json.gz')
    assert restored['run']['returncode'] == 0 and restored['all_supplied_inputs_unchanged']
    assert json.loads(channel(restored['run'])) == historical
    assert restored['source'] == reads['files'][AUDIT]
    assert len(a.load('auditor-direct-controls.json.gz')['rejected']) == 4
    admitted = a.load('auditor-bypass-admission.json.gz')
    assert admitted['admitted']['current'] == a.sha(a.decode(admitted['competing_source_base64'])) != AFTER

    readiness = a.load('readiness-run.json.gz')
    assert a.load('readiness-build.json.gz')['returncode'] == 0
    assert readiness['inputs_unchanged'] and readiness['executable_unchanged']
    assert readiness['run']['returncode'] == 0 and not channel(readiness['run'], 'stderr')
    assert '6 passed; 0 failed; 0 ignored' in channel(readiness['run'])
    context = a.load('readiness-inputs.json.gz')['context']
    assert context['sources'][ENGINE]['sha256'] == AFTER
    binary(a.load('readiness-parent-binary.json')['artifact'])
    tests = []
    assert len(readiness['child_records']) == 3
    for name in readiness['child_records']:
        stem = name.removeprefix(a.PREFIX).removesuffix('-run.json.gz')
        child = a.load(stem+'-run.json.gz')
        assert a.load(stem+'-build.json.gz')['returncode'] == 0
        assert child['run']['returncode'] == 0 and child['executable_unchanged']
        assert not channel(child['run'], 'stderr')
        execution = a.load(stem+'-execution-inputs.json.gz')
        binary(execution['executable']['artifact'])
        original = a.load(stem+'-inputs.json.gz')
        for path, packet in original['files'].items():
            if path != 'Cargo.lock':
                assert execution['files'][path] == packet, 'emitted source changed during build'
        stdout = channel(child['run'])
        assert '0 failed; 0 ignored' in stdout
        count = 4 if '4 passed;' in stdout else 3 if '3 passed;' in stdout else 0
        assert count
        tests.append(count)
    assert sorted(tests) == [3, 4, 4]
    book = a.load('book-runs.json.gz')
    marker = 'Rust signed-selector admission permits only the exact reviewed before/after runtime source pair.'
    import html
    assert book['healthy']['returncode'] == book['fault']['returncode'] == 0
    assert marker in html.unescape(a.decode(book['healthy']['page_base64']).decode())
    assert marker not in html.unescape(a.decode(book['fault']['page_base64']).decode())
    assert book['inputs_unchanged'] and book['fault_rejected']
    sys.path.insert(0, str(a.ROOT/'docs/checkpoints/signed-array-rust'))
    import publish
    selected = publish.check()
    return dict(historical_logs=134, historical_bytes=84613241, recovery_controls=22,
        runtime_source_denials=3, auditor_direct_denials=4, auditor_physical_faults=2,
        fresh_readiness_parent_tests=6, emitted_test_counts=sorted(tests),
        book_inputs=len(a.load('book-inputs.json.gz')['inputs']), rendered_denials=1,
        admission_inputs=len(manifest['inputs']), selected=selected)


if __name__ == '__main__':
    print(json.dumps(check(), sort_keys=True))
