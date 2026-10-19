"""Re-derive the complete supplied map and verify the unchanged full book."""
import gzip
import json
import subprocess
import sys
from html.parser import HTMLParser
from pathlib import Path
import route as r

assert sys.argv[1:] in ([], ['--capture'])
manifest = r.load()
a = r.artifact()
knowledge = json.loads((r.ROOT / (r.PREFIX + 'knowledge.json')).read_bytes())
packed = (r.ROOT / (r.PREFIX + 'knowledge-inputs.json.gz')).read_bytes()
assert r.sha(packed) == knowledge['capsule_sha256']
capsule = json.loads(gzip.decompress(packed))
old_path = r.ARTIFACTS + 'knowledge-inputs.json.gz'
old_raw = (r.ROOT / old_path).read_bytes()
assert r.sha(old_raw) == manifest['inputs'][old_path]['sha256']
old = json.loads(gzip.decompress(old_raw))
before = capsule['before']
assert before == {path: old['current'][path] for path in set(old['before']) | {r.OLD_CARD}}
assert len(before) == knowledge['before_markdown'] == 1488
assert knowledge['current_markdown'] == 1487 and knowledge['facts'] == 1349
assert knowledge['question_keys'] == 10453 and knowledge['inputs_unchanged']
assert knowledge['changed_cards'] == [r.CARD] and knowledge['removed_cards'] == [r.OLD_CARD]
assert set(capsule['current']) == set(knowledge['inputs'])
markdown = set(before) - {r.OLD_CARD}
assert len(markdown) == 1487 and markdown <= set(capsule['current'])
total = 0
for path, item in capsule['current'].items():
    value = r.decode(item['bytes_base64'])
    assert r.sha(value) == item['sha256'] == knowledge['inputs'][path]['sha256']
    assert item['mode'] == knowledge['inputs'][path]['mode']
    if path in before and path != r.CARD:
        assert value == r.decode(before[path]['bytes_base64']) and item['mode'] == before[path]['mode']
    else:
        assert (r.ROOT / path).read_bytes() == value
        assert (r.ROOT / path).stat().st_mode & 0o7777 == item['mode']
    if path in markdown and path.startswith('docs/knowledge/'):
        total += len(value)
card = r.decode(capsule['current'][r.CARD]['bytes_base64'])
assert card == r.decode(manifest['proposal'][r.CARD]['base64'])
old_header, old_body = r.decode(before[r.OLD_CARD]['bytes_base64']).split(b'\n---\n', 1)
assert old_body in card and not (r.ROOT / r.OLD_CARD).exists()
assert all(line in card for line in old_header.splitlines() if line.startswith(b'  - "'))
assert total == knowledge['knowledge_bytes'] == manifest['knowledge_bytes'] <= 8388608
assert knowledge['generation']['returncode'] == knowledge['check']['returncode'] == 0
assert not r.decode(knowledge['generation']['stdout_base64']) and not r.decode(knowledge['check']['stdout_base64'])
assert r.decode(knowledge['generation']['stderr_base64']) == b'knowledge-map: wrote KNOWLEDGE_MAP.md (1349 facts, 10453 question keys)\n'
assert r.decode(knowledge['check']['stderr_base64']) == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'

# All generator inputs are supplied. Historical Markdown is read from the
# capsule, so later unrelated fact edits cannot silently alter this proof.
original = json.loads(gzip.decompress(a.part_bytes(a.load_manifest())))
fresh = []
with a.common().original_fixture(original) as (fixture, environment):
    assert not (fixture / r.OLD_CARD).exists()
    for path, item in capsule['current'].items():
        target = fixture / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(r.decode(item['bytes_base64']))
        target.chmod(item['mode'])
    for command, output in [(['bash', 'knowledge-map/scripts/gen_knowledge_map.sh'], 'generated-map.md'),
                            (['bash', 'knowledge-map/scripts/check_knowledge_map.sh'], r.MAP)]:
        run = subprocess.run(command, cwd=fixture, env=dict(environment, KM_OUTPUT=output), capture_output=True)
        fresh.append(dict(command=command, output=output, returncode=run.returncode,
                          stdout_base64=r.encode(run.stdout), stderr_base64=r.encode(run.stderr)))
        if run.returncode != 0:
            break
    generated = (fixture / 'generated-map.md').read_bytes() if (fixture / 'generated-map.md').is_file() else b''
    unchanged = all(r.sha((fixture / path).read_bytes()) == item['sha256'] and
                    (fixture / path).stat().st_mode & 0o7777 == item['mode']
                    for path, item in capsule['current'].items())


