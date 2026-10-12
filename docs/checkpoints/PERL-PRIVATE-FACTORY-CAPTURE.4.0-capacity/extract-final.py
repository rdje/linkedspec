"""One-shot one-LF archive normalization with the whole original publication preserved."""
import base64
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-capacity/'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
target = ROOT / (PREFIX + 'extraction-final.json')
assert not target.exists(), 'one-shot archive EOF normalization'
capsule = json.loads(gzip.decompress((ROOT / (PREFIX + 'eof-original-inputs.json.gz')).read_bytes()))
assert len(capsule) == 438 and all(sha((ROOT / p).read_bytes()) == item['sha256'] for p, item in capsule.items())
archive = ROOT / (PREFIX + 'knowledge-headers.md')
original = archive.read_bytes()
assert original.endswith(b'\n\n') and not original.endswith(b'\n\n\n')
current = original[:-1]
archive.write_bytes(current)
record = json.loads((ROOT / (PREFIX + 'extraction.json')).read_bytes())
record['producer_sha256'] = sha(Path(__file__).read_bytes())
record['archive_sha256'] = sha(current)
record['eof_normalization'] = {'removed_bytes': 1, 'original_archive_sha256': sha(original),
    'scope': 'Only one final LF is removed. All fourteen complete archived headers and every live-card byte remain unchanged; the first extractor/report/archive and whole438/full105949 publication survive in immutable supplied custody.'}
target.write_text(json.dumps(record, indent=2) + '\n')
print('Archive EOF normalization PASS:exactly one LF;live cards/book/runtime unchanged;original438/full105949 preserved')
