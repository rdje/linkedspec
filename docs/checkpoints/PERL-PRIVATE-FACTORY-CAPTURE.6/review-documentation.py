"""Readonly full captured Knowledge and rendered book semantics, with live overlays explicit."""
import base64
import gzip
import hashlib
import json
import re
import subprocess
import sys
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.6/'
BASE = '64b66167c2277533c2393899e3754e14a74f0b31'
NATIVE = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
WORKFLOW = 'docs/linkedspec-book/src/development/documentation-workflow.md'
sha = lambda value: hashlib.sha256(value).hexdigest()
decode = base64.b64decode
raw = lambda path: (ROOT / path).read_bytes()
read = lambda name: json.loads(raw(PREFIX + name))
old = lambda path: subprocess.check_output(['git', 'show', BASE + ':' + path], cwd=ROOT)
assert sys.argv[1:] in ([], ['--capture'])

class Tables(HTMLParser):
    def __init__(self):
        super().__init__()
        self.tables, self.table, self.row, self.cell = [], None, None, None
    def handle_starttag(self, tag, attrs):
        if tag == 'table': self.table = []
        elif tag == 'tr' and self.table is not None: self.row = []
        elif tag in ('td', 'th') and self.row is not None: self.cell = []
    def handle_data(self, data):
        if self.cell is not None: self.cell.append(data)
    def handle_endtag(self, tag):
        if tag in ('td', 'th') and self.cell is not None:
            self.row.append(' '.join(''.join(self.cell).split()))
            self.cell = None
        elif tag == 'tr' and self.row is not None:
            self.table.append(self.row)
            self.row = None
        elif tag == 'table' and self.table is not None:
            self.tables.append(self.table)
            self.table = None

def tables(value):
    parser = Tables()
    parser.feed(value.decode())
    return parser.tables

def unpack(envelope):
    assert envelope['encoding'] == 'gzip-base64'
    value = gzip.decompress(decode(envelope['data']))
    assert len(value) == envelope['bytes'] and sha(value) == envelope['sha256']
    return json.loads(value)

preflight = read('documentation-preflight.json')
preparation = read('documentation-preparation.json')
assert preparation == preflight and preparation['result'] == 'PASS'
assert preparation['base'] == BASE and preparation['knowledge_bytes'] == 8384111
assert sha(raw(PREFIX + 'prepare-docs.py')) == preparation['producer_sha256']
cards = preparation['changed_cards']
assert len(cards) == 15 and len(preparation['changed_bodies']) == 2
for path, item in preparation['originals'].items():
    assert decode(item['bytes_base64']) == old(path) and sha(old(path)) == item['sha256']
for path, item in preparation['proposed'].items():
    value = decode(item['bytes_base64'])
    assert sha(value) == item['sha256'] and len(value) == item['bytes']
    if path != WORKFLOW:
        assert raw(path) == value
polish = read('workflow-polish.json')
value = decode(polish['before_base64'])
assert sha(value) == polish['before_sha256'] == preparation['proposed'][WORKFLOW]['sha256']
for item in polish['replacements']:
    assert item['before'].encode() in value
    value = value.replace(item['before'].encode(), item['after'].encode())
assert raw(WORKFLOW) == value and sha(value) == polish['after_sha256']

knowledge = read('knowledge.json')
packed = raw(PREFIX + 'knowledge-inputs.json.gz')
assert sha(packed) == knowledge['capsule_sha256']
capsule = json.loads(gzip.decompress(packed))
original, current = capsule['original'], capsule['current']
assert len(original) == 1487 and set(original) <= set(current)
assert knowledge['result'] == 'PASS' and knowledge['markdown'] == 1487
assert knowledge['facts'] == 1349 and knowledge['question_keys'] == 10448
assert knowledge['knowledge_bytes'] == 8384111 <= 8388608
assert knowledge['changed_cards'] == cards and knowledge['changed_bodies'] == preparation['changed_bodies']
total, bodies = 0, []
for path, item in original.items():
    assert decode(item['bytes_base64']) == old(path)
    now = current[path]
    value = decode(now['bytes_base64'])
    assert sha(value) == now['sha256'] == knowledge['inputs'][path]['sha256']
    assert now['mode'] == knowledge['inputs'][path]['mode']
    if path in cards:
        assert value == raw(path) == decode(preparation['proposed'][path]['bytes_base64'])
        assert (ROOT / path).stat().st_mode & 0o7777 == now['mode']
        if value.split(b'\n---\n', 1)[1] != old(path).split(b'\n---\n', 1)[1]: bodies.append(path)
    else:
        assert value == decode(item['bytes_base64'])
    if path.startswith('docs/knowledge/'):
        total += len(value)
assert sorted(bodies) == sorted(preparation['changed_bodies']) and total == 8384111
for path, item in current.items():
    if path in original and path not in cards:
        continue
    assert sha(raw(path)) == item['sha256'] and (ROOT / path).stat().st_mode & 0o7777 == item['mode']
assert knowledge['generation']['returncode'] == knowledge['check']['returncode'] == 0
assert decode(knowledge['generation']['stderr_base64']) == b'knowledge-map: wrote KNOWLEDGE_MAP.md (1349 facts, 10448 question keys)\n'
assert decode(knowledge['check']['stderr_base64']) == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'

