"""Capture and strictly review the bounded historical-audit compatibility repair."""
from pathlib import Path
import base64
import copy
import gzip
import hashlib
import importlib.util
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('audit.py')
BASE = '224d5443af794d4e5ade6e80bd8f09145ee7b5b3'
AUDITOR = 'tests/language-readiness/verify_objectives.py'
PROOF = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
HISTORICAL = PROOF.removesuffix('proof.py') + 'verification.json'
SOURCE = 'perl/LinkedSpec/ActionIR/Contracts.pm'
TESTS = ['t/nested_boundary_quoted_labels.t', 't/capture_boundary_quoted_labels.t']
FAILURE = b'ValueError: current executable evidence drift: ' + SOURCE.encode() + b'\n'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def require(value, reason):
    if not value:
        raise ValueError(reason)


def read(suffix):
    return json.loads(Path(PREFIX + suffix).read_bytes())


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def decode(value):
    require(value['encoding'] == 'gzip-base64', 'audit channel encoding')
    raw = gzip.decompress(base64.b64decode(value['data'], validate=True))
    require(len(raw) == value['bytes'] and sha(raw) == value['sha256'], 'audit channel byte identity')
    return raw


def commands():
    return [
        ['bash', 'tools/run_python_project_data.sh', Path(PREFIX + 'audit-probe.py').relative_to(ROOT).as_posix()],
        ['bash', 'tools/run_python_project_data.sh', PROOF],
        ['bash', 'tools/project_data_run.sh', 'prove', '-v', '-Iperl'] + TESTS,
    ]


def inputs():
    paths = set(json.loads((ROOT / HISTORICAL).read_bytes())['tracked_inputs'])
    paths.update((HISTORICAL, AUDITOR, PROOF, Path(__file__).relative_to(ROOT).as_posix()))
    paths.update(Path(PREFIX + suffix).relative_to(ROOT).as_posix() for suffix in
                 ('audit-before.py', 'audit-probe.py', 'audit-census.py', 'audit-census.json', 'second-canonical.json'))
    return {path: sha((ROOT / path).read_bytes()) for path in sorted(paths)}


def check_report(report):
    require(report['complete'] and report['base'] == BASE, 'complete audit boundary')
    require(report['instrument_sha256'] == sha(Path(__file__).read_bytes()), 'actual audit producer')
    require([row['command'] for row in report['runs']] == commands(), 'complete audit command population')
    expected = inputs()
    require(report['inputs'] == expected, 'complete actual audit inputs')
    for row, code in zip(report['runs'], (1, 0, 0)):
        require(row['exit'] == code and row['inputs_before'] == row['inputs_after'] == expected,
                'exact audit exits and input guards')
    red, green, tests = report['runs']
    red_error = decode(red['stderr'])
    require(decode(red['stdout']) == b'' and red_error.startswith(b'Traceback (most recent call last):\n')
            and red_error.endswith(FAILURE),
            'actual original auditor RED')
    require(decode(green['stderr']) == decode(tests['stderr']) == b'', 'empty successful audit outer stderr')
    proof = json.loads(decode(green['stdout']))
    require(proof['healthy_audit_guard'] == {'original_log_attempts': 0, 'tracked_write_attempts': 0}
            and proof['isolated_deterministic_capture'] is True, 'isolated recovery denial and regeneration')
    manifest = json.loads((ROOT / 'tests/language-readiness/artifacts/objective-audit-inputs.json').read_bytes())
    require(proof['restored_inputs'] == 134 and proof['restored_bytes'] == 84613241
            and proof['restored_hashes'] == {row['path']: row['sha256'] for row in manifest['entries']},
            'complete exact original artifact recovery')
    require(len(proof['controls']) == 22, 'all original recovery controls')
    audit = proof['audit_report']
    prior = json.loads((ROOT / HISTORICAL).read_bytes())['audit_report']
    require(audit['checkpoints'] == prior['checkpoints'] and audit['latest_source_inputs'] == prior['latest_source_inputs']
            and audit['retained_log_hashes'] == prior['retained_log_hashes']
            and audit['historical_source_references'] == 257
            and len(audit['checkpoints']) == 24 and len(audit['latest_source_inputs']) == 149,
            'unchanged historical source checkpoint and log identities')
    counts = {SOURCE: 6, 't/phase0_regression.t': 17, 'tools/run_ci_local.sh': 27,
              'tools/test_perl_project_data_storage.sh': 6}
    require(proof['audit_controls']['governance_mutations_by_source'] == counts
            and proof['audit_controls']['governance_mutations_rejected'] == 56,
            'complete effective historical evolution controls')
    text = decode(tests['stdout']).decode()
    require(not re.search(r'^\s*not ok\b', text, re.M), 'all nested boundary assertions pass')
    require(re.findall(r'^1\.\.(\d+)\s*$', text, re.M) == ['28', '18'], 'complete boundary plans')
    for path, plan in zip(TESTS, (28, 18)):
        section = text.split(path + ' ..', 1)[1].split('\n1..' + str(plan), 1)[0]
        require(re.findall(r'^ok (\d+)\b', section, re.M) == [str(i) for i in range(1, plan + 1)],
                'complete ordered boundary assertions')
    return proof


