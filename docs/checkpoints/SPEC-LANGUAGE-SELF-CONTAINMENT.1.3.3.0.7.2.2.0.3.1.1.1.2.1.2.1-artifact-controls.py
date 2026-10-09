"""Actual selected-reader failures when each supplied checkpoint JSON is absent."""
import base64
import hashlib
import json
import os
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.1-'
EDGES = {
 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0-cases.json': 't/actionir_method_argument_source_frames.t',
 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0-cases.json': 't/actionir_executable_source_membership.t',
 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1-cases.json': 't/actionir_compiler_source_membership.t',
}
def digest(raw):
    return hashlib.sha256(raw).hexdigest()

baseline = json.loads((ROOT / (PREFIX + 'consumers.json')).read_text())
assert baseline['returncode'] == 0 and baseline['unchanged']
files = {p: (ROOT / p).read_bytes() for p in baseline['inputs']}
assert {p: digest(raw) for p, raw in files.items()} == baseline['inputs']
rows = []
for missing, test in EDGES.items():
    with tempfile.TemporaryDirectory(prefix='missing-artifact-', dir=os.environ['TMPDIR']) as directory:
        supplied = Path(directory)
        for p, raw in files.items():
            if p == missing:
                continue
            target = supplied / p
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(raw)
        command = ['perl', '-Iperl', test]
        result = subprocess.run(command, cwd=supplied,
                                env=dict(os.environ, PERL5LIB='', PERL5OPT='', LINKEDSPEC_EVENT_ORDER_BASELINE='0', LINKEDSPEC_MEMBERSHIP_BASELINE='0'),
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        rows.append({'missing': missing, 'command': command, 'returncode': result.returncode,
                     'inputs': {p: h for p, h in baseline['inputs'].items() if p != missing},
                     'stdout_base64': base64.b64encode(result.stdout).decode(),
                     'stderr_base64': base64.b64encode(result.stderr).decode()})
        assert result.returncode != 0 and b'No such file or directory' in result.stderr, missing
report = {'rows': rows, 'producer_sha256': digest(Path(__file__).read_bytes()),
          'baseline_sha256': digest((ROOT / (PREFIX + 'consumers.json')).read_bytes())}
(ROOT / (PREFIX + 'artifact-controls.json')).write_text(json.dumps(report, indent=2) + '\n')
print('Three actual missing-checkpoint artifact controls RED; supplied baseline remains unchanged.')
