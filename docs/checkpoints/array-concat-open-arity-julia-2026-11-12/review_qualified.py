"""Run the unchanged historical oracle with one exact compressed artifact source."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
sys.dont_write_bytecode = True
seal = json.loads((BASE / 'sealed-identities.json').read_bytes())
path = BASE / 'review.py'
body = path.read_bytes()
assert len(body) == seal[str(path)]['bytes'] and hashlib.sha256(body).hexdigest() == seal[str(path)]['sha256']
record = json.loads((BASE / 'patch-retention.json').read_bytes())
source = str(BASE / 'source.diff')
assert record['source'] == source and record['retained'] == str(BASE / 'source.diff.gz')
assert not Path(source).exists()
compressed = Path(record['retained']).read_bytes()
assert len(compressed) == record['compressed_bytes'] and hashlib.sha256(compressed).hexdigest() == record['compressed_sha256']


def recover(payload):
    original = gzip.decompress(payload)
    assert len(original) == record['original_bytes'] == seal[source]['bytes'], 'original patch size'
    assert hashlib.sha256(original).hexdigest() == record['original_sha256'] == seal[source]['sha256'], 'original patch digest'
    return original


original = recover(compressed)
spec = importlib.util.spec_from_file_location('julia_concat_historical_reader', path)
reader = importlib.util.module_from_spec(spec)
spec.loader.exec_module(reader)
read_file = reader.read


def read_retained(name):
    return recover(compressed) if str(name) == source else read_file(name)


reader.read = read_retained
reader.main()
altered = bytearray(original)
assert altered and altered[0] != ord('!')
altered[0] = ord('!')
try:
    recover(gzip.compress(bytes(altered), mtime=0))
except AssertionError as failure:
    assert str(failure) == 'original patch digest'
else:
    raise AssertionError('wrong compressed patch accepted')
try:
    recover(gzip.compress(original[:-1], mtime=0))
except AssertionError as failure:
    assert str(failure) == 'original patch size'
else:
    raise AssertionError('truncated compressed patch accepted')
print(json.dumps(dict(patch_qualification='PASS', unchanged_historical_reader='PASS',
    compressed_patch_controls=['wrong original digest', 'truncated original'],
    scope='One read-only exact artifact-source substitution. Original reader/first0/seal/SDK observations remain unchanged; no SDK or used producer replay.')))
