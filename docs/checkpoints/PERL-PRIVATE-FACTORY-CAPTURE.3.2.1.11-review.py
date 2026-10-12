"""Readonly composed Knowledge list-association review; --capture writes once."""
import base64
import gzip
import hashlib
import io
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '328b11c5ed1d5ffbc870f6785448e3a8249fe882'
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-'
GATE = 'knowledge-map/scripts/check_knowledge_map.sh'
FIXTURE = 't/knowledge_map_header_lists.t'
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda path: (ROOT / path).read_bytes()
load = lambda tail: json.loads(read(PREFIX + tail))
decode = lambda row, key: base64.b64decode(row[key + '_base64'], validate=True)

def original(paths):
    paths = sorted(set(paths))
    assert all('\n' not in path for path in paths)
    process = subprocess.run(['git', 'cat-file', '--batch'], cwd=ROOT,
        input=''.join(BASE + ':' + path + '\n' for path in paths).encode(), capture_output=True)
    assert process.returncode == 0 and not process.stderr
    stream, values = io.BytesIO(process.stdout), {}
    for path in paths:
        header = stream.readline().split()
        assert len(header) == 3 and header[1] == b'blob', ('recoverable original', path, header)
        values[path] = stream.read(int(header[2]))
        assert stream.read(1) == b'\n'
    assert not stream.read()
    return values

def header_state(raw):
    lines = raw.decode().splitlines()
    if not lines or lines[0] != '---':
        return False, []
    owner, answers, orphan = None, False, []
    for number, line in enumerate(lines[1:], 2):
        if line.strip() == '---':
            break
        if re.match(r'^\s+-\s+', line):
            if owner is None:
                orphan.append(number)
            if owner == 'answers' and re.sub(r'^\s+-\s+', '', line).strip(' "'):
                answers = True
        elif re.match(r'^[A-Za-z_][A-Za-z0-9_]*:', line):
            key, value = line.split(':', 1)
            owner = key if not value.strip() else None
            if key == 'answers' and re.match(r'^\s*\[.*[A-Za-z0-9].*\]\s*$', value):
                answers = True
    return answers, orphan

preserved, baseline = load('preservation.json'), load('baseline.json')
assert preserved['base'] == BASE and preserved['producer_sha256'] == sha(read(PREFIX + 'preserve.py'))
assert preserved['baseline_sha256'] == sha(read(PREFIX + 'baseline.json'))
assert baseline['returncode'] == 0 and not decode(baseline, 'stderr')
assert decode(baseline, 'stdout') == b'Named dispatch publication PASS: 534 live inputs; 123810 bytes\n'
selected = preserved['selected']
assert len(selected) == 1 and selected[0]['path'] == 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8.json'
prior = selected[0]
raw_prior = read(prior['before'])
assert len(raw_prior) == prior['bytes'] == 123810 and sha(raw_prior) == prior['sha256']
old_claim = json.loads(raw_prior)
bindings = old_claim['claims'][0]['durability']['inputs']
assert len(bindings) == 534
old_paths = [row['path'] for row in preserved['census']]
namespace = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', BASE, '--', 'docs/claims'], cwd=ROOT, text=True).splitlines()
assert old_paths == sorted(namespace), 'complete fixed original claim namespace'
git = original(old_paths + [item['path'] for item in bindings])
assert git[prior['path']] == raw_prior
for item in bindings:
    assert sha(git[item['path']]) == item['sha256'], ('all original claim bindings', item['path'])
for row in preserved['census']:
    assert sha(git[row['path']]) == row['sha256']
    expected = json.loads(git[row['path']])
    for intersection in row['intersections']:
        value = expected['claims'][intersection['claim_index']]['durability']
        value['mode'], value['revision'] = 'historical', BASE
    assert json.loads(read(row['path'])) == expected, ('mode/revision only', row['path'])
    if not row['intersections']:
        assert read(row['path']) == git[row['path']], 'all nonintersecting original claims immutable'

population = load('population.json')
assert population['base'] == BASE and population['producer_sha256'] == sha(read(PREFIX + 'population.py'))
packed = read(PREFIX + 'population.json.gz')
assert sha(packed) == population['capsule_sha256']
capsule = {path: base64.b64decode(raw, validate=True) for path, raw in json.loads(gzip.decompress(packed)).items()}
assert len(capsule) == len(population['rows']) == 1485
git = original(list(capsule) + list(population['source_inputs']))
assert all(git[path] == raw for path, raw in capsule.items()), 'actual original complete capsule'
assert all(sha(git[path]) == digest for path, digest in population['source_inputs'].items())
fact_count = 0
for row in population['rows']:
    raw = capsule[row['path']]
    fact, orphans = header_state(raw)
    assert sha(raw) == row['sha256'] and len(raw) == row['bytes']
    assert row['fact'] == fact and not orphans and not row['orphans']
    fact_count += fact
