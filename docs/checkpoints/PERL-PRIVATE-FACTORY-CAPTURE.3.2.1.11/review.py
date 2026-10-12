"""Readonly final review; original observations are supplied, never refreshed."""
import base64
import gzip
import hashlib
import importlib.util
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11/'
OLD = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11-'
BASE = '328b11c5ed1d5ffbc870f6785448e3a8249fe882'
TARGET = ROOT / (PREFIX + 'review.json')
assert sys.argv[1:] in ([], ['--capture'])
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda p: (ROOT / p).read_bytes()
load = lambda p: json.loads(read(p))
decode = lambda r, k: base64.b64decode(r[k + '_base64'], validate=True)

def checked(command):
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    assert result.returncode == 0 and not result.stderr, (command, result.stderr)
    return result.stdout

preserved = load(PREFIX + 'preservation.json')
assert preserved['result'] == 'PASS' and preserved['base'] == BASE
assert preserved['producer_sha256'] == sha(read(PREFIX + 'preserve.py'))
claim = read(PREFIX + 'original-claim.json')
assert len(claim) == preserved['claim_bytes'] == 35512 and sha(claim) == preserved['claim_sha256']
packed = read(PREFIX + 'original-inputs.json.gz')
assert sha(packed) == preserved['capsule_sha256']
frozen = {p: base64.b64decode(v, validate=True) for p, v in json.loads(gzip.decompress(packed)).items()}
bindings = json.loads(claim)['claims'][0]['durability']['inputs']
assert len(frozen) == len(bindings) == 136
assert all(sha(frozen[r['path']]) == r['sha256'] for r in bindings)
assert sha(gzip.decompress(read(PREFIX + 'canonical1-candidate.diff.gz'))) == preserved['candidate_sha256']
assert preserved['actual_canonical_session'] == 5315 and preserved['actual_canonical_returncode'] == 1
assert b'ValueError: unreviewed governance drift: tools/run_ci_local.sh' in decode(preserved, 'canonical_log')
baseline = load(PREFIX + 'baseline.json')
assert baseline['returncode'] == 0 and not decode(baseline, 'stderr')
assert decode(baseline, 'stdout') == b'Knowledge gate publication PASS: 136 live inputs; 35512 bytes\n'
assert b'Frozen first publication replay PASS:' in checked(['python3', PREFIX + 'replay.py'])
replay = load(PREFIX + 'replay.json')
assert replay['claim_bytes'] == 35512 and replay['bindings'] == 136
assert [r['name'] for r in replay['rows']] == ['unchanged-first-publication', 'changed-full-publication', 'missing-bound-fixture', 'exact-restoration']
assert [r['returncode'] == 0 for r in replay['rows']] == [True, False, False, True]
for row in replay['rows'][1:3]:
    assert b'AssertionError' in decode(row, 'stderr'), 'actual replay semantic denial'
assert replay['rows'][0]['stdout_base64'] == replay['rows'][3]['stdout_base64']

current = load(PREFIX + 'current.json')
assert current['producer_sha256'] == sha(read(PREFIX + 'current.py'))
original_population = {p: base64.b64decode(v, validate=True) for p, v in json.loads(gzip.decompress(frozen[OLD + 'population.json.gz'])).items()}
paths = checked(['find', 'docs/knowledge', 'docs/decisions', '-type', 'f', '-name', '*.md']).decode().splitlines()
assert sorted(paths) == sorted(original_population) and len(paths) == 1485
changed = sorted(p for p in paths if read(p) != original_population[p])
assert changed == current['changed_cards'] and len(changed) == 6
assert changed == json.loads(frozen[OLD + 'current.json'])['changed_cards']

