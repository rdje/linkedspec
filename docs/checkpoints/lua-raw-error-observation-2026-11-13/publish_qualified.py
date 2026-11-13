"""Qualify only the two known reference mentions; preserve the failed publisher."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
source = BASE / 'publish.py'
body = source.read_bytes()
identities = json.loads((BASE / 'proofs/publish/source-identities.json').read_bytes())
assert dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=source.stat().st_mode & 0o777) == identities[str(source)]
assert (BASE / 'proofs/publish/exit.txt').read_text() == '1\n'
failure = gzip.decompress((BASE / 'proofs/publish/stderr.gz').read_bytes())
assert b'assert buffers[REFERENCE].count(old_phrase) == 1' in failure
text = body.decode()
changes = (
    ("OUT = BASE / 'publication'", "OUT = BASE / 'publication-qualified'"),
    ('assert buffers[REFERENCE].count(old_phrase) == 1', 'assert buffers[REFERENCE].count(old_phrase) == 2'),
)
for old, new in changes:
    assert text.count(old) == 1
    text = text.replace(old, new)
assert not (BASE / 'publication-qualified').exists()
(BASE / 'publish-qualified-execution.py.gz').write_bytes(gzip.compress(text.encode(), mtime=0))
(BASE / 'publication-qualification.json').write_text(json.dumps(dict(original_sha256=hashlib.sha256(body).hexdigest(),
    execution_sha256=hashlib.sha256(text.encode()).hexdigest(), exact_changes=changes,
    reason='The helper reference has the same known phrase in its pipeline and concat sections. Preserve both historical scopes and update both prospective coverage pointers. The original failed before shared writes.'), indent=2) + '\n')
exec(compile(text, str(BASE / 'publish.py') + '#qualified', 'exec'), {'__file__': str(BASE / 'publish.py'), '__name__': '__main__'})
