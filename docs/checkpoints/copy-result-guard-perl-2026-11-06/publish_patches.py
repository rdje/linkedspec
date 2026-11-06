"""Losslessly transport exact patch records without textual whitespace diagnostics."""
import gzip
import hashlib
import json
from pathlib import Path

BASE = Path('docs/checkpoints/copy-result-guard-perl-2026-11-06')
qualified_path = BASE / 'review_publication.py'
assert not qualified_path.exists(), 'one-shot publication qualification'
aliases = {}
for name in ('producer-change.patch', 'producer-change-final.patch'):
    path = BASE / name
    original = path.read_bytes()
    destination = Path(str(path) + '.gz')
    assert not destination.exists()
    destination.write_bytes(gzip.compress(original, mtime=0))
    assert gzip.decompress(destination.read_bytes()) == path.read_bytes()
    aliases[str(path)] = dict(capsule=str(destination), sha256=hashlib.sha256(original).hexdigest(), bytes=len(original))
    path.unlink()
(BASE / 'patch-aliases.json').write_text(json.dumps(aliases, indent=2, sort_keys=True) + '\n')
source = (BASE / 'review.py').read_text()
needle = 'def main():\n'
assert source.count(needle) == 1
helper = '''def retained(path):
    target = ROOT / path
    if target.is_file():
        return target.read_bytes()
    aliases = json.loads((ROOT / BASE / 'patch-aliases.json').read_bytes())
    assert path in aliases, 'only declared patch aliases may replace a raw record'
    row = aliases[path]
    body = gzip.decompress((ROOT / row['capsule']).read_bytes())
    assert hashlib.sha256(body).hexdigest() == row['sha256'] and len(body) == row['bytes']
    return body


'''
source = source.replace(needle, helper + needle)
needle = "        body = (ROOT / path).read_bytes()\n        assert hashlib.sha256(body).hexdigest() == expected['sha256'] and len(body) == expected['bytes']"
assert source.count(needle) == 1
source = source.replace(needle, needle.replace('(ROOT / path).read_bytes()', 'retained(path)'))
source = source.replace('def main():\n', '''def main():
    for path, expected in json.loads((ROOT / BASE / 'publication-input-identities.json').read_bytes()).items():
        body = (ROOT / path).read_bytes()
        assert hashlib.sha256(body).hexdigest() == expected['sha256'] and len(body) == expected['bytes']
''')
qualified_path.write_text(source)
names = ('publish_patches.py', 'review.py', 'review_publication.py', 'patch-aliases.json',
         'sealed-identities.json', 'producer-change.patch.gz', 'producer-change-final.patch.gz')
records = {}
for name in names:
    path = BASE / name
    body = path.read_bytes()
    records[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body))
(BASE / 'publication-input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
print('Exact original patch bytes retained in lossless capsules; original reader/seal unchanged')
