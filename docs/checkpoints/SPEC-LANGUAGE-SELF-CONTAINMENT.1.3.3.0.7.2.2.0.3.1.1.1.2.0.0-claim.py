"""Publish the bounded recovery claim with retained artifact byte identities."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0'
PREFIX = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0'
OLD = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0-'
paths = [
    PREFIX + '-crash.json', PREFIX + '-handoff.md', PREFIX + '-review.py',
    PREFIX + '-review.json', PREFIX + '-review-initial.py',
    PREFIX + '-review-initial-channels.json',
    OLD + 'before-SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1.json',
    OLD + 'freeze.json', OLD + 'preserve.py',
    'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1.json',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1-plan.json',
    'tools/run_python_project_data.sh', 'tools/project_data_env.sh',
    PREFIX + '-claim.py',
]
plan = json.loads((ROOT / paths[10]).read_bytes())
paths += list(plan['bounded_owners'])
inputs = [{'path': path, 'sha256': hashlib.sha256((ROOT / path).read_bytes()).hexdigest(),
           'role': 'producer' if path.endswith(('-review.py', '-claim.py', '-preserve.py')) else 'input'}
          for path in paths]
report = json.loads((ROOT / (PREFIX + '-review.json')).read_bytes())
assert report['result'] == 'PASS' and report['recovered_files'] == 8 and len(report['controls']) == 6
statement = ('All eight surviving changed files reconstruct byte-exact from the original '
             '58a11ae80cc55f8d19a0a7a4f0203ae491d11383 Git delta and four complete untracked '
             'payloads. All48 original claim bindings verify; only durability mode/revision '
             'change. Six reason-sensitive corruption controls observe RED before GREEN. '
             'Eight selected production owners equal original Git bytes; the unfinished '
             '205-line private emission draft is retained as evidence outside production.')
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'surviving-draft-recovery',
    'statement': statement,
    'scope': ('The original non-ignored dirty-file inventory only. Immutable activation Git '
              'supplies four tracked baseline files and the48 original historical inputs; '
              'their SHA256 identities are retained in the crash snapshot and original claim '
              'snapshot and rechecked by the reviewer. This does not recover process memory, '
              'lost conversation or unsaved editor buffers, and does not accept the draft, '
              'close the foundation or later repair, run Phase0/canonical CI, or push. '
              'The initially failed reviewer and complete actual captured channels remain '
              'inputs; only the corrected isolated-index/object-store reviewer supplies GREEN. '
              'No cross-host reproduction claim is made.'),
    'rederive': {'status': 'checked',
                 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + '-review.py; bash tools/run_python_project_data.sh ' + PREFIX + '-claim.py',
                 'granularity': 'Each surviving file, original tracked baseline, retained untracked payload, original historical binding, selected production owner and actual corruption failure reason.',
                 'result': statement},
    'falsify': {'status': 'checked',
                'hypothesis': 'An apparently complete handoff could drop or alter a surviving draft, substitute another activation, silently refresh a historical claim or leave unverified production installed.',
                'oracle': 'Immutable original Git blobs plus independently reconstructed private-index delta; original dirty-file inventory and historical claim hashes; byte-exact live production comparison.',
                'red_control': 'Observed named REDs: missing-survivor, foreign-activation, source-inverse, changed-draft, wrong-baseline and rehashed-foreign-freeze. The source inverse changes the actual invocation accessor in a valid patch and reaches the recovered-byte assertion.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs},
}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print('Recovery claim published:', len(inputs), 'retained artifact/producer inputs.')
