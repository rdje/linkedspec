"""Fresh unchanged Rust readiness consumers with complete emitted custody."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import common as a


def main():
    directories = [f'tests/language-readiness/{name}' for name in
                   ['nested-tree', 'context-names', 'lossless-segments', 'lossless-child']]
    files = subprocess.check_output(['git', 'ls-files', *directories], cwd=a.ROOT, text=True).splitlines()
    files += ['rust/linkedspec-core/src/numeric.rs', 'tests/numeric-conversion/functions.json']
    supplied = a.context(files)
    a.save('readiness2-inputs.json.gz', dict(context=supplied,
        producer=a.read(a.PREFIX+'fresh_readiness2.py'),
        scope='Fresh current Rust nesting/context/lossless compatibility only. Unchanged authored oracles and public carriers; parent and every emitted child producer/input/executable are retained. No historical result refresh or language completeness promotion.'))
    build = a.run(['bash', 'tools/run_cargo_local.sh', 'test', '--manifest-path', 'rust/Cargo.toml',
                   '--locked', '--offline', '-p', 'linkedspec-runtime', '--test',
                   'nested_tree_readiness', '--no-run', '--message-format=json'])
    a.save('readiness2-build.json.gz', build)
    assert build['returncode'] == 0
    paths = []
    for line in a.decode(build['stdout_base64']).splitlines():
        item = json.loads(line)
        if item.get('reason') == 'compiler-artifact' and item.get('executable') \
                and item['target']['name'] == 'nested_tree_readiness':
            paths.append(Path(item['executable']))
    assert len(paths) == 1
    executable = paths[0]
    relative = executable.relative_to(a.ROOT).as_posix()
    artifact = a.archive(executable, 'readiness2-parent')
    a.save('readiness2-parent-binary.json', dict(path=relative, artifact=artifact))
    env = os.environ.copy()
    env['LINKEDSPEC_NUMERIC_REAL_CARGO'] = shutil.which('cargo')
    assert env['LINKEDSPEC_NUMERIC_REAL_CARGO']
    env['LINKEDSPEC_CARGO_CMD'] = str(a.ROOT/a.PREFIX/'readiness_cargo.py')
    run = a.run([str(executable), '--nocapture'], cwd=a.ROOT/'rust/linkedspec-runtime', env=env)
    stable = a.identity(relative) == {key: artifact[key] for key in ('sha256', 'mode')}
    inputs_stable = a.unchanged(supplied['inputs'])
    a.save('readiness2-run.json.gz', dict(run=run, executable_unchanged=stable,
        inputs_unchanged=inputs_stable, child_records=sorted(
            file.relative_to(a.ROOT).as_posix() for file in (a.ROOT/a.PREFIX).glob('readiness-child-*-run.json.gz'))))
    assert run['returncode'] == 0 and stable and inputs_stable
    print('Fresh Rust readiness parent and emitted children PASS; exact executable/source custody retained.')


if __name__ == '__main__':
    main()
