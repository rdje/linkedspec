"""Preserve verbatim preliminary TAP without source-diff whitespace changes."""
from pathlib import Path
import base64
import gzip
import hashlib
import json

PREFIX = __file__.removesuffix('retain-initial-tap.py')
expected = {
    'before': (26062, 'aa26b9a358573e6630e3f1b17925e59427d940829477326d94477410aca42bdb'),
    'after': (21059, 'e986b923ff796068113887f157e79a59c2c5d1d2c9979e7de2968f256747ddd8'),
}
for mode, (size, digest) in expected.items():
    original = Path(PREFIX + 'initial-' + mode + '.tap')
    output = Path(PREFIX + 'initial-' + mode + '-tap.json')
    if original.exists():
        raw = original.read_bytes()
        assert len(raw) == size and hashlib.sha256(raw).hexdigest() == digest
        block = {'encoding': 'gzip-base64', 'bytes': size, 'sha256': digest,
                 'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}
        output.write_text(json.dumps(block, indent=2) + '\n')
    else:
        block = json.loads(output.read_bytes())
        raw = gzip.decompress(base64.b64decode(block['data'], validate=True))
    retained = json.loads(output.read_bytes())
    assert retained['encoding'] == 'gzip-base64' and retained['bytes'] == size and retained['sha256'] == digest
    decoded = gzip.decompress(base64.b64decode(retained['data'], validate=True))
    assert decoded == raw and len(decoded) == size and hashlib.sha256(decoded).hexdigest() == digest
    if original.exists(): original.unlink()
print('Two preliminary TAP channels preserved byte-exactly; no observed whitespace edited')
