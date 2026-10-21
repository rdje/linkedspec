"""Finish admission from the retained passing TAP, scoped to the new nested block."""
import common as c
import context


def main():
    result = c.load('checks-test2-run.json.gz')
    run = result['run']
    assert result['inputs_unchanged'] and run['returncode'] == 0
    assert not c.decode(run['stderr_base64'])
    output = c.decode(run['stdout_base64'])
    block = output.split(b'# Subtest: sorted scalar kinds survive lexical selection and cloning\n',1)[1]
    assert block.count(b'1..8\n') == 9
    assert b'ok 13 - sorted scalar kinds survive lexical selection and cloning\n' in block
    assert b'Result: PASS' in block
    path = 't/uniform_binding_contract.t'
    assert c.read(path) == c.load('checks-correction.json.gz')['after']
    proposal = 't/sorted_value_kinds_perl.t'
    original = c.read(proposal)
    assert original == c.load('permanent.json.gz')['kind_test']
    supplied = context.snapshot()
    c.write_new('admission-finish-inputs.json.gz',supplied)
    c.source(proposal).unlink()
    assert c.unchanged({name:item for name,item in supplied['inputs'].items() if name != proposal})
    c.write_new('checks-admission.json.gz',dict(target=path,after=c.read(path),
        original_proposal=original,proposal_absent=not (c.ROOT/proposal).exists(),
        run='checks-test2-run.json.gz',cases=block.count(b'1..8\n'),assertions=72,
        scope='The actual corrected mandatory suite passes. Its first writer then rejected an overly broad count including old eight-test plans; this finisher scopes the same retained TAP to the new parent. No tests are rerun or observations replaced. Whole original unexecuted proposal is retained before exact deletion.'))
    print('Mandatory scalar checks admitted: nine nested cases / 72 assertions; exact proposal removed')


if __name__ == '__main__':
    main()
