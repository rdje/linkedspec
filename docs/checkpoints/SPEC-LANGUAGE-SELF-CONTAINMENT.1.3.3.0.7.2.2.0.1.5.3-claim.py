"""Publish the bounded recognition source-origin repair from retained actual proof."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.3'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
ORIGINAL = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.0-'
REVISION = '34f687c09e197cf0798ed01c3c760e63a0203513'
PREVIOUS = 'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.2.json'


def digest(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


def load(name):
    return json.loads((ROOT / (PREFIX + name + '.json')).read_bytes())


runtime, book, freeze, before = [load(n) for n in
                                ('verification', 'book-verification', 'freeze', 'before-review')]
assert runtime['complete'] and book['complete'] and before['complete']
assert runtime['revision'] == freeze['revision'] == REVISION
assert runtime['regular_inputs'] == before['regular_inputs'] == 4668
assert tuple(runtime[k] for k in (
    'runtime_overlays', 'fixture_replacements', 'owner_deltas', 'commands', 'contracts',
    'cases', 'seeds', 'events', 'statement_frames', 'source_origins', 'compiler_cases',
    'fixture_suites', 'fixture_groups', 'component_commands', 'component_inputs',
    'component_deltas',
)) == (0, 1, 1, 10, 7, 22, 3, 42, 63, 42, 4, 13, 1671, 1, 4668, 5)
assert runtime['original_red_groups'] == before['original_red_groups'] == [
    149, 151, 153, 155, 157, 159, 160, 161, 162, 163, 164, 165, 166, 171, 176, 181, 186, 191,
]
assert len(runtime['controls']) == 200
assert all(c['observed'] == 'RED' and c['reason'] for c in runtime['controls'])
assert (book['book_inputs'], book['rendered_examples'], book['rendered_sections'],
        len(book['controls']), freeze['bound_inputs']) == (58, 29, 4, 53, 122)
assert all(c['rejected'] and c['reason'] for c in book['controls'])
for result, producer in ((runtime, 'review.py'), (book, 'book.py'),
                         (freeze, 'freeze.py'), (before, 'before-review.py')):
    assert result['instrument_sha256'] == digest(PREFIX + producer), 'actual publication producer'
assert before['review_producer_sha256'] == digest(PREFIX + 'review.py')
expected = load('before-progressive-claim')
for claim in expected['claims']:
    claim['durability'].update(mode='historical', revision=REVISION)
assert json.loads((ROOT / PREVIOUS).read_bytes()) == expected, 'mode/revision-only original claim freeze'

paths = [p.relative_to(ROOT).as_posix()
         for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if p.is_file()]
paths += [PREVIOUS,
          'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py',
          'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.2-after-observations.json',
          'tools/check_recognition_transaction_contract.py',
          'capability_conformance/recognition_transaction_contract.json']
paths += [ORIGINAL + n for n in ('cases.json', 'probe.pl', 'oracle.py', 'review.py', 'observations.json')]
paths += ['docs/knowledge/' + n + '.md' for n in (
    'perl-recognition-annotation-statement-origins', 'perl-dedicated-producer-source-diagnosis',
    'perl-staged-annotation-statement-origins', 'perl-progressive-annotation-statement-origins',
    'project-root-evidence-filesystem-modes',
)]
paths += [
    'perl/LinkedSpec.pm', 'perl/LinkedSpec/ActionIR/Scanner.pm',
    'perl/LinkedSpec/ActionIR/ScannerCore.pm', 'perl/LinkedSpec/ActionIR/Contracts.pm',
    'perl/LinkedSpec/ActionIR/MethodExpr.pm', 'perl/LinkedSpec/ActionIR/StatementSplit/Core.pm',
    'perl/LinkedSpec/ActionIR/StagedParseJob.pm', 'perl/LinkedSpec/ActionIR/ProgressiveSpanDispatch.pm',
    'perl/LinkedSpec/ActionIR/Scanner/RecognitionTransactionRules.pm',
    'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
]
paths += ['t/' + n + '.t' for n in (
    'staged_ast_enrichment_perl_contract', 'progressive_span_dispatch_perl_contract',
    'progressive_span_dispatch_perl_authority', 'recognition_transaction_perl_authority',
    'recognition_transaction_perl_contract', 'generated_source_contract',
    'recursive_observation_perl_contract', 'actionir_helper_source_provenance',
    'actionir_statement_source_frames', 'actionir_ast_parser', 'canonical_event_occurrence_order',
    'actionir_nested_block_source_spans', 'phase0_regression',
)]
paths += [e['path'] for e in load('book-inputs')['entries']]
inputs = [{'path': p, 'sha256': digest(p),
           'role': 'producer' if p.endswith(('.py', '.pl', '.pm', '.t', '.sh')) else 'input'}
          for p in sorted(set(paths))]
statement = (
    'Immutable34f687c09 supplies4668 regular parent Git inputs, one declared fixture replacement in '
    'both epochs/one recognition-family source owner delta after and ten guarded runtime commands. '
    'The191-group recurring fixture observes18 original recognition/nested RED groups before and '
    'all191 GREEN after. All seven original contracts/22 cases preserve42 events/63 physical frames '
    'per seed;26 new recognition/observation origins join16 retained staged/progressive origins, '
    'giving42 total. Complete preceding public callback/compiler and staged/progressive origin '
    'channels remain exact under seeds0/1/42. Thirteen suites pass1671 ordered groups including '
    'Phase01035, both syntax channels pass and200 effective reason-specific evidence controls '
    'observe RED. The published recognition gate passes in actual tracked Git context with4668 '
    'guarded parent inputs/five fully retained byte deltas. Book58 inputs/29 examples/four chapters/'
    '53 RED and122 original hash-verified progressive claim mode/revision-only freeze pass.'
)
scope = (
    'Five private RecognitionTransactionRules statement producers; one production file and one '
    'recurring fixture. Original literal event/argument fields and independently assembled scalar '
    'intervals distinguish repeated valid and malformed annotations. Frames are obtained before '
    'trim/operand callbacks, preserve the original statement-list snapshot and authorize only '
    'unchanged source raw. Constructor identities and copied-array/foreign/changed-raw/fatal/'
    'real-nested controls are fixture observations; original probe references are measured at '
    'actual dispatcher return. The unchanged probe builds four Get parsers with complete descriptor '
    'ActionIR, substitution and parser-source channels without executing those four parsers. '
    'Selected consumers separately execute only their covered routes. Three sampled seeds do not '
    'establish arbitrary callback/host behavior. The conservative complete supplied Git supersets '
    'are not minimal observed IO. Original runtime inputs recover through ' + REVISION +
    ' and tracked object/content/mode manifests; declared fixture/owner replacements bind current '
    'source. The component gate runs read-only in the actual repository because its public checker '
    'requires tracked metadata; original bytes recover from Git and five observed root byte deltas '
    'are fully retained, with separate filesystem/Git modes and unchanged-input guards. Later '
    'continuity edits do not refresh that snapshot. No project permissions change. Historical '
    'progressive/mode-repair measurements retain their original producers and hash identities. '
    'Book examples are rendered teaching, not extra parser executions. No static token/effect/'
    'observation policy, runtime restoration/boolean kind, public event, lowering/carrier/admission/'
    'CI/backend/dependency change. Canonical family acceptance .1.5.4, all-producer composition, '
    'quoted/comment membership and precise replacement remain subsequent owners. Existing token '
    'order, restoration, boolean-kind, resource ceiling, marker lifetime, mark-copy observation and '
    'wrapper lifecycle repairs stay open; recovery/purge remain prohibited. Global historical '
    'runtime audit is not refreshed. Necessary OS/toolchain prerequisites are read-only external '
    'inputs; every project-owned output is repository-local. Gitlink/nonregular payloads are '
    'excluded; RGX/PGEN remain black boxes and other repositories remain read-only.'
)
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'recognition-annotation-original-statement-origins',
    'statement': statement, 'scope': scope,
    'rederive': {
        'status': 'checked',
        'command': '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + n for n in (
            'capture.py before', 'capture.py after', 'before-review.py', 'component.py',
            'review.py', 'freeze.py', 'book.py --review',
        )),
        'granularity': '4668 parent inputs; two epochs/10 commands and one actual-root component '
                       'command; seven contracts/22 cases/42 events/63 frames/42 origins per '
                       'sampled seed;191 recurring groups/1671 consumer groups;58 book inputs/'
                       '29 examples/four chapters;122 original hashes.',
        'result': statement,
    },
    'falsify': {
        'status': 'checked',
        'hypothesis': 'Missing or fabricated dedicated origins, paired equal raw by search, '
                      'cloned references or truncated callback/compiler/input/TAP channels '
                      'could falsely appear to repair the five recognition producers.',
        'oracle': 'Unchanged independently authored original event/argument literals and '
                  'assembled scalar intervals; complete preceding channels; actual dispatcher '
                  'and constructor-reference observations; complete immutable input identities, '
                  'ordered positive TAP and nested-failure rejection.',
        'red_control': 'The18 actual original recognition/nested fixture RED groups become GREEN '
                       'after the five bounded hooks.200 effective reason-specific mutations '
                       'reject omitted events/origins, swapped repeated intervals, foreign source '
                       'and changed arguments, cloned references/arrays, missing callbacks/'
                       'compiler nodes/constructors, forged or missing commands/exits/guards/'
                       'instruments/channels/input declarations/TAP and component byte recovery. '
                       '53 rendered-evidence controls preserve earlier teaching and reject '
                       'lost recognition examples, object/static/runtime boundaries.',
    },
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs},
}]}
target = ROOT / ('docs/claims/' + OWNER + '.json')
target.write_text(json.dumps(record, indent=2) + '\n')
assert target.stat().st_size <= 131072, 'bounded claim record'
print('Published recognition source-origin repair with ' + str(len(inputs)) + ' retained bindings')
