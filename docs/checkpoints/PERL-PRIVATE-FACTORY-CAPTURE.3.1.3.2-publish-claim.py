"""Readonly bounded publication reconstruction; --capture publishes the first record once."""
import hashlib
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
BASE = 'b0099d9ade78623b38c2213867b84f1e32014fe7'
LEAF = 'PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
TARGET = ROOT / ('docs/claims/' + LEAF + '.json')
CARD = 'docs/knowledge/perl-method-ast-array-end-capture.md'
OLD_PRODUCER = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4-publish-claim.py'
assert sys.argv[1:] in ([], ['--capture'])
digest = lambda raw: hashlib.sha256(raw).hexdigest()


def record(tail):
    return json.loads((ROOT / (PREFIX + tail)).read_bytes())


def expected():
    runtime, book, final, evidence = [record(t + '.json') for t in ('review', 'book-review', 'final-review', 'evidence')]
    preservation = record('preservation-control.json')
    assert runtime['result'] == book['result'] == final['result'] == evidence['result'] == 'PASS'
    assert runtime['assertions'] == 858 and runtime['cold_assertions'] == 8
    assert runtime['actual_caller_modes'] == 12 and runtime['bounded_branch_modes'] == 44
    assert runtime['required_callers'] == runtime['required_callback_roles'] == runtime['actually_invoked_roles'] == 1
    assert runtime['validated_only_roles'] == 0
    assert runtime['paired_original_semantic_failures'] == 12 and runtime['paired_original_passing_controls'] == 846
    assert runtime['semantic_source_faults'] == 3 and runtime['consumer_suites'] == 44 and runtime['supplied_files'] == 164
    assert runtime['historical_bindings_preserved'] == 356
    assert book['source_count'] == 89 and book['book_source_count'] == 57 and book['include_source_count'] == 32
    assert book['actual_controls'] == 3 and len(evidence['rows']) == 5
    assert preservation['unchanged'] is True and preservation['red']['returncode'] != 0 and preservation['restored']['returncode'] == 0
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
    assert len(bindings) == 356
    old_producer = subprocess.check_output(['git', 'show', BASE + ':' + OLD_PRODUCER], cwd=ROOT)
    historical = [{'path': freeze['claim'], 'sha256': digest(before), 'role': 'input'},
                  {'path': OLD_PRODUCER, 'sha256': digest(old_producer), 'role': 'producer'}]
    statement = ('One required extractor resolver across four AST array-end methods passes858 main/8 cold '
                 'assertions and three syntax-valid semantic source faults. Twelve complete native-current '
                 'callback rows and44 controlled branch rows retain scalar context, local receiver copies, '
                 'mutation-sensitive bare fallback, guard/validation/helper order, actual callback/node/span/maps, '
                 'effects/errors/fatal objects, host fallback texts and direct guard results. Identical858 names '
                 'retain12 original publication REDs/846 passing controls/all858 current GREEN. Supplied44 '
                 'suites/164 files including unchanged public uniform binding, five reviewer REDs/restoration, '
                 'original356-binding RED/restoration and complete book57+32/three controls pass.')
    return {'version': 1, 'owner': LEAF, 'claims': [
        {'name': 'method-required-ast-array-end-isolation', 'statement': statement, 'scope': runtime['scope'],
         'rederive': {'status': 'checked',
                      'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'final-review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py; bash tools/run_python_project_data.sh ' + PREFIX + 'publish-claim.py. Defaults readonly; capture/freezer/--capture are one-shot writers.',
                      'granularity': 'Four actual methods/one required callback role, every12 native-current row and44 branch row, identical858 assertion names/exact original12-failure set, every full mutant source/TAP plan, all164 supplied input bytes, five evidence counterfactuals/channels/reasons, every original356 binding and full book/include/rendered-marker population.',
                      'result': statement},
         'falsify': {'status': 'checked',
                     'hypothesis': 'A required array extractor can donate nested publication, wrapper identity can replace its actual reference, native guard/local-copy/fallback/context/error/results can change, or incomplete proof can masquerade as acceptance.',
                     'oracle': 'Clean-Git/current identical fixture names and native observations; actual eligible-call/parent-packet lookup, receiver scalar-copy versus AST source identity, mutation-sensitive bare fallback, source/helper/node/span/map/fatal/public callback references, exact guard order/results and source/input/channel/rendered-marker identities.',
                     'red_control': 'Exactly12 original publication REDs become GREEN while846 controls pass. Required-boundary removal, actual-to-wrapper substitution and required-diagnostic removal each produce syntax-valid complete858-assertion named semantic REDs. Five actual evidence corruptions reject failed positive, missing reader input, omitted inverse, erased semantic reason with rehashed index and missing consumer capture; exact restoration passes. Actual original-binding hash corruption rejects beyond mode/revision and restores. Missing SUMMARY fails, removing teaching text removes it from HTML, and omitted include reports ERROR despite exit0.'},
         'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}},
        {'name': 'original-history-capacity-boundary-preservation',
         'statement': 'All356 original live capacity input identities and every original proof/hash field remain exact. Only the original live durability mode/revision changes to historical at b0099d9ad; the already historical AST-call preservation claim is unchanged.',
         'scope': 'The complete accepted two-claim capacity record and every356 individually retained live binding at clean b0099d9ad. This compact claim binds that complete original record and its actual final publisher. It preserves historical evidence without refreshing any capacity, runtime or book observation.',
         'rederive': {'status': 'checked',
                      'command': 'bash tools/run_python_project_data.sh ' + PREFIX + 'review.py; bash tools/run_python_project_data.sh ' + PREFIX + 'preservation-control.py',
                      'granularity': 'Every original Git input hash and complete before/after JSON; only one live mode/revision may differ. Existing historical fields and all356 old bindings stay exact.',
                      'result': 'All356 original identities match clean b0099d9ad; complete mode/revision-only comparison and actual original-binding RED/restoration pass.'},
         'falsify': {'status': 'checked',
                     'hypothesis': 'A historical-mode label can conceal refreshed or corrupted original input identities.',
                     'oracle': 'Complete original Git claim, every original Git input hash and exact mode/revision-only JSON comparison.',
                     'red_control': 'Actual first-original-binding all-zero SHA corruption fails beyond mode/revision. Original bytes restore before actual readonly PASS; full counterfactual and actual channels are retained.'},
         'durability': {'status': 'checked', 'mode': 'historical', 'revision': BASE, 'inputs': historical}}
    ]}


data = expected()
serialized = (json.dumps(data, indent=2) + '\n').encode()
assert len(serialized) <= 131072, ('claim exceeds bounded size', len(serialized))
if sys.argv[1:]:
    assert not TARGET.exists(), 'one-shot claim already published'
    TARGET.write_bytes(serialized)
else:
    assert TARGET.read_bytes() == serialized, 'AST array-end publication drift'
print('AST array-end publication PASS:', len(data['claims'][0]['durability']['inputs']),
      'live; original356 preserved through two historical inputs;', len(serialized), 'bytes')
