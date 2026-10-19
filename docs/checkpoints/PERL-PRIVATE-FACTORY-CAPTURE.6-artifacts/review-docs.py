"""Independently regenerate the full current supplied map and check every book table."""
import gzip
import json
import subprocess
import sys
from html.parser import HTMLParser
from pathlib import Path
import artifact as a

assert sys.argv[1:] in ([], ['--capture'])
manifest = a.load_manifest()
knowledge = json.loads((a.ROOT / (a.HOME + 'knowledge.json')).read_bytes())
packed = (a.ROOT / (a.HOME + 'knowledge-inputs.json.gz')).read_bytes()
assert a.sha(packed) == knowledge['capsule_sha256']
capsule = json.loads(gzip.decompress(packed))
old_raw = (a.ROOT / (a.PREFIX + 'knowledge-inputs.json.gz')).read_bytes()
assert a.sha(old_raw) == manifest['inputs'][a.PREFIX + 'knowledge-inputs.json.gz']['sha256']
old = json.loads(gzip.decompress(old_raw))
assert capsule['before'] == {path: old['current'][path] for path in old['original']}
before = capsule['before']
assert len(before) == 1487 and knowledge['original_markdown'] == 1487
assert knowledge['current_markdown'] == 1488 and knowledge['facts'] == 1350 and knowledge['question_keys'] == 10453
assert knowledge['added_cards'] == [a.CARD] and knowledge['inputs_unchanged']
assert set(capsule['current']) == set(knowledge['inputs'])
markdown = {path for path in capsule['current'] if path in before or path == a.CARD}
assert markdown == set(before) | {a.CARD} and len(markdown) == 1488
total = 0
for path, item in capsule['current'].items():
    value = a.decode(item['bytes_base64'])
    assert a.sha(value) == item['sha256'] == knowledge['inputs'][path]['sha256']
    assert item['mode'] == knowledge['inputs'][path]['mode']
    if path in before:
        assert value == a.decode(before[path]['bytes_base64']) and item['mode'] == before[path]['mode']
    else:
        assert (a.ROOT / path).read_bytes() == value and (a.ROOT / path).stat().st_mode & 0o7777 == item['mode']
    if path in markdown and path.startswith('docs/knowledge/'): total += len(value)
assert a.decode(capsule['current'][a.CARD]['bytes_base64']) == a.decode(manifest['proposal'][a.CARD]['base64'])
assert total == knowledge['knowledge_bytes'] == manifest['knowledge_bytes'] <= 8388608
assert knowledge['generation']['returncode'] == knowledge['check']['returncode'] == 0
assert not a.decode(knowledge['generation']['stdout_base64']) and not a.decode(knowledge['check']['stdout_base64'])
assert a.decode(knowledge['generation']['stderr_base64']) == b'knowledge-map: wrote KNOWLEDGE_MAP.md (1350 facts, 10453 question keys)\n'
assert a.decode(knowledge['check']['stderr_base64']) == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'

# The fresh producer sees every supplied source, including the new fact. It
# cannot accidentally consult later unbound live Markdown.
raw = a.part_bytes(manifest)
original = json.loads(gzip.decompress(raw))
fresh = []
with a.common().original_fixture(original) as (fixture, environment):
    for path, item in capsule['current'].items():
        target = fixture / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(a.decode(item['bytes_base64']))
        target.chmod(item['mode'])
    for command, output in [(['bash', 'knowledge-map/scripts/gen_knowledge_map.sh'], 'generated-map.md'),
                            (['bash', 'knowledge-map/scripts/check_knowledge_map.sh'], a.MAP)]:
        run = subprocess.run(command, cwd=fixture, env=dict(environment, KM_OUTPUT=output), capture_output=True)
        fresh.append(dict(command=command, output=output, returncode=run.returncode,
                          stdout_base64=a.encode(run.stdout), stderr_base64=a.encode(run.stderr)))
        if run.returncode != 0: break
    generated = (fixture / 'generated-map.md').read_bytes() if (fixture / 'generated-map.md').is_file() else b''
    unchanged = all(a.sha((fixture / path).read_bytes()) == item['sha256'] and
                    (fixture / path).stat().st_mode & 0o7777 == item['mode'] for path, item in capsule['current'].items())


class Tables(HTMLParser):
    def __init__(self):
        super().__init__(); self.tables, self.table, self.row, self.cell = [], None, None, None
    def handle_starttag(self, tag, attrs):
        if tag == 'table': self.table = []
        elif tag == 'tr' and self.table is not None: self.row = []
        elif tag in ('td', 'th') and self.row is not None: self.cell = []
    def handle_data(self, data):
        if self.cell is not None: self.cell.append(data)
    def handle_endtag(self, tag):
        if tag in ('td', 'th') and self.cell is not None:
            self.row.append(' '.join(''.join(self.cell).split())); self.cell = None
        elif tag == 'tr' and self.row is not None:
            self.table.append(self.row); self.row = None
        elif tag == 'table' and self.table is not None:
            self.tables.append(self.table); self.table = None