def header_state(raw):
    lines = raw.decode().splitlines()
    if not lines or lines[0] != '---':
        return False, []
    owner, fact, orphan = None, False, []
    for number, line in enumerate(lines[1:], 2):
        if line.strip() == '---':
            break
        if re.match(r'^\s+-\s+', line):
            if owner is None:
                orphan.append(number)
            if owner == 'answers' and re.sub(r'^\s+-\s+', '', line).strip(' "'):
                fact = True
        elif re.match(r'^[A-Za-z_][A-Za-z0-9_]*:', line):
            key, value = line.split(':', 1)
            owner = key if not value.strip() else None
            if key == 'answers' and re.match(r'^\s*\[.*[A-Za-z0-9].*\]\s*$', value):
                fact = True
    return fact, orphan

facts = 0
for path in paths:
    raw = read(path)
    fact, orphan = header_state(raw)
    assert not orphan, ('final current header association', path, orphan)
    facts += fact
    assert current['inputs'][path] == sha(raw), ('complete current population', path)
    if path in changed:
        first = frozen[path]
        end = first.index(b'\n---\n', 4) + 5
        old_header, old_body = first[:end], first[end:]
        new_end = raw.index(b'\n---\n', 4) + 5
        expected = old_header.replace((OLD + 'publish-claim.py').encode(), (PREFIX + 'publish.py').encode())
        assert raw[:new_end] == expected and raw[new_end:].startswith(old_body), 'exact route/body lineage'
        assert old_header in raw[new_end:], 'complete first uncommitted header retained'
assert facts == 1349
for path, value in current['inputs'].items():
    assert sha(read(path)) == value, ('actual final current gate input', path)
assert current['returncode'] == 0 and not decode(current, 'stdout')
assert decode(current, 'stderr') == b'knowledge-map: OK (facts valid, ids unique, map in sync)\n'
allowed = set(changed) | {'KNOWLEDGE_MAP.md', 'docs/linkedspec-book/src/development/documentation-workflow.md'}
assert {p for p in frozen if read(p) != frozen[p]} == allowed, 'bounded first-candidate evolution'
for p in ('knowledge-map/scripts/check_knowledge_map.sh', 't/knowledge_map_header_lists.t'):
    assert read(p) == frozen[p], 'original repaired checker and unchanged fixture'

registration = load(PREFIX + 'registration-final.json')
assert registration['result'] == 'PASS'
assert registration['producer_sha256'] == sha(read(PREFIX + 'registration-final.py'))
for p, value in registration['inputs'].items():
    assert sha(read(p)) == value, ('registration dependency identity', p)
assert len(registration['commands']) == 2
for row in registration['commands']:
    assert row['returncode'] == 0 and not decode(row, 'stderr'), 'actual full registration proof channels'
audit = json.loads(decode(registration['commands'][0], 'stdout'))
assert audit['healthy_audit_guard'] == {'original_log_attempts': 0, 'tracked_write_attempts': 0}
assert b'PASS: 29 Perl allocators' in decode(registration['commands'][1], 'stdout')
assert audit['tracked_inputs'].items() <= registration['inputs'].items()
for source, expected in [('tools/run_ci_local.sh', registration['ci']), ('tools/test_perl_project_data_storage.sh', registration['storage'])]:
    assert expected['path'] == source and expected['current'] == sha(read(source))
    assert expected['knowledge_header_gate_owner'] == 'PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11'
    rows = [r for r in audit['audit_report']['governance_updates'] if r['path'] == source]
    assert rows == [expected], 'actual public recovery current normalization'

def module(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT / path)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    value.ROOT = ROOT
    return value

