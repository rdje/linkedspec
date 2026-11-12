"""Construct/apply only the existing concat result-count selector and comment."""
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
before = owner.read_bytes()
assert before == gzip.decompress((BASE / 'owner-before.rs.gz').read_bytes())
old = b'            "concat_arrays" => count == 2,\n'
new = b'            "concat_arrays" => count >= 1,\n'
assert before.count(old) == 1
after = before.replace(old, new, 1)
old_comment = b'    // retain their original routes; variadic concat gains no new authority.\n'
new_comment = b'    // retain their original routes. Concat keeps its existing open arity.\n'
assert after.count(old_comment) == 1
after = after.replace(old_comment, new_comment, 1)
if args.apply:
    owner.write_bytes(after)
print(json.dumps(dict(applied=args.apply, owner=str(owner),
    before_sha256=hashlib.sha256(before).hexdigest(), after_sha256=hashlib.sha256(after).hexdigest(),
    scope='Only existing concat result-count classification and its comment; original producer/function dispatch/signatures/formats unchanged.')))
