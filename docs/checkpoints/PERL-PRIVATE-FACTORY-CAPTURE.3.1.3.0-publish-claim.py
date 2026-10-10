"""Readonly publication reconstruction; --capture writes the first bounded claim once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'b50ce085a63c8777973bc4c4e4a999a8840c462b'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
CARD = 'docs/knowledge/perl-method-ast-hash-key-capture.md'
OLD_PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1-publish-claim.py'
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail)).read_bytes())


def expected():
    runtime, book, final, evidence = [record(tail + '.json') for tail in ('review', 'book-review', 'final-review', 'evidence')]
    preservation = record('preservation-control.json')
    assert runtime['result'] == book['result'] == final['result'] == evidence['result'] == 'PASS'
    assert runtime['assertions'] == 171 and runtime['cold_assertions'] == 4
    assert runtime['actual_caller_modes'] == 3 and runtime['required_callback_roles'] == 1
    assert runtime['bounded_branch_modes'] == 15 and runtime['actually_invoked_roles'] == 1 and runtime['validated_only_roles'] == 0
    assert runtime['paired_original_semantic_failures'] == 3 and runtime['paired_original_passing_controls'] == 168
    assert runtime['semantic_source_faults'] == 3 and runtime['consumer_suites'] == 39 and runtime['supplied_files'] == 158
    assert runtime['historical_bindings_preserved'] == 275
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
    assert len(historical_bindings) == 275
    old_producer = subprocess.check_output(['git', 'show', BASE + ':' + OLD_PRODUCER], cwd=ROOT)
    # The complete original record retains and gates all275 individual hashes.
    # Retain that record and its actual final publisher rather than duplicating
    # the275-row list into this new, separately scoped preservation claim.
    historical = [{'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'},
                  {'path': OLD_PRODUCER, 'sha256': digest(old_producer), 'role': 'producer'}]
    statement = ('One guarded scalar-held hash-index key required resolver passes171 main/four cold assertions '
                 'and three syntax-valid effective source faults. Three native-current callback ledgers and15 '
                 'bounded branch ledgers retain scalar context/copy/effects/errors/fatal identity/public callbacks, '
                 'actual pre-validation node/target guards, source fallback and zero/reference lowered-value '
                 'handoff under explicit secondary controls. Identical171 assertion names retain3 original '
                 'isolation REDs/168 original passing controls/all171 current GREEN. Supplied39 suites/158 files, '
                 'five reviewer REDs/restoration, original-binding RED/restoration and full book57+32/three '
                 'controls pass. All275 original block-value live bindings remain historical. Draft producer '
                 'and both original results are retained; only its stale header/hash changes before exact recapture.')
    return {'version': 1, 'owner': LEAF, 'claims': [
        {'name': 'method-required-ast-hash-key-isolation', 'statement': statement, 'scope': runtime['scope'],
         'rederive': {'status': 'checked',
                      'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py; bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py. Defaults are readonly; --capture and capture/freezer scripts are one-shot writers.',
                      'granularity': 'One actually invoked callback/three full native-current rows and fifteen controlled branch rows; identical171 assertion names/exact3-failure set, every complete source-fault plan, supplied input, actual evidence counterfactual/channel/reason, original275 binding, draft/final baseline row and full book/include/rendered-marker population.',
                      'result': statement},
         'falsify': {'status': 'checked',
                     'hypothesis': 'A key callback can donate nested publication, a private wrapper can replace actual identity, native guard/source-fallback/context/copy/error/value behavior can change, or incomplete evidence can masquerade as acceptance.',
                     'oracle': 'Clean-Git/current identical fixture names and complete native ledgers; actual eligible-call identity and parent packet retrieval, copied key-source scalar and actual AST/public callback/helper references, explicit native source/output/zero/reference controls, source/population/channel hashes and rendered teaching markers. Draft/current producer differs only by stale header; both baseline rows otherwise compare exactly.',
                     'red_control': 'Exactly3 original isolation REDs turn GREEN while168 controls pass. Boundary removal, actual-to-wrapper substitution and required-validation removal each produce syntax-valid complete171-assertion named semantic REDs. Five actual evidence corruptions reject failed positive, missing reader input, omitted inverse, altered semantic text with rehashed index and missing consumer capture; exact restoration obtains PASS. Original-binding hash corruption rejects beyond mode/revision and restores. Missing SUMMARY fails; removed teaching text disappears from HTML; omitted include produces ERROR despite exit0.'},
         'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
        {'name': 'original-block-value-boundary-preservation',
         'statement': 'All275 original live block-value input bindings and every proof/hash field remain exact. Only the one original live durability mode/revision changes to historical at b50ce085a; the already historical local-return preservation claim remains unchanged.',
         'scope': 'Exactly the complete accepted original two-claim record and275 original live input identities at b50ce085a. The historical original record retains its individually gated input list; this compact claim binds the complete record and its actual final publisher. This preserves historical evidence without refreshing block-value runtime or book measurements.',
         'rederive': {'status': 'checked',
                      'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py',
                      'granularity': 'Every original Git-bound input and full before/after JSON; only the one original live mode/revision may differ. Original historical fields and275 original hashes stay exact.',
                      'result': 'All275 individual original input identities match cleanb50ce085a; complete mode/revision-only comparison and actual original-binding RED/restoration pass.'},
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
    assert TARGET.read_bytes() == serialized, 'guarded hash key publication drift'
print('Guarded hash key publication PASS:', len(data['claims'][0]['durability']['inputs']),
      'live; original275 preserved through two historical inputs;', len(serialized), 'bytes')
