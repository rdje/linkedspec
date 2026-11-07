"""Rehearse only the corrected writer's read/construct prefix; never mutate SDK."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
writer = BASE / 'repair_qualified.py'
marker = "(BASE / 'owner-before.rs.gz').write_bytes"
body = writer.read_text()
assert body.count(marker) == 1
owner = Path('rust/linkedspec-runtime/src/engine.rs')
before = owner.read_bytes()
namespace = dict(__file__=str(writer))
exec(compile(body[:body.index(marker)], str(writer) + ':construction-only', 'exec'), namespace)
candidate = namespace['source'].encode()
assert owner.read_bytes() == before
assert candidate.count(b'let array_transform_chain =') == 2
assert candidate.count(b'fn is_ordinary_array_transform_result_call(') == 1
assert candidate.count(b'fn is_ordinary_array_transform_result_chain(') == 1
assert not (BASE / 'owner-before.rs.gz').exists()
(BASE / 'writer-construction.rs.gz').write_bytes(gzip.compress(candidate, mtime=0))
(BASE / 'writer-construction.json').write_text(json.dumps(dict(
    writer_sha256=hashlib.sha256(writer.read_bytes()).hexdigest(),
    owner_sha256=hashlib.sha256(before).hexdigest(),
    candidate_sha256=hashlib.sha256(candidate).hexdigest(), owner_unchanged=True), indent=2) + '\n')
print('anchored construction checks pass for both guard blocks; actual SDK remains unchanged')
