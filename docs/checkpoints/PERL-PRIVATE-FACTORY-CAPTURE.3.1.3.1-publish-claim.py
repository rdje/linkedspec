"""Readonly publication reconstruction; --capture writes the first bounded claim once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '2e9e5443ea38789fe454ee7ee24a68be81d4546c'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
CARD = 'docs/knowledge/perl-method-ast-call-capture.md'
OLD_PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0-publish-claim.py'
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail)).read_bytes())


def expected():
    runtime, book, final, evidence = [record(tail + '.json') for tail in ('review', 'book-review', 'final-review', 'evidence')]
    preservation = record('preservation-control.json')
    assert runtime['result'] == book['result'] == final['result'] == evidence['result'] == 'PASS'
    assert runtime['assertions'] == 695 and runtime['cold_assertions'] == 12
    assert runtime['actual_caller_modes'] == 18 and runtime['required_callback_roles'] == 6
    assert runtime['bounded_branch_modes'] == 44 and runtime['actually_invoked_roles'] == 6 and runtime['validated_only_roles'] == 0
    assert runtime['paired_original_semantic_failures'] == 18 and runtime['paired_original_passing_controls'] == 677
    assert runtime['semantic_source_faults'] == 3 and runtime['consumer_suites'] == 41 and runtime['supplied_files'] == 160
    assert runtime['historical_bindings_preserved'] == 280
    assert book['source_count'] == 89 and book['book_source_count'] == 57 and book['include_source_count'] == 32
    assert book['actual_controls'] == 3 and len(evidence['rows']) == 5
    assert preservation['unchanged'] is True and preservation['red']['returncode'] != 0 and preservation['restored']['returncode'] == 0
    paths = set(runtime['checked']) | set(book['source_inputs']) | set(final['checked']) | {CARD}
    paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
    inputs = [{'path': path, 'sha256': digest((ROOT / path).read_bytes()),
               'role': 'producer' if Path(path).suffix in ('.py', '.pm', '.t') else 'input'} for path in sorted(paths)]
    freeze = record('freeze.json')
    before = (ROOT / freeze['before']).read_bytes()
    assert before == subprocess.check_output(['git', 'show', BASE + ':' + freeze['claim']], cwd=ROOT)
    original = json.loads(before)
    historical_bindings = [entry for claim in original['claims'] if claim['durability'].get('mode') == 'live'
                           for entry in claim['durability']['inputs']]
    assert len(historical_bindings) == 280
    old_producer = subprocess.check_output(['git', 'show', BASE + ':' + OLD_PRODUCER], cwd=ROOT)
    # The complete original record retains and gates all280 individual hashes.
    # Retain that record and its actual final publisher rather than duplicating
    # the280-row list into this new, separately scoped preservation claim.
    historical = [{'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'},
                  {'path': OLD_PRODUCER, 'sha256': digest(old_producer), 'role': 'producer'}]
    statement = ('One AST call-statement required resolver/six invoked roles passes695 main/12 cold assertions '
                 'and three syntax-valid effective source faults. Eighteen native-current callback ledgers and44 '
                 'bounded branch ledgers retain actual eager/lazy guard order, scalar contexts, source-helper '
                 'ARRAY identity, trim source slots/scoped copies, return-payload slice aliases, local scalar '
                 'copies, effects/errors/fatal identities/public callbacks and native branch fallback. '
                 'Identical695 assertion names retain18 original isolation REDs/677 passing controls/all695 '
                 'current GREEN. Supplied41 suites/160 files, five reviewer REDs/restoration, original-binding '
                 'RED/restoration and full book57+32/three controls pass. All280 original hash-key bindings '
                 'remain historical without refreshing any original proof/hash field.')
    return {'version': 1, 'owner': LEAF, 'claims': [
        {'name': 'method-required-ast-call-isolation', 'statement': statement, 'scope': runtime['scope'],
         'rederive': {'status': 'checked',
                      'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py; bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py. Defaults are readonly; --capture and capture/freezer scripts are one-shot writers.',
                      'granularity': 'Six actually invoked roles/eighteen full native-current rows and44 controlled branch rows; identical695 assertion names/exact18-failure set, every complete source-fault plan, supplied input, actual evidence counterfactual/channel/reason, original280 binding and full book/include/rendered-marker population.',
                      'result': statement},
         'falsify': {'status': 'checked',
                     'hypothesis': 'A required AST call callback can donate nested publication, wrapper identity can replace the actual callback, native eager/lazy guard/context/alias/copy/error/fallback behavior can change, or incomplete evidence can masquerade as acceptance.',
                     'oracle': 'Clean-Git/current identical fixture names and complete native ledgers; actual eligible-call identity/parent packet retrieval, source-helper ARRAY/source-slot/scoped-copy/local-scalar and fatal/public-callback/helper/map/span references, native branch output/count/guard/fallback controls, source/population/channel hashes and rendered teaching markers.',
                     'red_control': 'Exactly18 original isolation REDs turn GREEN while677 controls pass. Boundary removal, actual-to-wrapper substitution and required-validation removal each produce syntax-valid complete695-assertion named semantic REDs. Five actual evidence corruptions reject failed positive, missing reader input, omitted inverse, altered semantic text with rehashed index and missing consumer capture; exact restoration obtains PASS. Original-binding hash corruption rejects beyond mode/revision and restores. Missing SUMMARY fails; removed teaching text disappears from HTML; omitted include produces ERROR despite exit0.'},
         'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
        {'name': 'original-ast-hash-key-boundary-preservation',
         'statement': 'All280 original live hash-key input bindings and every proof/hash field remain exact. Only the one original live durability mode/revision changes to historical at 2e9e5443e; the already historical block-value preservation claim remains unchanged.',
         'scope': 'Exactly the complete accepted original two-claim record and280 original live input identities at 2e9e5443e. The historical original record retains its individually gated input list; this compact claim binds the complete record and its actual final publisher. This preserves historical evidence without refreshing hash-key runtime or book measurements.',
         'rederive': {'status': 'checked',
                      'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py',
                      'granularity': 'Every original Git-bound input and full before/after JSON; only the one original live mode/revision may differ. Original historical fields and280 original hashes stay exact.',
                      'result': 'All280 individual original input identities match clean2e9e5443e; complete mode/revision-only comparison and actual original-binding RED/restoration pass.'},
         'falsify': {'status': 'checked', 'hypothesis': 'A historical-mode label can hide a refreshed or corrupted original input binding.',
                     'oracle': 'Complete original claim recovered from clean Git, every original Git input hash and exact mode/revision-only JSON comparison.',
                     'red_control': 'Actual first-original-binding all-zero SHA corruption fails beyond mode/revision. Original bytes restore before actual readonly PASS. Full counterfactual and actual channels are retained.'},
         'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical}}
    ]}


data = expected()
serialized = (json.dumps(data, indent=2) + '\n').encode()
assert len(serialized) <= 131072, ('claim exceeds bounded size', len(serialized))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot claim already published'
    TARGET.write_bytes(serialized)
else:
    assert TARGET.read_bytes() == serialized, 'AST call publication drift'
print('AST call publication PASS:', len(data['claims'][0]['durability']['inputs']),
      'live; original280 preserved through two historical inputs;', len(serialized), 'bytes')
