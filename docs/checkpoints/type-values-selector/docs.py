"""Explain exact fixture evolution and verified checkpoint partitioning in existing owners."""
import datetime
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'docs/checkpoints/type-evaluated-values'))
import common as c
import partition_storage as storage

P = storage.P
saved = storage.load('preservation.json.gz')
grade = storage.load('scanner-review.json')
removed = storage.load('partition-removal.json')
assert grade['result'] == removed['result'] == 'PASS'
aggregate = 'docs/knowledge/aggregate-selector-self-test-concurrency-boundary.md'
artifacts = 'docs/knowledge/repo-generated-artifact-cleanup-boundary.md'
book = 'docs/linkedspec-book/src/development/documentation-workflow.md'
before = {path: c.read(path) for path in (aggregate, artifacts, book)}
assert before[aggregate] == saved['before'][aggregate] and before[book] == saved['before'][book]
graph = json.loads(__import__('gzip').decompress(
    (ROOT / (c.PREFIX + 'graph-required-inputs.json.gz')).read_bytes()))['inputs']
assert all(graph[path] == before[path] for path in (aggregate, artifacts))
texts = {path: c.decode(item['base64']).decode() for path, item in before.items()}
today = datetime.datetime.now(datetime.timezone.utc).date().isoformat()
for path in (aggregate, artifacts):
    lines = texts[path].splitlines(keepends=True)
    date = next(index for index, line in enumerate(lines) if line.startswith('date: '))
    lines[date] = 'date: ' + today + '\n'
    texts[path] = ''.join(lines)
lines = texts[aggregate].splitlines(keepends=True)
index = next(index for index, line in enumerate(lines) if line.startswith('reverify: '))
lines[index] = ('reverify: "Readonly: bash tools/run_python_project_data.sh '
    'docs/checkpoints/type-evaluated-values/publish.py. Original .7 proof requires '
    'accepted557a7d9e533710c6aae211f905ca2f231a8aedae inputs."\n')
texts[aggregate] = ''.join(lines) + (
    '\nCurrent fixture revisions keep historical registrations and add exact owner/prior/current '
    'identities. Three fixtures retain their selector occurrences;28 denials and actual '
    'source faults9/6/3 distinguish edited or foreign admissions. '
    'See docs/checkpoints/type-values-selector/.\n')
texts[artifacts] = texts[artifacts].replace('answers:\n',
    'answers:\n  - "how are oversized checkpoints retained without large Git blobs"\n', 1)
texts[artifacts] += (
    '\nOversized checkpoints use bounded payload chunks with physical, payload and whole-stream '
    'hashes plus original modes. Verify exact recovery and actual retained-reader use before '
    'removing duplicate originals. Logical inputs survive; physical bindings change explicitly.\n')
texts[book] += (
    '\nWhen maintained diagnostic tests change, retain their historical scanner registrations.\n'
    'An exact reviewed admission must identify its owner, original digest and current digest.\n'
    'Compare the old and new selector occurrences, then reject edited files, copies, extra\n'
    'selectors and wrong or missing registrations. Removing each admission check must expose\n'
    'false acceptances to the control probe.\n\n'
    'Large immutable checkpoints can retain their exact bytes as bounded payload chunks.\n'
    'Gate physical chunk hashes, decoded payload hashes, order, offsets, whole-stream hash,\n'
    'byte count and original mode. Copy and verify first, use the retained reader in its\n'
    'explicit original source context, then remove only the verified duplicate originals.\n'
    'Keep rejected attempts distinct. Record the physical input migration while preserving\n'
    'every original logical identity; an uncommitted draft has no historical Git revision.\n')
after = {path: dict(base64=c.encode(text.encode()), sha256=c.sha(text.encode()), mode=before[path]['mode'])
         for path, text in texts.items()}
old_bytes = sum(len(c.decode(item['base64'])) for path, item in graph.items()
                if path.startswith('docs/knowledge/'))
new_bytes = old_bytes + sum(len(c.decode(after[path]['base64'])) - len(c.decode(before[path]['base64']))
                            for path in (aggregate, artifacts))
assert new_bytes <= 8388608, new_bytes
cleanup = 'docs/ARTIFACT_CLEANUP.md'
cleanup_before = c.read(cleanup)
cleanup_text = ('# Latest artifact cleanup\n\n- Date: ' + removed['cleanup_utc'] +
    '\n- Summary: Removed only two verified duplicate checkpoint streams (' +
    str(removed['removed_bytes']) + ' bytes) after exact chunk recovery, actual retained-reader '
    'use and corruption controls;31 bounded chunks and all original logical hashes/modes remain. '
    'No caches or other repository data were removed.\n')
cleanup_after = dict(base64=c.encode(cleanup_text.encode()), sha256=c.sha(cleanup_text.encode()),
                     mode=cleanup_before['mode'])
c.write_new(P + 'docs-proposals.json.gz', dict(before=before, after=after,
    continuity_before={cleanup: cleanup_before}, continuity_after={cleanup: cleanup_after},
    producer=c.read(P + 'docs.py'), knowledge_bytes_before=old_bytes, knowledge_bytes_after=new_bytes,
    scope='Existing fact owners and budgets retained. One storage question is added. '
          'The immutable removal report owns the measured cleanup; its bounded latest '
          'pointer may advance later without changing these historical observations.'),
    packed=True)
assert c.unchanged(before) and c.read(cleanup) == cleanup_before
for path, item in dict(after, **{cleanup: cleanup_after}).items():
    (ROOT / path).write_bytes(c.decode(item['base64']))
    (ROOT / path).chmod(item['mode'])
print('Selector/storage book and facts updated; Knowledge bytes', new_bytes)
