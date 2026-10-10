"""One-shot finite capacity publication after actual independent/evidence review."""
import base64
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
assert not TARGET.exists(), 'one-shot capacity claim already published'
spec = importlib.util.spec_from_file_location('finite_capacity', ROOT / (PREFIX + 'capacity.py'))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
result = m.command(['python3', PREFIX + 'capacity.py', 'final'])
m.save('final.json', result)
assert result['exit_code'] == 0 and result['stderr']['bytes'] == 0, result
assert b'Complete finite capacity review/evidence PASS' in base64.b64decode(result['stdout']['base64'])
plan = m.load('plan.json')
paths = set(plan['preserved']) | set(plan['resulting_inputs'])
paths.add('docs/knowledge/finite-engineering-notes-member-0131.md')
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
sha = lambda raw: hashlib.sha256(raw).hexdigest()
inputs = [{'path': p, 'sha256': sha((ROOT / p).read_bytes()),
           'role': 'producer' if Path(p).suffix in ('.py', '.pl') else 'input'} for p in sorted(paths)]
statement = ('One finite engineering-history member and exact manifest growth are independently verified. '
             'All220 prior immutable history/decision files remain exact; the production rollover archives '
             'only a complete clean-source suffix. Engineering notes measure46 files/29064 lines/3253190 '
             'bytes, manifest45 lines/27245 bytes, decisions132 files/13144 lines/971652 bytes. '
             'Thirty actual production threshold observations,23 accepted/indexed/exact-object authority '
             'REDs and three reviewer-corruption REDs/restored PASS verify this proposal. '
             'Exact staged canonical CI/receipt separately governs admission.')
data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'finite-engineering-history-member', 'statement': statement,
     'scope': 'Exactly one member, exact manifest line/byte overhead and sole ADR0131 decision overhead at clean cdc45f9cb. Existing root/aggregate/per-file and unrelated controls, prior immutable bytes, runtime/checker/dependency behavior stay unchanged. Focused evidence alone admits no capacity; canonical staged proof governs landing.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'capacity.py final. Apply/capture/evidence/publisher are retained one-shot writers, not resume entrypoints.',
                  'granularity': 'Every old immutable file; independently reconstructed clean-source record suffix and current root, every manifest field/row, sole exact ADR/index insertion and full registry object/byte comparison; actual complete current censuses and each of30/23 production observations; all actual reviewer channels and counterfactual bytes.', 'result': statement},
     'falsify': {'status': 'checked', 'hypothesis': 'Extra capacity could land without exact accepted/indexed authority, a boundary could admit excess usage, or preservation evidence could hide missing/altered history.',
                 'oracle': 'Unchanged production threshold/authority functions executed against actual current metrics and in-memory decision/index mutations; independent Git-backed full-byte reconstruction and actual reviewer subprocesses.',
                 'red_control': 'All five dimensions reject actual usage under old limits and reject new-limit-plus-one; exact new boundaries pass. Twenty-three actual authority denials distinguish missing new decision/index, proposed/missing/duplicate status, wrong old/new canonical limit/contract objects and unreviewed increases. Three actual reviewer subprocesses reject missing history membership, forged original hash and forged resulting registry hash; actual exact restoration passes.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-capacity-input-boundary',
     'statement': 'Original registry, index, manifest, current chronology roots and actual support sources remain bound to clean cdc45f9cb; no original measurement hash is refreshed.',
     'scope': 'Exactly nine original mutable/support input identities in the independent plan; unchanged immutable file identities are additionally live-gated by the first claim.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'capacity.py final',
                  'granularity': 'Each exact original Git blob identity and complete clean-source reconstruction.', 'result': 'All nine original input hashes match clean cdc45f9cb; prior history remains exact.'},
     'falsify': {'status': 'checked', 'hypothesis': 'Forged original identities could conceal altered source history.',
                 'oracle': 'Independent Git-backed population and original/current hash comparison.',
                 'red_control': 'Actual forged original-history hash fails the reviewer and exact original plan restoration passes; full channels retained.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': m.BASE,
                    'inputs': [{'path': p, 'sha256': h, 'role': 'input'} for p, h in sorted(plan['original_inputs'].items())]}}
]}
raw = (json.dumps(data, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded claim size', len(raw))
TARGET.write_bytes(raw)
print('Finite capacity claim published:', len(inputs), 'live/nine historical inputs;', len(raw), 'bytes.')
