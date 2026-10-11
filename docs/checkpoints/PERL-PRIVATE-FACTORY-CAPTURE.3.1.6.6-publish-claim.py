"""Bounded finite admission claim. Default readonly; --capture is one-shot."""
import base64
import hashlib
import importlib.util
import json
import sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
assert sys.argv[1:] in ([], ['--capture'])
spec = importlib.util.spec_from_file_location('capacity', ROOT / (PREFIX + 'capacity.py'))
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
result = m.command(['python3', PREFIX + 'review.py'])
assert result['exit_code'] == 0 and result['stderr']['bytes'] == 0, result
if sys.argv[1:]:
    assert not TARGET.exists() and not (ROOT / (PREFIX + 'final.json')).exists(), 'one-shot publication'
    m.save('final.json', result)
else:
    assert m.load('final.json') == result, 'actual full readonly review'
plan = m.load('plan.json')
book = m.load('book-review.json')
paths = set(plan['preserved']) | set(plan['resulting_inputs']) | set(book['source_inputs'])
paths.add('docs/knowledge/finite-engineering-notes-member-0131.md')
paths.add('docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2.json')
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
inputs = [{'path': p, 'sha256': m.sha(m.read(p)), 'role': 'producer' if Path(p).suffix in ('.py', '.pl') else 'input'} for p in sorted(paths)]
assert len(plan['preserved']) == 224 and plan['measured'] == {
    'engineering_notes': {'files': 47, 'lines': 29361, 'bytes': 3280501},
    'decisions': {'files': 134, 'lines': 13215, 'bytes': 980960},
    'manifest': {'lines': 46, 'bytes': 27857}}, 'current claim granularity'
statement = ('One finite engineering-history member and exact manifest/decision overhead are independently verified at clean d8418423e. '
             'All224 prior immutable history/decision files remain exact; the production rollover archives only a complete clean-source suffix as segment4961. '
             'Engineering notes47 files/29361 lines/3280501 bytes, manifest46 lines/27857 bytes and decisions134 files/13215 lines/980960 bytes are rederived. '
             'Actual next-record464-line/59032-byte pressure and old admission REDs,30 production threshold observations,23 accepted/indexed/exact-object authority denials, '
             'three reviewer-corruption REDs/each restored PASS and full book89 inputs/three actual controls verify the finite proposal. '
             'All337 accepted scalar input bindings are preserved historically with exact original claim fields; two beyond-immediate-hash preservation REDs restore exactly. '
             'Existing capacity card body/questions remain exact with three new questions; no Knowledge slot is added. Exact staged canonical CI/receipt separately governs admission.')
data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'finite-engineering-history-member', 'statement': statement,
     'scope': 'Exactly one member,612 manifest bytes/one line and sole ADR0133/index35-line overhead. No future reserve; root/aggregate/per-file and unrelated limits, prior immutable bytes, runtime/checker/dependency behavior remain unchanged. Actual old routing gate rejects archive files and manifest lines/bytes; actual production-function controls additionally cover decision files/lines. Authority controls use actual unchanged functions with in-memory ADR/index faults; exact staged canonical proof separately governs admission. Book sources57 plus32 recursive includes are supplied on repository volume; executable is read-only reused with no cross-version HTML claim.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py (readonly default); review.py, capacity.py final, book-review.py and preservation-controls.py are readonly. Apply/capture/evidence/freezer and --capture writers are one-shot, not resume entrypoints.',
                  'granularity': 'Each224 prior immutable file; entire clean-Git suffix/blob/line range/digest/path and current root; every prior manifest row and exact new header/row; sole indexed ADR and full registry byte comparison; each30/23 production control, three reviewer and two preservation counterfactual populations/full channels; all337 historical hashes; full89 book/config/include inputs and three actual rendered controls; original existing card body/all questions.', 'result': statement},
     'falsify': {'status': 'checked', 'hypothesis': 'Extra capacity might pass without exact accepted/indexed authority, excess usage might fit, or omitted/forged history and scalar proof could hide behind refreshed immediate SHA metadata.',
                 'oracle': 'Independent Git-backed complete-source reconstruction, exact old/current object comparison, actual unchanged production threshold/authority functions, actual reviewer subprocesses, preserved original scalar claim and full recursive book/rendered prose controls.',
                 'red_control': 'Actual next-note --check fails; old production routing rejects47/46 files,46/45 manifest lines and27857/27245 bytes. All five production dimensions reject old-bound actual usage and new-limit-plus-one, passing exact new boundaries. Twenty-three authority denials reject missing ADR/index, proposed/missing/duplicate status, wrong old/new objects and unreviewed increase. Three reviewer subprocesses reject missing history member and forged original/resulting hashes. Two scalar preservation controls reject original binding/statement corruption beyond updated immediate metadata; each exact restoration passes. Book rejects missing SUMMARY, loses changed prose in HTML, and diagnoses missing include despite exit0. Every reached channel and changed byte is retained before assertions.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-capacity-input-boundary',
     'statement': 'All nine original mutable/support hashes remain bound to clean d8418423e; no original identity is refreshed.',
     'scope': 'Original registry/index/manifest/chronology roots and actual support sources in the plan; old immutable population additionally live-gated above.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'capacity.py final', 'granularity': 'Every exact original Git blob and complete source suffix.', 'result': 'Nine original inputs match Git; all224 prior immutable files remain exact.'},
     'falsify': {'status': 'checked', 'hypothesis': 'Forged original history could conceal changed source.', 'oracle': 'Independent Git original/current byte reconstruction.', 'red_control': 'Actual forged original hash rejects; exact restoration passes with complete channels.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': m.BASE, 'inputs': [{'path': p, 'sha256': h, 'role': 'input'} for p,h in sorted(plan['original_inputs'].items())]}},
    {'name': 'original-scalar-publication-boundary',
     'statement': 'All337 predecessor live hashes and original proof/claim fields remain exact; only its one live mode/revision becomes historical at d8418423e.',
     'scope': 'Full original scalar claim retained and337 referenced inputs independently checked against accepted Git. Existing historical array-boundary record unchanged; no runtime, CI or book observation refreshed.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-controls.py', 'granularity': 'Full original claim, all337 referenced Git hashes and exact mode/revision-only conversion.', 'result': '337 original bindings and claim fields retained exactly.'},
     'falsify': {'status': 'checked', 'hypothesis': 'Updated immediate SHA metadata might conceal original-binding or statement drift.', 'oracle': 'Accepted Git full claim and exact JSON equality allowing only mode/revision.', 'red_control': 'Two actual reviewer REDs reject altered original binding/preserved statement after immediate SHA updates; each exact restoration passes.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': m.BASE, 'inputs': [{'path': 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2.json', 'sha256': m.sha(m.old('docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2.json')), 'role': 'input'}]}}
]}
raw = (json.dumps(data, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded claim size', len(raw))
if sys.argv[1:]: TARGET.write_bytes(raw)
else: assert TARGET.read_bytes() == raw, 'publication/inputs drift'
print('Finite admission claim PASS:', len(inputs), 'live inputs;', len(raw), 'bytes; readonly reconstruction')
