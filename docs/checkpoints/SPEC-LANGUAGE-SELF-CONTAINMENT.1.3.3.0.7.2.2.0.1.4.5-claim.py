"""Publish cursor/input provenance only from complete retained focused evidence."""
from pathlib import Path
import hashlib
import importlib.util
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.5'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
REVISION = '907934281c4422baba6ef6580bd4080663c87e9e'


def sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


runtime, book, freeze = [json.loads((ROOT / (PREFIX + name + '.json')).read_bytes())
                         for name in ('verification', 'book-verification', 'freeze')]
assert runtime['complete'] and book['complete']
assert runtime['revision'] == freeze['revision'] == REVISION
assert tuple(runtime[k] for k in ('overlays', 'contracts', 'cases', 'commands', 'seeds',
    'before_origins', 'after_origins', 'events_per_seed', 'before_red_groups',
    'after_green_groups', 'fixture_suites', 'fixture_groups', 'compiler_cases_per_seed')) == (
        3, 112, 115, 8, 3, 133, 163, 227, 15, 96, 11, 1274, 11)
assert len(runtime['controls']) == 149
assert all(c['observed'] == 'RED' and c['reason'] for c in runtime['controls'])
assert (book['book_inputs'], book['rendered_examples'], book['rendered_sections'],
        len(book['controls']), freeze['bound_inputs'], freeze['unique_inputs'],
        freeze['claims']) == (58, 11, 3, 19, 30, 30, 1)
for report, producer in ((runtime, 'review.py'), (book, 'book.py'), (freeze, 'freeze.py')):
    assert report['instrument_sha256'] == sha(PREFIX + producer)
assert runtime['instrument_correction'] == {
    'initial_producer_sha256': sha(PREFIX + 'initial-review.py'),
    'initial_mutation_changed_bytes': False, 'actual_recursive_target_count': 1,
    'all_final_mutations_change_input': True}

# Retain and recheck the actual successful initial render. Its final corruption
# control changed zero bytes across an HTML line break; it published no acceptance.
initial_spec = importlib.util.spec_from_file_location('initial_cursor_book',
    ROOT / (PREFIX + 'initial-book.py'))
initial = importlib.util.module_from_spec(initial_spec)
initial_spec.loader.exec_module(initial)
initial_report = json.loads((ROOT / (PREFIX + 'initial-book.json')).read_bytes())
initial_manifest = json.loads((ROOT / (PREFIX + 'initial-book-inputs.json')).read_bytes())
initial.check_report(initial_report, initial_manifest)
assert initial_manifest['capsule_sha256'] == sha(PREFIX + 'initial-book-inputs.tar.gz')
final_manifest = json.loads((ROOT / (PREFIX + 'book-inputs.json')).read_bytes())
assert initial_manifest == final_manifest, 'unchanged complete publication inputs'
initial_html = initial.decode(initial_report['regression_html'])
assert b'Its scanner arguments remain empty' not in initial_html
assert b'Its scanner arguments remain\nempty' in initial_html

count = runtime['regular_inputs']
statement = (f'The15 original cursor/input producers preserve original scalar bounds, '
    f'balanced input_slice raw/empty scanner arguments and actual event/argument references. '
    f'Each epoch retains{count} immutable regular Git originals, one declared standard-fixture '
    'replacement and three authored overlays; after replaces only LegacyRules production. '
    'Eight guarded commands cover112 contracts/115 cases under three seeds, retaining227 '
    'events and growing private origins133-to163 per seed. All original public events, '
    'arguments, default callbacks and compiler channels remain unchanged. Actual original '
    'RED15/GREEN96; eleven suites1274 groups including Phase01035 pass.149 reason-specific '
    'controls observe RED. The58-input book renders11 examples/three chapters with19 RED '
    'controls.30 prior claim hashes verify before exact historical freeze.')
