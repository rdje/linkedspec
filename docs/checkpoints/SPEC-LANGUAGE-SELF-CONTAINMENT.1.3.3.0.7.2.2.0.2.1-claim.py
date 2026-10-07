"""Materialize the bounded claim from independently verified retained results."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.1'
PREFIX = ROOT / ('docs/checkpoints/' + OWNER + '-')
sha = lambda raw: hashlib.sha256(raw).hexdigest()

proof = json.loads(Path(str(PREFIX) + 'verification.json').read_bytes())
book = json.loads(Path(str(PREFIX) + 'book-verification.json').read_bytes())
supplement = json.loads(Path(str(PREFIX) + 'supplement-verification.json').read_bytes())
assert proof['compiler_groups'] == 39 and proof['original_red_groups'] == 38
assert len(proof['controlled_seeds']) == 3
assert not proof['remaining_value_or_error'] and proof['authored_value_oracles'] == 20
assert proof['no_original_value_oracle'] == ['unsupported_nested', 'raw_operand']
assert proof['direct_consumers']['plans'][-1] == 1035
assert len(proof['evidence_controls']) == 7 and len(supplement['historical_controls']) == 5
assert supplement['original_hashes'] == 116
assert book['book_inputs'] == 58 and book['exact_examples'] == 3 and len(book['controls']) == 5
repaired = proof['repaired_native_fresh']
statement = ('Compiler membership passes39 complete regression groups under seeds0/1/42 after '
             'the original compiler fails all38. Original public native/fresh value repairs: ' +
             ', '.join(repaired) + '. ' + str(proof['public_cases']) +
             ' original public cases retain full source/AST/value/error/generated channels. ' +
             'All20 original authored expected values match; unsupported_nested and raw_operand '
             'have no original successful-value oracle and remain unassessed. ' +
             str(proof['direct_consumers']['groups']) + ' ordered groups across15 direct consumers '
             'including the original1035-group Phase0 pass. The retained first integration replay '
             'failed exactly two Phase0 groups: the former scanner mock and numeric slash/newline '
             'compatibility; their bounded corrections preserve original public oracles. '
             'Seven effective evidence controls, five historical controls and '
             'five rendered controls observe RED;116 original selector input hashes remain frozen. '
             'Full book render retains58 inputs and three exact repair examples.')
paths = {p.relative_to(ROOT).as_posix() for p in PREFIX.parent.glob(PREFIX.name + '*') if p.is_file()}
paths |= {'perl/LinkedSpec/ActionIR/Scanner.pm', 'perl/LinkedSpec/RuleIR/EmitContext.pm',
          'perl/LinkedSpec/ActionIR/SourceMembership.pm', 'perl/LinkedSpec/ActionIR/ScannerCore.pm',
          'perl/LinkedSpec/ActionIR/Diagnostics.pm', 'perl/LinkedSpec/OwnerDispatch.pm',
          't/actionir_compiler_source_membership.t',
          'docs/knowledge/perl-compiler-source-membership.md',
          'docs/knowledge/perl-executable-source-membership.md',
          'tools/run_python_project_data.sh', 'tools/project_data_run.sh', 'tools/project_data_env.sh',
          'tools/check_claim_verification.py',
          'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0-observe.pm',
          'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-probe.pl',
          'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-fresh.pl',
          'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-cases.json',
          'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0-cases.json',
          'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py'}
manifest = json.loads(Path(str(PREFIX) + 'book-inputs.json').read_bytes())
paths |= {entry['path'] for entry in manifest['entries']}
after = json.loads(Path(str(PREFIX) + 'final-after-observations.json').read_bytes())
assert after['complete'] is True
paths |= set(after['runs'][-1]['command'][5:])
inputs = [{'path': path, 'sha256': sha((ROOT / path).read_bytes()),
           'role': 'producer' if Path(path).suffix in ('.py', '.pl', '.pm', '.sh', '.t') else 'input'}
          for path in sorted(paths)]
claim = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'compiler-original-executable-membership', 'statement': statement,
    'scope': 'Perl compiler scanner bridge only. Ordinary syntactic scanning, actual producer '
             'event/argument references, scalar source authority, real dependencies, family/order and '
             'caller errors persist.36 original authored scanner sources are lexical membership controls, '
             'not all174 scanner contracts or new native grammar/callback admission. Public corpus uses '
             'the original23 sources under seed0; compiler regression uses three controlled seeds. '
             'Correct values do not establish readiness: unresolved-pattern/marker origin remains '
             '.7.2.2.1; exact residual replacement .0.3, comments .7.3 and independent canonical '
             'membership acceptance .0.2.2 remain open. Full regular Git inputs are supplied at '
             '31395e440a38acec7a6712d470a90a90a6567863 plus two explicit authored overlays; '
             'after replaces only Scanner/EmitContext, the selector numeric slash/newline boundary '
             'and the Phase0 mock entry. The existing expression/statement slash policy is unchanged. '
             'Historical Git blobs '
             'and their exact object/content/mode identities are bound by retained manifests. This '
             'is a conservative supplied superset, not minimal observed IO. Initial rejected test '
             'and smart-apostrophe book instruments remain historical and are not product failures. '
             'The initial reviewer incorrectly required expected on unsupported_nested/raw_operand; '
             'its actual KeyError recurs, with both sources/channels retained and no invented value admission. '
             'Necessary OS/Perl/Python/mdBook reads only; project data repository-local/same-volume, '
             'other repositories read-only and dependencies black boxes. No CI/admission/policy expansion. '
             'Tracked producers, fixtures, original rejected instruments, full complete channels, '
             'regular Git input manifests/revision and publication capsule retain durability. '
             'The claim doctrine gates all declared identities. Reviewer reconstructs actual historical '
             'Git inputs and pins only declared current compiler/fixture overlays, command population '
             'and source oracles; it never silently refreshes historical channels. The initial claim '
             'generator misplaced this explanation in an unsupported durability mechanism field; '
             'the original generator/record and exact schema rejection remain retained.',
    'rederive': {'status': 'checked',
                 'command': 'bash tools/run_python_project_data.sh docs/checkpoints/' + OWNER + '-review.py; '
                            'bash tools/run_python_project_data.sh docs/checkpoints/' + OWNER + '-supplement-review.py; '
                            'bash tools/run_python_project_data.sh docs/checkpoints/' + OWNER + '-book.py --review',
                 'granularity': json.dumps(proof, sort_keys=True), 'result': statement},
    'falsify': {'status': 'checked',
               'hypothesis': 'A syntactic or equal-raw selection, copied/reordered arguments, suppressed real errors '
                             'or forged/truncated source/channel evidence could falsely establish compiler selection.',
               'oracle': 'Original independently authored .2.0 literal interval/argument/order oracles and .7.2.1 '
                         'public source/value corpus predate the bridge. Complete current regression retains actual '
                         'producer references and real callback/caller errors. Original compiler is actual RED; '
                         'original public native/fresh failures distinguish quoted-data corruption and host fallback.',
               'red_control': 'Original compiler fails38 complete groups under all three selected seeds; '
                              'seven effective evidence corruptions reject, five original claim corruptions reject '
                              'and five rendered controls reject. Original test-option/regex and smart punctuation '
                              'rejections remain independently adjudicated.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs},
}]}
# The source population is independently read rather than carried as an unwatched constant.
public_cases = json.loads((ROOT / 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1-cases.json').read_bytes())
assert proof['public_cases'] == len(public_cases)
claim['claims'][0]['scope'] = claim['claims'][0]['scope'].replace('original23 sources', 'original' + str(len(public_cases)) + ' sources')
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(claim, indent=2) + '\n')
print(statement)
print('Bound inputs:', len(inputs))
