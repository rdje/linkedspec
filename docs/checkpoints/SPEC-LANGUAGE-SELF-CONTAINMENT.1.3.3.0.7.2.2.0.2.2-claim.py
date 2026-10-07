"""Publish bounded immutable proof and the owned open callable compatibility defect."""
from pathlib import Path
import base64
import gzip
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2'
CLAIM_OWNER = OWNER + '.0'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
PREVIOUS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.1-'


def read(path):
    return json.loads((ROOT / path).read_bytes())


def main():
    proof = read(PREFIX + 'verification.json')
    history = read(PREFIX + 'freeze.json')
    book = read(PREFIX + 'book-verification.json')
    instruments = read(PREFIX + 'instrument-controls.json')
    historical = read(PREFIX + 'historical-verification.json')
    callable_proof = read(PREFIX + 'callable-verification.json')
    assert callable_proof['complete'] and callable_proof['observed_bad_pairs'] == ['x,y']
    actual = read(PREFIX + 'historical-actual.json')
    channel = gzip.decompress(base64.b64decode(actual['stdout']['data'], validate=True))
    assert hashlib.sha256(channel).hexdigest() == actual['stdout']['sha256']
    historical_inputs = json.loads(channel)['tracked_inputs']
    assert historical['complete'] and historical['original_red'] == 'unreviewed signature-regression drift: t/phase0_regression.t'
    assert instruments['complete'] and len(instruments['failures']) == 3
    assert proof['complete'] and history['complete']
    assert proof['overlays'] == [] and proof['controlled_seeds'] == [0, 1, 42]
    cases = read('docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-cases.json')
    assert proof['public_cases'] == len(cases)
    assert proof['public_seed_observations'] == len(cases) * len(proof['controlled_seeds'])
    assert proof['authored_value_pairs'] == sum('expected' in c for c in cases) * len(proof['controlled_seeds'])
    assert proof['authored_route_values'] == proof['authored_value_pairs'] * 2
    assert proof['no_original_value_oracle'] == ['unsupported_nested', 'raw_operand']
    paths = {p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if p.is_file()}
    paths.update(entry['path'] for entry in read(PREFIX + 'book-inputs.json')['entries'])
    paths.update(historical_inputs)
    paths.update(proof_path for proof_path in (
        'docs/knowledge/perl-compiler-source-membership.md',
        'docs/knowledge/perl-executable-source-membership.md',
        'docs/knowledge/phase0-compiler-scanner-mock-historical-inverse.md',
        'docs/knowledge/historical-objective-audit-input-recovery.md',
        'docs/knowledge/perl-source-membership-callable-signature-precedence.md',
        'tests/language-readiness/verify_objectives.py',
        'tools/project_data_run.sh', 'tools/project_data_env.sh', 'tools/run_python_project_data.sh',
        'tools/check_claim_verification.py',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0-cases.json',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-cases.json',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-probe.pl',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-fresh.pl',
        'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-observe.pm',
        'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.1.json',
        't/actionir_compiler_source_membership.t', 'perl/LinkedSpec/ActionIR/SourceMembership.pm',
        'perl/LinkedSpec/ActionIR/Scanner.pm', 'perl/LinkedSpec/ActionIR/ScannerCore.pm',
        'perl/LinkedSpec/RuleIR/EmitContext.pm', 'perl/LinkedSpec/ActionIR/Diagnostics.pm',
        'perl/LinkedSpec/OwnerDispatch.pm'))
    # The original complete RED and GREEN channels, original pre-regression
    # overlay and their actual verifier remain recoverable and hash-gated.
    paths.update(PREVIOUS + suffix for suffix in (
        'review.py', 'before-observations.json', 'before-inputs.json',
        'final-after-observations.json', 'final-after-inputs.json',
        'pre-regression-test.t', 'retry-capture.py', 'final-capture.py'))
    observations = read(PREFIX + 'observations.json')
    paths.update(observations['runs'][-1]['command'][5:])
    bindings = []
    for path in sorted(paths):
        source = ROOT / path
        assert source.is_file() and not source.is_symlink(), path
        bindings.append({'path': path, 'sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
                         'role': 'producer' if source.suffix in ('.py', '.pl', '.pm', '.sh', '.t') else 'input'})
    statement = (f"Immutable {proof['revision'][:9]} supplies{proof['regular_git_inputs']} regular committed "
                 f"inputs/no overlays for{proof['commands']} guarded commands. Compiler regression "
                 f"passes{proof['compiler_groups']} groups under seeds0/1/42. Original{proof['public_cases']} "
                 f"public sources retain{proof['public_seed_observations']} complete source/AST/lowering/"
                 f"metadata/generated/value/error observations;{proof['authored_value_pairs']} "
                 f"authored source/seed pairs match on both routes ({proof['authored_route_values']} "
                 "native/fresh value checks), with unsupported_nested/raw_operand "
                 "explicitly unassessed. Fifteen unchanged direct consumers pass"
                 f"{proof['direct_consumers']['groups']} groups including Phase0 "
                 f"{proof['direct_consumers']['plans'][-1]}. Original compiler RED recurs from retained "
                 "complete channels. " + str(len(proof['controls'])) + " evidence controls, " +
                 str(len(history['controls'])) + " historical controls and " + str(len(book['controls'])) +
                 " publication controls reject. All" + str(history['bound_inputs']) +
                 " original historical claim hashes stay exact. Full book render retains" +
                 str(book['book_inputs']) + " inputs/" + str(book['exact_examples']) + " exact examples. "
                 "The original historical-auditor drift rejection recurs; the exact Git-bound scanner-mock "
                 "inverse accepts while five source controls reject. Isolated historical replay restores " +
                 str(historical['restored_inputs']) + " inputs/" + str(historical['restored_bytes']) +
                 " bytes with " + str(historical['recovery_controls']) + " recovery controls and " +
                 str(historical['evolution_controls']) + " source-evolution denials; healthy guards record "
                 "zero original-log reads or tracked writes. Original three-source callable diagnosis "
                 "preserves typed AST/signatures: x,y filters the real return through literal range8..48 "
                 "and fails natively/freshly emitted; x,z/rest-y return ok. Five observed corruptions reject. "
                 "Both complete failed canonical candidates are retained; no successful canonical "
                 "measurement or membership closure is claimed.")
    claim = {'version': 1, 'owner': CLAIM_OWNER, 'claims': [{
        'name': 'immutable-compiler-membership-checkpoint', 'statement': statement,
        'scope': 'Perl compiler membership only. Original literal scalar intervals, event/argument references, '
                 'family/occurrence order, dependencies and caller errors remain fixture authority. '
                 'Production, Perl fixtures, CI, hooks and dependencies remain unchanged. The historical '
                 'evidence auditor admits only the committed af5d/31395 one-line scanner-mock correction '
                 'through a whole-file Git-bound inverse; original milestone/log/input/claim bytes and hashes '
                 'remain exact. The first canonical failure and its complete staged binary patch are retained; '
                 'the original auditor still reproduces that exact drift rejection. A second complete '
                 'canonical failure and candidate are retained and expose the existing callable fixture '
                 'regression. This record covers the original bounded fixture/consumer population and '
                 'the actual three-source callable diagnosis, not full compiler compatibility. Original '
                 'AST/signatures, real producer origins, substitutions/dumps/emitted modules and native/fresh '
                 'value/error channels distinguish signature masking from the earlier repaired splitter. '
                 'The transparent observer delegates exactly once to actual SourceMembership callbacks '
                 'without replacing the real dependency map. Its original last-empty-packet version '
                 'rejects for missing origins; the initial direct facade-bundle probe exits255, and exact '
                 'retained-source replay attributes it to missing LinkedSpec::_split_action_ir_statements. '
                 'Compiler repair .0.2.2.1 and fresh committed canonical .0.2.2.2 remain open. '
                 'The later .0.4 owner retains '
                 'its recurring-registration ledger work. Complete regular immutable Git input '
                 'superset at864b1a93934ab7fd4b059b0a7cb9d4b417e33c66 is reconstructed without overlays '
                 'and hash/mode/population guarded before and after every command. All supplied inputs '
                 'recover from the retained exact object/content/mode manifests and Git; this is not '
                 'minimal observed IO. Public channels recur under three controlled seeds from the '
                 'unchanged original22-source producer; all channels equal the committed integration '
                 'capture except the explicitly controlled seed. Two original no-value-oracle cases '
                 'retain full channels without inventing success acceptance. Existing38-group compiler '
                 'RED is reverified through its original retained historical inputs/reviewer, not '
                 'regenerated against current compiler owners. Membership parent .0.2 remains open '
                 'until corrected committed .0.2.2.2 and exact staged canonical receipt/normal hooks; this record publishes no '
                 'canonical CI measurement. Precise replacement .0.3, diagnostic origin .7.2.2.1, '
                 'comments .7.3, recurring executable .0.4 and broader quote/backend/audit scopes '
                 'remain open. The original compiler claim was already historical ataf5d19971 by '
                 'REPO-HYGIENE.11; all original hashes/boundary remain unchanged. Initial review '
                 'instrument incorrectly assumed a live claim; its original source and actual '
                 'assertion rejection are retained and independently recur. '
                 'The first full-permission guard and the ineffective nested-line consumer control '
                 'also remain as original producers with complete actual rejected channels; the '
                 '0640/100644 permission counterexample is retained as a reconstructable input. '
                 'Current root checks use Git executable mode; full reconstructed snapshot permissions '
                 'remain hash/mode guarded before and after every actual observation command. '
                 'Retained original source executes with its original __file__ identity for artifact '
                 'lookup; direct stored-filename invocation and its wrong-prefix rejection also recur. '
                 'Actual producer/input channels, complete immutable manifests and full publication capsule retain '
                 'durability and are claim-gated. Necessary OS/Perl/Python/mdBook/toolchain reads only; '
                 'project data remains repository-local/same-volume. Other repositories read-only, '
                 'Gitlinks/nonregular payloads excluded without inspection, RGX/PGEN black boxes. '
                 'No wrapper recovery/purge, readiness waiver or new grammar/backend admission.',
        'rederive': {'status': 'checked',
                    'command': '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + name
                                         for name in ('capture.py', 'review.py', 'freeze.py', 'instrument-controls.py', 'book.py --review', 'historical-capture.py', 'historical-review.py', 'callable-capture.py', 'callable-review.py')),
                    'granularity': json.dumps(proof, sort_keys=True), 'result': statement},
        'falsify': {'status': 'checked',
                   'hypothesis': 'Syntactic/equal-raw selection, changed literal or argument/source authority, '
                                 'truncated or forged channels, refreshed historical inputs or lost public teaching '
                                 'could falsely establish membership acceptance.',
                   'oracle': 'Independently authored literal/source/argument/occurrence fixtures predate the '
                             'compiler repair. Original public expected values and complete earlier public '
                             'channels distinguish corruption from preserved literal data. Original before '
                             'compiler fails all38 groups under three seeds; full original direct-consumer '
                             'plans and nested TAP successes establish reach. No acceptance inferred from '
                             'correct values for readiness or unsupported/raw no-oracle cases.',
                   'red_control': 'Original38-group compiler RED independently reverified under seeds0/1/42; ' +
                                  str(len(proof['controls'])) + ' effective evidence corruptions lose capture/'
                                  'command/exit/input/producer/channel/nested TAP/literal/AST/value/emitted-source/'
                                  'metadata/consumer-order/immutable-input authority and reject. '
                                  'Five historical controls and six actual-render controls reject. Original '
                                  'live-boundary instrument assertion actually recurs before correction. '
                                  'Original historical auditor rejects the committed scanner-mock delta; '
                                  'missing, duplicate, disabled, foreign mock and unrelated edit controls reject '
                                  'after the exact whole-file Git inverse. Complete isolated historical replay '
                                  'retains 22 recovery controls and 60 source-evolution denials. Five callable '
                                  'source/signature/origin/value/fresh controls reject; the original missing-origin '
                                  'observer also rejects and the initial direct-call exception recurs.'},
        'durability': {'status': 'checked', 'mode': 'live', 'inputs': bindings}}]}
    raw = (json.dumps(claim, indent=2) + '\n').encode()
    assert len(raw) <= 131072, 'bounded claim record'
    (ROOT / ('docs/claims/' + CLAIM_OWNER + '.json')).write_bytes(raw)
    print(statement)
    print('Bound inputs:', len(bindings))


if __name__ == '__main__':
    main()
