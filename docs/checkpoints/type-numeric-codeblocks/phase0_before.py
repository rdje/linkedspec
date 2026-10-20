"""Retain the exact numeric spelling consumers before their semantic migration."""
import json
import subprocess
import common as c

ACTOR = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-focused.pl'
SELECTED = [
    dict(number=476, name='emit_context_lowers_method_contracts_for_capture_and_structured_return_values'),
    dict(number=1015, name='spec_format_terse_3_2_1_numeric_word_aliases'),
    dict(number=1016, name='spec_format_terse_3_2_2_arithmetic_symbol_callees'),
]


def main():
    paths = set(c.load('candidate1-inputs.json')['inputs'])
    tracked = subprocess.check_output(['git', 'ls-files', '-z'], cwd=c.ROOT).decode().split('\0')
    paths.update(path for path in tracked if path.startswith(
        ('t/', 'tests/', 'specs/', 'bin/', 'conf/', 'tablescript/', 'ebnf/')))
    paths.update(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / c.PREFIX).iterdir()
                 if path.suffix in ('.py', '.pl'))
    paths.add(ACTOR)
    inputs = {path: c.identity(path) for path in sorted(paths)}
    plan = dict(selected=SELECTED, ordinary_root_tests=1035)
    before = c.read('t/phase0_regression.t')
    assert c.decode(before['base64']) == subprocess.check_output(
        ['git', 'show', c.BASE + ':t/phase0_regression.t'], cwd=c.ROOT)
    c.write_new('phase0-before-inputs.json', dict(inputs=inputs, plan=plan, test=before,
        scope='The unchanged ordinary test/imports run under the existing exact-name/number selector. '
              'Three selected roots are observed; all excluded roots remain explicit SKIP. '
              'This is focused proof, not an ordinary full Phase0 result.'))
    run = c.run(['perl', '-Iperl', ACTOR], input=json.dumps(plan).encode())
    c.write_new('phase0-before-run.json.gz', dict(run=run, inputs_unchanged=c.unchanged(inputs)))
    assert c.unchanged(inputs)
    marker = b'# FOCUSED_PHASE0_JSON '
    output = c.decode(run['stdout_base64'])
    assert output.count(marker) == 1
    result = json.loads(output.split(marker)[1].splitlines()[0])
    assert result['complete_selection'] and result['selected'] == result['wanted'] == len(SELECTED)
    assert result['root_tests'] == plan['ordinary_root_tests']
    assert run['returncode'] != 0 and not result['passing']
    print('Selected unchanged Phase0 spelling consumers observed RED:', result)


if __name__ == '__main__':
    main()
