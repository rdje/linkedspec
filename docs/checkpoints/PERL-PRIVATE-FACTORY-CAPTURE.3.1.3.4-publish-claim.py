"""Readonly bounded capacity publication reconstruction; --capture writes once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '9085eb1e5075146ca00dab52304f85937cf7ea05'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
CLAIM = 'docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1.json'
OLD_PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1-publish-claim.py'
CARD = 'docs/knowledge/guarded-ast-change-history-capacity.md'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail)).read_bytes())


review = record('final-review.json')
plan = record('final-plan.json')
book = record('book-review.json')
preserved = record('preserve-review.json')
assert review['result'] == book['result'] == preserved['result'] == 'PASS'
assert (review['immutable_files'], review['production_threshold_cases'], review['production_authority_cases'], review['reviewer_controls']) == (222, 30, 23, 4)
assert review['historical_bindings_preserved'] == preserved['historical_bindings_preserved'] == 279
assert (review['book_sources'], review['book_controls']) == (89, 3)
assert plan['measured']['change_history'] == {'files': 49, 'lines': 51753, 'bytes': 3967760}
assert plan['measured']['decisions'] == {'files': 133, 'lines': 13180, 'bytes': 976282}
assert plan['measured']['manifest'] == {'lines': 48, 'bytes': 27407}
paths = set(plan['preserved']) | set(plan['resulting_inputs']) | set(review['checked']) | set(book['source_inputs'])
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
paths.update({CARD, 'docs/knowledge/perl-method-ast-call-capture.md'})
inputs = [{'path': path, 'sha256': digest((ROOT / path).read_bytes()),
           'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.t', '.sh') else 'input'} for path in sorted(paths)]
freeze = record('freeze.json')
before = (ROOT / freeze['before']).read_bytes()
assert before == subprocess.check_output(['git', 'show', BASE + ':' + CLAIM], cwd=ROOT)
old = json.loads(before)
assert sum(len(c['durability']['inputs']) for c in old['claims'] if c['durability']['mode'] == 'live') == 279
old_producer = subprocess.check_output(['git', 'show', BASE + ':' + OLD_PRODUCER], cwd=ROOT)
historical = [{'path': CLAIM, 'sha256': digest(before), 'role': 'input'},
              {'path': OLD_PRODUCER, 'sha256': digest(old_producer), 'role': 'producer'}]
statement = ('One finite change-history candidate admits49 files and manifest48 lines/27407 bytes, '
             'with decisions133 files/13180 lines accounting only for the new ADR/index row/separator. '
             'Exact clean-source suffix112 lines/27100 bytes and all222 prior immutable files survive. '
             'Production30 threshold/23 authority cases, four exact reviewer corruptions/restoration, '
             'original279-input corruption/restoration and full book89/3 pass. Accepted0130/0131 '
             'index rows move unchanged into the table. Initial pressure/source-blob/one-line metadata '
             'instruments and observations remain retained without refreshed hashes. Exact staged '
             'canonical receipt and normal hooks govern admission; no future reserve or runtime change.')
data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'guarded-ast-finite-change-history-capacity', 'statement': statement, 'scope': review['scope'],
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py. Defaults readonly; capture/freezer/repair and --capture publication are one-shot. Canonical admission separately requires tools/run_ci_local.sh for the exact staged candidate.',
                  'granularity': 'Every complete clean-source record/suffix/blob/range/hash,222 older immutable files and original manifest rows; five finite registry scalars; exact accepted index-row/prose transformation; actual budgets and complete production control population; every instrument/counterfactual/channel/reason; original279 binding and full89 book/include/rendered population.',
                  'result': statement},
     'falsify': {'status': 'checked',
                 'hypothesis': 'A rollover can lose accepted bytes, rewrite unrelated controls, hide displaced index rows, undercount physical overhead, accept unreviewed authority, refresh historical evidence or omit required inputs.',
                 'oracle': 'Independent Git clean-source record/suffix reconstruction and every prior byte identity; unchanged production numeric and accepted/indexed/exact-object authority functions; complete actual physical census and full expected JSON/row/registry transformations; same-volume supplied draft replay; complete source/counterfactual/channel hashes and rendered markers.',
                 'red_control': 'Actual initial pressure exits255 before rollover. Production controls retain actual13180 rejected at initial13179; final budgets include only the separating LF. Thirty threshold and23 authority cases distinguish old/new ceilings and missing/proposed/duplicate/mismatched authority. Four actual reviewer corruptions reject missing history, forged original/resulting hashes and displaced0131 with a rehashed plan; restoration passes. Actual original-binding corruption rejects beyond historical mode/revision. Initial uppercase matcher and stale source-blob REDs remain retained with actual producers/inputs/channels. Missing SUMMARY fails; removed teaching marker disappears; omitted include emits ERROR despite exit0.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-ast-call-boundary-preservation',
     'statement': 'All279 original AST-call live bindings and every proof/hash field remain exact; only the one live mode/revision changes to historical at9085eb1e5. The already historical hash-key preservation claim stays unchanged.',
     'scope': 'Complete original two-claim record and279 original live Git input identities. The original record retains its individually gated list; this compact claim binds that entire record and its actual final publisher. No AST-call runtime/book observation is refreshed.',
     'rederive': {'status': 'checked', 'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'preserve-review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py',
                  'granularity': 'Every original Git input and complete before/after JSON; mode/revision-only change.',
                  'result': 'All279 original hashes match clean9085eb1e5; full mode/revision comparison and actual corruption RED/restoration pass.'},
     'falsify': {'status': 'checked', 'hypothesis': 'A historical label can hide a refreshed or corrupted original binding.',
                 'oracle': 'Complete original Git record, every original input hash and exact allowed mode/revision transformation.',
                 'red_control': 'Actual first-binding all-zero SHA corruption fails beyond mode/revision; exact original bytes restore before readonly PASS. Full counterfactual and actual channels survive.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical}}
]}
raw = (json.dumps(data, indent=2) + '\n').encode()
assert len(raw) <= 131072, ('bounded claim exceeded', len(raw))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot claim publication'
    TARGET.write_bytes(raw)
else:
    assert TARGET.read_bytes() == raw, 'finite capacity publication drift'
print('Finite capacity publication PASS:', len(inputs), 'live inputs;', len(raw), 'bytes; original279 historical')
