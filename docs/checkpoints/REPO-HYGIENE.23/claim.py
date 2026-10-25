"""One-shot publication writer; retired after producing the closed dated claim."""
import json
import common as c
import review


def main():
    inputs=c.snapshot()
    c.save('publication-inputs.json.gz',inputs)
    result=review.review('healthy')
    after=c.load('inventory-after.json.gz');before=c.load('inventory-before.json.gz')
    targets=c.load('after-targets.json.gz')
    assert after['inputs_unchanged'] and before['inputs_unchanged']
    assert targets['history_source_absent'] and targets['rust_quarantine_absent'] and targets['duplicate_originals_absent']
    assert all(row['closed'] for row in targets['leases'].values())
    controls=c.load('review-controls.json.gz');assert controls['red_controls']==6 and controls['healthy_and_restored_pass']
    expected={'part-bytes':'retained part bytes','part-mode':'retained part mode',
        'missing-part':'whole retained archive','wrong-total':'complete archive population/totals',
        'wrong-value':'typed Rust value','denied-inspection':'unproved open-file absence'}
    for name,reason in expected.items():
        run=c.load('review-control-'+name+'.json.gz')
        assert run['returncode']!=0 and ('AssertionError: '+reason).encode() in c.decode(run['stderr_base64'])
    book=c.load('book-current-render.json.gz');assert book['returncode']==0
    c.save('completed-observations.json.gz',dict(logs={name:c.read('.linkedspec-data/verification/'+name) for name in (
        'hygiene23-after.log','hygiene23-controls.log','hygiene23-book.log',
        'hygiene23-book-current.log','hygiene23-pressure.log','hygiene23-pressure-current.log',
        'hygiene23-knowledge.log')},
        qualification='Actual shell redirects combine channels. The first pressure check rejected50003/50000 lines; a wrapping-only correction retains every word and restores49999. Original render and failed pressure outputs remain. Canonical proof is a separate exact staged receipt.'))
    result.update(before_scoped_allocated_bytes=before['observation']['total']['allocated_bytes'],
        after_scoped_allocated_bytes=after['observation']['total']['allocated_bytes'],
        retained_history_archive_allocated_bytes=targets['retained_history_parts_allocated_bytes'],
        red_controls=6,book_render_pass=True)
    c.save('publication.json.gz',dict(result=result,inputs_unchanged=c.unchanged(inputs['inputs'])))
    assert c.unchanged(inputs['inputs'])
    files=sorted(path for path in (c.ROOT/c.PREFIX).iterdir() if path.is_file())
    rows=[dict(path=path.relative_to(c.ROOT).as_posix(),sha256=c.sha(path.read_bytes()),
        role='producer' if path.suffix=='.py' else 'input') for path in files]
    scope=('Dated exact two-target allocated reduction and retained-byte custody, using permitted quiescence and unchanged source metadata. '
        'Global before/after census excludes root Git/protected repositories and includes managed observer metadata; it is non-atomic and has no global per-file custody. '
        'Volume free-space delta is not causal reclaim. Reusable local dependencies/installed toolchains remain prerequisites; no cold bootstrap, dependency implementation audit, portable artifact guarantee, concurrent-adversarial or recovery/purge admission. Original disposal is never replayed.')
    record=dict(version=1,owner=c.OWNER,claims=[dict(name='dated-safe-two-target-cleanup',
        statement='Rust allocated reduction112969338880 bytes after fresh primary build/four public examples; history scratch119213043712 allocated bytes removed after lossless archive55259061 bytes and two actual restored readers.',
        scope=scope,rederive=dict(status='checked',command='bash tools/run_python_project_data.sh '+c.PREFIX+'review.py',
            granularity='Every retained unique payload and per-path metadata entry; exact native per-target du channels; actual public Rust/reader results and complete executable/source custody. Aggregate scoped census is separately qualified.',result=json.dumps(result,sort_keys=True)),
        falsify=dict(status='checked',hypothesis='A compact archive, successful aggregate or nonzero inspection status can conceal missing bytes/entries, wrong results or denied liveness.',
            oracle='Independent ZIP/manifest decoding and SHA256, native du, original/restored public-reader stdout, exact typed Rust JSON and permitted candidate-specific lsof channels.',
            red_control='Six actual commands reject changed part digest/mode, missing part, false file count, wrong Rust value and permission-denied liveness; healthy/restored pass. Full outputs and reason-sensitive acceptance retained.'),
        durability=dict(status='checked',mode='live',inputs=rows))])
    destination=c.ROOT/'docs/claims/REPO-HYGIENE.23.json'
    with destination.open('x') as output:json.dump(record,output,separators=(',',':'));output.write('\n')
    print(json.dumps(result,sort_keys=True))


if __name__=='__main__':main()
