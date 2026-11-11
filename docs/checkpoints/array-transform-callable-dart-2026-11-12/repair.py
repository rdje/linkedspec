"""Construct or apply only the registered-source Dart transform guard repair."""
import argparse
import gzip
import hashlib
import json
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--apply', action='store_true')
args = parser.parse_args()
BASE = Path(__file__).resolve().parent
owner = Path('dart/lib/src/runtime/interpreter.dart')
source = owner.read_bytes()
assert source == gzip.decompress((BASE / 'owner-before.dart.gz').read_bytes())
start = source.index(b'  bool _isOrdinaryArrayTransformResultChain(')
end = source.index(b'\n  bool ', start + 1)
body = source[start:end]
old = b'''      if (compiledSpec.functionRegistry.hasName(receiver.name)) {
        return false;
      }
      if ((receiver.sourceMethod ?? receiver.name) == receiver.name &&
'''
new = b'''      if (!compiledSpec.functionRegistry.hasName(receiver.name) &&
          (receiver.sourceMethod ?? receiver.name) == receiver.name &&
'''
assert body.count(old) == 1
body = body.replace(old, new, 1)
anchor = b'    if (receiver is ActionCallExpr) {\n'
comment = b'''    // Function evaluation keeps invocation checks and source effects. A following
    // canonical transform owns result guards without becoming a free helper call.
'''
assert body.count(anchor) == 1
body = body.replace(anchor, comment + anchor, 1)
updated = source[:start] + body + source[end:]
assert updated != source
if args.apply:
    owner.write_bytes(updated)
print(json.dumps(dict(applied=args.apply, owner=str(owner),
    before_sha256=hashlib.sha256(source).hexdigest(),
    after_sha256=hashlib.sha256(updated).hexdigest(),
    scope='Only registered source prefixes reach canonical transform guards; unregistered free-helper identity and existing invocation/producer policies remain.')))
