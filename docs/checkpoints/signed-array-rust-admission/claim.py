"""Extend only this uncommitted leaf claim after owned admission proof passes."""
import json
import admission_common as a
import review


def main():
    result = review.check()
    controls = a.load('input-controls.json.gz')
    assert controls['inputs_restored'] and len(controls['cases']) == 4
    for row in controls['cases'].values():
        assert row['red']['returncode'] != 0 and row['bypass']['returncode'] == 0
        assert row['restored_rejection']['returncode'] != 0
    path = 'docs/claims/TYPE-REFERENCE-BOOK.1.2.17.3.json'
    original = a.load('canonical1-candidate.json.gz')['overlays'][path]
    assert a.read(path) == {key: original[key] for key in ('base64', 'sha256', 'mode')}
    a.save('claim-before.json.gz', dict(original=a.read(path), producer=a.read(a.PREFIX+'claim.py')))
    record = json.loads(a.decode(original['base64']))
    files = sorted(file.relative_to(a.ROOT).as_posix() for file in (a.ROOT/a.PREFIX).iterdir() if file.is_file())
    record['claims'].append(dict(
        name='rust-signed-historical-source-admission',
        statement='The historical objective auditor admits only the reviewed Rust signed-selector source pair while preserving original source/log/runtime identities; fresh unchanged Rust readiness consumers pass separately.',
        scope='Dated exact Rust17.3 source image on activation691d2d876. The failed215-file canonical candidate and complete channels are retained before repair. Original134 historical streams/84613241 bytes/22 recovery controls and the original denial instrument remain exact. No historical runtime is rerun or old checkpoint refreshed. Fresh current Rust parent6/emitted4/4/3 tests retain whole source/workspace/actual executable inputs and pre/post identities. The explicit no-run build and direct child execution preserve the original parent assertions; doctests and whole SDK replay are not claimed. Accepted Git objects, installed Python/mdBook/Rust/OS and already-prepared published RGX outputs remain read-only prerequisites. New book rendering consumes all current configuration/source/recursive includes. Exact staged canonical CI and normal commit hooks remain mandatory landing gates; numeric55.1 and portable signed17.7 remain open.',
        rederive=dict(status='checked', command='bash tools/run_python_project_data.sh '+a.PREFIX+'review.py',
            granularity='Original stream byte/hash, exact historical/current engine image, actual auditor source fault and result, fresh unchanged Rust consumer/emitted binary, supplied book and closed publication input.',
            result=json.dumps(result, sort_keys=True)+'; four actual publication input denials admit under physical validator discard and reject after restoration; original healthy channels return exactly.'),
        falsify=dict(status='checked',
            hypothesis='A blanket runtime exemption, missing historical proof input, unrecoverable stream, stale Rust consumer or changed book admission statement passes.',
            oracle='Original immutable milestone/source/log identities; independent ZIP decoding and observed isolated read hashes/sizes; exact source pair from retained runtime epochs; unchanged authored Rust readiness cases/mutants; literal rendered admission boundary.',
            red_control='Actual old-auditor rollback reproduces executable drift RED. Actual current hash-guard removal admits an unreviewed source; the original full proof rejects the disabled guard. Three normal source mutations and four direct path/history/image denials reject. Exact source/mode restoration gives the identical healthy historical report. Actual rendered statement corruption and four physical missing/bytes/mode/required-omission publication faults reject; whole reviewer discard admits each and exact restoration rejects each.'),
        durability=dict(status='checked', mode='live', inputs=[dict(path=name, sha256=a.identity(name)['sha256'],
            role='producer' if name.endswith('.py') else 'input') for name in files])))
    raw = (json.dumps(record, sort_keys=True, separators=(',', ':'))+'\n').encode()
    assert len(raw) <= 128*1024
    (a.ROOT/path).write_bytes(raw)
    print('Combined dated claim:', len(files), 'new admission inputs; original claim retained unchanged.')


if __name__ == '__main__':
    main()
