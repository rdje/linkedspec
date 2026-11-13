"""Keep binary attachments as bytes; preserve the original UTF-8 reader failure."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
source = BASE / 'review_publication.py'
body = source.read_bytes()
identities = json.loads((BASE / 'proofs/publication-review/source-identities.json').read_bytes())
assert dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=source.stat().st_mode & 0o777) == identities[str(source)]
assert (BASE / 'proofs/publication-review/exit.txt').read_text() == '1\n'
failure = gzip.decompress((BASE / 'proofs/publication-review/stderr.gz').read_bytes())
assert b'UnicodeDecodeError' in failure and b'bodies[member.name] = body.decode()' in failure
text = body.decode()
old = 'bodies[member.name] = body.decode()'
new = "bodies[member.name] = body.decode() if member.name.endswith(('.md', '.py', '.json', '.txt')) else body"
assert text.count(old) == 1
text = text.replace(old, new)
(BASE / 'publication-reader-qualified-execution.py.gz').write_bytes(gzip.compress(text.encode(), mtime=0))
(BASE / 'publication-reader-qualification.json').write_text(json.dumps(dict(
    original_sha256=hashlib.sha256(body).hexdigest(), execution_sha256=hashlib.sha256(text.encode()).hexdigest(),
    exact_change=[old, new], scope='All archive membership/hash/mode checks remain; only known text suffixes decode. Original reader1 stays intact.'), indent=2) + '\n')
exec(compile(text, str(source) + '#qualified', 'exec'), {'__file__': str(source), '__name__': '__main__'})