assert fact_count == 1349
current = load('current.json')
assert current['producer_sha256'] == sha(read(PREFIX + 'current.py'))
paths = subprocess.check_output(['find', 'docs/knowledge', 'docs/decisions', '-type', 'f', '-name', '*.md'], cwd=ROOT, text=True).splitlines()
assert sorted(paths) == sorted(capsule), 'complete current scan membership'
changed = sorted(path for path in paths if read(path) != capsule[path])
assert changed == current['changed_cards'] and len(changed) == 6
for path in paths:
    raw = read(path)
    assert current['inputs'][path] == sha(raw)
    _, orphan = header_state(raw)
    assert not orphan, ('current Knowledge orphan list', path, orphan)
    if path in changed:
        old_header, old_body = capsule[path].split(b'\n---\n', 1)
        header, body = raw.split(b'\n---\n', 1)
        old_route = re.findall(rb'^reverify:.*$', old_header, re.M)
        assert len(old_route) == 1 and old_route[0] in body and body.startswith(old_body)
        assert re.sub(rb'^reverify:.*$', b'', header, flags=re.M) == re.sub(rb'^reverify:.*$', b'', old_header, flags=re.M)
        assert PREFIX.encode() + b'publish-claim.py' in header
assert current['returncode'] == 0 and not decode(current, 'stdout')
assert decode(current, 'stderr') == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
assert all(sha(read(path)) == digest for path, digest in current['inputs'].items())

before, after = load('before.json'), load('after.json')
run_sha = sha(read(PREFIX + 'run.py'))
assert before['producer_sha256'] == after['producer_sha256'] == run_sha
assert before['inputs'][FIXTURE] == after['inputs'][FIXTURE] == sha(read(FIXTURE)), 'identical fixture'
assert before['inputs'][GATE] == sha(original([GATE])[GATE])
assert after['inputs'][GATE] == sha(read(GATE))
left = json.loads(decode(before['rows'][0], 'stdout'))['rows']
right = json.loads(decode(after['rows'][0], 'stdout'))['rows']
assert len(left) == len(right) == 20 and len({row['name'] for row in left}) == 20
orphan_names = set()
for first, last in zip(left, right):
    for key in ('name', 'kind', 'header_base64'):
        assert first[key] == last[key], ('same complete case', key)
    _, orphan = header_state(b'---\n' + decode(first, 'header') + b'---\n')
    assert bool(orphan) == (first['kind'] == 'orphan')
    if orphan:
        orphan_names.add(first['name'])
    for stage, row in (('before', first), ('after', last)):
        assert row['generate']['status'] == 0 and not decode(row['check'], 'stdout')
        expected = 256 if row['kind'] == 'required' or (stage == 'after' and orphan) else 0
        assert row['check']['status'] == expected, ('semantic public verdict', stage, row['name'])
        if stage == 'after' and orphan:
            assert re.search(rb'front-matter orphan list item at line \d+', decode(row['check'], 'stderr'))
assert len(orphan_names) == 8 and sum(name.startswith('historical-') for name in orphan_names) == 2
for record in (before, after):
    assert record['rows'][0]['returncode'] == 0 and not decode(record['rows'][0], 'stderr')
    assert all(sha(read(path)) == digest for path, digest in record['inputs'].items() if path != GATE)

def tap(row, failed):
    raw = decode(row, 'stdout').decode()
    names = re.findall(r'^(?:not )?ok (\d+) - (.*)$', raw, re.M)
    failures = re.findall(r'^not ok (\d+) - (.*)$', raw, re.M)
    assert len(names) == 80 and [int(number) for number, _ in names] == list(range(1, 81))
    assert re.search(r'^1\.\.80$', raw, re.M) and len(failures) == failed
    assert bool(row['returncode']) == bool(failed)
    return names, failures

names, failures = tap(before['rows'][1], 16)
assert names == tap(after['rows'][1], 0)[0]
assert all(any(name.startswith(case + ' ') for case in orphan_names) for _, name in failures)
faults = load('faults-final.json')
assert faults['result'] == 'PASS' and faults['producer_sha256'] == sha(read(PREFIX + 'faults-final.py'))
assert faults['source_sha256'] == sha(read(GATE)) and faults['fixture_sha256'] == sha(read(FIXTURE))
assert [row['name'] for row in faults['rows']] == ['scalar-keeps-list-owner', 'malformed-answers-hidden', 'orphan-verdict-disabled']
for row, count in zip(faults['rows'], (14, 2, 16)):
    assert row['commands'][0]['returncode'] == row['commands'][1]['returncode'] == 0
    assert sha(base64.b64decode(row['source_base64'], validate=True)) == row['sha256']
    observed = tap(row['commands'][2], count)[1]
    assert [list(item) for item in observed] == row['failures']
