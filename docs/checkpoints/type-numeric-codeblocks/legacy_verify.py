"""Verify current numeric successors against the untouched historical fixtures."""
import common as c
import context


def main():
    extras = [c.PREFIX + name for name in ('common.py', 'context.py', 'legacy_verify.py')]
    extras.append('tests/numeric-codeblocks/legacy-consumers.json')
    snapshot = context.snapshot(extras)
    command = ['prove', '-q', '-Iperl', 't/codeblock_while_perl.t',
               't/actionir_scalar_receiver_required_capture.t']
    snapshot['command'] = command
    c.write_new('legacy-inputs.json.gz', snapshot)
    run = c.run(command)
    c.write_new('legacy-run.json.gz', dict(run=run, inputs_unchanged=c.unchanged(snapshot['inputs'])))
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    assert c.unchanged(snapshot['inputs'])
    print('Current numeric successors PASS: complete while/scalar-required suites; historical fixture bytes unchanged')


if __name__ == '__main__':
    main()
