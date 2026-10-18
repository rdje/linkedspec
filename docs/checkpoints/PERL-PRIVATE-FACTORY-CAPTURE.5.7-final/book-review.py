"""Check the entire supplied book population and actual rendered controls."""
import base64
import gzip
import re
import hashlib
import json
import subprocess
import sys
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-final/'
CONFIG = 'docs/linkedspec-book/book.toml'
CHAPTER = 'docs/linkedspec-book/src/development/documentation-workflow.md'
SUMMARY = 'docs/linkedspec-book/src/SUMMARY.md'
MARKER = b'Historical claim populations'
TARGET_CHAPTER = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
TARGET_MARKER = b'ControlFlow mixed-provider defaults'

class TableRows(HTMLParser):
    def __init__(self):
        super().__init__()
        self.rows, self.row, self.cell = [], None, None
    def handle_starttag(self, tag, attributes):
        if tag == 'tr':
            self.row = []
        elif tag in ('td', 'th'):
            self.cell = []
    def handle_data(self, value):
        if self.cell is not None:
            self.cell.append(value)
    def handle_endtag(self, tag):
        if tag in ('td', 'th') and self.cell is not None:
            self.row.append(' '.join(''.join(self.cell).split()))
            self.cell = None
        elif tag == 'tr' and self.row is not None:
            self.rows.append(self.row)
            self.row = None

native_path = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.6/after-native-data.json.gz'
native_index_path = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.6/after-native.json'
native_raw = (ROOT / native_path).read_bytes()
native_index_raw = (ROOT / native_index_path).read_bytes()
native_index = json.loads(native_index_raw)
assert native_index['data_sha256'] == hashlib.sha256(native_raw).hexdigest()
native = json.loads(gzip.decompress(native_raw))[1]['observation']
case = next(row['native'] for row in native['rows'] if row['label'] == 'selection/rule/fetch-effect/scalar')
root_before = str(case['before']['branch']['fields']['switch_counter'])
candidate_before = str(case['calls'][0]['args'][1]['fields']['switch_counter'])
fetch_after = str(case['fetch_observations'][0]['after'])
candidate_after = str(case['candidates']['items'][0]['fields']['switch_counter'])
root_after = str(case['branch_after']['fields']['switch_counter'])
expected_table = [
    ['Initial', root_before, '—'],
    ['Candidate cloned', root_before, candidate_before],
    ['Apply fetched', fetch_after, candidate_before],
    ['Callback completes', fetch_after, candidate_after],
    ['Candidate accepted', root_after, candidate_after],
]
default_path = PREFIX + 'after-native-data.json.gz'
default_index_path = PREFIX + 'after-native.json'
default_raw = (ROOT / default_path).read_bytes()
default_index_raw = (ROOT / default_index_path).read_bytes()
assert json.loads(default_index_raw)['data_sha256'] == hashlib.sha256(default_raw).hexdigest()
default_native = json.loads(gzip.decompress(default_raw))[1]['observation']
providers = list(dict.fromkeys(default_native['providers']))
assert providers == ['LinkedSpec::RuleIR::EmitContext', 'LinkedSpec::ActionIR::ValueExpr']
provider_table = [[owner, ', '.join(key for key, provider in zip(default_native['keys'], default_native['providers']) if provider == owner), rule]
 for owner, rule in zip(providers, ['Plain built-in package name and actual retained definition', 'Fixed provider and actual retained definition'])]
object_path = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-object/after-data.json.gz'
object_index_path = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7-object/after.json'
object_raw = (ROOT / object_path).read_bytes()
object_index_raw = (ROOT / object_index_path).read_bytes()
assert json.loads(object_index_raw)['data_sha256'] == hashlib.sha256(object_raw).hexdigest()
object_rows = json.loads(gzip.decompress(object_raw))[1]['observation']['rows']
assert len(object_rows) == 108
object_table = []
for owner in ('LinkedSpec::ActionIR::ControlFlow', 'LinkedSpec::ActionIR::FlowExpr', 'LinkedSpec::ActionIR::MethodLowering'):
    selected = [r for r in object_rows if r['owner'] == owner]
    native = {(r['variant'], r['context']): r for r in selected if r['stage'] == 'native-builder'}
    actual = [r for r in selected if r['stage'] == 'current-factory']
    eq = {r['ordinary']['equal_calls'] - native[(r['variant'], r['context'])]['ordinary']['equal_calls'] for r in actual}
    strings = {r['ordinary']['string_calls'] - native[(r['variant'], r['context'])]['ordinary']['string_calls'] for r in actual}
    facade = {sum(v['selected'] for v in r['authority'] if not(owner.endswith('ControlFlow') and v['key'] == 'extract_array_symbol_name')) for r in actual}
    assert len(actual) == 18 and eq == strings == facade == {0}
    object_table.append([owner.split('::')[-1], str(next(iter(eq))), str(next(iter(strings))), str(next(iter(facade)))])
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()
entries = subprocess.check_output(['git', 'ls-files', '--stage', '-z', '--', 'docs/linkedspec-book'], cwd=ROOT).decode().split('\0')
files, modes = {}, {}
for entry in filter(None, entries):
    header, path = entry.split('\t')
    mode, blob, stage = header.split()
    if path != CONFIG and not path.startswith('docs/linkedspec-book/src/'):
        continue
    assert mode in ('100644', '100755') and stage == '0'
    files[path] = (ROOT / path).read_bytes()
    modes[path] = int(mode, 8) & 0o777
