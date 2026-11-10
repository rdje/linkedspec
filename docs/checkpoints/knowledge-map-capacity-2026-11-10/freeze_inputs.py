"""Retain every exact source body from the already acquired input epoch."""
import base64
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
destination = HERE / 'input-epoch.json.gz'
assert not destination.exists(), 'one-shot retention already exists'
manifest = json.loads((HERE / 'current-generation.json').read_text())
images = {}
for row in manifest['inputs']:
    raw = (ROOT / row['path']).read_bytes()
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], 'input changed since acquisition: ' + row['path']
    images[row['path']] = {'sha256': row['sha256'], 'base64': base64.b64encode(raw).decode()}
destination.write_bytes(gzip.compress(json.dumps(images, sort_keys=True).encode(), mtime=0))
assert json.loads(gzip.decompress(destination.read_bytes())) == images
claim = ROOT / 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.18.1.json'
archive = HERE / 'implementation-overbound-claim.json.gz'
assert not archive.exists()
archive.write_bytes(gzip.compress(claim.read_bytes(), mtime=0))
log = HERE / 'canonical-second.log.gz'
assert not log.exists()
log.write_bytes(gzip.compress((ROOT / '.linkedspec-data/knowledge-capacity-ci-restart.log').read_bytes(), mtime=0))
print(json.dumps({'result': 'PASS', 'all_manifest_source_bodies': 'retained byte-exact',
                  'input_epoch_sha256': hashlib.sha256(destination.read_bytes()).hexdigest()}, sort_keys=True))
