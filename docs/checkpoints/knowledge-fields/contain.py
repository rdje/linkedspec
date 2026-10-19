"""Preserve the successful epoch and contain only generated blank separators."""
import ast
import gzip
import json
from pathlib import Path
import common as c

pressure_raw = (c.ROOT / (c.HOME + 'pressure-red.json.gz')).read_bytes()
pressure = json.loads(gzip.decompress(pressure_raw))
assert pressure['result'] == 'observed RED' and pressure['command']['returncode'] != 0
channels = c.decode(pressure['command']['stdout_base64']) + c.decode(pressure['command']['stderr_base64'])
assert b'knowledge_map exceeds control:' in channels and b'22596/22500' in channels
old_epoch = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'after.json.gz')).read_bytes()))
old_map = c.decode(old_epoch['map_base64'])
assert (c.ROOT / 'KNOWLEDGE_MAP.md').read_bytes() == old_map
path = 'knowledge-map/scripts/gen_knowledge_map.sh'
before = c.read(path)
assert before['sha256'] == old_epoch['inputs'][path]['sha256']
old = b'if ($3!="") printf "_%s_\\n\\n", $3'
new = b'if ($3!="") printf "_%s_\\n", $3'
source = c.decode(before['base64'])
assert source.count(old) == 1
after = source.replace(old, new, 1)

capture = (c.ROOT / (c.HOME + 'capture-after.py')).read_bytes()
capture = capture.replace(b'capture-after.py', b'capture-compact.py')
capture = capture.replace(b'after-inputs.json.gz', b'compact-inputs.json.gz')
capture = capture.replace(b"c.HOME + 'after.json.gz', record", b"c.HOME + 'compact.json.gz', record")
marker = b"c.HOME + 'red-final.json.gz', c.HOME + 'assertion-repair.json', c.HOME + 'preservation.json']"
assert capture.count(marker) == 1
capture = capture.replace(marker,
    b"c.HOME + 'red-final.json.gz', c.HOME + 'assertion-repair.json', c.HOME + 'preservation.json',\n"
    b"         c.HOME + 'contain.py', c.HOME + 'containment.json', c.HOME + 'pressure-preparation.json.gz',\n"
    b"         c.HOME + 'pressure-red.json.gz', c.HOME + 'after.json.gz', c.HOME + 'after-inputs.json.gz',\n"
    b"         c.HOME + 'review-epoch.py', c.HOME + 'review-epoch.json']", 1)
review_before = c.read(c.HOME + 'review-epoch.py')
review = c.decode(review_before['base64'])
for old_name, new_name in [('after.json.gz', 'compact.json.gz'), ('after-inputs.json.gz', 'compact-inputs.json.gz'),
                           ('capture-after.py', 'capture-compact.py'), ('review-epoch.json', 'review-compact.json')]:
    review = review.replace(("c.HOME + '" + old_name + "'").encode(), ("c.HOME + '" + new_name + "'").encode())
assert review.count(b'if not line.startswith(') == 1
review = review.replace(b'if not line.startswith(', b'if line and not line.startswith(', 1)
review = review.replace(b'all nonmetadata fact bytes', b'all nonempty nonmetadata fact lines')
review = review.replace(b'All nonmetadata fact bytes', b'All nonempty nonmetadata fact lines')
review = review.replace(b'all scalar/nonmetadata bytes', b'all scalar/nonempty fact lines')
marker = b'# Re-run the actual generator/checker with supplied original Markdown and the\n'
assert review.count(marker) == 1
extra = b'''original_epoch = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'after.json.gz')).read_bytes()))
original_map = c.decode(original_epoch['map_base64']).decode()
assert [line for line in original_map.splitlines() if line] == [line for line in new_map.splitlines() if line], 'only blank separators change'
assert len(original_map.splitlines()) == 22596 and len(new_map.splitlines()) == 21247
containment = json.loads((c.ROOT / (c.HOME + 'containment.json')).read_bytes())
assert c.decode(containment['after_generator_base64']) == c.decode(inputs['knowledge-map/scripts/gen_knowledge_map.sh']['base64'])

'''
review = review.replace(marker, extra + marker, 1)
ast.parse(capture, filename=c.HOME + 'capture-compact.py')
ast.parse(review, filename=c.HOME + 'review-compact.py')
record = dict(result='PASS', producer_base64=c.encode(Path(__file__).read_bytes()), before_generator=before,
              after_generator_base64=c.encode(after), after_generator_sha256=c.sha(after),
              original_epoch_sha256=c.sha((c.ROOT / (c.HOME + 'after.json.gz')).read_bytes()),
              original_reader=review_before, original_review=c.read(c.HOME + 'review-epoch.json'),
              pressure_sha256=c.sha(pressure_raw),
              proposals={c.HOME + 'capture-compact.py': c.encode(capture), c.HOME + 'review-compact.py': c.encode(review)},
              scope='A single printf removes one redundant empty separator after each fact title. '
                    'No metadata, nonempty line, scalar presentation or question content changes. '
                    'The complete first successful epoch/source/review and actual pressure RED '
                    'remain immutable. Distinct compact producers/readers prove the contained '
                    'epoch; actual rendered main-content equivalence is required before landing. '
                    'No threshold, registry, old observation or Git identity is rewritten.')
c.write_new(c.HOME + 'containment.json', record)
assert c.read(path) == before
(c.ROOT / path).write_bytes(after)
for name, value in record['proposals'].items():
    with (c.ROOT / name).open('xb') as output:
        output.write(c.decode(value))
print('Single-separator containment prepared;original epoch and actual pressure RED retained')
