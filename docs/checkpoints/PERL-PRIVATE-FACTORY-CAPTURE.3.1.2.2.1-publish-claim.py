"""Readonly publication reconstruction; --capture writes the first bounded claim once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'de3b50dd06d4aff6babf379282f90368810d49e5'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
CARD = 'docs/knowledge/perl-method-block-value-capture.md'
OLD_PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0-publish-claim.py'
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail)).read_bytes())


def expected():
    runtime, book, final, evidence = [record(tail + '.json') for tail in ('review', 'book-review', 'final-review', 'evidence')]
    preservation = record('preservation-control.json')
    assert runtime['result'] == book['result'] == final['result'] == evidence['result'] == 'PASS'
    assert runtime['assertions'] == 222 and runtime['cold_assertions'] == 5
    assert runtime['actual_caller_modes'] == 9 and runtime['required_callback_roles'] == 4
    assert runtime['bounded_branch_modes'] == 16 and runtime['actually_invoked_roles'] == 3 and runtime['validated_only_roles'] == 1
    assert runtime['paired_original_semantic_failures'] == 9 and runtime['paired_original_passing_controls'] == 213
    assert runtime['semantic_source_faults'] == 3 and runtime['consumer_suites'] == 37 and runtime['supplied_files'] == 156
    assert runtime['historical_bindings_preserved'] == 273
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
    assert len(historical_bindings) == 273
    old_producer = subprocess.check_output(['git', 'show', BASE + ':' + OLD_PRODUCER], cwd=ROOT)
    # The complete original record retains and gates all273 individual hashes.
    # Retain that record and its actual final publisher rather than duplicating
    # the273-row list into this new, separately scoped preservation claim.
    historical = [{'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'},
                  {'path': OLD_PRODUCER, 'sha256': digest(old_producer), 'role': 'producer'}]
    statement = ('One required block-value resolver passes222 main/five cold assertions and three syntax-valid '
                 'effective source faults. Trim/split/parse supply nine native-current callback ledgers; the '
                 'normalizer is locally validated only. Sixteen bounded AST/copied-bridge/early-result/fallback '
                 'ledgers retain actual caller behavior under explicit secondary-helper controls; three generated '
                 'blocks have independent Perl execution value/effect oracles. The complete222 assertion names '
                 'have exactly9 original isolation REDs,213 original passing controls and222 current GREEN. '
                 'Supplied37 suites/156 files, five reviewer REDs, original-binding RED/restoration and complete '
                 'book57+32/three controls pass. All273 original local-return live bindings stay historical '
                 'without refreshing any original measurement.')
    return {'version': 1, 'owner': LEAF, 'claims': [
        {'name': 'method-required-block-value-isolation', 'statement': statement, 'scope': runtime['scope'],
         'rederive': {'status': 'checked',
                      'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py; bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py. Defaults are readonly; --capture and capture/freezer scripts are one-shot writers.',
                      'granularity': 'Three invoked callback roles/nine complete native-current rows, one locally validated-only role and sixteen controlled branch rows; identical222 assertion names and exact9-failure set; every source-fault plan, supplied input, actual evidence counterfactual/channel/reason, original binding and complete book/include/rendered marker population.',
                      'result': statement},
         'falsify': {'status': 'checked',
                     'hypothesis': 'A trim/split/parse callback can donate publication, a private wrapper can replace actual identity, native caller behavior can change, or incomplete/corrupt evidence can masquerade as acceptance.',
                     'oracle': 'Clean-Git/current same-fixture assertion names and complete native ledgers; actual eligible-call identity and parent packet retrieval; actual split-array slot aliases, copied bridge map, zero/reference early results, independent controlled generated-guard execution, public callbacks, exact native context/copy/error/fatal/effect controls; source/population/channel hashes and rendered teaching markers.',
                     'red_control': 'Exactly9 original isolation REDs turn GREEN while213 original controls pass. Exactly one trim publication avoids multiple-publication ambiguity masking. Independent boundary removal, wrapper substitution and required-validation removal produce syntax-valid complete222-assertion semantic REDs. Five actual evidence corruptions reject failed positive, missing reader input, omitted inverse, altered semantic text with rehashed index and missing consumer capture, then restore PASS. Original-binding hash corruption rejects beyond mode/revision and restores. Missing SUMMARY fails; removed teaching text disappears from HTML; omitted include produces ERROR despite exit0.'},
         'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
        {'name': 'original-local-return-boundary-preservation',
         'statement': 'All273 original live local-return input bindings and every proof/hash field remain exact. Only the one original live durability mode/revision changes to historical at de3b50dd; the already historical preservation claim remains unchanged.',
         'scope': 'Exactly the complete accepted original two-claim record and273 original live input identities at de3b50dd. The historical original record retains its individually gated input list; this compact claim binds the complete record and its actual final publisher. This preserves historical evidence without refreshing local-return runtime or book measurements.',
         'rederive': {'status': 'checked',
                      'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py',
                      'granularity': 'Every original Git-bound input and full before/after JSON; only the one original live mode/revision may differ. Original historical fields and273 original hashes stay exact.',
                      'result': 'All273 individual original input identities match cleande3b50dd; complete mode/revision-only comparison and actual original-binding RED/restoration pass.'},
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
    assert TARGET.read_bytes() == serialized, 'block-value publication drift'
print('Block value publication PASS:', len(data['claims'][0]['durability']['inputs']),
      'live; original273 preserved through two historical inputs;', len(serialized), 'bytes')
