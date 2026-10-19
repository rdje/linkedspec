"""Review complete current metadata/docs and freshly re-derive supplied inputs."""
import gzip
import json
import os
import subprocess
import sys
import tempfile
from pathlib import Path
import common as c
import metadata_oracle as oracle

assert sys.argv[1:] in ([], ['--capture'], ['--semantic-only'])
current_raw = (c.ROOT / (c.HOME + 'current.json.gz')).read_bytes()
current = json.loads(gzip.decompress(current_raw))
packed = (c.ROOT / (c.HOME + 'current-inputs.json.gz')).read_bytes()
assert c.sha(packed) == current['capsule_sha256']
inputs = json.loads(gzip.decompress(packed))['inputs']
assert set(inputs) == set(current['inputs'])
for path, item in inputs.items():
    assert c.sha(c.decode(item['base64'])) == item['sha256'] == current['inputs'][path]['sha256']
    assert item['mode'] == current['inputs'][path]['mode']
assert current['generation']['returncode'] == current['check']['returncode'] == 0 and current['inputs_unchanged']
assert current['producer_sha256'] == c.sha((c.ROOT / (c.HOME + 'prepare-docs-final.py')).read_bytes())
proposal = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'docs-preparation.json.gz')).read_bytes()))
before = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'population-inputs.json.gz')).read_bytes()))['inputs']
markdown = {path for path in before if path.startswith(('docs/knowledge/', 'docs/decisions/')) and path.endswith('.md')}
assert markdown == {path for path in inputs if path.startswith(('docs/knowledge/', 'docs/decisions/')) and path.endswith('.md')}, 'complete current graph'
assert len(markdown) == 1487 and len(proposal['changed_facts']) == 15
for path in markdown:
    if path in proposal['proposals']:
        expected = proposal['proposals'][path]
        assert c.decode(inputs[path]['base64']) == c.decode(expected['base64']) and inputs[path]['mode'] == expected['mode'], ('authorized current fact projection', path)
    else:
        assert inputs[path] == before[path], ('unchanged supplied historical fact', path)
for path in proposal['proposals']:
    expected = proposal['proposals'][path]
    assert c.read(path)['sha256'] == expected['sha256']
    assert c.decode(inputs[path]['base64']) == c.decode(expected['base64'])
for path in ('knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/check_knowledge_map.sh',
             '.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf',
             'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh'):
    assert c.read(path) == inputs[path], ('current producer/configuration', path)
mapping = c.decode(current['map_base64'])
assert c.sha(mapping) == current['map_sha256']
assert (c.ROOT / 'KNOWLEDGE_MAP.md').read_bytes() == mapping, 'current generated map matches retained actual epoch'
assert current['map_lines'] == len(mapping.splitlines()) == 21249
population = oracle.verify_graph(inputs, mapping, c.decode)
assert population == dict(markdown=1487, facts=1349, question_keys=10455, list_fields=248, list_items=897)
total = sum(len(c.decode(inputs[path]['base64'])) for path in markdown if path.startswith('docs/knowledge/'))
assert total == current['knowledge_bytes'] == proposal['knowledge_bytes_after'] == 8386908 <= 8388608
preservation = json.loads((c.ROOT / (c.HOME + 'preservation.json')).read_bytes())
old_claim = json.loads(c.decode(preservation['original']['base64']))
old_claim['claims'][0]['durability'].update(mode='historical', revision=c.BASE)
assert json.loads((c.ROOT / c.OLD_CLAIM).read_bytes()) == old_claim, 'only actual activation mode/revision freeze'

envelope = json.loads((c.ROOT / (c.HOME + 'book.json')).read_bytes())
assert envelope['encoding'] == 'gzip-base64'
raw = gzip.decompress(c.decode(envelope['data']))
assert c.sha(raw) == envelope['sha256'] and len(raw) == envelope['bytes']
book = json.loads(raw)
assert book['result'] == 'PASS' and book['book_sources'] == 57 and book['include_sources'] == 32
assert book['producer_sha256'] == c.sha((c.ROOT / (c.HOME + 'book.py')).read_bytes())
book_inputs = json.loads(gzip.decompress((c.ROOT / (c.HOME + 'book-inputs.json.gz')).read_bytes()))
assert book_inputs['producer_sha256'] == book['producer_sha256'] and len(book_inputs['inputs']) == 89
source = 'docs/linkedspec-book/src/development/documentation-workflow.md'
target = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
summary = 'docs/linkedspec-book/src/SUMMARY.md'
marker, target_marker = b'Evidence and verification lists', b'Invocation scopes and canonical apply'
assert [row['name'] for row in book['rows']] == ['final', 'missing-summary', 'changed-chapter', 'changed-target', 'missing-include']
for path, item in book_inputs['inputs'].items():
    assert c.read(path) == item, ('complete current book input', path)