tap(faults['restored'], 0)
first_faults, first_failure = load('faults.json'), load('faults-first-failure.json')
assert first_failure['actual_tool_session'] == 58494 and first_failure['actual_returncode'] == 1
assert first_failure['producer_sha256'] == sha(read(PREFIX + 'faults.py'))
assert first_failure['report_sha256'] == sha(read(PREFIX + 'faults.json'))
assert first_failure['restored_gate_sha256'] == sha(read(GATE))
assert b'AssertionError' in base64.b64decode(first_failure['merged_log_base64'], validate=True)
for row, count in zip(first_faults['rows'], (14, 2, 34)):
    tap(row['commands'][2], count)
expected_final = read(PREFIX + 'faults.py').replace(b"target = ROOT / (PREFIX + 'faults.json')", b"target = ROOT / (PREFIX + 'faults-final.json')")
expected_final = expected_final.replace(b"b'[ -z \"$orphan\" ] && note '", b"b'[ -n \"\" ] && note '")
assert read(PREFIX + 'faults-final.py') == expected_final, 'distinct sole control correction/output identity'

metadata = load('metadata-lists.json')
assert metadata['result'] == 'REPRODUCED' and metadata['repair_owner'].endswith('.3.2.1.12')
assert metadata['producer_sha256'] == sha(read(PREFIX + 'metadata-lists.py'))
assert metadata['before_sha256'] == sha(read(PREFIX + 'before.json'))
assert metadata['generator_sha256'] == sha(read('knowledge-map/scripts/gen_knowledge_map.sh'))
assert {row['missing_field'] for row in metadata['rows']} == {'evidence', 'reverify'}
for row in metadata['rows']:
    assert row['returncode'] == row['original_checker_status'] == 0
    assert ('**' + row['missing_field'] + ':**').encode() not in decode(row, 'map')

book = subprocess.run(['python3', PREFIX + 'book-review.py'], cwd=ROOT, capture_output=True)
assert book.returncode == 0 and not book.stderr, ('actual readonly book review', book.stderr)
book_report = load('book-review.json')
tails = ('preserve.py', 'preservation.json', 'baseline.json', 'before-PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8.json',
    'population.py', 'population.json', 'population.json.gz', 'run.py', 'before.json', 'after.json',
    'faults.py', 'faults.json', 'faults-first-failure.json', 'faults-final.py', 'faults-final.json',
    'metadata-lists.py', 'metadata-lists.json', 'current.py', 'current.json', 'book.py', 'book.json',
    'book-review.py', 'book-review.json', 'review.py')
input_paths = set(book_report['source_inputs']) | {PREFIX + tail for tail in tails}
input_paths.update(changed + [GATE, FIXTURE, 'KNOWLEDGE_MAP.md', '.knowledge_map.conf',
    'knowledge-map/scripts/gen_knowledge_map.sh', 'knowledge-map/scripts/knowledge_map.conf',
    'knowledge-map/KNOWLEDGE_MAP_ARCHITECTURE.md', 'tools/run_ci_local.sh',
    'tools/project_data_env.sh', 'tools/project_data_run.sh',
    'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8-headers-census.json', prior['path']])
report = {'result': 'PASS', 'base': BASE, 'producer_sha256': sha(Path(__file__).read_bytes()),
    'original_claim_bindings': 534, 'original_claim_bytes': 123810, 'original_markdown_inputs': 1485,
    'original_facts': 1349, 'current_changed_cards': changed, 'cases': 20, 'assertions': 80,
    'original_red': 16, 'original_controls': 64, 'fault_reds': [14, 2, 16],
    'book_inputs': book_report['source_count'], 'book_controls': book_report['actual_controls'],
    'metadata_projection_repair_owner': metadata['repair_owner'],
    'input_metadata': {path: sha(read(path)) for path in sorted(input_paths)},
    'scope': 'Complete original scan bytes retained as a capsule, six exact current header overlays and unchanged fact bodies; current full source hashes and actual full gate channels. Original accepted callback proof is recovered at its Git boundary, without rerunning or relabeling its native observations. Public list association only; no complete YAML/field-type, new runtime/private/parent or other-backend admission. Canonical staged receipt remains the mandatory landing boundary. Metadata projection remains separately owned.'}
target = ROOT / (PREFIX + 'review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot composed capture'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'exact readonly composed report'
print('Knowledge composed review PASS: 20/80; 16 original REDs; 14/2/16 source controls; complete1485/1349 population; prior534/full123810; book89/four')
