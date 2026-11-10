"""Readonly finite Phase0 semantic and complete historical-stage review."""
import base64
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert hashlib.sha256(raw).hexdigest() == row['sha256']
    return raw


def channels(record):
    selected = json.loads((HERE / 'phase0-selected-names.json').read_bytes())
    counts = {}
    for stage, expected_exit in (('before', 7), ('after', 0)):
        row = record['commands'][stage]
        assert row['exit'] == expected_exit and row['cwd'] == '.'
        assert row['argv'] == ['bash', 'tools/project_data_run.sh', 'perl', '-Iperl',
            str((HERE / 'phase0_selected.pl').relative_to(ROOT)),
            str((HERE / 'phase0-selected-names.json').relative_to(ROOT)),
            '.linkedspec-data/phase0-selected-' + stage + '-seen.json']
        raw = {}
        for name, item in row['channels'].items():
            value = gzip.decompress((ROOT / item['path']).read_bytes())
            assert hashlib.sha256(value).hexdigest() == item['decoded_sha256']
            raw[name] = value
        assert json.loads(raw['seen.json']) == selected
        assert raw['stdout.log'].endswith(b'1..8\n')
        assert len(re.findall(rb'^    (?:not )?ok ', raw['stdout.log'], re.M)) == 140
        failures = len(re.findall(rb'^    not ok ', raw['stdout.log'], re.M))
        assert failures == (20 if stage == 'before' else 0)
        assert len(re.findall(rb'^not ok ', raw['stdout.log'], re.M)) == (7 if stage == 'before' else 0)
        if stage == 'after':
            assert raw['stderr.log'] == b''
        counts[stage] = dict(exit=row['exit'], assertions=140, failed_assertions=failures)
    return counts


def review():
    cases = json.loads((HERE / 'phase0-oracle-cases.json').read_bytes())
    observed = json.loads(gzip.decompress((HERE / 'phase0-values-qualified.json.gz').read_bytes()))
    old = gzip.decompress((HERE / 'phase0-before.t.gz').read_bytes())
    assert observed['inputs']['t/phase0_regression.t']['sha256'] == hashlib.sha256(old).hexdigest()
    assert decode(observed['inputs']['t/phase0_regression.t']) == old
    assert len(cases) == 20
    frames = []
    for stage in ('activation', 'repaired'):
        row = observed['commands'][stage]
        assert row['exit'] == 0 and row['cwd'] == '.'
        assert row['argv'][-3:] == [str((HERE / 'phase0_value_probe.pl').relative_to(ROOT)),
                                  str((HERE / 'phase0-oracle-cases.json').relative_to(ROOT)), 't/phase0_regression.t']
        frame = json.loads(decode(row['frame']))
        assert decode(row['stdout']).endswith(decode(row['frame']))
        assert decode(row['stderr']) == b''
        assert frame['module_sha256'] == observed['methods'][stage]['sha256']
        assert len(frame['rows']) == 20
        for case, actual in zip(cases, frame['rows']):
            assert actual['line'] == case['line']
            assert actual['observed'] == case['expected']
            assert actual['wrong_value'] != case['expected'] and actual['warning'] != case['expected']
            assert 'error' not in json.loads(actual['observed'])
        frames.append(frame)
    assert frames[0]['rows'] == frames[1]['rows']
    assert frames[0]['helper_sha256'] == frames[1]['helper_sha256']
    restored = (ROOT / 't/phase0_regression.t').read_text()
    for case in cases:
        assert restored.count(case['replacement']) == 1
        restored = restored.replace(case['replacement'], case['original_assertion'], 1)
    assert restored.encode() == old, 'healthy assertions/helper/plans/source changed'
    assert (ROOT / 'perl/LinkedSpec/ActionIR/MethodLowering.pm').read_bytes() == decode(observed['methods']['repaired'])
    bundle = ROOT / observed['source_bundle']['path']
    assert hashlib.sha256(bundle.read_bytes()).hexdigest() == observed['source_bundle']['sha256']
    sources = json.loads(gzip.decompress(bundle.read_bytes()))['sources']
    for name, expected in observed['source_members'].items():
        assert sources[name]['sha256'] == expected
        raw = decode(observed['methods']['repaired']) if name.endswith('/MethodLowering.pm') else decode(sources[name])
        assert (ROOT / name).read_bytes() == raw, 'finite producer/input drift: ' + name
    spec = importlib.util.spec_from_file_location('phase0_calibrated_objectives', ROOT / 'tests/language-readiness/verify_objectives.py')
    audit = importlib.util.module_from_spec(spec); spec.loader.exec_module(audit)
    read = lambda name: (ROOT / name).read_bytes()
    images = audit.current_image_admissions(read)
    effective, report = audit.phase0_fixture_reader(read, images)
    old_intake = json.loads(gzip.decompress((HERE / 'objective-image-intake.json.gz').read_bytes()))
    prior_read, current_stage = audit.phase0_value_fixture_reader(read, images)
    legacy_read, legacy_report = audit._prior_phase0_fixture_reader(prior_read, images)
    assert prior_read('t/phase0_regression.t') == old
    assert legacy_report == old_intake['phase0']
    assert effective('t/phase0_regression.t') == legacy_read('t/phase0_regression.t')
    assert report['value_calibration'] == current_stage and current_stage['exact_assertion_edits'] == 20
    frontier = json.loads(gzip.decompress((HERE / 'objective-frontier-intake.json.gz').read_bytes()))
    historical = {row['path']: dict(sha256=row['historical_sha256']) for row in frontier['rows']}
    images.verify(historical, effective)
    old_controls = audit.falsify_phase0_fixture(images)
    prior = json.loads(gzip.decompress((HERE / 'objective-current-recovery.stdout.log.gz').read_bytes()))
    assert old_controls == prior['audit_controls']['phase0_fixture_mutations_rejected']
    new_controls = audit.falsify_phase0_value_fixture(images)
    assert len(new_controls) == len(set(new_controls)) == 12
    assert len(images.falsify(historical, effective)) == 19
    selected = json.loads((HERE / 'phase0-selected-channels.json').read_bytes())
    selected_counts = channels(selected)
    rejected = []
    for label in ('wrong-exit', 'missing-command'):
        changed = json.loads(json.dumps(selected))
        if label == 'wrong-exit': changed['commands']['after']['exit'] = 1
        else: del changed['commands']['after']
        try:
            channels(changed)
        except (AssertionError, KeyError):
            rejected.append(label)
        else:
            raise AssertionError('selected channel corruption admitted: ' + label)
    return dict(result='PASS', finite_cases=20, unchanged_activation_current_source_values=True,
                observed_wrong_value_and_warning_controls=40,
                exact_original_assertion_inverse=True, healthy_source_and_plans_preserved=True,
                original_phase0_controls=old_controls, new_phase0_controls=new_controls,
                historical_images=19, selected=selected_counts, rejected_channel_controls=rejected,
                limits=observed['limits'])


if __name__ == '__main__':
    print(json.dumps(review(), sort_keys=True))
