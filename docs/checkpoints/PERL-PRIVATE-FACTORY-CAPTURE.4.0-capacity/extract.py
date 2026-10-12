"""One-shot exact extraction of only the seven new historical header appendices."""
import base64
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-capacity/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
target = ROOT / (PREFIX + 'extraction.json')
assert not target.exists(), 'one-shot exact header extraction'
preservation = json.loads((ROOT / (PREFIX + 'preservation.json')).read_bytes())
assert preservation['original_bindings'] == 408 and preservation['original_claim_bytes'] == 94719
capsule = json.loads(gzip.decompress((ROOT / (PREFIX + 'original-inputs.json.gz')).read_bytes()))
assert all(sha((ROOT / p).read_bytes()) == item['sha256'] for p, item in capsule.items()), 'all first bindings before extraction'
knowledge = json.loads(gzip.decompress((ROOT / (OLD + 'knowledge-inputs.json.gz')).read_bytes()))
cards = json.loads((ROOT / (OLD + 'knowledge.json')).read_bytes())['changed_cards']
before = {p.relative_to(ROOT).as_posix(): p.read_bytes() for p in (ROOT / 'docs/knowledge').glob('*.md')}
assert sum(map(len, before.values())) == 8401572
archive = '# Required FlowExpr historical Knowledge headers\n\n'
archive += ('Owned by PERL-PRIVATE-FACTORY-CAPTURE.4.0. The first uncommitted408-input/full94719 '
    'publication and all input bytes remain in original-claim.json/original-inputs.json.gz beside this file. '
    'Use replay.py through tools/run_python_project_data.sh for that unchanged supplied candidate; '
    'it has no fabricated accepted Git revision. Original pre-FlowExpr headers require accepted81b356ce. '
    'Current scalar routes are in the seven live cards. Only newly duplicated header appendices move here.\n\n')
rows = []
for path in cards:
    original = base64.b64decode(knowledge['original'][path]['bytes_base64'], validate=True)
    first = before[path]
    old_end, first_end = original.index(b'\n---', 4) + 4, first.index(b'\n---', 4) + 4
    old_head, first_head = original[:old_end], first[:first_end]
    marker = (b'\n\n# Original framework route before required FlowExpr integration' if path.endswith('/perl-factory-capture-framework.md')
              else b'\n\n# Accepted Knowledge gate route retained by FlowExpr .4.0')
    assert first.count(marker) == 1 and old_head in first[first.index(marker):]
    body = first[first_end:first.index(marker)]
    if not path.endswith('/perl-factory-capture-framework.md'):
        assert body == original[old_end:], 'unchanged original fact body before extracted appendix'
    heading = path.removeprefix('docs/knowledge/').removesuffix('.md')
    archive += '## ' + heading + '\n\n### Before FlowExpr (.11 accepted81b356ce)\n\n'
    archive += '```yaml\n' + old_head.decode() + '\n```\n\n'
    archive += '### First FlowExpr candidate (supplied408/full94719)\n\n'
    archive += '```yaml\n' + first_head.decode() + '\n```\n\n'
    head = first_head.replace((OLD + 'publish-claim.py').encode(), (PREFIX + 'publish.py').encode())
    note = ('\n\nHistorical header archive: `'+PREFIX+'knowledge-headers.md` ('+heading+'). '
            'The complete original fact body and runtime observations are retained; the first uncommitted '
            'FlowExpr proof replays from its complete supplied bytes through the sibling replay.py.\n').encode()
    raw = head + body + note
    (ROOT / path).write_bytes(raw)
    rows.append({'path': path, 'before_sha256': sha(first), 'after_sha256': sha(raw),
                 'original_header_sha256': sha(old_head), 'first_header_sha256': sha(first_head),
                 'removed_appendix_base64': base64.b64encode(first[first.index(marker):]).decode(),
                 'bytes_removed': len(first) - len(raw)})
archive_path = ROOT / (PREFIX + 'knowledge-headers.md')
archive_path.write_text(archive)
after = {p.relative_to(ROOT).as_posix(): p.read_bytes() for p in (ROOT / 'docs/knowledge').glob('*.md')}
assert set(after) == set(before)
assert [p for p in sorted(before) if before[p] != after[p]] == cards
assert sum(map(len, after.values())) <= 8388608
book = ROOT / 'docs/linkedspec-book/src/development/documentation-workflow.md'
text = book.read_text()
marker = '### Historical claim populations'
assert text.count(marker) == 1
position = text.index('\n', text.index(marker)) + 1
text = text[:position] + ('\nCurrent Knowledge cards keep their factual explanation and one current verification route. '
    'Repeated historical route headers belong in the owning checkpoint archive, with exact original '
    'bytes and a readonly replay route. This keeps the bounded live-card collection useful without '
    'discarding earlier evidence or raising its size limits. A first uncommitted candidate is recovered '
    'from its supplied bytes; it must never be assigned an invented accepted Git revision.\n') + text[position:]
book.write_text(text)
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
          'rows': rows, 'archive_sha256': sha(archive_path.read_bytes()),
          'before_collection_bytes': sum(map(len, before.values())), 'after_collection_bytes': sum(map(len, after.values())),
          'collection_limit': 8388608, 'unchanged_members': len(before) - len(cards),
          'scope': 'Exact finite content extraction only; no registry, policy, cap, fact membership, runtime or native evidence changes. Both original pre-FlowExpr and first uncommitted FlowExpr headers are retained verbatim in a tracked checkpoint. Six original fact bodies remain exact prefixes; framework callback teaching remains intact. The original whole408/full94719 candidate stays independently replayable.'}
target.write_text(json.dumps(report, indent=2) + '\n')
print('Finite Knowledge extraction PASS:', report['before_collection_bytes'], '->', report['after_collection_bytes'],
      '/', report['collection_limit'], 'bytes; seven exact header archives; no cap change')