scope = ('Original internal compatibility population at ' + REVISION + '. Regular Git '
    'inputs are a complete supplied superset, not a minimal observed IO census; gitlinks '
    'and nonregular entries are metadata-only exclusions. Whole-file inverse removes '
    'only15 snapshots/wrappers to recover committed original bytes. Recognizers/raw/args '
    'and dispatch stay exact; independent115-case literal events and Unicode/CRLF/repeated '
    'scalar intervals remain unchanged. Actual returned/constructor/argument references '
    'distinguish clones. The balanced input_slice scanner has empty args and no parser/trim '
    'callback; its separate compiler lowerer is unchanged. All existing call/anonymous/'
    'named/mark origins and quoted-boundary repairs recur. No runtime cursor movement, '
    'source projection, grammar, public schema, ScannerCore, CI/hook/storage/dependency '
    'or other-repository change. Entry/match producers, executable quoted/comment membership, '
    'replacement, other backends and broad audits remain separately owned. The existing '
    'mark-copy deletion-observation repair remains CONFORMANCE-SOURCE-READING.2.7-owned. '
    'Book examples are rendered teaching. Initial book corruption matched zero raw bytes '
    'across a line break, so review stopped without an acceptance report; complete initial '
    'producer/render/input capsule is retained and rechecked, mutation is corrected and '
    'final actual render is independently reviewed. The initial copied freeze selected '
    'already historical named claim and stopped without changing it; corrected mark freeze '
    'verifies exact committed inputs even though mutable fixture preparation preceded it. '
    'Initial source-regex corruption also changed zero bytes because its target missed '
    'the recursive named expr group; review stopped without publishing verification. '
    'The original reviewer is retained, exact zero-byte mutation and unique actual target '
    'are rechecked, and every final corruption must alter its input before rejection. '
    'Necessary host tools are read-only; project data stays on the repository volume and '
    'RGX/PGEN remain black boxes. Wrapper startup .7 owns establishment/liveness; recovery/'
    'purge stay prohibited and no lifecycle guarantee follows. Previous proof bytes/counts/'
    'adjudications remain exact; only prior durability becomes historical. Focused proof '
    'does not claim canonical CI; full-family/infrastructure/push boundaries require it.')
paths = [p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*')
         if p.is_file()]
paths += [
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0-cases.json',
    'perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm',
    'perl/LinkedSpec/ActionIR/ScannerCore.pm', 't/actionir_helper_source_provenance.t',
    'docs/knowledge/perl-legacy-cursor-input-source-origins.md',
    'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
    'tools/project_data_env.sh', 'tools/project_data_run.sh',
    'tools/run_python_project_data.sh', 'tools/check_claim_verification.py']
inputs = [{'path': path, 'sha256': sha(path),
           'role': 'producer' if path.endswith(('.py', '.pl', '.pm', '.t', '.sh')) else 'input'}
          for path in sorted(set(paths))]
commands = '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + command
    for command in ('freeze.py', 'capture.py before', 'capture.py after', 'review.py',
                    'book.py --review', 'claim.py'))
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'cursor-input-legacy-source-origins', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked', 'command': commands,
        'granularity': f'{count} originals/one fixture replacement/three overlays per epoch/'
            'one production delta;112 contracts/115 cases/three seeds/227 events/133-to163 '
            'origins;RED15-GREEN96/eleven suites1274 groups;58 book inputs/11 examples/'
            'three chapters;30 prior hashes.', 'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Wrong balanced raw/source bounds, copied objects, altered public '
            'effects/compiler channels, invented origins or incomplete inputs/TAP could '
            'falsely establish cursor/input source compatibility.',
        'oracle': 'Independent original literal raw/empty arguments/scalar intervals, '
            'actual object identities, entire original Git source inverse and all public '
            'compiler channels; complete input/mode/population/replacement/stream/exit/'
            'guard/ordered positive TAP.',
        'red_control': 'Original source fails15 expanded groups; repaired source passes96. '
            'All149 observed denials cover112 omitted events,15 missing cursor/input '
            'origins, forged identities/spans/callbacks/compiler channels/producer/inputs/'
            'commands/guards/exits/TAP, nested failures, invented original cursor/current '
            'entry/excluded origins, changed balanced input_slice raw, changed original '
            'regex and missing snapshot. Stable IDs/family guards protect control scope. '
            'All19 final book controls reject missing teaching/authority/examples/guards, '
            'forged artifacts and failed rendering.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print(str(len(inputs)) + ' bound actual producer/artifact inputs; cursor/input claim published')
