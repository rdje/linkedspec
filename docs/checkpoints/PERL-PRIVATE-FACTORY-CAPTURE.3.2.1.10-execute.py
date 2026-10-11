"""Execute a hash-bound review body while checking its historical report identity.

The historical report still names its actual original capture producer. __file__
therefore refers to that immutable original when recomputing the old report. The
executed body is separate, hash-bound and explicitly identified in this output;
its SHA must never be presented as the historical capture producer's SHA.
"""
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BODY = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10-corrected-body.py'
ORIGINAL = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2-review.py'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2.json'
assert len(sys.argv) == 2
sha = lambda raw: hashlib.sha256(raw).hexdigest()
raw = (ROOT / BODY).read_bytes()
assert sha(raw) == sys.argv[1], 'actual executed body identity'
historical = json.loads((ROOT / CLAIM).read_bytes())['claims'][0]['durability']['inputs']
original_sha = next(entry['sha256'] for entry in historical if entry['path'] == ORIGINAL)
assert sha((ROOT / ORIGINAL).read_bytes()) == original_sha, 'immutable historical capture producer'
sys.argv = [ORIGINAL]
exec(compile(raw, str(ROOT / BODY), 'exec'), {'__file__': str(ROOT / ORIGINAL), '__name__': '__main__'})
print('Executed review body SHA256 ' + sha(raw) + '; historical report producer remains ' + original_sha)