def capture():
    guarded = inputs()
    report = {'base': BASE, 'instrument_sha256': sha(Path(__file__).read_bytes()),
              'inputs': guarded, 'complete': False, 'runs': []}
    for command in commands():
        before = inputs()
        result = subprocess.run(command, cwd=ROOT, capture_output=True)
        after = inputs()
        report['runs'].append({'command': command, 'exit': result.returncode,
                              'stdout': envelope(result.stdout), 'stderr': envelope(result.stderr),
                              'inputs_before': before, 'inputs_after': after})
        Path(PREFIX + 'audit-observations.json').write_text(json.dumps(report, indent=2) + '\n')
        require(before == after == guarded, 'unchanged audit inputs during capture')
        print('audit command ' + str(len(report['runs'])) + ' exit ' + str(result.returncode), flush=True)
    report['complete'] = True
    Path(PREFIX + 'audit-observations.json').write_text(json.dumps(report, indent=2) + '\n')
    check_report(report)


def review():
    report = read('audit-observations.json')
    proof = check_report(report)
    original = subprocess.check_output(['git', 'show', BASE + ':' + AUDITOR], cwd=ROOT)
    require(original == Path(PREFIX + 'audit-before.py').read_bytes(), 'exact original auditor source')
    census = read('audit-census.json')
    expected_deltas = {SOURCE, 't/phase0_regression.t', 'tools/run_ci_local.sh', 'tools/test_perl_project_data_storage.sh'}
    require(len(census['sources']) == 149 and {row['path'] for row in census['sources']
            if row.get('changed') and row['kind'] == 'executable'} == expected_deltas, 'complete audited executable delta census')
    module_spec = importlib.util.spec_from_file_location('repaired_audit', ROOT / AUDITOR)
    audit = importlib.util.module_from_spec(module_spec)
    module_spec.loader.exec_module(audit)
    current = (ROOT / SOURCE).read_bytes()
    historical_hash = proof['audit_report']['latest_source_inputs'][SOURCE]['sha256']
    evolution = audit.verify_boundary_contract_evolution(SOURCE, current, historical_hash)
    # The complete original file is an independent oracle for the two-edit inverse.
    inverse = current.replace(audit.BOUNDARY_IMPORT, b'', 1).replace(
        audit.BOUNDARY_LOOP_AFTER, audit.BOUNDARY_LOOP_BEFORE, 1)
    require(inverse == subprocess.check_output(['git', 'show', audit.BOUNDARY_BEFORE + ':' + SOURCE], cwd=ROOT)
            and sha(inverse) == historical_hash, 'exact original boundary contract recovery')
    controls = []

    def reject(name, mutation, reason):
        bad = copy.deepcopy(report)
        mutation(bad)
        require(bad != report, 'effective audit corruption: ' + name)
        try:
            check_report(bad)
        except ValueError as error:
            require(str(error) == reason, 'unrelated audit corruption rejection: ' + name)
            controls.append({'name': name, 'reason': reason, 'observed': 'RED'})
        else:
            raise ValueError('accepted audit corruption: ' + name)

    for i in range(3):
        reject('false exit ' + str(i), lambda x, i=i: x['runs'][i].update(exit=7), 'exact audit exits and input guards')
        reject('missing guard ' + str(i), lambda x, i=i: x['runs'][i].update(inputs_after={}), 'exact audit exits and input guards')
    reject('missing command', lambda x: x['runs'].pop(), 'complete audit command population')
    reject('forged producer', lambda x: x.update(instrument_sha256='0' * 64), 'actual audit producer')
    reject('missing input', lambda x: x['inputs'].pop(next(iter(x['inputs']))), 'complete actual audit inputs')
    reject('false GREEN stream', lambda x: x['runs'][1]['stdout'].update(sha256='0' * 64), 'audit channel byte identity')
    reject('hidden outer warning', lambda x: x['runs'][1].update(stderr=envelope(b'warning\n')), 'empty successful audit outer stderr')
    reject('false original RED', lambda x: x['runs'][0].update(stderr=envelope(b'other failure\n')), 'actual original auditor RED')
    reject('hidden original startup warning', lambda x: x['runs'][0].update(stderr=envelope(
        b'setpgid: Operation not permitted\n' + decode(x['runs'][0]['stderr']))), 'actual original auditor RED')
    for name, mutation, reason in (
        ('escaped recovery read', lambda x: x['healthy_audit_guard'].update(original_log_attempts=1), 'isolated recovery denial and regeneration'),
        ('incomplete recovery', lambda x: x.update(restored_inputs=133), 'complete exact original artifact recovery'),
        ('refreshed historical source', lambda x: x['audit_report']['latest_source_inputs'][SOURCE].update(sha256='0' * 64), 'unchanged historical source checkpoint and log identities'),
        ('missing boundary falsifier', lambda x: x['audit_controls']['governance_mutations_by_source'].update({SOURCE: 5}), 'complete effective historical evolution controls'),
    ):
        def change(x, mutation=mutation):
            value = json.loads(decode(x['runs'][1]['stdout']))
            mutation(value)
            x['runs'][1]['stdout'] = envelope(json.dumps(value).encode())
        reject(name, change, reason)
    result = {'complete': True, 'base': BASE, 'commands': 3, 'audited_sources': 149,
              'historical_source_references': 257, 'checkpoints': 24, 'restored_inputs': 134,
              'restored_bytes': 84613241, 'recovery_controls': 22, 'evolution_controls': 56,
              'boundary_controls': 6, 'boundary_recurrence_controls': 6,
              'boundary_fixture_groups': 46, 'controls': controls,
              'evolution': evolution, 'input_bindings': report['inputs'],
              'instrument_sha256': sha(Path(__file__).read_bytes())}
    Path(PREFIX + 'audit-verification.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: v for k, v in result.items() if k not in ('controls', 'input_bindings', 'evolution')}))
    print(str(len(controls)) + ' effective audit evidence controls RED')


if __name__ == '__main__':
    require(sys.argv[1:] in (['capture'], ['review']), 'usage: audit.py {capture|review}')
    capture() if sys.argv[1] == 'capture' else review()
