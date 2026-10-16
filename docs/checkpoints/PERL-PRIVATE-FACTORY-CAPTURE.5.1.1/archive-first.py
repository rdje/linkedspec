"""Retain the failed first instrument outside executable test discovery, then remove only its verified copy."""
import base64
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.1/'
SOURCE = 't/actionir_control_attached_native.pl'
ARCHIVE = PREFIX + 'instrument-first.txt'
TARGET = ROOT / (PREFIX + 'instrument-first-archive.json')
sha = lambda value: hashlib.sha256(value).hexdigest()
assert not TARGET.exists() and not (ROOT / ARCHIVE).exists()
raw = (ROOT / SOURCE).read_bytes()
mode = (ROOT / SOURCE).stat().st_mode & 0o7777
cap = json.loads(gzip.decompress((ROOT / (PREFIX + 'before-native-inputs.json.gz')).read_bytes()))
assert raw == base64.b64decode(cap[SOURCE]['bytes_base64'], validate=True)
assert sha(raw) == cap[SOURCE]['sha256'] and mode == cap[SOURCE]['mode']
with (ROOT / ARCHIVE).open('xb') as output:
    output.write(raw)
(ROOT / ARCHIVE).chmod(mode)
assert (ROOT / ARCHIVE).read_bytes() == raw and (ROOT / ARCHIVE).stat().st_mode & 0o7777 == mode
assert (ROOT / SOURCE).read_bytes() == raw
(ROOT / SOURCE).unlink()
r = {'producer_sha256': sha(Path(__file__).read_bytes()), 'original_path': SOURCE,
     'archive_path': ARCHIVE, 'source_sha256': sha(raw), 'source_bytes': len(raw), 'mode': mode,
     'original_capsule_sha256': sha((ROOT / (PREFIX + 'before-native-inputs.json.gz')).read_bytes()),
     'scope': 'Exact original failed instrument bytes/mode are retained both in their original-path source '
              'capsule and this readable text archive. Only the verified untracked first test-path copy '
              'is removed, preventing invalid retired syntax from entering executable test discovery. '
              'The distinct fixed instrument and all original command/source/data records remain unchanged.'}
with TARGET.open('x') as output:
    output.write(json.dumps(r, indent=2) + '\n')
print('First failed native instrument archived byte/mode-exact; executable test path removed safely')
