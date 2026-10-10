"""Readonly bounded publication reconstruction; --capture publishes once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '4fde89c1958faf4057ab80eb7e7cd50962c7ac3c'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
CARD = 'docs/knowledge/perl-method-ast-assignment-capture.md'
OLD_PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2-publish-claim.py'
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail)).read_bytes())


def expected():
    runtime, book, final, evidence = [record(t + '.json') for t in ('review', 'book-review', 'final-review', 'evidence')]
    preservation = record('preservation-control.json')
    initial = record('initial-control-review.json')
    assert runtime['result'] == book['result'] == final['result'] == evidence['result'] == 'PASS'
    assert runtime['assertions'] == 864 and runtime['cold_assertions'] == 8
    assert runtime['actual_caller_modes'] == 3 and runtime['bounded_branch_modes'] == 66
    assert runtime['required_callers'] == runtime['required_callback_roles'] == runtime['actually_invoked_roles'] == 1
    assert runtime['validated_only_roles'] == 0
    assert runtime['paired_original_semantic_failures'] == 3 and runtime['paired_original_passing_controls'] == 861
    assert runtime['semantic_source_faults'] == 3 and runtime['consumer_suites'] == 46 and runtime['supplied_files'] == 166
    assert runtime['historical_bindings_preserved'] == 283
    assert book['source_count'] == 89 and book['book_source_count'] == 57 and book['include_source_count'] == 32
    assert book['actual_controls'] == 3 and len(evidence['rows']) == 5 and len(final['rows']) == 4
    assert preservation['unchanged'] is True and preservation['red']['returncode'] != 0 and preservation['restored']['returncode'] == 0
    assert initial['returncode'] != 0 and initial['unchanged'] is True
    paths = set(runtime['checked']) | set(book['source_inputs']) | set(final['checked']) | {CARD}
    paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
    inputs = [{'path': p, 'sha256': digest((ROOT / p).read_bytes()),
               'role': 'producer' if Path(p).suffix in ('.py', '.pm', '.t') else 'input'} for p in sorted(paths)]
    freeze = record('freeze.json')
    before = (ROOT / freeze['before']).read_bytes()
    assert before == subprocess.check_output(['git', 'show', BASE + ':' + freeze['claim']], cwd=ROOT)
    old = json.loads(before)
    bindings = [entry for claim in old['claims'] if claim['durability'].get('mode') == 'live'
                for entry in claim['durability']['inputs']]
    assert len(bindings) == 283
    old_producer = subprocess.check_output(['git', 'show', BASE + ':' + OLD_PRODUCER], cwd=ROOT)
    historical = [{'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'},
                  {'path': OLD_PRODUCER, 'sha256': digest(old_producer), 'role': 'producer'}]
    statement = ('One required key resolver on AST hash-index fallback passes864 main/8 cold assertions and '
                 'three syntax-valid semantic faults. Three complete native-current callback rows and66 '
                 'controlled branch rows preserve lazy guards, scalar context/local key copies, actual '
                 'callback/node/map/fatal identities, helper order, new target-span construction and direct '
                 'results. Identical864 names retain3 original publication REDs/861 controls/all864 current '
                 'GREEN. Supplied46 suites/166 files, five reviewer corruptions/restoration, original283-binding '
                 'RED/restoration and complete book57+32/three controls pass. The initial wrong-target '
                 'preservation producer/result/reviewer remain exact; an independent supplied-tree check '
                 'reproduces its readonly validation rejection before admitting the corrected control.')
    return {'version': 1, 'owner': LEAF, 'claims': [
        {'name': 'method-required-ast-assignment-isolation', 'statement': statement, 'scope': runtime['scope'],
         'rederive': {'status': 'checked',
                      'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; separately preservation-control.py and publish-claim.py under that wrapper. Defaults readonly; capture/freezer/--capture are one-shot writers.',
                      'granularity': 'Every3 native-current callback row and66 independently enumerated branch row, identical864 TAP names/exact original3-failure set, all complete mutant sources/channels, every166 supplied input, five actual evidence controls, initial wrong-target instrument/counterfactual/rejection, every283 original binding and complete book/include/rendered marker population.',
                      'result': statement},
         'falsify': {'status': 'checked',
                     'hypothesis': 'A key callback can donate publication, a wrapper can replace actual identity, native lazy guards/copies/context/error/span/results can move, or incomplete and ineffective evidence can masquerade as acceptance.',
                     'oracle': 'Clean-Git/current complete native observations and identical fixture populations; actual eligible-call/parent-packet lookup, local key versus AST source identity, exact source/fast-path/required validation order, new tracked target-span values/reference and actual maps/fatal objects. Complete source/input/channel and rendered-marker identities independently distinguish evidence loss.',
                     'red_control': 'Exactly3 original publication REDs become GREEN with861 controls preserved. Required-boundary removal, actual-to-wrapper substitution and required-diagnostic removal each produce syntax-valid complete864 TAP and named semantic REDs. Five actual reviewer corruptions reject and restore; correct original-binding corruption rejects beyond mode/revision and restores. The initial wrong target produced reviewer return0 and is refused by its own validation, reproduced in an independently supplied tree. Missing SUMMARY fails, removed teaching disappears from HTML, and omitted include reports ERROR despite exit0.'},
         'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
        {'name': 'original-array-end-boundary-preservation',
         'statement': 'All283 original array-end live input identities and every original proof/hash field remain exact. Only the live mode/revision changes to historical at4fde89c19; the already historical capacity preservation claim is unchanged.',
         'scope': 'Complete accepted two-claim array-end record and every283 original live binding at clean4fde89c19. This compact claim binds the complete original record and its actual final publisher, without refreshing any runtime or book observation.',
         'rederive': {'status': 'checked',
                      'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; separately preservation-control.py under that wrapper.',
                      'granularity': 'Every original Git input hash and complete before/after JSON, permitting only one live mode/revision change. All283 original hashes and existing historical fields stay exact.',
                      'result': 'Every283 original identity matches clean4fde89c19; exact mode/revision-only comparison and actual original-binding RED/restoration pass.'},
         'falsify': {'status': 'checked',
                     'hypothesis': 'A historical label can conceal refreshed or corrupted original input identities, or corruption of an unrelated claim can count as rejection.',
                     'oracle': 'Complete original Git claim, all original Git input hashes and mode/revision-only comparison; retained initial wrong-target producer/result identifies its ineffective zero result.',
                     'red_control': 'Corrected first-original-binding all-zero SHA corruption fails beyond mode/revision and original bytes restore before actual readonly PASS. Initial unrelated-claim corruption is retained and independently refused rather than counted as a valid RED.'},
         'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical}}
    ]}


data = expected()
serialized = (json.dumps(data, indent=2) + '\n').encode()
assert len(serialized) <= 131072, ('claim exceeds bounded size', len(serialized))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot claim already published'
    TARGET.write_bytes(serialized)
else:
    assert TARGET.read_bytes() == serialized, 'AST assignment publication drift'
print('AST assignment publication PASS:', len(data['claims'][0]['durability']['inputs']),
      'live; original283 preserved through two historical inputs;', len(serialized), 'bytes')
