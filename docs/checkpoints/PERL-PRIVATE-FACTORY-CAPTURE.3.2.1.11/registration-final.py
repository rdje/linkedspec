"""One-shot exact historical registration controls and full public dependency proof."""
import base64
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11/'
TARGET = ROOT / (PREFIX + 'registration-final.json')
assert not TARGET.exists(), 'one-shot complete registration proof'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
CI = 'tools/run_ci_local.sh'
STORAGE = 'tools/test_perl_project_data_storage.sh'
AUDITOR = 'tests/language-readiness/verify_objectives.py'
MILESTONE = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.5-verification.json'

def module(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    value.ROOT = ROOT
    return value

before = module('registration_before', PREFIX + 'auditor-before.py')
current = module('registration_current', AUDITOR)
milestone = json.loads((ROOT / MILESTONE).read_bytes())['audit']['current_source_hashes']
intermediate = json.loads((ROOT / (PREFIX + 'audit-ci-only.json')).read_bytes())
for row in intermediate['audit_report']['governance_updates']:
    if row['path'] == STORAGE:
        milestone[STORAGE] = row['historical']
rows = []

def rejected(name, function, source, raw, expected, reason):
    try:
        function(source, raw, expected)
    except ValueError as error:
        message = str(error)
        assert reason in message, (name, message)
        rows.append({'name': name, 'source': source, 'input_sha256': sha(raw),
            'input_base64': base64.b64encode(raw).decode(), 'reason': message})
    else:
        raise AssertionError('unrejected registration mutation: ' + name)

ci = (ROOT / CI).read_bytes()
storage = (ROOT / STORAGE).read_bytes()
rejected('original-CI-drift', before.verify_governance_evolution, CI, ci, milestone[CI], 'unreviewed governance drift:')
rejected('original-storage-registration', before.verify_perl_storage_evolution, STORAGE, storage, milestone[STORAGE], 'Perl storage registration mismatch:')
ci_good = current.verify_governance_evolution(CI, ci, milestone[CI])
storage_good = current.verify_perl_storage_evolution(STORAGE, storage, milestone[STORAGE])
assert ci_good['knowledge_header_gate_owner'] == storage_good['knowledge_header_gate_owner'] == 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11'
anchor, insertion = current.KNOWLEDGE_HEADER_GATE_CI_INSERTIONS[0]
assert ci.count(anchor + insertion) == 1
inverse = ci.replace(anchor + insertion, anchor, 1)
assert inverse == subprocess.check_output(['git', 'show', '328b11c5ed1d5ffbc870f6785448e3a8249fe882:' + CI], cwd=ROOT)
before.verify_governance_evolution(CI, inverse, milestone[CI])
ci_variants = [
    ('missing-block', ci.replace(insertion, b'', 1)),
    ('duplicate-block', ci.replace(insertion, insertion * 2, 1)),
    ('disabled-test', ci.replace(b'PERL5LIB= prove t/knowledge_map_header_lists.t', b'PERL5LIB= true t/knowledge_map_header_lists.t', 1)),
    ('missing-tracked-input', ci.replace(b'require_tracked_file t/knowledge_map_header_lists.t\n', b'', 1)),
    ('wrong-tracked-input', ci.replace(b'require_tracked_file t/knowledge_map_header_lists.t', b'require_tracked_file t/other_header_lists.t', 1)),
    ('unrelated-edit', ci + b'# unrelated unreviewed edit\n'),
]
for name, raw in ci_variants:
    assert raw != ci
    rejected('CI/' + name, current.verify_governance_evolution, CI, raw, milestone[CI], 'governance')
old_storage = (ROOT / (PREFIX + 'storage-before.sh')).read_bytes()
before.verify_perl_storage_evolution(STORAGE, old_storage, milestone[STORAGE])
assert storage.replace(b'== 29 ))', b'== 28 ))', 1).replace(b'drifted from 29 to', b'drifted from 28 to', 1).replace(
    b' t/knowledge_map_header_lists.t; do', b'; do', 1).replace(b'PASS: 29 Perl allocators', b'PASS: 28 Perl allocators', 1) == old_storage
membership = b' t/knowledge_map_header_lists.t; do'
storage_variants = [
    ('missing-owner', storage.replace(membership, b'; do', 1)),
    ('wrong-owner', storage.replace(membership, b' t/other_header_lists.t; do', 1)),
    ('old-count', storage.replace(b'== 29 ))', b'== 28 ))', 1)),
    ('wrong-diagnostic', storage.replace(b'drifted from 29 to', b'drifted from 28 to', 1)),
    ('duplicated-owner', storage.replace(membership, b' t/knowledge_map_header_lists.t t/knowledge_map_header_lists.t; do', 1)),
    ('unrelated-edit', storage + b'# unrelated unreviewed edit\n'),
]
for name, raw in storage_variants:
    assert raw != storage
    rejected('storage/' + name, current.verify_perl_storage_evolution, STORAGE, raw, milestone[STORAGE], 'Perl storage')
commands = []
for command in (['bash', 'tools/run_python_project_data.sh', 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'],
                ['bash', STORAGE]):
    process = subprocess.run(command, cwd=ROOT, capture_output=True)
    commands.append({'command': command, 'returncode': process.returncode,
        'stdout_base64': base64.b64encode(process.stdout).decode(), 'stderr_base64': base64.b64encode(process.stderr).decode()})
    TARGET.write_text(json.dumps({'result': 'pending', 'controls': rows, 'commands': commands}, indent=2) + '\n')
    assert process.returncode == 0 and not process.stderr, ('actual public dependency proof', command, process.stderr)
audit = json.loads(base64.b64decode(commands[0]['stdout_base64']))
assert audit['healthy_audit_guard'] == {'original_log_attempts': 0, 'tracked_write_attempts': 0}
assert b'PASS: 29 Perl allocators' in base64.b64decode(commands[1]['stdout_base64'])
inputs = dict(audit['tracked_inputs'])
for path in (CI, STORAGE, AUDITOR, MILESTONE, 't/knowledge_map_header_lists.t', PREFIX + 'auditor-before.py',
             PREFIX + 'auditor-ci-only.py', PREFIX + 'audit-ci-only.json', PREFIX + 'storage-before.sh',
             PREFIX + 'registration-before.json', PREFIX + 'registration-final.py'):
    inputs[path] = sha((ROOT / path).read_bytes())
assert all(sha((ROOT / path).read_bytes()) == value for path, value in inputs.items())
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()), 'controls': rows,
    'ci': ci_good, 'storage': storage_good, 'commands': commands, 'inputs': inputs,
    'scope': 'Two unchanged original-source registration REDs; six CI and six storage reason-sensitive current denials. Exact new CI insertion inverse recovers accepted328b11c5 whole runner; exact storage update recovers its accepted28-owner source. Complete public isolated historical recovery and direct managed-storage proof pass without refreshing historical runtime observations.'}
TARGET.write_text(json.dumps(report, indent=2) + '\n')
print('Registration compatibility PASS: two original REDs; six CI/six storage denials; exact inverses; public recovery/storage GREEN')