class Tables(HTMLParser):
    def __init__(self):
        super().__init__()
        self.tables, self.table, self.row, self.cell = [], None, None, None

    def handle_starttag(self, tag, attrs):
        if tag == 'table':
            self.table = []
        elif tag == 'tr' and self.table is not None:
            self.row = []
        elif tag in ('td', 'th') and self.row is not None:
            self.cell = []

    def handle_data(self, data):
        if self.cell is not None:
            self.cell.append(data)

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
    value = gzip.decompress(r.decode(envelope['data']))
    assert len(value) == envelope['bytes'] and r.sha(value) == envelope['sha256']
    return json.loads(value)


book_path = r.ARTIFACTS + 'book.json'
book_raw = (r.ROOT / book_path).read_bytes()
assert r.sha(book_raw) == manifest['inputs'][book_path]['sha256']
book = unpack(json.loads(book_raw))
prior_path = a.PREFIX + 'book.json'
prior_raw = (r.ROOT / prior_path).read_bytes()
assert r.sha(prior_raw) == manifest['inputs'][prior_path]['sha256']
prior_book = unpack(json.loads(prior_raw))
assert book['result'] == 'PASS' and book['book_sources'] == 57 and book['include_sources'] == 32
assert book['producer_sha256'] == r.sha((r.ROOT / (r.ARTIFACTS + 'book.py')).read_bytes())
assert [row['name'] for row in book['rows']] == ['final', 'missing-summary', 'changed-chapter', 'changed-target', 'missing-include']
healthy = book['rows'][0]
assert len(healthy['inputs']) == 89 and healthy['returncode'] == 0
for path, expected in healthy['inputs'].items():
    assert expected == manifest['inputs'][path]['sha256'] == r.sha((r.ROOT / path).read_bytes())
    assert (r.ROOT / path).stat().st_mode & 0o7777 == healthy['modes'][path] == manifest['inputs'][path]['mode']
native = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
workflow_marker, native_marker = b'Checkpoint artifact parts', b'Invocation scopes and canonical apply'
for row in book['rows']:
    assert row['unchanged'] and row['command'][-2:] == ['-d', 'output']
    expected = {path: (r.ROOT / path).read_bytes() for path in healthy['inputs']}
    name = row['name']
    if name == 'missing-summary':
        del expected['docs/linkedspec-book/src/SUMMARY.md']
    elif name == 'changed-chapter':
        expected[a.WORKFLOW] = expected[a.WORKFLOW].replace(workflow_marker, b'', 1)
    elif name == 'changed-target':
        expected[native] = expected[native].replace(native_marker, b'', 1)
    elif name == 'missing-include':
        del expected['examples/integration/word.spec']
    assert row['inputs'] == {path: r.sha(value) for path, value in expected.items()}
    assert row['modes'] == {path: healthy['modes'][path] for path in expected}
    html, native_html, stderr = r.decode(row['html_base64']), r.decode(row['target_html_base64']), r.decode(row['stderr_base64'])
    assert row['marker_present'] == (workflow_marker in html) and row['target_marker_present'] == (native_marker in native_html)
    if name == 'missing-summary':
        assert row['returncode'] != 0 and b'SUMMARY' in stderr
    elif name == 'missing-include':
        assert row['returncode'] == 0 and b'Error updating' in stderr and b'examples/integration/word.spec' in stderr
    else:
        assert row['returncode'] == 0 and b'ERROR' not in stderr
    if name == 'changed-chapter':
        assert not row['marker_present']
    if name == 'changed-target':
        assert not row['target_marker_present']
for field in ('html_base64', 'target_html_base64'):
    assert tables(r.decode(healthy[field])) == tables(r.decode(prior_book['rows'][0][field]))
assert b'127,191,037 bytes' in r.decode(healthy['html_base64']) and b'32 MiB' in r.decode(healthy['html_base64'])
report = dict(result='PASS', producer_sha256=r.sha(Path(__file__).read_bytes()), fresh_knowledge=fresh,
    supplied_sources_unchanged=unchanged, generated_map_sha256=r.sha(generated),
    expected_map_sha256=capsule['current'][r.MAP]['sha256'],
    population=dict(markdown=1487, facts=1349, question_keys=10453, knowledge_bytes=total,
                    consolidated_facts=1, removed_redundant_facts=1, book_inputs=89, render_controls=4),
    source_inputs=healthy['inputs'],
    scope='Complete supplied1487-source map re-derivation/check preserves all10453 question keys. '
          'The complete artifact fact moves to its existing canonical home under unchanged limits. '
          'All89 book inputs and four actual render controls remain byte/mode exact to the696 '
          'baseline; every original rendered table is independently compared. No rerender, later '
          'unbound historical fact body or native writer is used.')
target = r.ROOT / (r.PREFIX + 'documentation-review.json')
assert len(fresh) == 2 and all(row['returncode'] == 0 for row in fresh) and unchanged, report
assert generated == r.decode(capsule['current'][r.MAP]['bytes_base64'])
if sys.argv[1:]:
    with target.open('x') as output:
        output.write(json.dumps(report, indent=1) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
print('Canonical-home documentation PASS:1487/1349/10453;unchanged89/four controls;all old tables exact')
