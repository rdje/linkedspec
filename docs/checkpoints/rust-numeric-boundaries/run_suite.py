"""Retain source and executable custody for one direct Rust test target."""
from pathlib import Path
import json
import sys
import common as c


def main():
    assert len(sys.argv) == 5
    label, package, kind, target = sys.argv[1:]
    assert all(value.replace('-', '').replace('_', '').isalnum()
        for value in (label, package, target))
    assert package in ('linkedspec-core','linkedspec-runtime') and kind in ('test','lib')
    extras = [file.relative_to(c.ROOT).as_posix()
        for directory in ('tests/numeric-conversion', 'rust/linkedspec-core/tests',
                          'rust/linkedspec-runtime/tests', 'rust/linkedspec-core/src')
        for file in (c.ROOT/directory).glob('*') if file.is_file()
        and (directory == 'tests/numeric-conversion' or 'numeric' in file.name)]
    supplied = c.context(extras)
    c.save(label+'-inputs.json.gz',dict(context=supplied))
    command = ['bash','tools/run_cargo_local.sh','test','--manifest-path','rust/Cargo.toml',
        '--locked','--offline','-p',package,'--no-run','--message-format=json']
    command += ['--test',target] if kind == 'test' else ['--lib']
    build = c.run(command)
    c.save(label+'-build.json.gz',build)
    assert build['returncode'] == 0, 'actual build channels retained'
    paths = []
    for line in c.decode(build['stdout_base64']).splitlines():
        row = json.loads(line)
        if row.get('reason') == 'compiler-artifact' and row.get('executable') \
                and row['target']['name'] == target:
            paths.append(Path(row['executable']))
    assert len(paths) == 1, paths
    file = paths[0]
    artifact = c.archive(file,label)
    relative = file.relative_to(c.ROOT).as_posix()
    c.save(label+'-binary.json',dict(path=relative,artifact=artifact))
    run = c.run([str(file),'--nocapture'],cwd=c.ROOT/'rust'/package)
    stable = c.identity(relative) == {key:artifact[key] for key in ('sha256','mode')}
    inputs_stable = c.unchanged(supplied['inputs'])
    c.save(label+'-run.json.gz',dict(run=run,executable_unchanged=stable,
        inputs_unchanged=inputs_stable))
    assert stable and inputs_stable
    print(label,'actual test exit',run['returncode'],'; source/executable identities unchanged.')


if __name__ == '__main__':
    main()