def tables(value):
    parser = Tables(); parser.feed(value.decode()); return parser.tables


def unpack(envelope):
    assert envelope['encoding'] == 'gzip-base64'
    value = gzip.decompress(a.decode(envelope['data']))
    assert len(value) == envelope['bytes'] and a.sha(value) == envelope['sha256']
    return json.loads(value)


book = unpack(json.loads((a.ROOT / (a.HOME + 'book.json')).read_bytes()))
old_book_raw = (a.ROOT / (a.PREFIX + 'book.json')).read_bytes()
assert a.sha(old_book_raw) == manifest['inputs'][a.PREFIX + 'book.json']['sha256']
old_book = unpack(json.loads(old_book_raw))
assert book['result'] == 'PASS' and book['book_sources'] == 57 and book['include_sources'] == 32
assert book['producer_sha256'] == a.sha((a.ROOT / (a.HOME + 'book.py')).read_bytes())
assert [row['name'] for row in book['rows']] == ['final', 'missing-summary', 'changed-chapter', 'changed-target', 'missing-include']
healthy = book['rows'][0]
assert len(healthy['inputs']) == 89 and healthy['returncode'] == 0
for path, expected in healthy['inputs'].items():
    assert a.sha((a.ROOT / path).read_bytes()) == expected and (a.ROOT / path).stat().st_mode & 0o7777 == healthy['modes'][path]
native = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
workflow_marker, native_marker = b'Checkpoint artifact parts', b'Invocation scopes and canonical apply'
for row in book['rows']:
    assert row['unchanged'] and row['command'][-2:] == ['-d', 'output']
    expected = {path: (a.ROOT / path).read_bytes() for path in healthy['inputs']}
    name = row['name']
    if name == 'missing-summary': del expected['docs/linkedspec-book/src/SUMMARY.md']
    elif name == 'changed-chapter': expected[a.WORKFLOW] = expected[a.WORKFLOW].replace(workflow_marker, b'', 1)
    elif name == 'changed-target': expected[native] = expected[native].replace(native_marker, b'', 1)
    elif name == 'missing-include': del expected['examples/integration/word.spec']
    assert row['inputs'] == {path: a.sha(value) for path, value in expected.items()}
    assert row['modes'] == {path: healthy['modes'][path] for path in expected}
    html, native_html, stderr = a.decode(row['html_base64']), a.decode(row['target_html_base64']), a.decode(row['stderr_base64'])
    assert row['marker_present'] == (workflow_marker in html) and row['target_marker_present'] == (native_marker in native_html)
    if name == 'missing-summary': assert row['returncode'] != 0 and b'SUMMARY' in stderr
    elif name == 'missing-include': assert row['returncode'] == 0 and b'Error updating' in stderr and b'examples/integration/word.spec' in stderr
    else: assert row['returncode'] == 0 and b'ERROR' not in stderr
    if name == 'changed-chapter': assert not row['marker_present']
    if name == 'changed-target': assert not row['target_marker_present']
for field in ('html_base64', 'target_html_base64'):
    assert tables(a.decode(healthy[field])) == tables(a.decode(old_book['rows'][0][field])), 'all original669 rendered tables stay exact'
assert b'127,191,037 bytes' in a.decode(healthy['html_base64']) and b'32 MiB' in a.decode(healthy['html_base64'])
report = dict(result='PASS', producer_sha256=a.sha(Path(__file__).read_bytes()), fresh_knowledge=fresh,
    supplied_sources_unchanged=unchanged, generated_map_sha256=a.sha(generated),
    expected_map_sha256=capsule['current'][a.MAP]['sha256'],
    population=dict(markdown=1488, facts=1350, question_keys=10453, knowledge_bytes=total,
                    new_facts=1, book_inputs=89, render_controls=4), source_inputs=healthy['inputs'],
    scope='Complete supplied1488-source map re-derivation/check, one new artifact fact and complete '
          'current89-source book/four controls. Every original669 rendered table is exactly preserved. '
          'No later unbound live old fact body or retired native writer is consulted.')
target = a.ROOT / (a.HOME + 'documentation-review.json')
if sys.argv[1:]:
    with target.open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
else: assert json.loads(target.read_bytes()) == report
assert len(fresh) == 2 and all(row['returncode'] == 0 for row in fresh) and unchanged, report
assert generated == a.decode(capsule['current'][a.MAP]['bytes_base64']), 'current supplied map derives exactly'
print('Artifact documentation review PASS:1488/1350/10453;one new fact;89/four controls;all old tables exact')
