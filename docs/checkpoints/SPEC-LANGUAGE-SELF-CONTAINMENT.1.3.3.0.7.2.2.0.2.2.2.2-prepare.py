"""Prepare new immutable acceptance instruments from retained predecessor producers."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('prepare.py')
PARENT = ROOT / 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2-'
REPAIR = ROOT / 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1-'
REVISION = '5b4a9a8ca2203f651d3c9d3a36cc9836c30a5375'


def write(name, source):
    target = Path(PREFIX + name)
    assert not target.exists(), 'new acceptance instrument only'
    target.write_text(source)


def main():
    freeze = Path(str(REPAIR) + 'freeze.py').read_text()
    freeze = freeze.replace('78012b1e78bb114a41f54873f30ca63c421568c8', REVISION)
    freeze = freeze.replace('0.2.2.2.0.json', '0.2.2.2.1.json')
    freeze = freeze.replace('grouped-pattern diagnosis checkpoint', 'focused grouped-pattern repair')
    write('freeze.py', freeze)
    capture = Path(str(PARENT) + 'capture.py').read_text()
    capture = capture.replace('0f31461d696186775585e19355a0bc5c41849dfb', REVISION)
    capture = capture.replace('corrected-membership-acceptance', 'complete-membership-acceptance')
    capture = capture.replace("CALLABLE = ",
        "GROUPED = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2-cause-probe.pl'\n"
        "DEFAULT = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1-default-probe.pl'\n"
        "CALLABLE = ", 1)
    capture = capture.replace("'callable_codeblock_literal_contract', 'phase0_regression')]",
        "'callable_codeblock_literal_contract', 'phase0_regression',\n"
        "    'multiline_helper_pattern_validation', 'phase0_validation_fuzz',\n"
        "    'inter_match_gap_capture_perl_contract', 'duplicate_regex_slot_identity_perl_contract',\n"
        "    'sparse_and_action_slots_perl_regression', 'uniform_binding_contract')]")
    capture = capture.replace("    commands += [('consumers', 0,",
        "    commands += [('grouped', seed, ['perl', '-Iperl', GROUPED]) for seed in (0, 1, 42)]\n"
        "    commands += [('default', 0, ['perl', '-Iperl', DEFAULT])]\n"
        "    commands += [('consumers', 0,")
    write('capture.py', capture)
    print('Prepared new history and complete77-command capture instruments')


if __name__ == '__main__':
    main()
