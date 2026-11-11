"""Construct or apply only the registered-source transform classifier repair."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--apply', action='store_true')
args = parser.parse_args()
BASE = Path(__file__).resolve().parent
owner = Path('rust/linkedspec-runtime/src/engine.rs')
raw = owner.read_bytes()
assert raw == gzip.decompress((BASE / 'owner-before.rs.gz').read_bytes())
start = raw.index(b'    fn is_ordinary_array_transform_result_chain(')
end = raw.index(b'\n    fn ', start + 1)
body = raw[start:end]
old = b'''            if self.spec.find_function(name).is_some() {
                return false;
            }
            if Self::is_ordinary_array_transform_result_call(name, args, false) {
'''
new = b'''            if self.spec.find_function(name).is_none()
                && Self::is_ordinary_array_transform_result_call(name, args, false)
            {
'''
assert body.count(old) == 1
body = body.replace(old, new, 1)
anchor = b'        if let Expr::Call { name, args } = receiver {\n'
comment = b'''        // Function evaluation retains signature checks and source effects. Only
        // a following canonical transform establishes this function result guard.
'''
assert body.count(anchor) == 1
body = body.replace(anchor, comment + anchor, 1)
updated = raw[:start] + body + raw[end:]
assert updated != raw
if args.apply:
    owner.write_bytes(updated)
print(json.dumps(dict(applied=args.apply, owner=str(owner),
    before_sha256=hashlib.sha256(raw).hexdigest(),
    after_sha256=hashlib.sha256(updated).hexdigest(),
    scope='Only the transform classifier admits registered receiver prefixes; free-helper identity remains unregistered. Existing evaluation validates signatures before classification.')))
