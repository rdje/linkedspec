"""Publish the actual immutable Legacy recurrence without claiming the CI receipt."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.7'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
REVISION = '65304aded7d1a096c701b768b076b29c4eb893b2'
LEGACY = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.6-'
ORIGINAL = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0-'


def digest(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


runtime, book, freeze = [json.loads((ROOT / (PREFIX + name + '.json')).read_bytes())
                         for name in ('verification', 'book-verification', 'freeze')]
manifest = json.loads((ROOT / (PREFIX + 'inputs.json')).read_bytes())
assert runtime['complete'] and book['complete']
assert runtime['revision'] == manifest['revision'] == freeze['revision'] == REVISION
assert runtime['regular_inputs'] == len(manifest['entries']) and manifest['overlays'] == []
assert tuple(runtime[key] for key in ('overlays', 'commands', 'contracts', 'cases', 'seeds',
                                    'source_origins', 'events_per_seed', 'complete_compiler_pairs',
                                    'fixture_suites', 'fixture_groups')) == (0, 4, 112, 115, 3, 227, 227, 33, 12, 1318)
assert runtime['families'] == {'call-return-push': 8, 'anonymous-capture': 26,
                              'named-capture': 17, 'mark-control': 14,
                              'cursor-input': 15, 'entry-match': 32}
assert len(runtime['controls']) == 269
assert all(control['observed'] == 'RED' and control['reason'] for control in runtime['controls'])
assert (book['book_inputs'], book['rendered_examples'], book['rendered_sections'],
        len(book['controls']), freeze['bound_inputs']) == (58, 18, 4, 31, 457)
assert all(control['rejected'] and control['reason'] for control in book['controls'])
for result, producer in ((runtime, 'review.py'), (book, 'book.py'), (freeze, 'freeze.py')):
    assert result['instrument_sha256'] == digest(PREFIX + producer)
previous_path = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1.1.json'
before = json.loads((ROOT / (PREFIX + 'before-rollover-claim.json')).read_bytes())
for claim in before['claims']:
    claim['durability'].update(mode='historical', revision=REVISION)
assert json.loads((ROOT / previous_path).read_bytes()) == before, 'mode/revision-only historical freeze'

# The complete runtime input population is recoverable from immutable Git objects
# and its tracked content/mode/membership manifest. Bind the actual instruments,
# imported literal oracles, prior full channels and current publication directly.
paths = [path.relative_to(ROOT).as_posix() for path in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if path.is_file()]
paths += [LEGACY + name for name in ('probe.pl', 'cases.json', 'oracle.py', 'after-observations.json')]
paths += [ORIGINAL + name for name in ('cases.json', 'inventory.json', 'inventory.py')]
paths += [previous_path,
          'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.json',
          'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py',
          'docs/knowledge/perl-legacy-family-source-acceptance.md',
          'perl/LinkedSpec.pm', 'perl/LinkedSpec/ActionIR/ScannerCore.pm',
          'perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm', 'perl/LinkedSpec/ActionIR/Contracts.pm',
          'perl/LinkedSpec/ActionIR/BoundaryLabels.pm',
          'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh']
book_manifest = json.loads((ROOT / (PREFIX + 'book-inputs.json')).read_bytes())
paths += [entry['path'] for entry in book_manifest['entries']]
paths += [entry['path'] for entry in manifest['entries'] if entry['path'].startswith('t/')
          and entry['path'] in ('t/nested_boundary_quoted_labels.t', 't/capture_boundary_quoted_labels.t',
                               't/typed_source_location_perl_contract.t', 't/actionir_helper_source_provenance.t',
                               't/actionir_statement_source_frames.t', 't/actionir_ast_parser.t',
                               't/canonical_event_occurrence_order.t', 't/actionir_nested_block_source_spans.t',
                               't/trace_actionir_method_lowering.t', 't/complete_named_mark_contract.t',
                               't/generated_source_contract.t', 't/phase0_regression.t')]
inputs = [{'path': path, 'sha256': digest(path),
           'role': 'producer' if path.endswith(('.py', '.pl', '.pm', '.t', '.sh')) else 'input'}
          for path in sorted(set(paths))]
count = runtime['regular_inputs']
statement = (f'Fresh immutable65304aded recurrence supplies{count} regular committed Git inputs/no overlays '
             'and four fully guarded commands. All112 original Legacy dispatcher contracts in six families '
             'retain115 literal cases,227 events/origins per seed and actual returned/constructor/argument '
             'identities across three hash seeds. All33 original Toolbox compiler pairs and every complete '
             'callback/compiler/origin channel equal the previous committed proof byte-for-byte. Twelve '
             'unchanged suites pass1318 complete ordered groups including Phase01035;269 effective '
             'reason-specific evidence controls observe RED. Complete58-input book renders18 examples '
             'across four chapters with31 rejection controls. All457 prior rollover claim hashes verify '
             'before historical mode/revision-only freeze.')
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'complete-legacy-family-immutable-recurrence', 'statement': statement,
    'scope': ('Immutable clean ' + REVISION + ' complete regular Git supplied-input superset, not minimal '
              'observed I/O. Every supplied runtime byte/object/mode/member is recoverable from the named '
              'committed revision and tracked manifest; actual before/after guards cover the full population. '
              'No runtime overlays or production/spec/standard-test changes. Original independent literal '
              'source/argument/scalar oracle changes only the separately verified final quoted-label correction. '
              'Internal dispatcher IDs are compatibility inventory, not public helper admission. Each original '
              'syntactic occurrence preserves raw spelling, original arguments, physical scalar intervals and '
              'actual references; helper-looking data remains in that population. Three complete bulk channels '
              'and33 Toolbox compiler pairs are bounded to the original115 cases; selected suites run once. '
              'Book examples are rendered teaching, not additional runtime execution. The exact staged canonical '
              'receipt independently gates this milestone and parent closeout; this record does not publish '
              'a canonical CI measurement. Remaining staged/progressive/recognition producers, all-producer '
              'composition, executable quoted/comment membership and precise replacement remain separate. '
              'The named-mark clearing-observation gap remains CONFORMANCE-SOURCE-READING.2.7-owned; wrapper '
              'startup .7 supplies no new establishment/liveness guarantee and recovery/purge remain prohibited. '
              'Other backend admission, arbitrary host syntax/callbacks and global historical audits are '
              'unassessed. Necessary OS/Perl/Python/prove/mdBook/Git prerequisites are read-only; all project '
              'scratch and outputs stay repository-local. Gitlinks/nonregular metadata exclude payloads; '
              'RGX/PGEN remain black boxes. No CI/storage/dependency/other-repository change.'),
    'rederive': {'status': 'checked',
                'command': '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + name
                                    for name in ('capture.py', 'review.py', 'freeze.py', 'book.py --review')),
                'granularity': f'{count} immutable inputs/0 overlays/4 commands;112 contracts/115 cases/6 families/3 seeds/227 origins/33 compiler pairs;12 suites/1318 groups;58 book inputs/18 examples/4 chapters;457 prior hashes.',
                'result': statement},
    'falsify': {'status': 'checked',
               'hypothesis': 'Omitted events/origins, equal-valued cloned references, false scalar bounds, altered compiler channels or incomplete runtime/TAP/input evidence could falsely accept the complete family.',
               'oracle': 'Original independently authored literal source/events/args/scalar fixtures and six-family dispatcher inventory, actual returned/constructor/argument identities, exact previous committed complete channels, immutable Git object/content/mode/membership and ordered complete positive TAP with nested-failure rejection.',
               'red_control': '269 effective reason-specific RED controls omit each original contract event and each case origin, falsify all three reference identities and repeated scalar intervals in each family, lose callbacks/change all three compiler channels, omit or forge commands/guards/exits/instruments/channels/inputs, invent runtime overlays, alter the original literal oracle and shorten or hide failures in TAP.31 book controls reject missing examples/teaching/scope and forged or failed renders/guards/channels.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs},
}]}
target = ROOT / ('docs/claims/' + OWNER + '.json')
target.write_text(json.dumps(record, indent=2) + '\n')
assert target.stat().st_size <= 131072, 'bounded claim record'
print('Published actual complete Legacy-family acceptance with ' + str(len(inputs)) + ' retained bindings')
