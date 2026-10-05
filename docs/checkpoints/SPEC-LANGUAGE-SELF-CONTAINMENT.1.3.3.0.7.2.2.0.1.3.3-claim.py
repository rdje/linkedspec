"""Publish fresh immutable Flow family acceptance without claiming the CI receipt."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.3'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
REVISION = '1d450522afb79aa87e579db148224ad6ed2c11e0'

def digest(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()

runtime, book, freeze = [json.loads((ROOT / (PREFIX + n + '.json')).read_bytes())
                         for n in ('verification', 'book-verification', 'freeze')]
assert runtime['complete'] and book['complete']
assert runtime['revision'] == freeze['revision'] == REVISION
assert tuple(runtime[k] for k in ('regular_inputs', 'overlays', 'commands', 'contracts', 'seeds',
                                 'source_origins', 'method_frames', 'complete_compiler_pairs',
                                 'fixture_suites', 'fixture_groups', 'authority_groups')) == (
                                     4233, 0, 10, 16, 3, 147, 138, 48, 16, 837, 3)
assert len(runtime['controls']) == 31
assert all(c['observed'] == 'RED' and c['reason'] for c in runtime['controls'])
assert (book['book_inputs'], book['rendered_examples'], book['rendered_sections'],
        len(book['controls']), freeze['bound_inputs']) == (58, 19, 3, 19, 51)
assert all(c['rejected'] and c['reason'] for c in book['controls'])
for result, producer in ((runtime, 'review.py'), (book, 'book.py'), (freeze, 'freeze.py')):
    assert result['instrument_sha256'] == digest(PREFIX + producer)

# Prior records retain the actual imported oracle/probe closure. Bind those bytes
# directly as well as the frozen records; never promote their earlier adjudications.
paths = [p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*')
         if p.is_file()]
for previous in ('SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.1',
                 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0.1'):
    record = json.loads((ROOT / ('docs/claims/' + previous + '.json')).read_bytes())
    paths.append('docs/claims/' + previous + '.json')
    for claim in record['claims']:
        paths.extend(item['path'] for item in claim['durability']['inputs'])
paths += [
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0.1-after-frames-observations.json',
    'docs/knowledge/perl-flow-recursive-source-provenance.md',
    'perl/LinkedSpec/ActionIR/Scanner/FlowRules.pm',
    'perl/LinkedSpec/ActionIR/MethodExpr.pm', 'perl/LinkedSpec/ActionIR/ScannerCore.pm',
    'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
    'docs/linkedspec-book/src/development/documentation-workflow.md',
    'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh']
inputs = [{'path': p, 'sha256': digest(p),
           'role': 'producer' if p.endswith(('.py', '.pl', '.pm', '.t', '.sh')) else 'input'}
          for p in sorted(set(paths))]
statement = ('Fresh immutable 1d45052 recurrence supplies4233 regular committed Git inputs/no overlays '
             'and ten fully guarded commands. All sixteen Flow contracts preserve147 original source '
             'origins and actual returned/constructor/argument references across three hash seeds. '
             'Original MethodExpr CSV/parser frames retain138 scalar occurrences and returned identities. '
             'All48 complete original compiler/callback pairs and three complete MethodExpr channels '
             'equal the prior committed proof byte-for-byte. Sixteen selected unchanged suites pass837 '
             'ordered groups; the separate three-group custom authority fixture passes under all three '
             'seeds.31 reason-specific evidence controls observe RED. Complete58-input book renders19 '
             'original examples/three chapters with19 rejection controls. All51 previous live claim '
             'hashes verify before historical mode/revision-only freeze.')
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'sixteen-flow-family-immutable-recurrence', 'statement': statement,
    'scope': ('Immutable clean ' + REVISION + ' complete regular Git supplied-input superset, not minimal '
              'observed IO. Original object/content/mode/membership and every command/channel guard are '
              'recoverable; no runtime overlays or production/spec/standard-test changes. Actual imported '
              'original corrected literal Flow source/argument/scalar/traversal oracle and independent '
              'MethodExpr literal slot oracle bind the current measured references, not JSON equality. '
              'Quoted syntactic case observations remain in the original population; marker-first '
              'depth-first then inline order is preserved without lexical sorting or equal-text lookup. '
              'Custom copied/foreign/changed/opaque/transformed callbacks retain ordinary behavior and '
              'bounded authority denial. Sixteen fixture groups are837 once; authority three groups recur '
              'separately under each seed; Phase0 is reserved for the canonical gate. Book examples are '
              'rendered teaching, not native execution. Exact staged canonical CI receipt is separately '
              'mandatory before parent closure; this claim does not publish a canonical CI measurement. '
              'Prior adjudications and limitations stay unchanged. Remaining Legacy/staged/progressive/'
              'recognition producers, executable membership/comments/replacement, arbitrary malicious '
              'callbacks/host syntax, other backend admission and global historical audits remain owned '
              'separately. Gitlinks/nonregular metadata exclude payloads; RGX/PGEN remain black boxes. '
              'OS/Perl/Python/prove/mdBook are necessary read-only prerequisites; project data stays '
              'repository-local. No CI/storage/dependency/other-repository change.'),
    'rederive': {'status': 'checked',
                'command': '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + x
                                    for x in ('capture.py', 'review.py', 'freeze.py', 'book.py --review')),
                'granularity': '4233 inputs/zero overlays/10 commands;16 contracts/3 seeds/147 origins/138 frames/48 pairs;16 suites/837 groups plus authority3;58 book inputs/19 examples/3 chapters;51 prior hashes.',
                'result': statement},
    'falsify': {'status': 'checked',
               'hypothesis': 'Lost source occurrences, forged equal-valued references, wrong scalar bounds, shortened fixtures or omitted inputs/channels could falsely admit the complete family.',
               'oracle': 'Original independently authored corrected literal Flow source/args/scalar/traversal oracle; independent MethodExpr literal slot/source frames; actual returned/constructor/args identities; exact complete previous compiler and method channels; complete immutable Git object/content/mode/membership and full ordered positive TAP with nested-failure rejection.',
               'red_control': '31 observed reason-specific RED controls erase each direct/composite origin population, forge actual recursive returned/constructor/args references, change a recursive scalar, lose a MethodExpr frame or CSV identity, omit commands/guards/Git inputs, forge channels/producer or fail an authority assertion.19 book controls reject missing examples/teaching, failed or forged guards/channels/render inputs.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}]}
target = ROOT / ('docs/claims/' + OWNER + '.json')
target.write_text(json.dumps(record, indent=2) + '\n')
assert target.stat().st_size <= 131072
print('Published Flow acceptance with ' + str(len(inputs)) + ' retained inputs')
