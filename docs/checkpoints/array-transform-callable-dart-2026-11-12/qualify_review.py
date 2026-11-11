"""Qualify only the reader's raw-channel negative control; retain original1."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent
assert (BASE / 'launches/first-review/exit.txt').read_text() == '1\n'
stderr = gzip.decompress((BASE / 'launches/first-review/stderr.log.gz').read_bytes())
assert b'TypeError: Object of type bytes is not JSON serializable' in stderr
assert b"reject('actual Dart stderr hidden'" in stderr
source = (BASE / 'review.py').read_bytes()
old = b"reject('actual Dart stderr hidden', lambda: require_same(raw('after/native-stderr.log.gz') + b'warning', b''))"
new = b"reject('actual Dart stderr hidden', lambda: require_bytes(raw('after/native-stderr.log.gz') + b'warning', b''))"
assert source.count(old) == 1
target = source.replace(old, new).replace(b'\ndef main():', b'\ndef require_bytes(left, right):\n    assert left == right\n\n\ndef main():', 1)
path = BASE / 'review_qualified.py'
assert not path.exists()
path.write_bytes(target)
record = dict(original_exit=1, original_source_sha256=hashlib.sha256(source).hexdigest(),
    original_stderr_sha256=hashlib.sha256(stderr).hexdigest(),
    qualified_source_sha256=hashlib.sha256(target).hexdigest(),
    root_cause='Raw bytes passed to strict JSON value comparator by one corruption control; TypeError escaped the expected assertion/value/key failures.',
    repair='Only that control now uses a raw-byte equality assertion. Original sealed reader, failed run, SDK epochs, profiles and production repair remain exact.',
    scope='No acquisition replay, rebaseline, suppression or product change; qualified first full reader remains pending.')
(BASE / 'review-qualification.json').write_text(json.dumps(record, indent=2) + '\n')
print('Qualified exactly one reader-only raw-byte corruption control; original1 retained')
