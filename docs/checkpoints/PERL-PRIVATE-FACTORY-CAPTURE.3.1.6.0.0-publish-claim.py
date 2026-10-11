"""Publish once, or readonly reconstruct, the bounded public receiver-copy claim."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = '2b4e484a9bf27471d23d86f72aa25c7616b2bd3b'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
OLD_PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2-publish-claim.py'
CARDS = {'docs/knowledge/perl-scalar-bound-receiver-copy.md',
         'docs/knowledge/perl-method-regex-undef-required-capture.md'}
CANONICAL = PREFIX + 'canonical/'
CANONICAL_CLAIM = CANONICAL + 'claim.json'
assert sys.argv[1:] in ([], ['--capture'], ['--extend-canonical'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail + '.json')).read_bytes())


runtime, book, final, evidence = [record(t) for t in ('review', 'book-review', 'final-review', 'evidence')]
assert all(r['result'] == 'PASS' for r in (runtime, book, final, evidence))
expected = {'assertions': 50, 'public_cases_per_route': 14,
            'paired_original_semantic_failures': 9, 'paired_original_passing_controls': 41,
            'semantic_source_faults': 3, 'consumer_suites': 61, 'supplied_files': 184,
            'historical_bindings_preserved': 307}
assert all(runtime[k] == v for k, v in expected.items())
assert book['source_count'] == 89 and book['actual_controls'] == 3
assert len(evidence['rows']) == 5 and len(final['rows']) == 3
preservation = record('preservation-control')
assert preservation['unchanged'] is True and preservation['red']['returncode'] != 0
assert preservation['restored']['returncode'] == 0
paths = set(runtime['checked']) | set(book['source_inputs']) | set(final['checked']) | CARDS
paths.update(p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(LEAF + '-*') if p.is_file())
paths.add(CANONICAL_CLAIM)
inputs = [{'path': p, 'sha256': digest((ROOT / p).read_bytes()),
           'role': 'producer' if Path(p).suffix in ('.py', '.pl', '.pm', '.t') else 'input'}
          for p in sorted(paths)]
freeze = record('freeze')
before = (ROOT / freeze['before']).read_bytes()
assert before == subprocess.check_output(['git', 'show', BASE + ':' + freeze['claim']], cwd=ROOT)
old = json.loads(before)
bindings = [entry for claim in old['claims'] if claim['durability'].get('mode') == 'live'
            for entry in claim['durability']['inputs']]
assert len(bindings) == 307
historical = [
    {'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'},
    {'path': OLD_PRODUCER,
     'sha256': digest(subprocess.check_output(['git', 'show', BASE + ':' + OLD_PRODUCER], cwd=ROOT)),
     'role': 'producer'},
]
statement = ('A scalar-bound variable with one zero-argument receiver copy now reuses function-form runtime '
             'container dispatch. One exact12-line AST insertion passes50 main assertions:9 original semantic '
             'REDs/41 controls/all50 current GREEN. Live Get and actual retained standalone source each execute14 '
             'cases; typed AST poisoned-source execution independently retains the hash. Distinct outer containers '
             'and shared nested references match Perl function-form copy. Arrays/empty containers/scalars, legacy '
             'aggregate storage, wrong arity and multi-step chains retain their controls. Three syntax-valid source '
             'faults reject9/4/8 named assertions. Supplied61 suites/184 files, five evidence corruptions, original307 '
             'binding corruption/restoration and complete book89/three controls pass. Original probe/regression '
             'and native channels remain unchanged; exact canonical receipt independently governs landing.')
data = {'version': 1, 'owner': LEAF, 'claims': [
    {'name': 'scalar-bound-single-copy-type', 'statement': statement, 'scope': runtime['scope'],
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; separately preservation-control.py and publish-claim.py under that wrapper. Defaults readonly; capture/freezer/faults/evidence/--capture are one-shot writers.',
                  'granularity': 'Every14 named live/standalone case, six identity facts per route, actual consumed generated-source bytes, typed AST poison/source/legacy/arity controls, all50 paired TAP names and exact9 original failures, every184 supplied input, three complete mutants and exact9/4/8 semantic failure sets, evidence5/original307 restoration and all89 book inputs/render controls.',
                  'result': statement},
     'falsify': {'status': 'checked',
                 'hypothesis': 'A scalar-held hash can be treated as an array, subsequent chain steps can be discarded, or copy can return the original container rather than a snapshot; altered proof/input identities can conceal this.',
                 'oracle': 'Explicit array/hash/empty/scalar expected values, function-form and multi-step controls, outer/nested reference identity observed before JSON serialization, typed AST semantic fields with poisoned source and exact clean-source insertion reconstruction. Full actual standalone generated source is retained in each execution channel.',
                 'red_control': 'Original9 semantic REDs become GREEN with41 controls preserved. Complete syntax-valid mutants removing the fix, swallowing later chain steps and borrowing original references fail exactly9/4/8 named assertions. Five evidence corruptions and one original-binding corruption reject then restore. Book missing SUMMARY fails, removed teaching disappears from HTML and omitted include reports ERROR despite exit0.'},
     'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
    {'name': 'original-regex-undef-boundary-preservation',
     'statement': 'All307 original regex/undefined-return live input identities and every original proof/hash field remain exact. Only that live durability mode/revision becomes historical at2b4e484a9; the existing push preservation claim stays exact.',
     'scope': 'Complete accepted regex/undefined-return claim and every307 original live binding at clean2b4e484a9. Compact historical bindings retain the complete original record and actual publisher. Replays require accepted original Git inputs; no original observation is refreshed.',
     'rederive': {'status': 'checked',
                  'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; separately preservation-control.py under that wrapper.',
                  'granularity': 'Every original Git input SHA and complete before/after claim JSON with only one live mode/revision change permitted.',
                  'result': 'All307 original hashes/proof fields and existing historical fields remain exact; actual original-binding corruption RED/restoration pass.'},
     'falsify': {'status': 'checked',
                 'hypothesis': 'Historical relabeling conceals refreshed or corrupted original identities.',
                 'oracle': 'Complete original Git claim and307 original Git hashes, plus exact mode/revision-only comparison.',
                 'red_control': 'All-zero SHA in the first original binding fails beyond mode/revision; original bytes restore before actual readonly PASS.'},
     'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical}},
]}
supplement = json.loads((ROOT / CANONICAL_CLAIM).read_bytes())
assert supplement['version'] == 1 and supplement['owner'] == LEAF
assert len(supplement['claims']) == 1
data['claims'].extend(supplement['claims'])
serialized = (json.dumps(data, indent=2) + '\n').encode()
assert len(serialized) <= 131072, ('claim exceeds bounded size', len(serialized))
if sys.argv[1:] == ['--extend-canonical']:
    original_bytes = (ROOT / (CANONICAL + 'runtime-claim-before.json')).read_bytes()
    assert TARGET.read_bytes() == original_bytes, 'canonical extension is one-shot'
    original = json.loads(original_bytes)
    original_inputs = {entry['path']: entry for entry in original['claims'][0]['durability']['inputs']}
    current_inputs = {entry['path']: entry for entry in inputs}
    self_path = Path(__file__).relative_to(ROOT).as_posix()
    assert len(original_inputs) == 303
    assert set(current_inputs) == set(original_inputs) | {CANONICAL_CLAIM}
    assert all(current_inputs[p] == entry for p, entry in original_inputs.items() if p != self_path)
    assert original_inputs[self_path]['sha256'] == digest((ROOT / (CANONICAL + 'runtime-publisher-before.py')).read_bytes())
    original['claims'][0]['durability']['inputs'] = inputs
    assert data['claims'][:2] == original['claims'], 'runtime proof fields changed beyond publication extension'
    TARGET.write_bytes(serialized)
elif sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot claim already published'
    TARGET.write_bytes(serialized)
else:
    assert TARGET.read_bytes() == serialized, 'receiver-copy publication drift'
print('Receiver-copy publication PASS:', len(inputs), 'live inputs;', len(serialized), 'bytes; original307 preserved')
