"""Record the verified recurring-consumer boundary in the existing fact and contributor book."""
import gzip
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c

P = 'docs/checkpoints/type-values-required/'
review = json.loads((ROOT / (P + 'controls-complete-review.json')).read_bytes())
assert review['result'] == 'PASS' and review['mapper_bypass_failed_assertions'] == 198
preserved = json.loads(gzip.decompress((ROOT / (P + 'preservation.json.gz')).read_bytes()))
fact = 'docs/knowledge/perl-method-assignment-required-capture.md'
book = 'docs/linkedspec-book/src/development/documentation-workflow.md'
before = {path: c.read(path) for path in (fact, book)}
assert all(item == preserved['before'][path] for path, item in before.items())
text = c.decode(before[fact]['base64']).decode()
needle = 'answers:\n'
assert text.count(needle) >= 1
text = text.replace(needle, needle +
    '  - "how do recurring private tests survive MethodLowering line changes"\n', 1)
text += ('\nRecurring tests map unchanged same-routine statements to c053 coordinates; '
         'raw captures stay frozen. Emitted values execute independently. '
         'Twelve suites pass5001 assertions; mapper bypass fails198 and restores. '
         'See docs/checkpoints/type-values-required/.\n')
book_text = c.decode(before[book]['base64']).decode()
book_text += (
    '\nPrivate diagnostic tests retain their original native captures when unrelated\n'
    'source insertions move a diagnostic. Translate only fresh error coordinates\n'
    'through byte-identical statements in the same named routine at an explicit\n'
    'Git anchor; preserve callback names, paths and all other row fields. Reject\n'
    'unmatched statements. For source formatting changes, execute the expression\n'
    'against an independent value expectation. A test invocation observer covers\n'
    'its declared argument and binding ABI; it does not establish runtime dispatch.\n'
    'Prove wrong callbacks, files and lines still differ, then bypass the actual\n'
    'mapper and observe failing assertions before restoring it.\n')
after = {path: dict(base64=c.encode(value.encode()), sha256=c.sha(value.encode()),
                   mode=before[path]['mode']) for path, value in ((fact, text), (book, book_text))}
graph = json.loads(gzip.decompress(
    (ROOT / (c.PREFIX + 'graph-signature-inputs.json.gz')).read_bytes()))['inputs']
assert graph[fact] == before[fact]
old_bytes = sum(len(c.decode(item['base64'])) for path, item in graph.items()
                if path.startswith('docs/knowledge/'))
new_bytes = old_bytes + len(text.encode()) - len(c.decode(before[fact]['base64']))
assert new_bytes <= 8388608
c.write_new(P + 'docs-proposals.json.gz', dict(before=before, after=after,
    producer=c.read(P + 'docs.py'), knowledge_bytes_before=old_bytes,
    knowledge_bytes_after=new_bytes), packed=True)
assert c.unchanged(before)
for path, item in after.items():
    (ROOT / path).write_bytes(c.decode(item['base64']))
    (ROOT / path).chmod(item['mode'])
print('Recurring-consumer fact/book updated; Knowledge bytes', new_bytes)
