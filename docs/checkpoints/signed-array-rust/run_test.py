"""Retain a named actual test build, executable and complete execution channels."""
import json
from pathlib import Path
import re
import sys
import common as c
import epoch
import binary

TEST = 'rust/linkedspec-runtime/tests/signed_array_selector_contract.rs'
FIXTURE = 'tests/signed-array-rust/cases.json'


def main():
    assert len(sys.argv) in (2, 3) and re.fullmatch(r'[a-z][a-z0-9-]*', sys.argv[1])
    assert len(sys.argv) == 2 or sys.argv[2] == '--skip-emitted'
    name = 'test-' + sys.argv[1]
    supplied = epoch.snapshot([TEST, FIXTURE])
    c.write_new(name + '-inputs.json.gz', dict(context=supplied,
        producer=c.read(c.PREFIX + 'run_test.py'), test=c.read(TEST), fixture=c.read(FIXTURE)))
    build = c.run(['bash', 'tools/run_cargo_local.sh', 'test', '--manifest-path', 'rust/Cargo.toml',
        '--locked', '--offline', '-p', 'linkedspec-runtime', '--test',
        'signed_array_selector_contract', '--no-run', '--message-format=json'])
    c.write_new(name + '-build.json.gz', build)
    assert build['returncode'] == 0, 'inspect actual test-build channels; no behavior RED yet'
    executables = []
    for line in c.decode(build['stdout_base64']).splitlines():
        message = json.loads(line)
        if (message.get('reason') == 'compiler-artifact'
                and message['target']['name'] == 'signed_array_selector_contract'
                and message.get('executable')):
            executables.append(Path(message['executable']))
    assert len(executables) == 1, 'exact owned test executable'
    executable = executables[0]
    relative = executable.relative_to(c.ROOT).as_posix()
    artifact = binary.archive(executable, name)
    c.write_new(name + '-binary.json', dict(path=relative, artifact=artifact))
    command = [relative, '--nocapture']
    if len(sys.argv) == 3:
        command += ['--skip', 'signed_array_independently_compiled_emitted_source']
    run = c.run(command)
    unchanged = c.unchanged(supplied['inputs'])
    c.write_new(name + '-run.json.gz', dict(run=run, inputs_unchanged=unchanged,
        executable_unchanged=c.identity(relative) == {key: artifact[key] for key in ('sha256', 'mode')}))
    emitted = []
    for line in c.decode(run['stdout_base64']).decode().splitlines():
        marker = 'SIGNED_ARRAY_EMITTED_EXECUTABLE '
        if marker in line:
            metadata = json.JSONDecoder().raw_decode(line.split(marker, 1)[1])[0]
            child = binary.archive(c.source(metadata['path']), name + '-emitted-' + str(len(emitted) + 1))
            assert child['sha256'] == metadata['sha256'] and child['bytes'] == metadata['bytes']
            if metadata.get('mode') is not None:
                assert child['mode'] == metadata['mode']
            emitted.append(dict(observed=metadata, artifact=child))
    if emitted:
        c.write_new(name + '-emitted-binaries.json.gz', dict(executables=emitted))
    assert unchanged
    assert c.identity(relative) == {key: artifact[key] for key in ('sha256', 'mode')}
    print('Retained actual test execution:', name, 'exit', run['returncode'])


if __name__ == '__main__':
    main()
