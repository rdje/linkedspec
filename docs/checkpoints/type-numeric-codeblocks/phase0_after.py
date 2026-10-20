"""Verify migrated consumers and actual observer/selection fault controls."""
import json
import re
from pathlib import Path
import common as c

ACTOR = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-phase0-focused.pl'
TEST = 't/phase0_regression.t'


def summary(run):
    marker = b'# FOCUSED_PHASE0_JSON '
    output = c.decode(run['stdout_base64'])
    assert output.count(marker) == 1
    return json.loads(output.split(marker)[1].splitlines()[0])


def healthy(run, plan):
    result = summary(run)
    assert run['returncode'] == 0 and not c.decode(run['stderr_base64'])
    assert result['passing'] and result['complete_selection']
    assert result['selected'] == result['wanted'] == len(plan['selected'])
    assert result['root_tests'] == plan['ordinary_root_tests']
    loaded = Path(result['loaded_method_lowering'])
    assert loaded.resolve() == (c.ROOT / 'perl/LinkedSpec/ActionIR/MethodLowering.pm').resolve()
    return result


def main():
    prior = c.load('phase0-before-inputs.json')
    plan = prior['plan']
    paths = set(prior['inputs'])
    paths.update(path.relative_to(c.ROOT).as_posix() for path in (c.ROOT / c.PREFIX).iterdir()
                 if path.suffix in ('.py', '.pl'))
    paths.update(c.PREFIX + name for name in ('phase0-golden-inputs.json', 'phase0-golden-run.json.gz',
                                             'phase0-migration.json.gz'))
    inputs = {path: c.identity(path) for path in sorted(paths)}
    original = c.read(TEST)
    c.write_new('phase0-after-inputs.json', dict(inputs=inputs, plan=plan, test=original,
        scope='Current complete owned selected-test context. Three real roots run; excluded roots are SKIP. '
              'The original full ordinary1035 result is not inferred from this selector.'))
    execute = lambda selection: c.run(['perl', '-Iperl', ACTOR], input=json.dumps(selection).encode())
    positive = execute(plan)
    c.write_new('phase0-after-run.json.gz', dict(run=positive, inputs_unchanged=c.unchanged(inputs)))
    result = healthy(positive, plan)
    assert c.unchanged(inputs)
    before = b'sub evaluate_lowered_json {\n    my ($code, $setup) = @_;\n'
    after = before + b'    return q#{"value":null,"warnings":[]}# if defined($setup) && index($setup, q{my $offset = 2;}) >= 0;\n'
    raw = c.decode(original['base64'])
    assert raw.count(before) == 1
    target = c.ROOT / TEST
    try:
        target.write_bytes(raw.replace(before, after, 1))
        fault = execute(plan)
        c.write_new('phase0-observer-observed.json.gz', dict(run=fault,
            mutant_sha256=c.identity(TEST)['sha256'], before=c.encode(before), after=c.encode(after)))
    finally:
        target.write_bytes(raw)
        target.chmod(original['mode'])
    assert c.read(TEST) == original and c.unchanged(inputs)
    restored = execute(plan)
    healthy(restored, plan)
    failed = re.findall(r"Failed test '([^']+)'", c.decode(fault['stderr_base64']).decode())
    ids = {row['id'] for row in c.load('phase0-migration.json.gz')['changes']}
    assert fault['returncode'] != 0 and not summary(fault)['passing']
    assert ids <= set(failed)
    missing_plan = dict(selected=[dict(number=476, name='missing-numeric-selection')], ordinary_root_tests=1035)
    missing = execute(missing_plan)
    denied = summary(missing)
    assert missing['returncode'] != 0 and not denied['complete_selection']
    assert denied['selected'] == 0 and denied['wanted'] == 1
    assert c.unchanged(inputs)
    c.write_new('phase0-controls.json.gz', dict(result=result, restored=restored, missing=missing,
        missing_plan=missing_plan, observer_failures=failed, numeric_observer_failures=sorted(ids),
        producer=c.read(c.PREFIX + 'phase0_after.py'), inputs_restored=True))
    print('Focused Phase0 PASS:', result['selected'], 'real roots;', len(ids),
          'numeric observer REDs restored; missing selector RED')


if __name__ == '__main__':
    main()
