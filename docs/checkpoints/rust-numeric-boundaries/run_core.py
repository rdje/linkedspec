"""Capture the actual core contract executable immediately before direct use."""
import json
from pathlib import Path
import sys
import common as c


def main():
    assert len(sys.argv) in (2, 3)
    label = sys.argv[1]
    assert label.replace('-', '').isalnum()
    extras = ['tests/numeric-conversion/cases.json',
        'rust/linkedspec-core/tests/numeric_conversion_contract.rs']
    supplied = c.context(extras)
    c.save('core-'+label+'-inputs.json.gz', dict(context=supplied,
        scope='Actual permanent numeric consumer, fixture and conservative current producer closure before no-run build and direct execution. SDK/OS/prepared RGX products are read-only prerequisites. The full output is retained even when the intended correct-value assertions are RED.'))
    command = ['bash', 'tools/run_cargo_local.sh', 'test', '--manifest-path', 'rust/Cargo.toml',
        '--locked', '--offline', '-p', 'linkedspec-core', '--test', 'numeric_conversion_contract',
        '--no-run', '--message-format=json']
    if len(sys.argv) == 3:
        assert sys.argv[2] == 'float-roundtrip-control'
        command += ['--features', 'serde_json/float_roundtrip']
    build = c.run(command)
    c.save('core-'+label+'-build.json.gz', build)
    assert build['returncode'] == 0
    paths = []
    for line in c.decode(build['stdout_base64']).splitlines():
        item = json.loads(line)
        if item.get('reason') == 'compiler-artifact' and item.get('executable') \
                and item['target']['name'] == 'numeric_conversion_contract':
            paths.append(Path(item['executable']))
    assert len(paths) == 1
    executable = paths[0]
    relative = executable.relative_to(c.ROOT).as_posix()
    artifact = c.archive(executable, 'core-'+label)
    c.save('core-'+label+'-binary.json', dict(path=relative, artifact=artifact))
    run = c.run([str(executable), '--nocapture'], cwd=c.ROOT/'rust/linkedspec-core')
    stable = c.identity(relative) == {key: artifact[key] for key in ('sha256', 'mode')}
    inputs_stable = c.unchanged(supplied['inputs'])
    c.save('core-'+label+'-run.json.gz', dict(run=run, executable_unchanged=stable,
        inputs_unchanged=inputs_stable))
    assert stable and inputs_stable
    print('Core numeric contract captured:', label, 'actual exit', run['returncode'],
        '; source/executable identities unchanged.')


if __name__ == '__main__':
    main()
