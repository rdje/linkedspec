"""Grade the exact mock-entry inverse, actual old RED and complete archival GREEN."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import importlib.util
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('historical-review.py')
AUDITOR = 'tests/language-readiness/verify_objectives.py'
PROOF = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def decode(block):
    assert block['encoding'] == 'gzip-base64', 'historical channel encoding'
    raw = gzip.decompress(base64.b64decode(block['data'], validate=True))
    assert len(raw) == block['bytes'] and sha(raw) == block['sha256'], 'complete historical channel identity'
    return raw


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    before_path = Path(PREFIX + 'before-historical-verifier.py')
    old = load('original_objective_auditor', before_path)
    current = load('current_objective_auditor', ROOT / AUDITOR)
    original = subprocess.check_output(['git', 'show', '864b1a93934ab7fd4b059b0a7cb9d4b417e33c66:' + AUDITOR], cwd=ROOT)
    assert before_path.read_bytes() == original, 'exact original verifier retained'
    source = 't/phase0_regression.t'
    contents = (ROOT / source).read_bytes()
    historical = sha(current.git('show', current.SIGNATURE_BEFORE + ':' + source))
    try:
        old.verify_signature_regression_evolution(source, contents, historical)
    except ValueError as error:
        assert str(error) == 'unreviewed signature-regression drift: ' + source, 'actual original distinguishing RED'
        original_red = str(error)
    else:
        raise AssertionError('original verifier must reject the committed scanner mock')
    accepted = current.verify_signature_regression_evolution(source, contents, historical)
    controls = []
    for name, altered, reason in (
        ('missing committed mock', contents.replace(current.COMPILER_SCAN_AFTER, current.COMPILER_SCAN_BEFORE, 1), 'compiler scanner mock registration mismatch:'),
        ('duplicate mock', contents.replace(current.COMPILER_SCAN_AFTER, current.COMPILER_SCAN_AFTER * 2, 1), 'compiler scanner mock registration mismatch:'),
        ('disabled mock', contents.replace(current.COMPILER_SCAN_AFTER, current.COMPILER_SCAN_AFTER.replace(b'sub {', b'sub { return;'), 1), 'compiler scanner mock registration mismatch:'),
        ('foreign mock', contents.replace(current.COMPILER_SCAN_AFTER, current.COMPILER_SCAN_AFTER.replace(b'_scan_executable_contract_ir_events', b'_other_scan'), 1), 'compiler scanner mock registration mismatch:'),
        ('unrelated source edit', contents + b'# unreviewed change\n', 'unreviewed signature-regression drift:'),
    ):
        assert altered != contents, 'effective source evolution control'
        try:
            current.verify_signature_regression_evolution(source, altered, historical)
        except ValueError as error:
            assert str(error).startswith(reason), 'distinguishing source evolution RED'
            controls.append({'name': name, 'observed_red': str(error)})
        else:
            raise AssertionError('unrejected source evolution control: ' + name)
    actual = json.loads(Path(PREFIX + 'historical-actual.json').read_bytes())
    assert actual['command'] == ['bash', 'tools/run_python_project_data.sh', PROOF], 'actual historical producer'
    assert actual['exit'] == 0 and decode(actual['stderr']) == b'', 'actual quiet historical GREEN'
    assert actual['proof_sha256'] == sha((ROOT / PROOF).read_bytes()), 'historical proof producer identity'
    assert actual['auditor_sha256'] == sha((ROOT / AUDITOR).read_bytes()), 'current ledger identity'
    assert actual['instrument_sha256'] == sha(Path(PREFIX + 'historical-capture.py').read_bytes()), 'actual retention producer'
    result = json.loads(decode(actual['stdout']))
    assert result['isolated_deterministic_capture'] is True and result['healthy_audit_guard'] == {
        'original_log_attempts': 0, 'tracked_write_attempts': 0}, 'unchanged archival denial boundary'
    for path, digest in result['tracked_inputs'].items():
        assert sha((ROOT / path).read_bytes()) == digest, 'actual historical producer/input identity: ' + path
    failed = json.loads(Path(PREFIX + 'failed-canonical.json').read_bytes())
    assert failed['exit'] == 1 and b'ValueError: unreviewed signature-regression drift: t/phase0_regression.t' in decode(failed), 'complete first canonical failure'
    assert failed['candidate']['base'] == '864b1a93934ab7fd4b059b0a7cb9d4b417e33c66', 'original candidate activation'
    patch = decode(failed['candidate']['full_index_binary_diff'])
    assert b'diff --git a/' + AUDITOR.encode() not in patch, 'original failed candidate had no verifier change'
    summary = {'complete': True, 'original_red': original_red, 'accepted_source': accepted,
               'source_controls': controls, 'restored_inputs': result['restored_inputs'],
               'restored_bytes': result['restored_bytes'], 'recovery_controls': len(result['controls']),
               'evolution_controls': result['audit_controls']['governance_mutations_rejected'],
               'healthy_audit_guard': result['healthy_audit_guard'],
               'failed_candidate_sha256': sha(patch), 'instrument_sha256': sha(Path(__file__).read_bytes())}
    Path(PREFIX + 'historical-verification.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps(summary, indent=2))


if __name__ == '__main__':
    main()
