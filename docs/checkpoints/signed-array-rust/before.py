"""One-shot current public CLI baseline before Rust runtime diagnosis or edits."""
import json
import os
from pathlib import Path
import common as c
import epoch
import binary

PLAN = 'docs/checkpoints/signed-array-selectors/cases.json'
JOURNAL = '.linkedspec-data/verification/signed-rust-before-events.jsonl'
TRACE = '.linkedspec-data/verification/signed-rust-before.trace.log'


def event(value):
    with (c.ROOT / JOURNAL).open('a') as output:
        output.write(json.dumps(value, sort_keys=True, separators=(',', ':')) + '\n')


def main():
    assert not (c.ROOT / JOURNAL).exists() and not (c.ROOT / TRACE).exists()
    supplied = epoch.snapshot()
    c.write_new('before-inputs.json.gz', dict(context=supplied,
        producer=c.read(c.PREFIX + 'before.py'), plan=c.read(PLAN),
        scope='Actual current CLI baseline; no target success or source-level cause is inferred before observations. Rust inputs remain unchanged. Installed SDK/OS and prepared published dependency products are read-only prerequisites.'))
    versions = {name: c.run(command) for name, command in {
        'cargo': ['bash', 'tools/run_cargo_local.sh', '--version'],
        'rustc': ['rustc', '-vV']}.items()}
    c.write_new('before-versions.json.gz', versions)
    assert all(run['returncode'] == 0 for run in versions.values())
    build = c.run(['bash', 'tools/run_cargo_local.sh', 'build', '--manifest-path', 'rust/Cargo.toml',
        '--locked', '--offline', '-p', 'linkedspec-runtime', '--bin', 'linkedspec-rust'])
    c.write_new('before-build.json.gz', build)
    assert build['returncode'] == 0, 'public Cargo build failed; inspect retained channels'
    target = Path(os.environ.get('CARGO_TARGET_DIR', str(c.ROOT / 'rust/target')))
    if not target.is_absolute():
        target = c.ROOT / target
    executable = target / 'debug/linkedspec-rust'
    relative = executable.relative_to(c.ROOT).as_posix()
    artifact = binary.archive(executable, 'before-cli')
    c.write_new('before-binary.json', dict(path=relative, artifact=artifact))
    help_run = c.run([relative, '--help'])
    c.write_new('before-help.json.gz', help_run)
    assert help_run['returncode'] == 0
    with (c.ROOT / JOURNAL).open('x'):
        pass
    rows = []
    for case in json.loads(c.decode(c.read(PLAN)['base64']))['cases']:
        run = c.run([relative, '--inline-spec', case['source'], '--input', case['input']])
        row = dict(id=case['id'], run=run)
        rows.append(row)
        event(row)
    program = 'Top: /x/\n I { items=[10,20,30]; chosen_index=-2; return([chosen_index,items[chosen_index],items[-1],items[-4],items[0]]) }\n'
    calibration = c.run([relative, '--inline-spec', program, '--input', 'x', '--trace', 'debug',
        '--trace-file', TRACE, '--trace-mode', 'route', '--trace-reset'])
    unchanged = c.unchanged(supplied['inputs'])
    c.write_new('before-runs.json.gz', dict(rows=rows, calibration=dict(source=program,
        run=calibration, trace=c.read(TRACE)), inputs_unchanged=unchanged,
        executable_unchanged=c.identity(relative) == {key: artifact[key] for key in ('sha256', 'mode')}))
    assert unchanged
    assert c.identity(relative) == {key: artifact[key] for key in ('sha256', 'mode')}
    assert calibration['returncode'] == 0 and not c.decode(calibration['stderr_base64'])
    print('Current Rust CLI baseline retained; inspect exact observations before classifying causes.')


if __name__ == '__main__':
    main()
