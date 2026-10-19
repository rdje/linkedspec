"""Readonly child review; its publisher owns the temporary assembled copy."""
import copy
import gzip
import json
import subprocess
from pathlib import Path
import artifact as a

manifest = a.load_manifest()
raw = a.part_bytes(manifest)
assert (a.ROOT / a.RAW).is_file() and (a.ROOT / a.RAW).read_bytes() == raw, 'publisher-owned assembled context'
projection = json.loads(gzip.decompress((a.ROOT / (a.HOME + 'reader-projection.json.gz')).read_bytes()))
assert a.decode(projection['producer_base64']) == (a.ROOT / (a.HOME + 'prepare-review.py')).read_bytes()
before = json.loads(a.decode(projection['original_manifest_base64']))
assert a.sha(a.decode(projection['original_manifest_base64'])) == projection['original_manifest_sha256']
expected = copy.deepcopy(before)
for path, value in projection['after'].items():
    expected['proposal'][path]['base64'] = value
expected['knowledge_bytes'] = projection['knowledge_bytes']
assert expected == manifest, 'exact retained proposal refinement'
assert a.replay_before(manifest, raw) == manifest['use_from_parts']
for path, item in manifest['proposal'].items():
    assert (a.ROOT / path).read_bytes() == a.decode(item['base64'])
    assert (a.ROOT / path).stat().st_mode & 0o7777 == item['mode']
for name in ('review-docs.py', 'controls.py'):
    run = subprocess.run(['python3', a.HOME + name], cwd=a.ROOT, capture_output=True)
    assert run.returncode == 0 and not run.stderr, ('actual current artifact/doc review', name, run.stdout, run.stderr)
assert manifest['size_red']['returncode'] == 1 and b'oversized original artifact' in a.decode(manifest['size_red']['stderr_base64'])
print('Current bounded artifact proof PASS:4 exact parts;whole669 recovery;current documentation/controls')
