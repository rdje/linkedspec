"""Publish the bounded mixed BasicRules proof, with exact supplied input closure."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.2.0'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
REVISION = '318457e6e62683d485ded02bdbe9566931aaca97'
DIAGNOSIS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-'
GUARD = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2-'


def digest(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


runtime, book, freeze = [json.loads((ROOT / (PREFIX + name + '.json')).read_bytes())
                         for name in ('verification', 'book-verification', 'freeze')]
assert runtime['complete'] and book['complete'] and runtime['revision'] == freeze['revision'] == REVISION
assert (runtime['regular_inputs'], runtime['overlays'], runtime['contracts'], runtime['seeds'],
        runtime['authored_statement_frames'], runtime['authored_event_origins'], runtime['fixture_suites'],
        runtime['fixture_groups'], runtime['foreign_probes']) == (3899, 3, 20, 3, 129, 147, 8, 144, 3)
assert runtime['initial_failed_capture_preserved'] and len(runtime['controls']) == 20
assert all(c['observed'] == 'RED' and c['reason'] for c in runtime['controls'])
assert (book['book_inputs'], book['rendered_examples'], book['rendered_sections'], len(book['controls']), freeze['bound_inputs']) == (58, 5, 2, 7, 53)
assert all(c['rejected'] and c['reason'] for c in book['controls'])
for result, producer in ((runtime, 'review.py'), (book, 'book.py'), (freeze, 'freeze.py')):
    assert result['instrument_sha256'] == digest(PREFIX + producer)
paths = [p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if p.is_file()]
paths += [DIAGNOSIS + 'capture.py', GUARD + 'guard-probe.pl']
paths += ['perl/LinkedSpec/ActionIR/StatementSplit/Core.pm', 'perl/LinkedSpec/ActionIR/ScannerCore.pm',
          'perl/LinkedSpec/ActionIR/Scanner/PrimitiveBasicRules.pm',
          't/actionir_statement_source_frames.t', 't/actionir_basic_statement_source_provenance.t',
          't/actionir_basic_regex_source_provenance.t', 't/actionir_helper_source_provenance.t',
          't/actionir_ast_parser.t', 't/canonical_event_occurrence_order.t',
          't/actionir_raw_dependency_provenance.t', 't/actionir_nested_block_source_spans.t',
          'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
          'docs/linkedspec-book/src/development/documentation-workflow.md',
          'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh']
inputs = [{'path': p, 'sha256': digest(p), 'role': 'producer' if p.endswith(('.py', '.pl', '.pm', '.t', '.sh')) else 'input'}
          for p in sorted(set(paths))]
statement = ('One literal mixed source independently composes all nine regex and eleven statement BasicRules contracts '
             'under three seeds: 60 ordered public/private contract pairs retain exact original arguments and callback '
             'sequences, 147 original event/argument reference identities and scalar origins, and 129 original splitter '
             'frames. Three complete Toolbox compiler inspections have clean channels and exact cross-seed bytes. '
             'Eight unchanged fixtures/consumers pass144 complete groups; three foreign-source probes preserve events '
             'with no invented origin. Twenty reason-specific runtime/evidence controls observe RED. Seven render '
             'controls reject corruptions; five original examples and composition teaching render from58 complete '
             'book inputs. All53 original statement-family claim input hashes verify before its historical-only freeze.')
scope = ('Focused mixed-oracle preparation at immutable clean ' + REVISION + '. All3899 regular Git blobs plus '
         'three explicit authored oracle/case/probe overlays are retained or recoverable by immutable Git object identity, '
         'with independent content/mode/population review and full before/after guards around all seven actual commands. '
         'This is a conservative supplied-input superset, not minimal observed IO. Gitlinks/non-regular entries are '
         'excluded by metadata without payload reads. Current existing Perl/spec/test bytes still match the immutable '
         'boundary; no production/test/spec/CI/dependency changes occur. The independent literal construction defines '
         'every expected raw, argument object and scalar interval without scanning producer outputs or searching equal '
         'text. Nine regex forms intentionally retain quoted syntactic matches; eleven statement forms retain the original '
         'splitter-selected statements. Within-contract source order is distinct from contract-precedence composition. '
         'Permanent original guards cover nested/callback/error/opaque/empty/source-authority behavior. Public/private '
         'value equality and actual original event/argument reference checks describe the inspected invocations; they '
         'do not imply cross-invocation reference identity. The initial wrong test-path driver retains original producer, '
         'immutable manifest and full actual prove channels/exit2, is explicitly incomplete and is never promoted. '
         'Only its test selection is corrected; the fresh complete run is separately captured. Book publication inputs '
         'and rendered HTML are a separate complete retained boundary. Necessary host OS/Perl/Python standard libraries '
         'and PATH-resolved prove/mdBook are read-only prerequisites; project data remains on the repository volume. '
         'Canonical recurrence and BasicRules parent closeout are separately owned by .1.1.2.1. Remaining producers, '
         'executable membership, comments, replacement, arbitrary host syntax, malicious callback mutation, native '
         'execution, backend/cross-host admission and global historical audit are outside this bounded proof.')
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'mixed-twenty-basic-provenance-composition', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked',
                 'command': '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + step for step in
                                      ('oracle.py', 'capture.py', 'review.py', 'freeze.py', 'book.py --review')),
                 'granularity': '3899 immutable regular Git members/three authored overlays; seven actual commands; twenty contracts/three seeds/147 origins/129 frames; eight ordered TAP suites/144 groups; three Toolbox records and foreign probes;58 publication inputs/five examples and53 unchanged prior claim input hashes.',
                 'result': statement},
    'falsify': {'status': 'checked',
                'hypothesis': 'Equal raw text, reconstructed argument/event objects, missing callbacks, unretained source inputs or producers and partial/failed TAP could falsely pass combined family proof.',
                'oracle': 'Independent literal segment construction with explicit per-contract raw/arguments/scalar spans; original reference-address comparisons reported as booleans; public/private callback log equality; literal foreign-source boundary; independent Git object/content/mode/membership census; exact actual producer/channel hashes; complete ordered positive TAP plans with nested failure rejection; retained rendered examples and composition teaching.',
                'red_control': 'Twenty actual reason-specific RED controls reject missing contracts/arguments/events, reused equal-text spans, forged event/argument identities, erased callback effects/ignored frames, public schema additions, failed compiler probes, invented foreign origins, missing/forged Git inputs, missing overlays, incomplete runs, forged producers/channels, failed actual commands, shortened TAP plans and nested failures. Seven rendered corruptions reject failed render, missing guard, forged producer/channel and missing examples/composition/diagnostic teaching. The original wrong-path actual prove failure remains distinct incomplete evidence.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}
}]}
target = ROOT / 'docs/claims' / (OWNER + '.json')
target.write_text(json.dumps(record, indent=2) + '\n')
assert target.stat().st_size <= 131072
print('Published mixed twenty-contract focused claim with ' + str(len(inputs)) + ' retained input/producer artifacts')
