"""Correct only the new publication's semantic-follow-up owner; retain its draft."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
plan = json.loads((BASE / 'plan.json').read_bytes())
path = Path('docs/claims/' + plan['owner'] + '.json')
body = path.read_bytes()
record = json.loads(body)
leg = record['claims'][0]['falsify']
old = plan['owner'].rsplit('.', 4)[0] + '.2'
new = plan['owner'].rsplit('.', 3)[0] + '.2'
assert leg['status'] == 'gap' and leg['repair_owner'] == old and old != new
with (BASE / 'claim-owner-draft.json.gz').open('xb') as stream:
    stream.write(gzip.compress(body, mtime=0))
leg['repair_owner'] = new
after = (json.dumps(record, indent=2) + '\n').encode()
path.write_bytes(after)
(BASE / 'claim-owner-correction.json').write_text(json.dumps(dict(path=str(path), before_sha256=hashlib.sha256(body).hexdigest(),
    after_sha256=hashlib.sha256(after).hexdigest(), old=old, new=new,
    reason='New publisher removed four components instead of three when deriving broader3.2; only this uncommitted claim owner is corrected. Actual used publisher and original draft retained unchanged.'), indent=2) + '\n')
print(new)
