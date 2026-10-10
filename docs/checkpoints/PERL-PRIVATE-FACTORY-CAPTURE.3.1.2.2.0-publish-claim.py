"""Readonly publication reconstruction; --capture writes the first bounded claim once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '268891fdf948b1ccf875087416b62100e0ddc059'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
CARD = 'docs/knowledge/perl-method-local-return-capture.md'
OLD_PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-selector-rgx-finish.py'
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail)).read_bytes())


def expected():
    runtime, book, final, evidence = [record(tail + '.json') for tail in ('review', 'book-review', 'final-review', 'evidence')]
    preservation = record('preservation-control.json')
    assert runtime['result'] == book['result'] == final['result'] == evidence['result'] == 'PASS'
    assert runtime['assertions'] == 115 and runtime['cold_assertions'] == 4
    assert runtime['actual_caller_modes'] == 6 and runtime['required_callback_roles'] == 2
    assert runtime['paired_original_semantic_failures'] == 6 and runtime['paired_original_passing_controls'] == 109
    assert runtime['semantic_source_faults'] == 3 and runtime['consumer_suites'] == 35 and runtime['supplied_files'] == 154
    assert runtime['historical_bindings_preserved'] == 399
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
    assert len(historical_bindings) == 399
    old_producer = subprocess.check_output(['git', 'show', BASE + ':' + OLD_PRODUCER], cwd=ROOT)
    # The complete original record retains and gates all399 individual hashes.
    # Retain that record and its actual final publisher rather than duplicating
    # the399-row list into this new, separately scoped preservation claim.
    historical = [{'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'},
                  {'path': OLD_PRODUCER, 'sha256': digest(old_producer), 'role': 'producer'}]
    statement = ('One required local-return resolver passes115 main/four cold assertions and three effective '
                 'syntax-valid source faults. Two invoked roles/six native-current ledgers retain contexts, '
                 'shared parser arrays, count arguments, copies, effects/errors/public callbacks and payload guards. '
                 'The same complete115 assertion names have exactly6 original publication-isolation REDs,109 '
                 'original passing controls and115 current GREEN. Supplied35 suites/154 files, five reviewer REDs, '
                 'original-binding RED/restoration and complete book57+32/three controls pass. '
                 'All399 original capacity/audit live bindings remain historical without refreshing measurements.')
    return {'version': 1, 'owner': LEAF, 'claims': [
        {'name': 'method-required-local-return-isolation', 'statement': statement, 'scope': runtime['scope'],
         'rederive': {'status': 'checked',
                      'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py; bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py. Defaults are readonly; --capture and capture/freezer scripts are one-shot writers.',
                      'granularity': 'Both actual callback roles and six complete native/current rows; identical115 assertion names and exact6-failure set; every source-fault plan, supplied input, actual evidence counterfactual/channel/reason, original binding and complete book/include/rendered marker population.',
                      'result': statement},
         'falsify': {'status': 'checked',
                     'hypothesis': 'A parser/normalizer can donate publication, a private wrapper can replace actual identity, native caller behavior can change, or incomplete/corrupt evidence can masquerade as acceptance.',
                     'oracle': 'Clean-Git/current same-fixture assertion names and complete native ledgers; actual eligible-call identity and parent packet retrieval; shared parser-returned argument arrays, count arguments, public callbacks, exact native context/copy/error/fatal/effect controls; source/population/channel hashes and rendered teaching markers.',
                     'red_control': 'Exactly6 original isolation REDs turn GREEN while109 original controls pass. Independent boundary removal, wrapper substitution and required-validation removal produce syntax-valid complete115-assertion semantic REDs. Five actual evidence corruptions reject failed positive, missing reader input, omitted inverse, altered semantic text with rehashed index and missing consumer capture, then restore PASS. Original-binding hash corruption rejects beyond mode/revision and restores. Missing SUMMARY fails; removed teaching text disappears from HTML; omitted include produces ERROR despite exit0.'},
         'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
        {'name': 'original-capacity-audit-boundary-preservation',
         'statement': 'All399 original live capacity/audit input bindings and every proof/hash field remain exact. Only the two original live durability mode/revision fields change to historical at268891fdf; both already historical claims remain unchanged.',
         'scope': 'Exactly the complete accepted original four-claim record and399 original live input identities at268891fdf. The historical original record retains its individually gated input list; this compact claim binds the complete record and its actual final publisher. This preserves historical evidence without refreshing capacity, audit, runtime or book measurements.',
         'rederive': {'status': 'checked',
                      'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py',
                      'granularity': 'Every original Git-bound input and full before/after JSON; only the two original live mode/revision fields may differ. Original historical fields and399 original hashes stay exact.',
                      'result': 'All399 individual original input identities match clean268891fdf; complete mode/revision-only comparison and actual original-binding RED/restoration pass.'},
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
    assert TARGET.read_bytes() == serialized, 'local-return publication drift'
print('Local return publication PASS:', len(data['claims'][0]['durability']['inputs']),
      'live; original399 preserved through two historical inputs;', len(serialized), 'bytes')
