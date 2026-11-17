"""Narrow the new metadata statement to the producer named by its proof legs."""
import copy
import gzip
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
claim = Path('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.37.json')
with tarfile.open(BASE / 'claim-scope-before.tar.gz', 'x:gz') as archive:
    for path in (BASE / 'correct_claim_scope.py', claim):
        archive.add(path, arcname=str(path), recursive=False)
(BASE / 'claim-scope-stopped-normal.log.gz').write_bytes(gzip.compress(Path('.linkedspec-data/artifact-review-nov17-commit.log').read_bytes(), mtime=0))
before = json.loads(claim.read_bytes())
after = copy.deepcopy(before)
after['claims'][0]['statement'] = ('1322 dated path/suffix/byte rows agree across the eight published scopes. Six evidence controls and an actual stage-byte source RED pass; separate readonly recovery passes and nothing is removed. The actual logical Git-index input matches its retained clean-base tree inverse before scanner interpretation.')
check = copy.deepcopy(after); check['claims'][0]['statement'] = before['claims'][0]['statement']
assert check == before, 'only the new metadata statement is narrowed'
claim.write_text(json.dumps(after, indent=2) + '\n')
(BASE / 'claim-scope-correction.json').write_text(json.dumps(dict(result='PASS', changed='claims[0].statement only',
    reason='Metadata rederive command supports the metadata/index statement. Reader proof remains in its separate claim; director authority remains in its own record.',
    old_statement=before['claims'][0]['statement'], new_statement=after['claims'][0]['statement'],
    normal_attempt='Stopped own claim checker before landing for author scope correction; no complete hook credit.'), indent=2) + '\n')
print('PASS: only the new metadata claim statement narrowed; all proof values/other claims unchanged')