before = module('original_registration', PREFIX + 'auditor-before.py')
normalizer = module('final_registration', 'tests/language-readiness/verify_objectives.py')
assert read(PREFIX + 'auditor-before.py') == checked(['git', 'show', BASE + ':tests/language-readiness/verify_objectives.py'])
assert read(PREFIX + 'storage-before.sh') == checked(['git', 'show', BASE + ':tools/test_perl_project_data_storage.sh'])
ci = read('tools/run_ci_local.sh')
anchor, insertion = normalizer.KNOWLEDGE_HEADER_GATE_CI_INSERTIONS[0]
assert ci.count(anchor + insertion) == 1
assert ci.replace(anchor + insertion, anchor, 1) == checked(['git', 'show', BASE + ':tools/run_ci_local.sh'])
storage = read('tools/test_perl_project_data_storage.sh')
assert storage.replace(b'== 29 ))', b'== 28 ))', 1).replace(b'drifted from 29 to', b'drifted from 28 to', 1).replace(b' t/knowledge_map_header_lists.t; do', b'; do', 1).replace(b'PASS: 29 Perl allocators', b'PASS: 28 Perl allocators', 1) == read(PREFIX + 'storage-before.sh')
expected_names = ['original-CI-drift', 'original-storage-registration'] + ['CI/' + n for n in ('missing-block', 'duplicate-block', 'disabled-test', 'missing-tracked-input', 'wrong-tracked-input', 'unrelated-edit')] + ['storage/' + n for n in ('missing-owner', 'wrong-owner', 'old-count', 'wrong-diagnostic', 'duplicated-owner', 'unrelated-edit')]
assert [r['name'] for r in registration['controls']] == expected_names
for row in registration['controls']:
    raw = base64.b64decode(row['input_base64'], validate=True)
    assert sha(raw) == row['input_sha256']
    is_ci = row['source'] == 'tools/run_ci_local.sh'
    selected = before if row['name'].startswith('original-') else normalizer
    function = selected.verify_governance_evolution if is_ci else selected.verify_perl_storage_evolution
    historical = registration['ci' if is_ci else 'storage']['historical']
    try:
        function(row['source'], raw, historical)
    except ValueError as error:
        assert str(error) == row['reason'], ('registration semantic denial', row['name'], str(error))
    else:
        raise AssertionError('registration semantic denial missing: ' + row['name'])
for source, expected in [('tools/run_ci_local.sh', registration['ci']), ('tools/test_perl_project_data_storage.sh', registration['storage'])]:
    function = normalizer.verify_governance_evolution if source.endswith('run_ci_local.sh') else normalizer.verify_perl_storage_evolution
    assert function(source, read(source), expected['historical']) == expected

assert b'Complete book review PASS57+32/four actual controls' in checked(['python3', PREFIX + 'book-review.py'])
book = load(PREFIX + 'book-review.json')
assert book['source_count'] == 89 and book['actual_controls'] == 4
first_book = json.loads(frozen[OLD + 'book-review.json'])
assert set(first_book['source_inputs']) == set(book['source_inputs'])
assert [p for p in book['source_inputs'] if first_book['source_inputs'][p] != book['source_inputs'][p]] == ['docs/linkedspec-book/src/development/documentation-workflow.md']
inputs = set(frozen) | set(registration['inputs']) | set(book['source_inputs']) | set(changed)
inputs.update(p.relative_to(ROOT).as_posix() for p in (ROOT / PREFIX).iterdir() if p.is_file() and p.name not in ('review.json', 'evidence.json', 'publish.py', 'evidence.py'))
report = {'result': 'PASS', 'producer_sha256': sha(Path(__file__).read_bytes()),
    'frozen_bindings': 136, 'frozen_claim_bytes': 35512, 'original_callback_bindings': 534,
    'original_callback_claim_bytes': 123810, 'current_markdown': len(paths), 'current_facts': facts,
    'current_changed_cards': changed, 'registration_original_reds': 2, 'registration_denials': 12,
    'book_inputs': 89, 'book_controls': 4, 'replay_controls': 2,
    'inputs': {p: sha(read(p)) for p in sorted(inputs)},
    'scope': 'Final current source/card/map/book identities and exact historical registration inverses; actual full recovery and managed storage. The complete first uncommitted focused publication replays from frozen supplied bytes; original runtime/native/fault/evidence observations remain immutable. Canonical1 failure remains exact; a later exact staged canonical receipt is mandatory for landing. No runtime/private/parent admission or full YAML grammar claim.'}
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot final review'
    TARGET.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert load(PREFIX + 'review.json') == report, 'exact final review publication'
print('Final current Knowledge review PASS: original136/full35512; registration2 RED/12 denials; full1485/1349; book89/four')
