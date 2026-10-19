"""Preserve the first proposal and give the child reviewer its caller's assembly lifetime."""
import ast
import copy
import gzip
import json
from pathlib import Path
import artifact as a

target = a.ROOT / (a.HOME + 'reader-projection.json.gz')
assert not target.exists()
raw = (a.ROOT / a.MANIFEST).read_bytes()
original = json.loads(raw)
assert original['result'] == 'PASS'
after = {path: a.decode(item['base64']) for path, item in original['proposal'].items()}
for path, value in after.items(): assert (a.ROOT / path).read_bytes() == value
old_total = original['knowledge_bytes']
card = after[a.CARD]
for old, new in [(b'has127191037 bytes', b'has 127,191,037 bytes'),
                 (b'at most33554432 bytes', b'at most 33,554,432 bytes'),
                 (b'is100MiB;32MiB', b'is 100 MiB; 32 MiB'),
                 (b'uncommitted669 claim/preflight', b'uncommitted claim, preflight and its 669 bindings')]:
    assert card.count(old) == 1
    card = card.replace(old, new)
after[a.CARD] = card
new_total = old_total + len(card) - len(a.decode(original['proposal'][a.CARD]['base64']))
assert new_total <= 8388608
workflow = after[a.WORKFLOW]
for old, new in [(b'has127,191,037 bytes', b'has 127,191,037 bytes'),
                 (b'is100MiB', b'is 100 MiB'), (b'at most32MiB', b'at most 32 MiB'),
                 (b'original669-input', b'original 669-input')]:
    assert workflow.count(old) == 1
    workflow = workflow.replace(old, new)
after[a.WORKFLOW] = workflow
publisher = after[a.PUB]
old = ("transport = subprocess.run(['python3', " + repr(a.SELF) + "], cwd=ROOT, capture_output=True)").encode()
new = ("transport = subprocess.run(['python3', " + repr(a.HOME + 'review.py') + "], cwd=ROOT, capture_output=True)").encode()
assert publisher.count(old) == 1
publisher = publisher.replace(old, new)
assert str(old_total).encode() in publisher
after[a.PUB] = publisher.replace(str(old_total).encode(), str(new_total).encode())
finalizer = after[a.FINALIZER]
assert str(old_total).encode() in finalizer
after[a.FINALIZER] = finalizer.replace(str(old_total).encode(), str(new_total).encode())
ast.parse(after[a.PUB], filename=a.PUB)
ast.parse(after[a.FINALIZER], filename=a.FINALIZER)
review = '''"""Readonly child review; its publisher owns the temporary assembled copy."""
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
'''
with (a.ROOT / (a.HOME + 'review.py')).open('x') as output: output.write(review)
record = dict(result='PASS', original_manifest_base64=a.encode(raw), original_manifest_sha256=a.sha(raw),
    after={path: a.encode(value) for path, value in after.items()}, knowledge_bytes=new_total,
    producer_base64=a.encode(Path(__file__).read_bytes()), reviewer_sha256=a.sha(review.encode()),
    scope='Whole first producer/manifest/proposal stays exact. The child reader shares its caller-owned '
          'assembled input rather than deleting it through a nested lifecycle context. Human prose '
          'spacing is corrected before first current documentation capture; only current size '
          'constants follow those exact byte changes. No original669 or native observation changes.')
with target.open('xb') as output: output.write(gzip.compress(json.dumps(record, sort_keys=True).encode(), mtime=0))
for path, value in after.items():
    original['proposal'][path]['base64'] = a.encode(value)
original['knowledge_bytes'] = new_total
(a.ROOT / a.MANIFEST).write_text(json.dumps(original, indent=1) + '\n')
for path, value in after.items(): (a.ROOT / path).write_bytes(value)
print('Current artifact child/spacing proposal refined; whole original retained; Knowledge bytes:', new_total)
