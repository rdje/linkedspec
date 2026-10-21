"""Bind artifact-reader controls and advance the actual in-flight pointer after final tests."""
import common as c


def main():
    paths=[c.PREFIX+'review.py','MEMORY.md']
    before={path:c.read(path) for path in paths}
    after={path:c.decode(packet['base64']).decode() for path,packet in before.items()}
    path=c.PREFIX+'review.py';text=after[path]
    anchor='def check(fresh=True):\n'
    addition='''def artifact_checks():
    import publish
    saved=c.load('artifact-inputs.json.gz');run=c.load('artifact-run.json.gz')
    observed=c.load('artifact-fault-observed.json.gz')
    assert c.read(c.PREFIX+'publish.py')==saved['producer']
    assert observed['producer']['base64']==saved['mutant_base64']
    assert observed['producer']['mode']==saved['producer']['mode']
    assert run['initial_inputs_unchanged'] and run['producer_restored']
    assert observed['outcomes']==run['fault'] and run['restored']==run['healthy']
    for name,case in saved['cases'].items():
        assert run['healthy'][name]==dict(rejected=True,reason=case['reason'])
        assert run['fault'][name]==dict(rejected=False,reason='')
        try:publish.validate_inputs(case['declared'],saved['actual'])
        except AssertionError as error:assert str(error)==case['reason']
        else:raise AssertionError('Artifact declaration admitted: '+name)
    assert len(saved['cases'])==3
    return dict(denials=3,validator_fault_admissions=3,restored_denials=3)


'''
    assert text.count(anchor)==1;text=text.replace(anchor,addition+anchor,1)
    text=text.replace('    prior=custody.prior();epochs=custody.epochs()',
        '    artifacts=artifact_checks()\n    prior=custody.prior();epochs=custody.epochs()',1)
    text=text.replace('prior_inputs=prior,epochs=epochs,kinds=kinds,','prior_inputs=prior,epochs=epochs,artifacts=artifacts,kinds=kinds,',1)
    text=text.replace("              'because ordinary Phase0 test source is unchanged. Exact staged canonical receipt governs landing.')",
        "              'because ordinary Phase0 test source is unchanged. Three artifact omission/byte/mode '\n              'denials and an actual discarded-validator fault admit3 before exact restoration. '\n              'Exact staged canonical receipt governs landing.')",1)
    compile(text,path,'exec');after[path]=text
    after['MEMORY.md']=after['MEMORY.md'].replace(
        'Run focused.py focused2 on final sources, then doc_proof.py and composed readonly review/publication. Seven actual faults are restored; actual192/65 old-library identity is verified. No inverse needed: ordinary Phase0 source stays unchanged and650 controls pass.',
        'Run doc_proof.py, then readonly verify_kinds/verify_library and review.py. Final14 suites/1948 TAP/scanner/history650 pass;214 and seven runtime faults are verified, plus three artifact denials/validator fault. Finalize commit docs/publication and exact canonical candidate before normal commit; next9 only after clean landing.')
    after['MEMORY.md']=after['MEMORY.md'].replace('Malformed fluent guard and15 permanent assertions added; final214/dependents/canonical pending.',
        'Malformed fluent guard and15 permanent assertions verified with final214/14 dependents. Book/composed/canonical/normal commit pending.')
    c.write_new('prepare-doc-review.json.gz',dict(before=before,after={path:c.encode(raw.encode()) for path,raw in after.items()},
        producer=c.read(c.PREFIX+'prepare_doc_review.py')))
    for path,raw in after.items():(c.ROOT/path).write_text(raw)
    print('Final14/1948/history650 recorded; book/composed proof next')


if __name__=='__main__':main()