assert len(files) == 57 and files[CHAPTER].count(MARKER) == 1
assert files[TARGET_CHAPTER].count(TARGET_MARKER) == 1
assert b'| Undefined input, or undefined/empty trim result | Undefined |' in files[TARGET_CHAPTER], 'native trim-result documentation'
book_paths = set(files)
# Independently enumerate the local recursive include graph, including anchors.
seen = set()
while set(files) - seen:
    relative = sorted(set(files) - seen)[0]
    seen.add(relative)
    for directive in re.findall(rb'\{\{#include\s+([^}]+)\}\}', files[relative]):
        spelling = directive.strip().decode().split(':')[0]
        path = ((ROOT / relative).parent / spelling).resolve().relative_to(ROOT).as_posix()
        if path not in files:
            assert subprocess.run(['git', 'ls-files', '--error-unmatch', '--', path], cwd=ROOT, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
            files[path] = (ROOT / path).read_bytes()
            modes[path] = (ROOT / path).stat().st_mode & 0o777
assert len(files) == 89 and len(set(files) - book_paths) == 32
book_raw = (ROOT / (PREFIX + 'book.json')).read_bytes()
packed = json.loads(book_raw)
assert packed['producer_sha256'] == digest((ROOT / (PREFIX + 'book.py')).read_bytes())
raw = gzip.decompress(base64.b64decode(packed['data'], validate=True))
assert packed['encoding'] == 'gzip-base64' and packed['bytes'] == len(raw) and packed['sha256'] == digest(raw)
assert gzip.compress(raw, mtime=0) == base64.b64decode(packed['data'], validate=True)
book = json.loads(raw)
assert book['result'] == 'PASS' and book['book_sources'] == 57 and book['include_sources'] == 32
assert book['producer_sha256'] == digest((ROOT / (PREFIX + 'book.py')).read_bytes())
assert [row['name'] for row in book['rows']] == ['final', 'missing-summary', 'changed-chapter', 'changed-target', 'missing-include']
for row in book['rows']:
    expected = dict(files)
    if row['name'] == 'missing-summary':
        del expected[SUMMARY]
    elif row['name'] == 'changed-chapter':
        expected[CHAPTER] = expected[CHAPTER].replace(MARKER, b'', 1)
    elif row['name'] == 'changed-target':
        expected[TARGET_CHAPTER] = expected[TARGET_CHAPTER].replace(TARGET_MARKER, b'', 1)
    elif row['name'] == 'missing-include':
        del expected['examples/integration/word.spec']
    assert row['inputs'] == {path: digest(raw) for path, raw in expected.items()}, 'wrong book input population/content'
    assert row['modes'] == {path: modes[path] for path in expected}
    assert row['unchanged'] is True
    assert row['command'][1:] == ['build', 'docs/linkedspec-book', '-d', 'output']
    out = base64.b64decode(row['stdout_base64'], validate=True)
    err = base64.b64decode(row['stderr_base64'], validate=True)
    html = base64.b64decode(row['html_base64'], validate=True)
    assert row['marker_present'] == (MARKER in html)
    target_html = base64.b64decode(row['target_html_base64'], validate=True)
    assert row['target_marker_present'] == (TARGET_MARKER in target_html)
    if row['name'] == 'missing-summary':
        assert row['returncode'] != 0 and b'SUMMARY' in err and not html and not target_html
    else:
        assert row['returncode'] == 0 and bool(html)
        assert row['output_locations'] == ['output/development/documentation-workflow.html']
        assert b'bounded mixed-provider default integration' in html.replace(b'\n', b' '), 'current output workflow teaching'
        assert b'last committed predecessor is the complete525-input' in html.replace(b'\n', b' '), 'current predecessor teaching'
        assert b'ce9eaf32e' in html and b'2b35b77ea' in html and b'dadce45ac8' in html and b'4a8e92aef' in html and b'09000223f' in html and b'a60764c11' in html and b'e2ec1e96b' in html, 'retained predecessor lineage'
        assert (MARKER in html) == (row['name'] != 'changed-chapter'), 'wrong rendered teaching oracle'
        assert b'undefined/empty trim result' in target_html, 'wrong whitespace teaching oracle'
        assert b'LVALUE' in target_html and b'Writes through it change the same trimmed scalar' in target_html, 'wrong attached-head alias teaching'
        assert b'A truthy parser result is forwarded unchanged' in target_html, 'wrong attached parser return teaching'
        assert b'The trim argument is a writable local scalar' in target_html, 'wrong single-statement alias teaching'
        assert b'A rule result of' in target_html and b'qualifies' in target_html, 'wrong zero-rule acceptance teaching'
        assert b'nested references remain shared' in target_html, 'wrong shallow candidate teaching'
        assert b'ordinary reference values cannot retain a scalar emission packet' in target_html.replace(b'\n', b' '), 'wrong reference packet teaching'
        assert b'else_seen' in target_html and b'state stays set' in target_html, 'wrong else partial-state teaching'
        assert b'counter of7 advances to8' in target_html.replace(b'\n', b' '), 'wrong empty while counter teaching'
        assert b'parser returns its actual hash' in target_html.replace(b'\n', b' '), 'output parser packet teaching'
        assert b'array-element' in target_html and b'alias' in target_html, 'output trim alias teaching'
        assert b'two dependency-map reads' in target_html.replace(b'\n', b' '), 'optional selection teaching'
        assert b'native regex match alias' in target_html, 'optional alias teaching'
        assert b'opaque' in target_html and b'native-call thunk' in target_html, 'opaque dispatch teaching'
        tables = TableRows()
        tables.feed(target_html.decode('utf-8'))
        header = ['Step', 'Root counter', 'Candidate counter']
        assert tables.rows.count(header) == 1, 'candidate table header'
        offset = tables.rows.index(header)
        assert tables.rows[offset + 1:offset + 6] == expected_table, 'native-derived candidate table'
        header = ['Provider', 'Default keys', 'Selection']
        assert tables.rows.count(header) == 1, 'provider table header'
        offset = tables.rows.index(header)
        assert tables.rows[offset + 1:offset + 3] == provider_table, 'native-derived provider table'
        header = ['Factory', 'Added equality calls', 'Added string calls', 'Object facade selections']
        assert tables.rows.count(header) == 1, 'object-effects table header'
        offset = tables.rows.index(header)
        assert tables.rows[offset + 1:offset + 4] == object_table, 'native-derived object-effects table'
        assert b'Package objects keep their native callback lookup' in target_html.replace(b'\n', b' '), 'native object lookup teaching'
        assert b'does not revoke existing registration' in target_html.replace(b'\n', b' '), 'retained authority versus new grants'

        assert b'custom target' in target_html and b'fixed ValueExpr provider' in target_html, 'mixed target/provider teaching'
        assert b'A void invocation performs the native build and selects no map' in target_html.replace(b'\n', b' '), 'void no-selection teaching'
        assert b'disjoint two-map control' in target_html.replace(b'\n', b' '), 'complete list-map teaching'

        assert b'exactly one publication' in target_html.replace(b'\n', b' '), 'publication-cardinality teaching'
        assert b'Each selected inline branch still normalizes' in target_html.replace(b'\n', b' '), 'inline normalizer teaching'
        assert b'removes exactly the innermost switch' in target_html, 'switch stack teaching'
        assert bool(target_html) and (TARGET_MARKER in target_html) == (row['name'] != 'changed-target'), 'wrong ControlFlow expansion rendered teaching oracle'
        if row['name'] == 'missing-include':
            assert b'Error updating' in err and b'examples/integration/word.spec' in err
        else:
            assert b'ERROR' not in err, 'healthy complete book must resolve every include'
report = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
          'oracle_inputs': {native_path: digest(native_raw), native_index_path: digest(native_index_raw),
                            default_path: digest(default_raw), default_index_path: digest(default_index_raw),
                            object_path: digest(object_raw), object_index_path: digest(object_index_raw)},
          'book_capture_sha256': digest(book_raw), 'book_producer_sha256': book['producer_sha256'],
          'source_inputs': {path: digest(raw) for path, raw in files.items()},
          'source_count': len(files), 'book_source_count': len(book_paths), 'include_source_count': 32, 'actual_controls': 4,
          'scope': 'Exact full book source/config/recursive include population, actual retained command channels, input preservation and rendered marker controls. The known caller-relative CLI destination is checked in actual output locations; no immutable toolchain or cross-version HTML claim.'}
target = ROOT / (PREFIX + 'book-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot capture'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
print('Complete book review PASS57+32/four actual controls; exact input and rendered teaching identities')
