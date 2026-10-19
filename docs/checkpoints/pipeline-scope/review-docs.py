"""Re-derive the supplied current map and verify complete rendered semantics."""
import gzip
import json
import os
import subprocess
import sys
from html.parser import HTMLParser
from pathlib import Path
from common_final import ROOT, PREFIX, OLD, CARD, WORKFLOW, load, original_fixture, sha, encode, decode

assert sys.argv[1:] in ([], ['--capture'])
original = load()
projection = json.loads((ROOT / (PREFIX + 'projection-preflight.json')).read_bytes())
knowledge = json.loads((ROOT / (PREFIX + 'knowledge.json')).read_bytes())
packed = (ROOT / (PREFIX + 'knowledge-inputs.json.gz')).read_bytes()
assert sha(packed) == knowledge['capsule_sha256']
capsule = json.loads(gzip.decompress(packed))
old = json.loads(gzip.decompress(decode(original['inputs'][OLD + 'knowledge-inputs.json.gz']['base64'])))
assert capsule['original'] == old['original'] and len(capsule['original']) == 1487
assert knowledge['markdown'] == 1487 and knowledge['facts'] == 1349 and knowledge['question_keys'] == 10450
assert knowledge['inputs_unchanged'] and knowledge['changed_bodies_from_draft'] == [CARD]
assert knowledge['changed_cards'] == projection['changed_cards']
cards, total = set(knowledge['changed_cards']), 0
assert set(capsule['current']) == set(knowledge['inputs'])
for path, item in capsule['current'].items():
    value = decode(item['bytes_base64'])
    assert sha(value) == item['sha256'] == knowledge['inputs'][path]['sha256']
    assert item['mode'] == knowledge['inputs'][path]['mode']
    if path in capsule['original']:
        if path in cards:
            assert value == decode(projection['proposed'][path]['base64'])
        else:
            assert value == decode(old['current'][path]['bytes_base64']), ('whole captured unchanged member', path)
        if path.startswith('docs/knowledge/'): total += len(value)
    if path not in capsule['original'] or path in cards:
        assert (ROOT / path).read_bytes() == value and (ROOT / path).stat().st_mode & 0o7777 == item['mode']
assert total == knowledge['knowledge_bytes'] == projection['knowledge_bytes'] == 8384959 <= 8388608
assert knowledge['generation']['returncode'] == knowledge['check']['returncode'] == 0
assert not decode(knowledge['generation']['stdout_base64']) and not decode(knowledge['check']['stdout_base64'])
assert decode(knowledge['generation']['stderr_base64']) == b'knowledge-map: wrote KNOWLEDGE_MAP.md (1349 facts, 10450 question keys)\n'
assert decode(knowledge['check']['stderr_base64']) == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'

# Re-derive from the complete supplied graph, never later unbound live Markdown.
fresh = []
with original_fixture(original) as (fixture, environment):
    for path, item in capsule['current'].items():
        target = fixture / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(decode(item['bytes_base64']))
        target.chmod(item['mode'])
    for command, output in [(['bash', 'knowledge-map/scripts/gen_knowledge_map.sh'], 'generated-map.md'),
                            (['bash', 'knowledge-map/scripts/check_knowledge_map.sh'], 'KNOWLEDGE_MAP.md')]:
        supplied_env = dict(environment, KM_OUTPUT=output)
        run = subprocess.run(command, cwd=fixture, env=supplied_env, capture_output=True)
        fresh.append(dict(command=command, output=output, returncode=run.returncode,
                          stdout_base64=encode(run.stdout), stderr_base64=encode(run.stderr)))
        if run.returncode != 0: break
    generated = (fixture / 'generated-map.md').read_bytes() if (fixture / 'generated-map.md').is_file() else b''
    unchanged = all(sha((fixture / path).read_bytes()) == item['sha256'] and
                    (fixture / path).stat().st_mode & 0o7777 == item['mode']
                    for path, item in capsule['current'].items())


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
            self.row.append(' '.join(''.join(self.cell).split())); self.cell = None
        elif tag == 'tr' and self.row is not None:
            self.table.append(self.row); self.row = None
        elif tag == 'table' and self.table is not None:
            self.tables.append(self.table); self.table = None


def tables(value):
    parser = Tables(); parser.feed(value.decode()); return parser.tables


