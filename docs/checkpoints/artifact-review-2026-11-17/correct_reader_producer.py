"""Bind the historical three-case result to the actual executed qualifier."""
import copy
import gzip
import json
from pathlib import Path
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
path = Path('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.37.json')
with tarfile.open(BASE / 'reader-producer-before.tar.gz', 'x:gz') as archive:
    for source in (BASE / 'correct_reader_producer.py', path):
        archive.add(source, arcname=str(source), recursive=False)
(BASE / 'reader-producer-stopped-normal.log.gz').write_bytes(gzip.compress(Path('.linkedspec-data/artifact-review-nov17-commit-retry.log').read_bytes(), mtime=0))
before = json.loads(path.read_bytes()); after = copy.deepcopy(before)
claim, = [c for c in after['claims'] if c['name'] == 'historical-helper-plan-reader-scope']
assert json.loads(Path('.linkedspec-data/artifact-review-nov17-plan-reader.log').read_bytes()) == json.loads(claim['rederive']['result'])
claim['rederive']['command'] = 'bash tools/run_python_project_data.sh docs/checkpoints/artifact-review-2026-11-17/qualify_plan_reader.py'
claim['scope'] += ' The producer command is its actual historical invocation and must not be replayed against the current tree. Readonly historical recovery uses docs/checkpoints/perl-helper-path-plan-2026-11-17/review.py.'
check = copy.deepcopy(after); restored, = [c for c in check['claims'] if c['name'] == claim['name']]
original, = [c for c in before['claims'] if c['name'] == claim['name']]
restored['rederive']['command'] = original['rederive']['command']; restored['scope'] = original['scope']
assert check == before
path.write_text(json.dumps(after, indent=2) + '\n')
(BASE / 'reader-producer-correction.json').write_text(json.dumps(dict(result='PASS', changed='historical reader actual producer command and explicit replay scope only',
    actual_result_matches_retained_outer_output=True, measured_values_and_proof_legs_unchanged=True), indent=2) + '\n')
print('PASS: actual historical producer command matches its retained result; readonly recovery remains separate')
