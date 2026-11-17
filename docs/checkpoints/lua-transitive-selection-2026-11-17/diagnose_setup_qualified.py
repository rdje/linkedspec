"""Recover the draft newline failure and the actual partial archive format."""
import contextlib
import gzip
import io
import json
from pathlib import Path

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
source = (BASE / 'diagnose_setup.py').read_text()
before = "with tarfile.open(BASE / 'support-inputs.tar.gz') as archive:\n    assert archive.getmembers() == [], 'failed setup left an empty archive'"
after = "assert gzip.decompress((BASE / 'support-inputs.tar.gz').read_bytes()) == b'', 'partial archive has empty decoded payload'"
assert source.count(before) == 1
body = source.replace(before, after, 1)
body = body.replace('leaves an empty support archive', 'leaves a partial support archive with empty decoded payload')
output = io.StringIO()
with contextlib.redirect_stdout(output):
    exec(compile(body, str(BASE / 'diagnose_setup.py'), 'exec'), dict(__file__=str(BASE / 'diagnose_setup.py'), gzip=gzip))
result = json.loads(output.getvalue())
result['diagnosis_qualification'] = 'The first diagnosis correctly distinguishes the missing newline, then refuses to open the partial archive. This separate reader checks its actual empty decoded gzip payload; original ReadError/source/channels remain unchanged.'
print(json.dumps(result, indent=2, sort_keys=True))
