"""One-shot supplemental standard syntax and public Phase0 commands."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5-'
target = ROOT / (PREFIX + 'compat.json')
assert not target.exists(), 'one-shot standard command capture'
commands = [
    ['perl', '-c', 'perl/LinkedSpec.pm'],
    ['perl', '-c', '-Iperl', 't/phase0_regression.t'],
    ['prove', '-v', '-Iperl', 't/phase0_regression.t'],
]
rows = []
for command in commands:
    process = subprocess.run(command, cwd=ROOT, capture_output=True)
    rows.append({'command': command, 'returncode': process.returncode,
        'stdout_base64': base64.b64encode(process.stdout).decode(),
        'stderr_base64': base64.b64encode(process.stderr).decode()})
    record = {'result': 'pending', 'producer_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        'rows': rows, 'scope': 'Supplemental standard commands with complete actual channels. No complete transitive input capsule or new full-private/parent/canonical admission; independent guarded private Phase0 acceptance remains with SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.5.'}
    target.write_text(json.dumps(record, indent=2) + '\n')
    assert process.returncode == 0, 'standard command failed; actual result retained'
record['result'] = 'PASS'
target.write_text(json.dumps(record, indent=2) + '\n')
print('AST-optional supplemental standard syntax/public Phase0 commands PASS')
