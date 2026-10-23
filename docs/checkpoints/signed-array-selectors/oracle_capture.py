"""Retain actual distinguishing REDs without changing the engine or raw rows."""
import json
import common as c
import context
import oracle


def main():
    epoch = context.snapshot()
    c.write_new('oracle-inputs.json.gz',dict(context=epoch,
        producers={c.PREFIX+name:c.read(c.PREFIX+name) for name in
            ('oracle.py','oracle_capture.py','inspect_native.py','inspect_perl.py')},
        signed_cases=oracle.SIGNED_CASES,cli_failure_cases=oracle.CLI_FAILURE_CASES))
    command = ['bash','tools/run_python_project_data.sh',c.PREFIX+'oracle.py']
    requested = {route:c.run(command+['requested',route]) for route in
        ['perl/get','perl/generated']+[runtime+'/cli' for runtime in oracle.RUNTIMES]}
    cli = {runtime:c.run(command+['cli-failures',runtime]) for runtime in oracle.RUNTIMES}
    stable = c.unchanged(epoch['inputs'])
    c.write_new('oracle-runs.json.gz',dict(requested=requested,cli=cli,inputs_unchanged=stable,
        scope='Actual retained-output oracle commands: all eight named current routes reject the complete requested finite signed policy; the existing CLI-failure oracle rejects Perl and passes the other five routes. This is diagnostic RED evidence, not new runtime acceptance.'))
    assert stable
    for run in requested.values():
        assert run['returncode'] == 1 and not c.decode(run['stderr_base64'])
        assert json.loads(c.decode(run['stdout_base64']))['failures']
    for runtime,run in cli.items():
        assert run['returncode'] == (1 if runtime == 'perl' else 0)
        assert not c.decode(run['stderr_base64'])
        assert bool(json.loads(c.decode(run['stdout_base64']))['failures']) == (runtime == 'perl')
    print('Observed requested-policy RED on eight named routes; established CLI-failure RED on Perl / GREEN on five other runtimes; original sources and rows unchanged')


if __name__ == '__main__':
    main()
