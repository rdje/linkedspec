"""Retain the exact CI inverse and its independent registration fault controls.

The complete recovery report is an observation of historical evidence integrity,
not fresh execution of the runtimes described by that historical evidence.
"""
import argparse
import base64
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
AUDITOR = 'tests/language-readiness/verify_objectives.py'
RUNNER = 'tools/run_ci_local.sh'
SELECTED = (
    'tools/test_diagnosis_evidence.py',
    'docs/checkpoints/task-acceptance-backend-scope/test_restoration_boundary.py',
    'docs/checkpoints/task-acceptance-backend-scope/test_publish.py',
)
REPORT = ROOT / '.linkedspec-data/logs/task-evidence-ci-registration-focused.json'
OUTPUT = HERE / 'ci-registration-after.json.gz'


def packet(raw):
    return {'sha256': hashlib.sha256(raw).hexdigest(),
            'base64': base64.b64encode(raw).decode()}


def check(report):
    spec = importlib.util.spec_from_file_location('registration_audit', ROOT / AUDITOR)
    audit = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(audit)
    source = (ROOT / RUNNER).read_bytes()
    row, = [r for r in report['audit_report']['governance_updates'] if r['path'] == RUNNER]
    assert row['current'] == hashlib.sha256(source).hexdigest()
    assert row['task_evidence_owner'] == 'TYPE-REFERENCE-BOOK.1.2.23.4.3'
    assert audit.verify_governance_evolution(RUNNER, source, row['historical']) == row
    # These independently constructed command lines do not consult the auditor's
    # insertion list. Every mutation must be effective and specifically rejected.
    start = b'log "checking task-evidence path coverage through isolated indexes"\n'
    assert source.count(start) == 1
    begin = source.index(start)
    end = source.index(b'\n\n', begin) + 2
    block = source[begin:end]
    variants = [('missing-block', source.replace(block, b'', 1)),
                ('duplicate-block', source.replace(block, block * 2, 1))]
    for path in SELECTED:
        presence = ('require_tracked_file ' + path + '\n').encode()
        execution = ('bash "$REPO_ROOT/tools/run_python_project_data.sh" ' + path + '\n').encode()
        assert source.count(presence) == source.count(execution) == 1
        variants.extend(((path + ':missing-presence', source.replace(presence, b'', 1)),
                         (path + ':disabled-execution', source.replace(execution, b'true\n', 1)),
                         (path + ':wrong-execution', source.replace(
                             execution, execution.replace(path.encode(), b'tools/unreviewed.py'), 1))))
    rejected = []
    for label, changed in variants:
        assert changed != source
        try:
            audit.verify_governance_evolution(RUNNER, changed, row['historical'])
        except ValueError as error:
            assert str(error).startswith('governance registration mismatch:')
            rejected.append({'name': label, 'reason': str(error)})
        else:
            raise AssertionError('registration corruption accepted: ' + label)
    assert len(rejected) == 11
    assert report['healthy_audit_guard'] == {'original_log_attempts': 0, 'tracked_write_attempts': 0}
    return {'inverse': row, 'registration_faults': rejected,
            'historical_governance_denials': report['audit_controls']['governance_mutations_rejected']}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--record', action='store_true')
    args = parser.parse_args()
    if args.record:
        assert not OUTPUT.exists(), 'capture is one-shot'
        raw = REPORT.read_bytes()
        report = json.loads(raw)
        result = check(report)
        inputs = {}
        for name, expected in report['tracked_inputs'].items():
            image = packet((ROOT / name).read_bytes())
            assert image['sha256'] == expected, 'changed proof input: ' + name
            inputs[name] = image
        for name, expected in report['observed_artifact_inputs'].items():
            assert inputs[name]['sha256'] == expected
        body = {'result': result, 'report': packet(raw), 'inputs': inputs,
                'producer': packet(Path(__file__).read_bytes()),
                'limits': 'Exact CI inverse and selected corruption denials; complete recovery report '
                          'retained as historical evidence integrity, not new runtime execution or '
                          'transitive toolchain containment proof.'}
        encoded = json.dumps(body, sort_keys=True, separators=(',', ':')).encode()
        OUTPUT.write_bytes(gzip.compress(encoded, mtime=0))
        assert gzip.decompress(OUTPUT.read_bytes()) == encoded
    else:
        body = json.loads(gzip.decompress(OUTPUT.read_bytes()))
        report_raw = base64.b64decode(body['report']['base64'])
        assert packet(report_raw) == body['report']
        assert packet(Path(__file__).read_bytes()) == body['producer']
        result = check(json.loads(report_raw))
        assert result == body['result']
        for name, image in body['inputs'].items():
            assert packet(base64.b64decode(image['base64'])) == image
            assert packet((ROOT / name).read_bytes()) == image, 'changed retained input: ' + name
    print(json.dumps({'registration_controls': len(result['registration_faults']),
                      'governance_denials': result['historical_governance_denials'],
                      'retained_inputs': len(body['inputs']), 'result': 'PASS'}, sort_keys=True))


if __name__ == '__main__':
    main()
