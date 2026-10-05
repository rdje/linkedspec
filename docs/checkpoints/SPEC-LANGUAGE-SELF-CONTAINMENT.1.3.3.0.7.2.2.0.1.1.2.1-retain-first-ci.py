"""Retain the canceled candidate and bounded index-ordering diagnostic honestly."""
from pathlib import Path
import base64
import gzip
import hashlib
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('retain-first-ci.py')
BASE = '77444c8d2372bf2cd1bbce29022b62c9c8f72e9d'


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}


diff = subprocess.check_output(['git', 'diff', '--cached', '--binary', '--full-index'], cwd=ROOT)
assert sha(diff) == 'd13a6ab7d9391a19e644d1666868a6e6a3d912e9c98d197ad7121ced05478e4a'
log = (ROOT / '.linkedspec-data/scratch/basic-family-canonical.log').read_bytes()
report = {'base_revision': BASE, 'staged_diff': envelope(diff), 'combined_log': envelope(log),
          'command': 'bash tools/run_ci_local.sh > .linkedspec-data/scratch/basic-family-canonical.log 2>&1',
          'exit_observation': {'code': 143, 'authority': 'Observed completion of exec session20298 after TERM to identity-verified own canonical PID81203; identified wrapper/process tree drains.'},
          'instrument_sha256': sha(Path(__file__).read_bytes()),
          'scope': 'Canceled candidate before recording the verification ordering error. No complete canonical pass or receipt claimed. Exact original staged diff and actual combined log are retained; corrected candidate requires a fresh canonical gate.'}
Path(PREFIX + 'canonical-initial.json').write_text(json.dumps(report, indent=2) + '\n')
tool_text = ('claim-verification: FAIL: SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.2.1: exactly one Claim verification declaration required\n'
             'claim-verification: self-test PASS 3 positive / 16 rejected controls\n')
checker = 'tools/check_claim_verification.py'
old = subprocess.check_output(['git', 'show', BASE + ':' + checker], cwd=ROOT)
assert old == (ROOT / checker).read_bytes(), 'unchanged actual checker source'
failure = {'command': ['bash', 'scripts/check_claim_verification.sh'], 'exit': 1,
           'authority': 'Observed completion of exec session64359; tool-returned combined text copied exactly.',
           'tool_output': envelope(tool_text.encode()), 'checker': checker, 'checker_sha256': sha(old),
           'initial_committed_revision': BASE, 'later_staged_diff_sha256': sha(diff),
           'scope': 'Index staging occurred while this background check was in flight. The checker caches index blob IDs at entry, then selects the owner from the later live index; the current staged node has its declaration. Original cached blob IDs were not retained, so the precise earlier read boundary is not claimed recovered. This is a source-backed sequencing diagnosis, not a new checker repair or complete original-input claim. Rerun only after staging completes and keep the index unchanged.'}
Path(PREFIX + 'index-ordering-failure.json').write_text(json.dumps(failure, indent=2) + '\n')
print('Retained canceled canonical exit143 and limited index-ordering failure; no original pass claim')
