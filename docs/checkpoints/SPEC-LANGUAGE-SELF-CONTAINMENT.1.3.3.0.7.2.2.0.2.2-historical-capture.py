"""Retain the first staged candidate and complete corrected historical-audit channels."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('historical-capture.py')
AUDITOR = 'tests/language-readiness/verify_objectives.py'
PROOF = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


def main():
    # Preserve the original failed candidate while its index is still unchanged.
    # Later reruns retain that exact capture rather than substituting a new diff.
    failed_path = Path(PREFIX + 'failed-canonical.json')
    failed = json.loads(failed_path.read_bytes())
    if 'candidate' not in failed:
        staged = subprocess.check_output(['git', 'diff', '--cached', '--name-only'], cwd=ROOT).decode().splitlines()
        assert AUDITOR not in staged, 'first canonical candidate excludes the later ledger repair'
        patch = subprocess.check_output(['git', 'diff', '--cached', '--binary', '--full-index'], cwd=ROOT)
        failed['candidate'] = {'base': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT).decode().strip(),
                               'full_index_binary_diff': envelope(patch)}
        failed['retention_instrument_sha256'] = sha(Path(__file__).read_bytes())
        failed_path.write_text(json.dumps(failed, indent=2) + '\n')
    command = ['bash', 'tools/run_python_project_data.sh', PROOF]
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    output = {'command': command, 'exit': result.returncode,
              'stdout': envelope(result.stdout), 'stderr': envelope(result.stderr),
              'instrument_sha256': sha(Path(__file__).read_bytes()),
              'proof_sha256': sha((ROOT / PROOF).read_bytes()),
              'auditor_sha256': sha((ROOT / AUDITOR).read_bytes())}
    Path(PREFIX + 'historical-actual.json').write_text(json.dumps(output, indent=2) + '\n')
    assert result.returncode == 0 and result.stderr == b'', 'complete quiet corrected historical proof'
    print('Retained original staged failure and complete corrected historical proof')


if __name__ == '__main__':
    main()
