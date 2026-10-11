"""Reconstruct a readonly reviewer repair; --apply is one-shot."""
import hashlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7-'
sha = lambda raw: hashlib.sha256(raw).hexdigest()
read = lambda path: (ROOT / path).read_bytes()
assert sys.argv[1:] in ([], ['--apply'])
source = read(PREFIX + 'draft-census-review.py').decode()
# Keep independent reconstruction and source-bound checks; retire applied writers.
start = source.index('def apply():\n')
end = source.index('def verify_preservation():\n', start)
source = source[:start] + source[end:]
start = source.index('def capture():\n')
end = source.index('def review():\n', start)
source = source[:start] + source[end:]
source = source[:source.index('def evidence():\n')]
source += "parser = argparse.ArgumentParser()\nparser.add_argument('mode', choices=['review'], nargs='?', default='review')\nif __name__ == '__main__':\n    review()\n"
old = "sha(Path(__file__).read_bytes())"
source = source.replace("expected['reviewer_sha256'] = " + old,
    "expected['reviewer_sha256'] = sha(read(PREFIX + 'draft-census-review.py'))", 1)
source = source.replace("plan['reviewer_sha256'] == " + old,
    "plan['reviewer_sha256'] == sha(read(PREFIX + 'draft-census-review.py'))", 1)
source = source.replace("'corrected reviewer identity'", "'first corrected reviewer identity retained'", 1)
assert source.count('    verify_census_repair(plan)\n') == 1
source = source.replace('    verify_census_repair(plan)\n', '', 1)
source = source.replace('    verify_preservation()\n', '    verify_census_repair(plan)\n    verify_preservation()\n', 1)
source = source.replace('Finite one-member admission. Default review is readonly; writers are one-shot.',
    'Readonly finite-member reconstruction. Original applied/draft producers remain retained.')
expected = source.encode()
target = ROOT / (PREFIX + 'capacity.py')
record = ROOT / (PREFIX + 'reviewer-repair.json')
report = {'producer_sha256': sha(Path(__file__).read_bytes()),
    'original_reviewer_sha256': sha(read(PREFIX + 'draft-census-review.py')),
    'original_plan_sha256': sha(read(PREFIX + 'plan.json')),
    'failed_reached_sha256': sha(read(PREFIX + 'draft-census-evidence-reached.json')),
    'failure_sha256': sha(read(PREFIX + 'reviewer-failure.json')),
    'current_reviewer_sha256': sha(expected),
    'scope': 'Retire original one-shot writer entrypoints from the current reviewer; keep full applied/draft source exact. '
        'Move correction equality after independent field checks so named counterfactual reasons remain reachable. '
        'The original plan remains exact and identifies the original applied and first census reviewer sources. '
        'No original observation/hash is refreshed; distinct current evidence capture follows.'}
if sys.argv[1:]:
    assert not record.exists() and target.read_bytes() == read(PREFIX + 'draft-census-review.py')
    target.write_bytes(expected)
    record.write_text(json.dumps(report, indent=2) + '\n')
else:
    assert target.read_bytes() == expected, 'exact readonly reviewer repair'
    assert json.loads(record.read_bytes()) == report
print('Readonly reviewer repair PASS; original plan/source/failed reached evidence exact')
