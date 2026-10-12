"""Readonly current finite extraction, full Knowledge/book and original-candidate review."""
import base64
import gzip
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-capacity/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.4.0-'
BASE = '81b356cef997ea2bb65a8fb120c77506fed9241e'
assert sys.argv[1:] in ([], ['--capture'], ['--preflight'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
decode = lambda value: base64.b64decode(value, validate=True)
inputs = {}

def read(path):
    raw = (ROOT / path).read_bytes()
    inputs[path] = sha(raw)
    return raw

def load(tail):
    raw = read(PREFIX + tail)
    return json.loads(gzip.decompress(raw) if tail.endswith('.gz') else raw)

def checked(tail):
    process = subprocess.run(['python3', PREFIX + tail], cwd=ROOT, capture_output=True)
    assert process.returncode == 0 and not process.stderr, ('actual readonly current proof', tail, process.stderr)
    return process.stdout

preserved = load('preservation.json')
assert preserved['result'] == 'PASS' and preserved['base'] == BASE
assert preserved['producer_sha256'] == sha(read(PREFIX + 'preserve.py'))
original_raw = read(PREFIX + 'original-claim.json')
capsule_raw = read(PREFIX + 'original-inputs.json.gz')
assert preserved['original_claim_sha256'] == sha(original_raw) and len(original_raw) == 94719
assert preserved['capsule_sha256'] == sha(capsule_raw)
capsule = json.loads(gzip.decompress(capsule_raw))
assert len(capsule) == preserved['original_bindings'] == 408
original_claim = json.loads(original_raw)
assert {item['path']: item['sha256'] for item in original_claim['claims'][0]['durability']['inputs']} == {p: item['sha256'] for p, item in capsule.items()}
assert all(sha(decode(item['bytes_base64'])) == item['sha256'] for item in capsule.values()), 'every original candidate byte recoverable'
assert preserved['baseline']['returncode'] == 0 and not decode(preserved['baseline']['stderr_base64'])
assert decode(preserved['baseline']['stdout_base64']) == b'Required FlowExpr publication PASS: 408 live inputs; 94719 bytes\n'
assert [(r['name'], r['actual_tool_session'], r['actual_returncode']) for r in preserved['failed_admission']] == [('commit', 28075, 130), ('claim-check', 53944, 130)]
assert b'knowledge_cards exceeds control: aggregate bytes 8401572/8388608' in decode(preserved['failed_admission'][0]['merged_log_base64'])
assert b'First FlowExpr supplied replay PASS:408 complete bindings/full94719;' in checked('replay.py')
replay = load('replay.json')
assert replay['supplied_inputs'] == 1887 and len(replay['rows']) == 4
assert [r['returncode'] == 0 for r in replay['rows']] == [True, False, False, True]
assert replay['rows'][0] == dict(replay['rows'][-1], name='unchanged-first-publication')

first_knowledge = json.loads(gzip.decompress(decode(capsule[OLD + 'knowledge-inputs.json.gz']['bytes_base64'])))
first_record = json.loads(decode(capsule[OLD + 'knowledge.json']['bytes_base64']))
cards = first_record['changed_cards']
assert len(cards) == 7
extraction = load('extraction.json')
assert extraction['result'] == 'PASS' and extraction['producer_sha256'] == sha(read(PREFIX + 'extract.py'))
assert [row['path'] for row in extraction['rows']] == cards
archive = read(PREFIX + 'knowledge-headers.md')
assert sha(archive) == extraction['archive_sha256']
for row in extraction['rows']:
    path = row['path']
    first = decode(capsule[path]['bytes_base64'])
    original = decode(first_knowledge['original'][path]['bytes_base64'])
    old_end, first_end = original.index(b'\n---', 4) + 4, first.index(b'\n---', 4) + 4
    old_head, first_head = original[:old_end], first[:first_end]
    assert sha(old_head) == row['original_header_sha256'] and sha(first_head) == row['first_header_sha256']
    assert old_head in archive and first_head in archive, 'whole historical headers retained verbatim'
    footer = decode(row['removed_appendix_base64'])
    assert first.endswith(footer) and old_head in footer, 'exact original appendix extraction'
    body = first[first_end:-len(footer)]
    if not path.endswith('/perl-factory-capture-framework.md'):
        assert body == original[old_end:], 'complete original six fact bodies retained'
    head = first_head.replace((OLD + 'publish-claim.py').encode(), (PREFIX + 'publish.py').encode())
    heading = path.removeprefix('docs/knowledge/').removesuffix('.md')
    note = ('\n\nHistorical header archive: `'+PREFIX+'knowledge-headers.md` ('+heading+'). '
            'The complete original fact body and runtime observations are retained; the first uncommitted '
            'FlowExpr proof replays from its complete supplied bytes through the sibling replay.py.\n').encode()
    current = read(path)
    assert current == head + body + note, 'exact finite header extraction and current route'
    assert sha(first) == row['before_sha256'] and sha(current) == row['after_sha256']
    assert len(first) - len(current) == row['bytes_removed']

knowledge = load('knowledge.json')
population = load('knowledge-inputs.json.gz')
assert knowledge['base'] == BASE and knowledge['producer_sha256'] == sha(read(PREFIX + 'knowledge.py'))
assert knowledge['capsule_sha256'] == sha((ROOT / (PREFIX + 'knowledge-inputs.json.gz')).read_bytes())
assert population['original'] == first_knowledge['original'], 'full original accepted Knowledge population unchanged'
paths = sorted(p.relative_to(ROOT).as_posix() for directory in ['docs/knowledge', 'docs/decisions'] for p in (ROOT / directory).rglob('*.md') if p.is_file())
assert paths == sorted(population['original']) and len(paths) == knowledge['markdown'] == 1485
assert knowledge['changed_cards'] == cards
assert knowledge['inputs'] == {p: {'sha256': item['sha256'], 'mode': item['mode']} for p, item in population['current'].items()}
facts = 0
for path, item in population['current'].items():
    raw = (ROOT / path).read_bytes()
    assert raw == decode(item['bytes_base64']) and sha(raw) == item['sha256'], 'complete current Knowledge source identity'
    assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
    if path not in paths or path in cards:
        read(path)
    if path in paths and path not in cards:
        assert raw == decode(first_knowledge['current'][path]['bytes_base64']), 'every unaffected Knowledge member unchanged'
    if path not in paths:
        continue
    lines = raw.decode().splitlines()
    if not lines or lines[0] != '---':
        continue
    owner, fact = None, False
    for number, line in enumerate(lines[1:], 2):
        if line.strip() == '---':
            break
        if re.match(r'^\s+-\s+', line):
            assert owner is not None, ('current orphan list item', path, number)
            fact |= owner == 'answers'
        elif re.match(r'^[A-Za-z_][A-Za-z_0-9]*\s*:', line):
            key, value = line.split(':', 1)
            owner = key if not value.strip() else None
            if key == 'answers' and re.match(r'^\s*\[.*[A-Za-z0-9].*\]\s*$', value):
                fact = True
    facts += fact
assert facts == 1349
assert knowledge['returncode'] == 0 and not decode(knowledge['stdout_base64'])
assert decode(knowledge['stderr_base64']) == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
registry_path = 'doctrine/readme_stability/routes.jsonl'
registry = read(registry_path)
assert registry == subprocess.check_output(['git', 'show', BASE + ':' + registry_path], cwd=ROOT), 'unchanged pressure registry'
surface = next(json.loads(line) for line in registry.splitlines() if json.loads(line).get('id') == 'knowledge_cards')
limits = surface['limits']
members = {p.relative_to(ROOT).as_posix(): p.read_bytes() for p in (ROOT / 'docs/knowledge').glob('*.md')}
total_bytes = sum(map(len, members.values()))
total_lines = sum(raw.count(b'\n') for raw in members.values())
assert extraction['before_collection_bytes'] == 8401572 > limits['max_total_bytes'] == 8388608
assert total_bytes == extraction['after_collection_bytes'] == 8381805, 'exact finite Knowledge collection measurement'
assert set(members) == {p for p in population['original'] if p.startswith('docs/knowledge/')}
assert len(members) <= limits['max_files'] and total_lines <= limits['max_total_lines']
assert all(len(raw) <= limits['max_bytes_per_file'] and raw.count(b'\n') <= limits['max_lines_per_file'] for raw in members.values()), 'all unchanged member controls hold'

# All original runtime, instruments, records and88 unaffected book inputs remain exact.
changed = []
for path, item in capsule.items():
    if read(path) != decode(item['bytes_base64']):
        changed.append(path)
    assert (ROOT / path).stat().st_mode & 0o7777 == item['mode']
expected_changed = sorted(cards + ['KNOWLEDGE_MAP.md', 'docs/linkedspec-book/src/development/documentation-workflow.md'])
assert sorted(changed) == expected_changed, 'only nine bounded documentation inputs change after complete first proof'
first_overlay = read(PREFIX + 'documentation-workflow-first.md')
first_book_review = load('book-review.json')
assert first_book_review['source_inputs']['docs/linkedspec-book/src/development/documentation-workflow.md'] == sha(first_overlay)
assert first_book_review['source_count'] == 89 and first_book_review['actual_controls'] == 4
read(PREFIX + 'book.py'); read(PREFIX + 'book.json'); read(PREFIX + 'book-review.py')
assert b'Complete book review PASS57+32/four actual controls' in checked('book-review-final.py')
book = load('book-review-final.json')
assert book['source_count'] == 89 and book['actual_controls'] == 4
for path, digest in book['source_inputs'].items():
    assert sha(read(path)) == digest
chapter = (ROOT / 'docs/linkedspec-book/src/development/documentation-workflow.md').read_bytes()
assert (PREFIX + 'publish.py').encode() in chapter and b'Repeated historical route headers' in chapter
read(PREFIX + 'book-final.py'); read(PREFIX + 'book-final.json'); read(PREFIX + 'book-review-final.py')
read(PREFIX + 'replay.py'); read(PREFIX + 'review.py')
if sys.argv[1:] == ['--preflight']:
    print('Finite FlowExpr current preflight PASS:original408/full94719 supplied replay2;seven exact header extractions;Knowledge1485/1349/8381805 bytes;book89/four controls;runtime unchanged')
    sys.exit(0)

assert b'FlowExpr supplemental composed public guard PASS' in checked('validation.py')
validation = load('validation.json')
for path, digest in validation['sources'].items():
    assert sha(read(path)) == digest
read(PREFIX + 'validation.py')
report = {'result': 'PASS', 'producer_sha256': sha((ROOT / (PREFIX + 'review.py')).read_bytes()),
          'original_bindings': 408, 'original_claim_bytes': 94719, 'supplied_inputs': 1887, 'supplied_controls': 2,
          'exact_header_extractions': 7, 'changed_current_inputs': expected_changed,
          'knowledge_markdown': 1485, 'knowledge_facts': facts, 'knowledge_bytes': total_bytes,
          'knowledge_limit': limits['max_total_bytes'], 'book_sources': 89, 'book_controls': 4, 'inputs': inputs,
          'scope': 'Finite content extraction and current pointers only. Entire first required FlowExpr proof/408 inputs/full94719 publication and actual failed admission are preserved; unchanged first publisher replays with1887 supplied inputs/two actual controls/exact restoration. Nine current documentation inputs change, all runtime/native/paired/fault/consumer/Phase0 and first producers remain exact. Both historical header generations are archived verbatim, original fact bodies/teaching remain, whole current Knowledge1485/1349 and all unchanged per-member/collection limits hold. Complete current book89/four controls and supplemental composed public guard pass. No cap, policy, registry, source behavior, fabricated accepted revision, immutable toolchain, private/parent/canonical or other-backend admission.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot current finite review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'exact readonly current finite review'
print('Finite FlowExpr current review PASS:original408/full94719/replay2;seven exact header archives;Knowledge1485/1349/8381805;book89/four controls;runtime unchanged')
