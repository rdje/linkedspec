"""Retain the deliberately interrupted canonical candidate and actual merged log."""
import gzip
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DEST = Path(__file__).resolve().parent
assert not (DEST / 'interruption.json').exists(), 'one-shot interruption retention'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
candidate = subprocess.check_output(['git', 'diff', '--cached', '--binary', '--full-index'], cwd=ROOT)
log = (ROOT / '.linkedspec-data/verification/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-canonical02.log').read_bytes()
assert b'doctrines: ALL 10 enforced doctrines PASS.' in log
assert b't/knowledge_map_header_lists.t .. ok' in log
assert b'"healthy_audit_guard"' in log
for name, raw in [('candidate.diff.gz', candidate), ('log.gz', log)]:
    with (DEST / name).open('xb') as output:
        output.write(gzip.compress(raw, mtime=0))
record = {'owner': 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11',
    'producer_sha256': sha(Path(__file__).read_bytes()),
    'actual_tool_session': 1732, 'actual_returncode': 130,
    'candidate_sha256': sha(candidate), 'candidate_bytes': len(candidate),
    'log_sha256': sha(log), 'log_bytes': len(log),
    'reason': 'Deliberately stopped the exact owned CI process group after discovering TOOLBOX.md still described28 storage owners. No full canonical PASS or receipt is claimed. Correct the unbound documentation description and rerun the exact final candidate; focused producers and observations remain unchanged.'}
(DEST / 'interruption.json').write_text(json.dumps(record, indent=2) + '\n')
print('Interrupted canonical candidate/log retained; actual session1732/130; no gate completion claimed')
