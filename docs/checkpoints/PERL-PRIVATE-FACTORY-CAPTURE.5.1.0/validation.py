"""Supplemental complete public guard after staging the new executable fixtures."""
import base64
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0/'
assert sys.argv[1:] in ([], ['--capture'])
target = ROOT / (PREFIX + 'validation.json')
sha = lambda raw: hashlib.sha256(raw).hexdigest()
sources = [PREFIX + 'validation.py', 'tools/check_public_aggregate_selector_surface.py',
           'tools/check_executable_aggregate_selector_sources.py', 'tools/check_aggregate_selector_retirement.py',
           'tools/check_capability_conformance.pl', 'tools/project_data_env.sh', 'tools/project_data_run.sh',
           'tools/run_python_project_data.sh']
command = ['python3', 'tools/check_public_aggregate_selector_surface.py']
if sys.argv[1:]:
    assert not target.exists(), 'one-shot supplemental public guard'
    for path in ['t/actionir_control_expansion_capture.t', 't/actionir_control_expansion_native.pl']:
        subprocess.run(['git', 'ls-files', '--error-unmatch', '--', path], cwd=ROOT, check=True, stdout=subprocess.DEVNULL)
    identities = {p: sha((ROOT / p).read_bytes()) for p in sources}
    process = subprocess.run(command, cwd=ROOT, capture_output=True)
    report = {'producer_sha256': sha(Path(__file__).read_bytes()), 'sources': identities, 'command': command,
              'returncode': process.returncode, 'stdout_base64': base64.b64encode(process.stdout).decode(),
              'stderr_base64': base64.b64encode(process.stderr).decode(),
              'scope': 'Supplemental focused composed public selector/capability guard against the staged new executable fixtures and current book. Full actual command channels and actual producers are retained. This is not a new source-bound cross-backend/runtime/canonical admission or a complete transitive input capsule. Existing public capability and independent self-containment owners retain those admissions.'}
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    report = json.loads(target.read_bytes())
assert report['producer_sha256'] == sha(Path(__file__).read_bytes()) and report['command'] == command
assert all(sha((ROOT / p).read_bytes()) == h for p, h in report['sources'].items())
assert report['returncode'] == 0 and not base64.b64decode(report['stderr_base64'], validate=True)
out = base64.b64decode(report['stdout_base64'], validate=True)
assert b'public-aggregate-selector-surface: OK (70 public files; 40 classified removed/history references; 0 current examples; 5 migration contrasts; 11 contrast mutations; capability admitted)' in out
print('ControlFlow expansion supplemental composed public guard PASS; new executable fixtures were staged before the actual scan')
