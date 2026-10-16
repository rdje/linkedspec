"""Retain the incomplete supplied proof and reproduce its undeclared historical live read."""
import base64
import hashlib
import json
import os
import stat
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.1/'
TARGET = ROOT / (PREFIX + 'first-evidence-failure.json')
sha = lambda value: hashlib.sha256(value).hexdigest()
assert not TARGET.exists()
first = json.loads((ROOT / (PREFIX + 'review-final.json')).read_bytes())
identities = dict(first['inputs'])
identities[PREFIX + 'evidence.py'] = {'sha256': sha((ROOT / (PREFIX + 'evidence.py')).read_bytes()),
                                    'mode': stat.S_IMODE((ROOT / (PREFIX + 'evidence.py')).stat().st_mode)}
files = {p: (ROOT / p).read_bytes() for p in identities}
assert all(sha(files[p]) == x['sha256'] for p, x in identities.items())
preservation = json.loads((ROOT / (PREFIX + 'preservation.json')).read_bytes())
owned = set(preservation['owned_bound_paths'])
claim_paths = {x['path'] for x in preservation['selected']}
reads = set()
for entry in preservation['selected']:
    record = json.loads((ROOT / entry['before']).read_bytes())
    for claim in record['claims']:
        reads.update(x['path'] for x in claim['durability']['inputs']
                     if x['path'] not in owned and x['path'] not in claim_paths)
missing = sorted(reads - set(identities))
alias = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-match-alias.json'
assert alias in missing
with tempfile.TemporaryDirectory(prefix='attached-incomplete-proof-', dir=os.environ['TMPDIR']) as directory:
    supplied = Path(directory)
    assert supplied.stat().st_dev == ROOT.stat().st_dev
    for p, value in files.items():
        target = supplied / p
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(value)
        target.chmod(identities[p]['mode'])
    command = ['python3', PREFIX + 'review-final.py', '--preflight']
    env = dict(os.environ, GIT_DIR=str(ROOT / '.git'), GIT_WORK_TREE=str(supplied))
    p = subprocess.run(command, cwd=supplied, env=env, capture_output=True)
    unchanged = all((supplied / path).read_bytes() == value for path, value in files.items())
r = {'producer_sha256': sha(Path(__file__).read_bytes()),
     'first_evidence_producer_sha256': sha((ROOT / (PREFIX + 'evidence.py')).read_bytes()),
     'first_review_producer_sha256': sha((ROOT / (PREFIX + 'review-final.py')).read_bytes()),
     'first_full_review_sha256': sha((ROOT / (PREFIX + 'review-final.json')).read_bytes()),
     'first_outer_session': 97648, 'first_outer_returncode': 1,
     'inputs': identities, 'undeclared_historical_live_reads': missing,
     'replay': {'command': command, 'returncode': p.returncode,
                'stdout_base64': base64.b64encode(p.stdout).decode(),
                'stderr_base64': base64.b64encode(p.stderr).decode(), 'unchanged': unchanged},
     'scope': 'The first tool-reported artifact baseline failed on missing historical match-alias.json; '
              'its original parent/separate streams were not persisted by that producer. This distinct '
              'fresh supplied replay retains complete actual separate channels and reproduces the same '
              'first missing input. Its exact first declared source bytes/modes are bound here, and the '
              'full undeclared historical-read set is derived from both original publication records. '
              'Original capture data, first readers/producer and the first full root-only PASS remain '
              'unchanged. That PASS was not complete supplied-input admission. The repair resolves '
              'original historical bindings through their accepted Git revision, while current runtime '
              'inputs stay checked by new source-bound capsules; no observation is refreshed.'}
with TARGET.open('x') as output:
    output.write(json.dumps(r, indent=2) + '\n')
assert p.returncode == 1 and b'FileNotFoundError' in p.stderr and alias.encode() in p.stderr and unchanged
print('Incomplete supplied evidence retained:', len(identities), 'declared inputs;', len(missing), 'undeclared historical live reads; actual missing-alias RED')
