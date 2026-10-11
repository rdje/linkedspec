"""Readonly complete finite-admission review, including retained failed drafts."""
import base64
import gzip
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7-'
spec = importlib.util.spec_from_file_location('capacity', ROOT / (PREFIX + 'capacity.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
for tail, arguments in [('capacity.py', ['review']), ('reviewer-repair.py', []),
                        ('evidence.py', []), ('preservation-controls.py', []), ('book-review.py', [])]:
    result = m.command(['python3', PREFIX + tail] + arguments)
    assert result['exit_code'] == 0 and result['stderr']['bytes'] == 0, (tail, result)

correction = m.load('book-correction.json')
for path, digest in correction['drafts'].items():
    assert m.sha(m.read(path)) == digest, 'exact original book draft'
old_source = m.read(PREFIX + 'draft-book.py')
assert old_source.count(correction['repair']['old'].encode()) == 1
assert m.read(PREFIX + 'book.py') == old_source.replace(correction['repair']['old'].encode(),
    correction['repair']['new'].encode(), 1), 'sole book instrument basename repair'
assert m.sha(m.read(PREFIX + 'book.py')) == correction['repair']['current_producer_sha256']
assert m.read(PREFIX + 'draft-book-review.py') == m.read(PREFIX + 'book-review.py')
assert correction['observed_tool_return']['exit_code'] == 1
assert "assert row['output_locations']" in base64.b64decode(correction['observed_tool_return']['output_base64']).decode()
envelope = m.load('draft-book.json')
raw = gzip.decompress(base64.b64decode(envelope['data']))
assert envelope['bytes'] == len(raw) and envelope['sha256'] == m.sha(raw)
assert envelope['producer_sha256'] == m.sha(old_source)
draft = json.loads(raw)
current = json.loads(gzip.decompress(base64.b64decode(m.load('book.json')['data'])))
assert len(draft['rows']) == len(current['rows']) == 4
for old, new in zip(draft['rows'], current['rows']):
    assert old['name'] == new['name'] and old['inputs'] == new['inputs'] and old['modes'] == new['modes']
    expected = [] if old['name'] == 'missing-summary' else ['output/dsl/actionir-lowering-mental-model.html']
    assert old['output_locations'] == expected, 'original wrong chapter census retained'
    assert old['returncode'] == new['returncode']
    assert old['marker_present'] == (b'Rollover generation and capacity admission are separate steps.'
                                     in base64.b64decode(old['html_base64']))

failure = m.load('reviewer-failure.json')
assert failure['observed_exit_code'] == 1
assert failure['original_producer_sha256'] == m.sha(m.read(PREFIX + 'draft-census-review.py'))
assert failure['reached_sha256'] == m.sha(m.read(PREFIX + 'draft-census-evidence-reached.json'))
reached = m.load('draft-census-evidence-reached.json')
assert reached['healthy']['exit_code'] == 0 and len(reached['rows']) == 1
row = reached['rows'][0]
assert row['name'] == 'missing_history_member' and row['observed']['exit_code'] != 0
assert b'only complete census and corrected reviewer identity change' in base64.b64decode(row['observed']['stderr']['base64'])
for item in [reached['healthy'], row['observed']]:
    for channel in ('stdout', 'stderr'):
        assert m.channel(base64.b64decode(item[channel]['base64'])) == item[channel]
mutant = json.loads(base64.b64decode(row['mutant']['base64']))
expected = m.load('plan.json')
del expected['preserved'][next(iter(expected['preserved']))]
assert mutant == expected, 'exact first census-repair failed counterfactual'

card = 'docs/knowledge/guarded-ast-change-history-capacity.md'
old_front, old_body = m.old(card).split(b'\n---\n', 1)
front, body = m.read(card).split(b'\n---\n', 1)
assert body.endswith(old_body), 'exact original ADR0132 card body'
answers = lambda raw: re.findall(rb'^  - "(.*)"$', raw, re.M)
assert answers(front) == answers(old_front) + [
    b'which decision admits change history segment 4963',
    b'how are array end callback bindings preserved before ADR0134',
    b'why does the ADR0134 census retain an incomplete180 member draft',
    b'which readonly command reviews current ADR0134 capacity']
assert (PREFIX + 'review.py').encode() in front
print('Finite change-history full review PASS:226 prior files/329 preserved;30 thresholds/23 authority/4 reviewer/2 preservation REDs; book89/3; original failed drafts retained')
