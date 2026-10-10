"""Compose readonly finite-capacity, historical-preservation, instrument and full-book proof."""
import base64
import copy
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4-'
INDEX = 'docs/decisions/INDEX.md'
REG = 'doctrine/readme_stability/routes.jsonl'
assert sys.argv[1:] in ([], ['--capture'])
checked = {}
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def read(path):
    raw = (ROOT / path).read_bytes()
    checked[path] = digest(raw)
    return raw


def record(tail):
    return json.loads(read(PREFIX + tail))


def channel(raw):
    return {'base64': base64.b64encode(raw).decode(), 'bytes': len(raw), 'sha256': digest(raw)}


plan = record('final-plan.json')
evidence = record('final-evidence.json')
assert evidence['producer_sha256'] == digest(read(PREFIX + 'final-capacity.py'))
assert evidence['plan_sha256'] == digest(read(PREFIX + 'final-plan.json'))
initial_controls = read(PREFIX + 'controls.pl')
assert initial_controls.count(b"'plan.json'") == 1
assert read(PREFIX + 'final-controls.pl') == initial_controls.replace(b"'plan.json'", b"'final-plan.json'")
names = ['missing_history_member', 'forged_original_hash', 'forged_resulting_hash', 'displaced_index_row']
reasons = ['complete prior immutable population', 'original immutable identity', 'resulting input identities',
           'sole indexed decision and exact accepted row placement']
assert len(evidence['rows']) == 4
original_index = read(INDEX)
for row, name, reason in zip(evidence['rows'], names, reasons):
    mutant = copy.deepcopy(plan)
    index_mutant = None
    if name == names[0]:
        del mutant['preserved'][next(iter(mutant['preserved']))]
    elif name == names[1]:
        mutant['preserved'][next(iter(mutant['preserved']))] = '0' * 64
    elif name == names[2]:
        mutant['resulting_inputs'][REG] = '0' * 64
    else:
        line = next(line for line in original_index.splitlines(keepends=True) if line.startswith(b'| [0131]('))
        displaced = original_index.replace(line, b'', 1) + line
        mutant['resulting_inputs'][INDEX] = digest(displaced)
        index_mutant = channel(displaced)
    assert row['name'] == name and row['reason'] == reason
    assert row['mutant'] == channel((json.dumps(mutant, indent=2) + '\n').encode()), 'exact evidence counterfactual'
    assert row['index_mutant'] == index_mutant
    observed = row['observed']
    assert observed['args'] == ['python3', PREFIX + 'final-capacity.py', 'review'] and observed['exit_code'] != 0
    for key in ('stdout', 'stderr'):
        assert observed[key] == channel(base64.b64decode(observed[key]['base64'], validate=True))
    assert reason.encode() in base64.b64decode(observed['stderr']['base64'])
rows = []
commands = [
    ['python3', PREFIX + 'final-capacity.py', 'final'],
    ['python3', PREFIX + 'preserve-review.py'],
    ['python3', PREFIX + 'preservation-control.py'],
    ['python3', PREFIX + 'draft-review.py'],
    ['python3', PREFIX + 'book-review.py'],
]
for command in commands:
    read(command[1])
    result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, PYTHONDONTWRITEBYTECODE='1'),
                            stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    rows.append({'command': command, 'returncode': result.returncode,
                 'stdout_base64': base64.b64encode(result.stdout).decode(),
                 'stderr_base64': base64.b64encode(result.stderr).decode()})
    assert result.returncode == 0 and not result.stderr, (command, result.stderr)
book = record('book-review.json')
assert book['result'] == 'PASS' and book['source_count'] == 89 and book['actual_controls'] == 3
preserved = record('preserve-review.json')
assert preserved['result'] == 'PASS' and preserved['historical_bindings_preserved'] == 279
for tail in ('draft-review.json', 'preservation-control.json', 'initial-metadata.json', 'plan.json', 'controls.json', 'final-controls.json', 'pressure.json', 'rollover.json', 'book.json', 'book.py'):
    read(PREFIX + tail)
report = {'result': 'PASS', 'producer_sha256': digest(Path(__file__).read_bytes()),
          'checked': dict(sorted(checked.items())), 'rows': rows,
          'immutable_files': len(plan['preserved']), 'production_threshold_cases': 30, 'production_authority_cases': 23,
          'reviewer_controls': 4, 'historical_bindings_preserved': 279,
          'book_sources': 89, 'book_controls': 3,
          'scope': 'Focused finite candidate proof only; exact staged canonical receipt governs admission. Independent clean-source/root/manifest/immutable-byte reconstruction, actual production threshold/authority controls, exact four evidence counterfactuals/rejections/restoration, original279 preservation/corruption, retained draft/applied/final instruments and complete book/include/rendered controls. Actual initial separator undercount remains retained; final measured budgets fit. No runtime or future-capacity admission follows.'}
target = ROOT / (PREFIX + 'final-review.json')
if sys.argv[1:]:
    assert not target.exists(), 'one-shot composed review'
    target.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert json.loads(target.read_bytes()) == report
print('Composed capacity review PASS222/30/23/4; original279 preserved; book89/3; canonical admission required')
