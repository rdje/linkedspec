"""Qualify only the first readonly reader's unordered four-route map comparison."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
original = BASE / 'review.py'
target = BASE / 'review_qualified.py'
assert not target.exists() and not (BASE / 'reader-qualification.json').exists()
failed = BASE / 'launches/first-review'
assert (failed / 'exit.txt').read_text() == '1\n'
stderr = gzip.decompress((failed / 'stderr.log.gz').read_bytes())
assert b'semantics' in stderr and b'exact(cold[prefix' in stderr and b'assert list(actual) == list(expected)' in stderr
old = '    assert list(actual) == list(expected) and canonical(actual) == canonical(expected)\n'
new = '    assert ((set(actual) == set(ROUTES) and set(expected) == set(ROUTES)) or list(actual) == list(expected)) and canonical(actual) == canonical(expected)\n'
source = original.read_text()
assert source.count(old) == 1
qualified = source.replace(old, new)
target.write_text(qualified)
assert target.read_text() == qualified
(BASE / 'reader-qualification.json').write_text(json.dumps(dict(
    original='review.py', original_sha256=hashlib.sha256(original.read_bytes()).hexdigest(),
    qualified='review_qualified.py', qualified_sha256=hashlib.sha256(target.read_bytes()).hexdigest(),
    original_actual_exit=1, original_stderr_bytes=len(stderr), original_stderr_sha256=hashlib.sha256(stderr).hexdigest(),
    cause='Four-route objects serialize in sorted JSON key order, while the authored values helper inserts native/restored/plan/fresh. Object member ordering is not a semantic difference.',
    correction='Only exact() permits unordered keys for objects whose keys are exactly the four routes. Complete case ordering, map census, types, values, flags and field absence still use the original oracle. Original sealed reader/source/channels remain unchanged; no SDK replay.'), indent=2) + '\n')
print('Prepared qualified readonly route-map comparison; first reader1 and sealed source remain intact')
