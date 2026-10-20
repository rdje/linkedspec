"""Preserve an uncommitted draft and gate its premeasurement manifest explicitly."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

guard_path = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-publication-guard.json.gz'
producer_path = 'docs/checkpoints/TYPE-REFERENCE-BOOK.1.2.3-publication-guard.py'
publisher_path = c.PREFIX + 'publish.py'
readme_path = c.PREFIX + 'README.md'
original = c.read(c.CLAIM)
record = json.loads(c.decode(original['base64']))
preflight = json.loads((ROOT / (c.PREFIX + 'publication.json')).read_bytes())
assert preflight['record_base64'] == original['base64']
inputs = record['claims'][0]['durability']['inputs']
for binding in inputs:
    item = c.read(binding['path'])
    assert item['sha256'] == binding['sha256']
    assert item['mode'] == preflight['input_modes'][binding['path']]
before = {path: c.read(path) for path in (publisher_path, readme_path)}
source = c.decode(before[publisher_path]['base64']).decode()
replacements = {
    "('publication.json', 'publication-inputs.json')":
        "('publication-final.json', 'publication-final-inputs.json')",
    "paths.update(('KNOWLEDGE_MAP.md', c.OLD_CLAIM,":
        "paths.update(('KNOWLEDGE_MAP.md', c.OLD_CLAIM,\n"
        "              '" + guard_path + "',\n              '" + producer_path + "',",
    "c.PREFIX + 'publication-inputs.json'": "c.PREFIX + 'publication-final-inputs.json'",
    "review.load('publication-inputs.json')": "review.load('publication-final-inputs.json')",
    "for path, item in identities.items()]":
        "for path, item in identities.items()]\n"
        "manifest_path = c.PREFIX + 'publication-final-inputs.json'\n"
        "manifest_item = c.read(manifest_path)\n"
        "bindings.append(dict(path=manifest_path, sha256=manifest_item['sha256'], role='input'))\n"
        "bindings.sort(key=lambda item: item['path'])",
    "with (c.ROOT / c.CLAIM).open('xb') as output:\n        output.write(raw)":
        "guard = review.load('../TYPE-REFERENCE-BOOK.1.2.3-publication-guard.json.gz')\n"
        "    assert c.read(c.CLAIM) == guard['original_claim']\n"
        "    (c.ROOT / c.CLAIM).write_bytes(raw)",
    "c.PREFIX + 'publication.json'": "c.PREFIX + 'publication-final.json'",
    "review.load('publication.json')": "review.load('publication-final.json')",
    "input_modes={path: item['mode'] for path, item in identities.items()}":
        "input_modes={**{path: item['mode'] for path, item in identities.items()},\n"
        "                     manifest_path: manifest_item['mode']}",
}
for old, new in replacements.items():
    assert source.count(old) == 1, old
    source = source.replace(old, new, 1)
readme = c.decode(before[readme_path]['base64']).decode() + (
    '\nThe first uncommitted publication draft and every original binding remain\n'
    'recoverable through the publication-guard capsule and unchanged tracked\n'
    'inputs. A guarded producer refinement adds the premeasurement manifest\n'
    'itself as a direct claim binding. Original publication.json and its manifest\n'
    'remain exact; publication-final.json is the current receipt. No historical\n'
    'Git identity is invented for the uncommitted draft.\n')
after = {}
for path, value in ((publisher_path, source), (readme_path, readme)):
    raw = value.encode()
    after[path] = dict(base64=c.encode(raw), sha256=c.sha(raw), mode=before[path]['mode'])
c.write_new(guard_path, dict(original_claim=original,
    original_preflight=c.read(c.PREFIX + 'publication.json'),
    original_manifest=c.read(c.PREFIX + 'publication-inputs.json'),
    producer=c.read(producer_path), before=before, after=after,
    original_binding_modes=preflight['input_modes'],
    scope='The complete original draft record and all binding hashes/modes are verified before '
          'writes. Every input remains exact at its tracked path except the two declared files, '
          'whose full original/proposed bytes and modes are retained here. The original manifest '
          'and receipt remain intact. This is an explicitly uncommitted draft, never a fabricated '
          'historical Git revision. The final publisher binds its actual manifest directly.'), packed=True)
assert c.read(c.CLAIM) == original and c.unchanged(before)
for path, item in after.items():
    (ROOT / path).write_bytes(c.decode(item['base64']))
    assert c.read(path) == item
print('Whole uncommitted draft preserved; final producer gates the actual manifest')