def unpack(envelope):
    assert envelope['encoding'] == 'gzip-base64'
    value = gzip.decompress(decode(envelope['data']))
    assert len(value) == envelope['bytes'] and sha(value) == envelope['sha256']
    return json.loads(value)


book = unpack(json.loads((ROOT / (PREFIX + 'book.json')).read_bytes()))
previous = unpack(json.loads(decode(original['inputs'][OLD + 'book.json']['base64'])))
assert book['result'] == 'PASS' and book['book_sources'] == 57 and book['include_sources'] == 32
assert book['producer_sha256'] == sha((ROOT / (PREFIX + 'book.py')).read_bytes())
assert [row['name'] for row in book['rows']] == ['final', 'missing-summary', 'changed-chapter', 'changed-target', 'missing-include']
healthy = book['rows'][0]
assert len(healthy['inputs']) == 89 and healthy['returncode'] == 0
for path, expected in healthy['inputs'].items():
    assert sha((ROOT / path).read_bytes()) == expected and (ROOT / path).stat().st_mode & 0o7777 == healthy['modes'][path]
native = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
workflow_marker, native_marker = b'Pipeline observation transport', b'Invocation scopes and canonical apply'
for row in book['rows']:
    assert row['unchanged'] and row['command'][-2:] == ['-d', 'output']
    expected = {path: (ROOT / path).read_bytes() for path in healthy['inputs']}
    name = row['name']
    if name == 'missing-summary': del expected['docs/linkedspec-book/src/SUMMARY.md']
    elif name == 'changed-chapter': expected[WORKFLOW] = expected[WORKFLOW].replace(workflow_marker, b'', 1)
    elif name == 'changed-target': expected[native] = expected[native].replace(native_marker, b'', 1)
    elif name == 'missing-include': del expected['examples/integration/word.spec']
    assert row['inputs'] == {path: sha(value) for path, value in expected.items()}
    assert row['modes'] == {path: healthy['modes'][path] for path in expected}
    html, native_html, stderr = decode(row['html_base64']), decode(row['target_html_base64']), decode(row['stderr_base64'])
    assert row['marker_present'] == (workflow_marker in html)
    assert row['target_marker_present'] == (native_marker in native_html)
    if name == 'missing-summary': assert row['returncode'] != 0 and b'SUMMARY' in stderr
    elif name == 'missing-include': assert row['returncode'] == 0 and b'Error updating' in stderr and b'examples/integration/word.spec' in stderr
    else: assert row['returncode'] == 0 and b'ERROR' not in stderr
    if name == 'changed-chapter': assert not row['marker_present']
    if name == 'changed-target': assert not row['target_marker_present']
for field in ('html_base64', 'target_html_base64'):
    assert tables(decode(healthy[field])) == tables(decode(previous['rows'][0][field])), 'every original rendered table stays exact'
assert b'161 missing claim inputs' in decode(healthy['html_base64'])
assert b'625 bindings' in decode(healthy['html_base64'])
report = dict(result='PASS', producer_sha256=sha(Path(__file__).read_bytes()),
              fresh_knowledge=fresh, supplied_sources_unchanged=unchanged,
              generated_map_sha256=sha(generated), expected_map_sha256=capsule['current']['KNOWLEDGE_MAP.md']['sha256'],
              population=dict(markdown=1487, facts=1349, question_keys=10450, knowledge_bytes=total,
                              routes=15, changed_bodies_from_draft=1, book_inputs=89, render_controls=4),
              source_inputs=healthy['inputs'],
              scope='Whole supplied current graph re-derivation and check; all original rendered '
                    'tables are exactly preserved, with current transport/closure prose present. '
                    'No later unbound live Markdown or retired native writer is consulted.')
target = ROOT / (PREFIX + 'documentation-review.json')
if sys.argv[1:]:
    with target.open('x') as output: output.write(json.dumps(report, indent=1) + '\n')
else: assert json.loads(target.read_bytes()) == report
assert len(fresh) == 2 and all(row['returncode'] == 0 for row in fresh) and unchanged, report
assert generated == decode(capsule['current']['KNOWLEDGE_MAP.md']['bytes_base64']), 'supplied current map is derived exactly'
print('Current supplied Knowledge and exact original-table book review PASS:1487/1349/10450;8384959;89/4')