book_envelope = read('book.json')
book = unpack(book_envelope)
assert book['result'] == 'PASS' and book['book_sources'] == 57 and book['include_sources'] == 32
assert [row['name'] for row in book['rows']] == ['final', 'missing-summary', 'changed-chapter', 'changed-target', 'missing-include']
healthy = book['rows'][0]
assert len(healthy['inputs']) == 89 and healthy['returncode'] == 0
for path, expected in healthy['inputs'].items():
    assert sha(raw(path)) == expected and (ROOT / path).stat().st_mode & 0o7777 == healthy['modes'][path]
workflow_marker = b'Pipeline scope proof'
native_marker = b'Invocation scopes and canonical apply'
for row in book['rows']:
    assert row['unchanged'] and row['command'][-2:] == ['-d', 'output']
    name = row['name']
    expected = {path: raw(path) for path in healthy['inputs']}
    if name == 'missing-summary': del expected['docs/linkedspec-book/src/SUMMARY.md']
    elif name == 'changed-chapter': expected[WORKFLOW] = expected[WORKFLOW].replace(workflow_marker, b'', 1)
    elif name == 'changed-target': expected[NATIVE] = expected[NATIVE].replace(native_marker, b'', 1)
    elif name == 'missing-include': del expected['examples/integration/word.spec']
    assert row['inputs'] == {path: sha(value) for path, value in expected.items()}
    assert row['modes'] == {path: healthy['modes'][path] for path in expected}
    workflow_html = decode(row['html_base64'])
    native_html = decode(row['target_html_base64'])
    stderr = decode(row['stderr_base64'])
    assert row['marker_present'] == (workflow_marker in workflow_html)
    assert row['target_marker_present'] == (native_marker in native_html)
    if name == 'missing-summary': assert row['returncode'] != 0 and b'SUMMARY' in stderr
    elif name == 'missing-include': assert row['returncode'] == 0 and b'Error updating' in stderr and b'examples/integration/word.spec' in stderr
    else: assert row['returncode'] == 0 and b'ERROR' not in stderr
    if name == 'changed-chapter': assert not row['marker_present']
    if name == 'changed-target': assert not row['target_marker_present']

workflow_tables = tables(decode(healthy['html_base64']))
native_tables = tables(decode(healthy['target_html_base64']))
expected_native = [
    ['Pipeline seam', 'Native call context', 'Private boundary'],
    ['Contract factory', 'Scalar', 'Actual factory callback; returned lower references stay unchanged'],
    ['Helper collection', 'Scalar', 'Its own actual callback capture'],
    ['Canonical-event construction', 'Scalar', 'Its own actual callback capture'],
    ['Canonical apply', 'Scalar', 'Actual selected CODE; other native callables remain opaque'],
    ['Unresolved-helper scan', 'Scalar', 'Its own actual callback capture'],
]
assert expected_native in native_tables
expected_workflow = [
    ['Current focused observation', 'Retained population'],
    ['Native context, aliases, ordering, values and errors', '96 original rows'],
    ['Callable, tied lookup and release behavior', '9 rows in distinct original/load-context epochs'],
    ['Positive pipeline fixture', '2,065 assertions'],
    ['Exact syntax-valid semantic source inverses', '13, each with the same plan of 2,065 assertions'],
    ['Complete supplied runtime inputs', '426 files with saved bytes and permissions'],
    ['All previously selected direct suites', '91 suites, 32,235 assertions'],
]
assert expected_workflow in workflow_tables
native_record = read('native-before.json')
native_rows = json.loads(decode(native_record['stdout_base64']))
assert len(native_rows) == 96 and {call[1] for row in native_rows for call in row['ordinary']['trace']} == {'scalar'}
runtime = read('runtime-review-final.json')
assert runtime['population']['focused_assertions'] == 2065 and runtime['population']['semantic_inverses'] == 13
assert runtime['population']['supplied_inputs'] == 426 and runtime['population']['direct_assertions'] == 32235
previous_book = unpack(json.loads(old('docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.7/book.json')))
for previous_field, actual in [('html_base64', workflow_tables), ('target_html_base64', native_tables)]:
    previous_tables = tables(decode(previous_book['rows'][0][previous_field]))
    position = 0
    for table in previous_tables:
        while position < len(actual) and actual[position] != table: position += 1
        assert position < len(actual), ('preserved original rendered table', table)
        position += 1
report = dict(result='PASS', producer_sha256=sha(Path(__file__).read_bytes()),
              population=dict(markdown=1487, facts=1349, question_keys=10448,
                              knowledge_bytes=8384111, routes=15, changed_bodies=2,
                              book_inputs=89, render_controls=4),
              source_inputs=healthy['inputs'], changed_cards=cards,
              expected_native_table=expected_native, expected_workflow_table=expected_workflow,
              scope='Readonly captured whole1487-source Knowledge snapshot plus15 current overlays and '
                    'current map/config/instruments; other captured Markdown remains historical at64b66167c '
                    'rather than reading unbound later live bodies. Normal Knowledge doctrine checks the '
                    'whole live repository. Complete current89-source book/render controls and both new '
                    'semantic tables are checked against retained native/runtime populations; every '
                    'original rendered table stays ordered and exact. No writer is executed.')
target = ROOT / (PREFIX + 'documentation-review.json')
if sys.argv[1:]:
    with target.open('x') as output: output.write(json.dumps(report, indent=2) + '\n')
else: assert json.loads(target.read_bytes()) == report
print('Independent pipeline documentation review PASS:1487/1349/10448;8384111 bytes;15 routes/2 bodies;book89/4')
