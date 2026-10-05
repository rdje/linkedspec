"""Publish the fresh immutable BasicRules family recurrence, with exact supplied input closure."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.2.1'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
REVISION = '77444c8d2372bf2cd1bbce29022b62c9c8f72e9d'
DIAGNOSIS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-'
GUARD = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2-'


def digest(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


runtime, book, freeze = [json.loads((ROOT / (PREFIX + name + '.json')).read_bytes())
                         for name in ('verification', 'book-verification', 'freeze')]
assert runtime['complete'] and book['complete'] and runtime['revision'] == freeze['revision'] == REVISION
assert (runtime['regular_inputs'], runtime['overlays'], runtime['contracts'], runtime['seeds'],
        runtime['authored_statement_frames'], runtime['authored_event_origins'], runtime['fixture_suites'],
        runtime['fixture_groups'], runtime['foreign_probes']) == (3921, 0, 20, 3, 129, 147, 8, 144, 3)
assert runtime['exact_prior_complete_toolbox_recurrence'] and len(runtime['controls']) == 20
assert all(c['observed'] == 'RED' and c['reason'] for c in runtime['controls'])
assert (book['book_inputs'], book['rendered_examples'], book['rendered_sections'], len(book['controls']), freeze['bound_inputs']) == (58, 5, 2, 8, 38)
assert all(c['rejected'] and c['reason'] for c in book['controls'])
for result, producer in ((runtime, 'review.py'), (book, 'book.py'), (freeze, 'freeze.py')):
    assert result['instrument_sha256'] == digest(PREFIX + producer)
paths = [p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if p.is_file()]
PREVIOUS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.2.0-'
paths += [PREVIOUS + name for name in ('oracle.py', 'cases.json', 'probe.pl', 'review.py', 'observations.json', 'verification.json')]
paths += [DIAGNOSIS + 'capture.py', GUARD + 'guard-probe.pl',
          'tools/check_claim_verification.py', 'scripts/check_claim_verification.sh',
          'tools/check_task_verification_fields.pl']
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
statement = ('Fresh immutable BasicRules recurrence supplies all3921 regular Git inputs with no overlays. '
             'The unchanged literal mixed source composes all nine regex and eleven statement contracts under '
             'three seeds:60 ordered public/private pairs retain147 original event/argument references and scalar '
             'origins,129 splitter frames and unchanged callback sequences. Three complete clean Toolbox streams '
             'equal the exact prior committed mixed proof byte-for-byte. Eight unchanged fixtures/consumers pass144 '
             'full groups; three foreign-source probes retain events with no invented origin. Twenty reason-specific '
             'controls observe RED, and eight render controls reject corruptions. Five original examples and family '
             'teaching render from58 complete book inputs. All38 prior mixed-claim input hashes verify before '
             'historical mode/revision-only freeze.')
scope = ('Twenty BasicRules private regex/statement provenance contracts only, at immutable clean ' + REVISION +
         '. The complete3921 regular Git population is a conservative supplied-input superset, not minimal observed '
         'IO. Original object/content/mode/membership identities are recoverable from that Git boundary. Every actual '
         'command retains both full output channels and before/after byte/mode/population guards; independent '
         'review checks current existing Perl/spec/test bytes plus all actually imported original oracle/reviewer '
         'and prior-channel inputs. Gitlinks/nonregular metadata are excluded without payload reads. The independent '
         'literal oracle defines original raw/arguments/scalar intervals without event-derived raw-text searching; '
         'exact recorder-time references and unchanged public/private callback logs are inspected for each invocation. '
         'Nine regex forms intentionally retain quoted syntactic matches; eleven statement forms retain original '
         'splitter-selected statements, including original ignored-frame occurrence indices. Permanent fixtures '
         'retain original callback/nesting/error/opaque/empty/source-authority guards. The premature reviewer timing '
         'attempt has only tool-returned combined output and producer identity: concurrent original observation-read '
         'bytes were not retained, so no complete input-closure or diagnostic reproduction claim follows. Final '
         'acceptance reviews only the completed stable capture. An overlapping pre-stage standalone claim check '
         'retains actual combined missing-declaration failure and unchanged checker source identity, with original '
         'cached blob IDs unrecorded. Cached index readers and live owner selection require stable staging. The first '
         'canonical attempt retains its exact staged diff/combined log and observed canceled exit143, without a pass '
         'or receipt claim; a fresh unchanged amended candidate must pass canonical CI. A known outer managed-book process-group warning '
         'is already owned by startup .7; actual group establishment was not observed and is not claimed. The '
         'completed inner mdBook render/full channels and every publication input remain separately captured. '
         'Read-only host OS/Perl/Python standard libraries and PATH-resolved prove/mdBook are necessary prerequisites; '
         'project scratch remains on the repository filesystem. Exact staged canonical CI receipt is the separate '
         'mandatory BasicRules parent-closeout landing condition; this record does not publish a new canonical CI '
         'measurement. Remaining scanner families, executable membership/comments/replacement, arbitrary host syntax '
         'or malicious callbacks, native execution, backend/cross-host admission and global historical audit remain '
         'separately owned. No production/spec/test/CI/hook/dependency change occurs.')
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'twenty-basic-family-immutable-recurrence', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked',
                 'command': '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + step for step in
                                      ('capture.py', 'review.py', 'freeze.py', 'book.py --review')),
                 'granularity': '3921 immutable regular Git members/no overlays; seven actual commands; twenty contracts/three seeds/147 origins/129 frames; eight ordered TAP suites/144 groups; three Toolbox records and foreign probes;58 publication inputs/five examples and38 unchanged prior claim input hashes.',
                 'result': statement},
    'falsify': {'status': 'checked',
                'hypothesis': 'Equal raw text, reconstructed argument/event objects, missing callbacks, unretained source inputs or producers and partial/failed TAP could falsely pass combined family proof.',
                'oracle': 'Independent literal segment construction with explicit per-contract raw/arguments/scalar spans; original reference-address comparisons reported as booleans; public/private callback log equality; literal foreign-source boundary; independent Git object/content/mode/membership census; exact actual producer/channel hashes; complete ordered positive TAP plans with nested failure rejection; retained rendered examples and composition teaching.',
                'red_control': 'Twenty actual reason-specific RED controls reject missing contracts/arguments/events, reused equal-text spans, forged event/argument identities, erased callbacks/ignored frames, public schema additions, failed compiler probes, invented foreign origins, missing/forged Git inputs, changed prior Toolbox streams, incomplete runs, forged producers/channels, failed commands, shortened TAP plans and nested failures. Eight render corruptions reject failed render, missing guard, forged producer/channel and missing examples/composition/family-closeout/diagnostic teaching. Original premature timing evidence remains explicitly limited.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}
}]}
target = ROOT / 'docs/claims' / (OWNER + '.json')
target.write_text(json.dumps(record, indent=2) + '\n')
assert target.stat().st_size <= 131072
print('Published immutable twenty-contract family claim with ' + str(len(inputs)) + ' retained input/producer artifacts')
