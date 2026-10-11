"""Compose unchanged runtime, retained prior stages, and current public admissions."""
import base64
import gzip
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
BOOK = 'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md'
PUBLIC = 'tools/check_public_aggregate_selector_surface.py'
SCANNER = 'tools/check_executable_aggregate_selector_sources.py'
AUDITOR = 'tests/language-readiness/verify_objectives.py'
CARDS = {'docs/knowledge/perl-scalar-bound-receiver-copy.md',
         'docs/knowledge/perl-receiver-copy-canonical-selection.md'}
digest = lambda raw: hashlib.sha256(raw).hexdigest()
assert sys.argv[1:] in ([], ['--capture'])
packet = json.loads(gzip.decompress((HERE / 'before.json.gz').read_bytes()))
boundary = json.loads(gzip.decompress((HERE / 'census/before.json.gz').read_bytes()))
scanner = json.loads(gzip.decompress((HERE / 'census/scanner-before.json.gz').read_bytes()))
legacy_envelope = json.loads((HERE.parent / (LEAF + '-canonical/after.json')).read_bytes())
legacy = json.loads(gzip.decompress(base64.b64decode(legacy_envelope['data'])))
legacy_execution = json.loads(base64.b64decode(legacy['execution']['stdout_base64']))
draft = json.loads(gzip.decompress((HERE / 'census/audit-proof.json.gz').read_bytes()))
assert len(legacy['inputs']) == 192 and len(legacy_execution['tracked_inputs']) == 183
assert set(draft['inputs']) == set(legacy_execution['tracked_inputs'])
supplementary = sorted(set(legacy['inputs']) - set(draft['inputs']))
assert len(supplementary) == 9 and all(p.startswith(PREFIX + 'canonical/') or p == 'tools/project_data_run.sh' for p in supplementary)
projections = {
 'docs/linkedspec-book/src/overview/project-status.md': [
  (b'Its 36 classified historical references include\nthe constructor guide\'s explicit single-bare-value rejection.', b'Its 40 classified historical references include\nthe constructor guide and four rejected assignment/set-key/return examples.'),
  (b'70 public files and 36 explicitly classified', b'70 public files and 40 explicitly classified'),
  (b'is included in the current census.', b'and four rejected assignment/set-key/return examples are included in the current census.')],
 'capability_conformance/README.md': [
  (b'inventory is locked at 36 classified removed/history references and zero current examples. The constructor\nguide\'s explicit single-bare-value rejection is included in that inventory.', b'inventory is locked at 40 classified removed/history references and zero current examples. The constructor\nguide and four later rejected assignment/set-key/return examples are included.')],
 'ARCHITECTURE_STATE.md': [
  (b'The current census is 69/36/0, with zero executable selector positives.', b'The current public census is 70/40/0; executable selector admission is checked separately.')],
 'docs/knowledge/aggregate-selector-public-admission.md': [
  (b'current inventory is 36 classified', b'current inventory is 40 classified')],
}
checked = {}
changed = []
for path,row in packet['inputs'].items():
    original = base64.b64decode(row['data'], validate=True)
    assert digest(original) == row['sha256']
    current = (ROOT / path).read_bytes()
    if path in CARDS:
        before,after = original.splitlines(keepends=True),current.splitlines(keepends=True)
        assert len(before) == len(after)
        delta = [(a,b) for a,b in zip(before,after) if a != b]
        assert len(delta) == 1 and all(line.startswith(b'reverify: ') for line in delta[0])
        assert b'book-repair/review.py' in delta[0][1] and b'retained failed03' in delta[0][1]
    elif path == PUBLIC:
        assert original == base64.b64decode(boundary['mutable_before'][PUBLIC])
        assert current == original.replace(b'EXPECTED_CLASSIFIED_REFERENCE_COUNT = 36\n', b'EXPECTED_CLASSIFIED_REFERENCE_COUNT = 40\n', 1)
    elif path == SCANNER:
        assert original == base64.b64decode(scanner['scanner_base64'])
        # Exact registry-only source evolution and all51 denials are executed below.
    elif path == AUDITOR:
        assert original == base64.b64decode(json.loads(gzip.decompress((HERE / 'census/audit-before.json.gz').read_bytes()))['original_base64'])
        # Exact complete source evolution and the fresh isolated proof execute below.
    elif path in projections:
        expected = original
        for old,new in projections[path]:
            assert expected.count(old) == 1, 'projection anchor changed: ' + path
            expected = expected.replace(old,new,1)
        assert current == expected, 'foreign census projection change: ' + path
    elif path != BOOK:
        assert current == original, 'original runtime/CI/proof input changed: ' + path
    if current != original:
        changed.append(path)
    checked[path] = digest(current)
commands = [
 ['python3', PREFIX + 'review.py'],
 ['python3', PREFIX + 'book-repair/census/replay-first.py'],
 ['python3', PREFIX + 'book-repair/census/book-review.py'],
 ['python3', PREFIX + 'book-repair/census/proof.py'],
 ['python3', PREFIX + 'book-repair/census/scanner-proof.py'],
 ['python3', PREFIX + 'book-repair/census/audit-final-source.py'],
 ['python3', PREFIX + 'book-repair/census/audit-final.py'],
]
rows = []
for command in commands:
    result = subprocess.run(command, cwd=ROOT, capture_output=True,
                            env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'))
    rows.append({'command': command, 'returncode': result.returncode,
                 'stdout_base64': base64.b64encode(result.stdout).decode(),
                 'stderr_base64': base64.b64encode(result.stderr).decode()})
    assert result.returncode == 0, (command, result.stderr.decode())
book = json.loads((HERE / 'census/book-review.json').read_bytes())
assert book['source_count'] == 89 and book['actual_controls'] == 3
assert book['source_inputs'][BOOK] == checked[BOOK]
# Gate current proof inputs from the earlier composition. The final publication
# consumer is bound directly by its claim, rather than by the evidence it consumes.
first_claim = json.loads(base64.b64decode(boundary['claim_base64']))
for claim in first_claim['claims']:
    if claim['durability']['mode'] == 'live':
        for row in claim['durability']['inputs']:
            if row['path'] != (HERE / 'publish-claim.py').relative_to(ROOT).as_posix():
                checked[row['path']] = digest((ROOT / row['path']).read_bytes())
report = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
          'checked': dict(sorted(checked.items())), 'rows': rows,
          'original_live_declarations': 502, 'original_unique_inputs': 487,
          'initial_book_live_declarations': boundary['live_declarations'],
          'initial_book_unique_inputs': boundary['unique_inputs'],
          'changed_original_paths': sorted(changed), 'book_inputs': 89, 'book_controls': 3,
          'historical_capsule_supplementary_inputs': supplementary,
          'scope': 'Current runtime/native/source-fault/consumer inputs remain exact. Original failed03 final review/publications and the complete initial521-binding book composition replay from exact recoverable bytes. Current public checker changes only expected count36 to40; scanner changes only17 exact path/full-byte registry entries with51 denials. Only the synthetic AST prose, reverify pointers and explicitly checked census projections otherwise differ among original487 inputs. Current full book89/3 and source-bound public70/40/0, parent69/36, exact additions3+1 and actual census RED controls pass. Exact canonical receipt remains independently required.'}
target = HERE / 'review-final.json'
if sys.argv[1:]:
    assert not target.exists(), 'one-shot final composition'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report, 'final composed review drift'
print('Final composition PASS: exact runtime; original502 and first521 input replays; book89/3; public70/40/0; scanner17/27/51 strict denials')