for row in book['rows']:
    expected = {path: c.decode(item['base64']) for path, item in book_inputs['inputs'].items()}
    if row['name'] == 'missing-summary':
        del expected[summary]
    elif row['name'] == 'changed-chapter':
        expected[source] = expected[source].replace(marker, b'', 1)
    elif row['name'] == 'changed-target':
        expected[target] = expected[target].replace(target_marker, b'', 1)
    elif row['name'] == 'missing-include':
        del expected['examples/integration/word.spec']
    assert row['inputs'] == {path: c.sha(value) for path, value in expected.items()}
    assert row['modes'] == {path: book_inputs['inputs'][path]['mode'] for path in expected} and row['unchanged']
    html, target_html, stderr = c.decode(row['html_base64']), c.decode(row['target_html_base64']), c.decode(row['stderr_base64'])
    assert row['marker_present'] == (marker in html) and row['target_marker_present'] == (target_marker in target_html)
    if row['name'] == 'missing-summary':
        assert row['returncode'] != 0 and b'SUMMARY' in stderr
    elif row['name'] == 'missing-include':
        assert row['returncode'] == 0 and b'Error updating' in stderr and b'examples/integration/word.spec' in stderr
    else:
        assert row['returncode'] == 0 and b'ERROR' not in stderr
    if row['name'] == 'changed-chapter':
        assert not row['marker_present']
    if row['name'] == 'changed-target':
        assert not row['target_marker_present']
assert book['rows'][0]['marker_present'] and book['rows'][0]['target_marker_present']

if sys.argv[1:] == ['--semantic-only']:
    print('Current metadata semantic review PASS:1487/1349/10455;897/248;book89/four controls')
    raise SystemExit(0)
fresh_paths = markdown | {'.knowledge_map.conf', 'knowledge-map/scripts/knowledge_map.conf',
    'knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/check_knowledge_map.sh',
    'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh'}
fresh = []
with tempfile.TemporaryDirectory(prefix='knowledge-fields-current-review-', dir=os.environ['TMPDIR']) as directory:
    fixture = Path(directory)
    assert fixture.stat().st_dev == c.ROOT.stat().st_dev
    for path in fresh_paths:
        target_file = fixture / path
        target_file.parent.mkdir(parents=True, exist_ok=True)
        target_file.write_bytes(c.decode(inputs[path]['base64']))
        target_file.chmod(inputs[path]['mode'])
    temporary = fixture / '.linkedspec-data/tmp'
    temporary.mkdir(parents=True)
    environment = dict(os.environ, GIT_DIR=subprocess.check_output(['git', 'rev-parse', '--absolute-git-dir'], cwd=c.ROOT, text=True).strip(),
                       GIT_WORK_TREE=str(fixture), GIT_OPTIONAL_LOCKS='0', TMPDIR=str(temporary),
                       KM_SCAN_DIRS='docs/knowledge docs/decisions', KM_OUTPUT='generated-map.md')
    for command in (['bash', 'knowledge-map/scripts/gen_knowledge_map.sh'], ['bash', 'knowledge-map/scripts/check_knowledge_map.sh']):
        run = subprocess.run(command, cwd=fixture, env=environment, capture_output=True)
        fresh.append(dict(command=command, returncode=run.returncode, stdout_base64=c.encode(run.stdout), stderr_base64=c.encode(run.stderr)))
        if run.returncode:
            break
    assert len(fresh) == 2 and all(row['returncode'] == 0 for row in fresh), fresh
    assert (fixture / 'generated-map.md').read_bytes() == mapping, 'fresh complete current map exact'
    assert all(c.sha((fixture / path).read_bytes()) == inputs[path]['sha256'] and (fixture / path).stat().st_mode & 0o7777 == inputs[path]['mode'] for path in fresh_paths)
report = dict(result='PASS', producer_sha256=c.sha(Path(__file__).read_bytes()),
              oracle_sha256=c.sha((c.ROOT / (c.HOME + 'metadata_oracle.py')).read_bytes()),
              population=population, knowledge_bytes=total, map_lines=len(mapping.splitlines()),
              changed_facts=proposal['changed_facts'], book_inputs=89, book_controls=4, fresh_commands=fresh,
              scope='Every current supplied source equals its actual declared original or exact authorized '
                    'fifteen-card projection. Every897 metadata entry/order/multiplicity and all10455 '
                    'question rows derive from source headers with an independent code-span decoder. '
                    'Full current supplied graph is freshly regenerated/checked with complete source '
                    'guards. All89 current book inputs and four actual source/command/render controls '
                    'are independently reconstructed. Only .6 mode/revision is historicalized.')
path = c.ROOT / (c.HOME + 'current-review.json')
if sys.argv[1:]:
    with path.open('x') as output:
        output.write(json.dumps(report, indent=1) + '\n')
else:
    assert json.loads(path.read_bytes()) == report
print('Current metadata review PASS:1487/1349/10455;all897 entries;15 routes;book89/four controls;fresh exact map')
