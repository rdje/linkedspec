"""Admit the proposed direct scalar checks through an existing mandatory suite."""
import re
import subprocess
import common as c
import context


def main():
    target = 't/uniform_binding_contract.t'
    proposal = 't/sorted_value_kinds_perl.t'
    before = c.read(target)
    original = c.read(proposal)
    assert original == c.load('permanent.json.gz')['kind_test']
    assert proposal not in subprocess.check_output(
        ['git', 'ls-files', '-z'], cwd=c.ROOT).decode().split('\0')
    ci = c.source('tools/run_ci_local.sh').read_text()
    assert 'PERL5LIB= prove -Iperl t/uniform_binding_contract.t\n' in ci
    source = c.decode(original['base64']).decode()
    body = source[source.index('my $json ='):source.rindex('\ndone_testing;')]
    body = body.replace('$json', '$kind_json')
    body = body.replace('sub scalar_flags {', 'my $scalar_flags = sub {', 1)
    body = body.replace('}\n\nsub flags_for {', '};\n\nmy $flags_for = sub {', 1)
    body = body.replace('}\n\nmy @cases = (', '};\n\nmy @cases = (', 1)
    body = body.replace('scalar_flags($_)', '$scalar_flags->($_)')
    body = body.replace('flags_for(', '$flags_for->(')
    body = body.replace('refaddr(', 'Scalar::Util::refaddr(')
    body = body.replace('dclone(', 'Storable::dclone(')
    block = "subtest 'sorted scalar kinds survive lexical selection and cloning' => sub {\n"
    block += ' use utf8;\n require B;\n require Scalar::Util;\n require Storable;\n require LinkedSpec::BindingRuntime;\n\n'
    block += '\n'.join(' ' + line if line else '' for line in body.splitlines()) + '\n};\n\n'
    text = c.decode(before['base64']).decode()
    assert text.count('done_testing();\n') == 1
    text = text.replace('done_testing();\n', block + 'done_testing();\n', 1)
    supplied = context.snapshot()
    c.write_new('checks-admission-inputs.json.gz', supplied)
    c.write_new('checks-admission-before.json.gz', dict(target=target, before=before,
        proposal=proposal, original=original, ci=c.read('tools/run_ci_local.sh')))
    c.source(target).write_text(text)
    c.source(target).chmod(before['mode'])
    test_inputs = context.snapshot()
    c.write_new('checks-test-inputs.json.gz', test_inputs)
    run = c.run(['bash', 'tools/project_data_run.sh', 'prove', '-v', '-Iperl', target])
    stable = c.unchanged(test_inputs['inputs'])
    c.write_new('checks-test-run.json.gz', dict(run=run, inputs_unchanged=stable))
    output = c.decode(run['stdout_base64'])
    assert stable and run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    assert b'Result: PASS' in output
    assert b'ok 13 - sorted scalar kinds survive lexical selection and cloning' in output
    labels = re.findall(r"\{id => '([^']+)'", source)
    assert len(labels) == 9
    for label in labels:
        assert ('# Subtest: ' + label + '\n').encode() in output
    assert c.read(proposal) == original
    c.source(proposal).unlink()
    unaffected = {path: item for path, item in supplied['inputs'].items()
        if path not in (target, proposal)}
    assert c.unchanged(unaffected)
    c.write_new('checks-admission.json.gz', dict(target=target, before=before,
        after=c.read(target), original_proposal=original, proposal_absent=not (c.ROOT/proposal).exists(),
        labels=labels, run='checks-test-run.json.gz',
        scope='Nine direct BindingRuntime flag/clone/order/independence subtests are nested in the existing mandatory uniform suite. The standalone proposal had never run; its exact whole source and mode survive before its verified deletion. Canonical CI command is unchanged.'))
    print('Mandatory uniform suite PASS; nine kind cases / 72 assertions admitted; proposal source preserved and removed')


if __name__ == '__main__':
    main()
