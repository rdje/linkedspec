"""Compose today's bounded census from one explicit unchanged source template."""
import gzip
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
prior = 'docs/checkpoints/artifact-review-2026-11-10/review.py'
raw = (ROOT / prior).read_bytes()
assert not (HERE / 'census.py').exists(), 'one-shot composition'
(HERE / 'composition-input.json.gz').write_bytes(gzip.compress(raw, mtime=0))
assert gzip.decompress((HERE / 'composition-input.json.gz').read_bytes()) == raw
body = raw.decode()
for old, new in (
    ('TYPE-REFERENCE-BOOK.1.2.23.4.19', 'TYPE-REFERENCE-BOOK.1.2.23.4.26'),
    ('artifact-review-2026-11-10/run.py', 'artifact-review-2026-11-11/run.py'),
):
    assert body.count(old) == 1
    body = body.replace(old, new)
needle = "             'docs/checkpoints/artifact-review-2026-11-11/run.py')"
assert body.count(needle) == 1
body = body.replace(needle, "             'docs/checkpoints/artifact-review-2026-11-11/run.py',\n"
    "             'docs/checkpoints/artifact-review-2026-11-11/prepare.py',\n"
    "             'docs/checkpoints/artifact-review-2026-11-11/retire.py',\n"
    "             'docs/checkpoints/artifact-review-2026-11-11/review.py',\n"
    "             'docs/checkpoints/artifact-review-2026-11-10/review.py')")
(HERE / 'census.py').write_text(body)
(HERE / 'composition.json').write_text(json.dumps(dict(template=prior,
    sha256=hashlib.sha256(raw).hexdigest(), bytes=len(raw),
    output_sha256=hashlib.sha256(body.encode()).hexdigest()), indent=2) + '\n')
print(json.dumps(dict(result='PASS', output='census.py', template=prior)))
