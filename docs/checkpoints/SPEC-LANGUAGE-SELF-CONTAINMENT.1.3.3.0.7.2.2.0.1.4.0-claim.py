"""Publish original Legacy diagnosis and the separately verified finite capacity prerequisite."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
REVISION = 'da3d34945d5067410b79f51782395f15b5184ff4'
def digest(path):
    return hashlib.sha256((ROOT/path).read_bytes()).hexdigest()
runtime, book, freeze = [json.loads((ROOT/(PREFIX+n+'.json')).read_bytes())
                         for n in ('verification', 'book-verification', 'freeze')]
assert runtime['complete'] and book['complete']
assert runtime['revision'] == freeze['revision'] == REVISION
assert tuple(runtime[k] for k in ('regular_inputs', 'overlays', 'commands', 'contracts', 'cases',
                                 'seeds', 'events_per_seed', 'source_origins_per_seed',
                                 'fixture_suites', 'fixture_groups', 'compiler_cases_per_seed')) == (
                                     4252, 3, 4, 112, 115, 3, 227, 2, 6, 103, 11)
assert len(runtime['controls']) == 123
assert all(c['observed'] == 'RED' and c['reason'] for c in runtime['controls'])
assert (book['book_inputs'], book['rendered_examples'], book['rendered_sections'],
        len(book['controls']), freeze['bound_inputs']) == (58, 19, 3, 20, 108)
assert all(c['rejected'] and c['reason'] for c in book['controls'])
for result, producer in ((runtime, 'review.py'), (book, 'book.py'), (freeze, 'freeze.py')):
    assert result['instrument_sha256'] == digest(PREFIX+producer)
paths = [p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/checkpoints').glob(OWNER+'-*') if p.is_file()]
paths += ['docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py',
          'perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm', 'perl/LinkedSpec/ActionIR/ScannerCore.pm',
          'perl/LinkedSpec/ActionIR/MethodExpr.pm', 'perl/LinkedSpec/ActionIR/Contracts.pm',
          'perl/LinkedSpec/ActionIR/Scanner.pm', 'perl/LinkedSpec/RuleIR/EmitContext.pm',
          'docs/knowledge/perl-legacy-source-producer-partition.md',
          'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
          'docs/linkedspec-book/src/dsl/source-boundary-helper-reference.md',
          'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh',
          'tools/check_claim_verification.py', 'scripts/check_readme_routing_pressure.pl',
          'scripts/check_readme_stability.sh', 'tools/roll_document_history.pl',
          'tools/read_document_history.pl', 'scripts/check_document_history.sh',
          'doctrine/readme_stability/routes.jsonl', 'README_POLICY.md',
          'docs/decisions/0127-legacy-diagnosis-note-capacity.md', 'docs/decisions/INDEX.md',
          'DEVELOPMENT_NOTES.md', 'docs/history/development-notes/manifest.jsonl']
paths += [p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/history/development-notes').glob('*.md')]
inputs = [{'path': p, 'sha256': digest(p),
           'role': 'producer' if p.endswith(('.py', '.pl', '.pm', '.t', '.sh')) else 'input'}
          for p in sorted(set(paths))]
statement = ('Fresh immutable original Legacy diagnosis retains4252 regular Git inputs/three exact '
             'authored overlays/four fully guarded commands.112 internal dispatcher contracts partition '
             'into six families (8/26/17/14/15/32).115 independent literal cases retain227 original '
             'events and two existing return_general source origins per seed, actual returned/constructor/'
             'args identities and exact public/private callback effects. All three full seed channels '
             'are byte-identical, including eleven original Toolbox substitution/descriptor/parser-source '
             'cases. Six unchanged suites pass103 ordered groups.123 reason-specific evidence controls '
             'observe RED. Complete58-input book renders19 original examples/three chapters with20 '
             'rejection controls.108 prior live input hashes verify before historical freeze.')
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'original-legacy-source-producer-diagnosis', 'statement': statement,
    'scope': ('Immutable clean '+REVISION+' regular Git supplied-input superset, not minimal observed IO; '
              'all original object/content/mode/membership and exact three cases/probe/oracle overlays '
              'are retained. Every command/channel/input guard is complete. Internal compatibility IDs '
              'are not public helper admission. Literal expected raw/args and cumulative scalar intervals '
              'are authored independently of observed matches. Original return_general helper-pattern '
              'view preserves actual parser/trim callbacks and source identities; remaining producers '
              'have no source origins yet. Textual inventory describes exact producer mechanisms, not '
              'arbitrary runtime reachability. Quoted comma boundary observation is retained unchanged '
              'with both scanner and Contracts repair owner .1.4.0.1; arbitrary label syntax is not '
              'admitted. First macro/mark argument expectations and source_span schema correction '
              'retain original failed authoring inputs; exploratory descriptor serialization and '
              'parser-source dereference errors are not final runtime acceptance. Book render is '
              'teaching, not native execution. The director-granted finite capacity prerequisite is '
              'separately verified in this record; exact canonical landing remains required. No production/'
              'spec/standard tests/CI/dependency/other-repository change. Only the separately scoped finite engineering-note storage controls change. Required OS/Perl/Python/'
              'prove/mdBook are read-only tools; project data stays repository-local. Gitlinks/nonregular '
              'metadata excludes payload reads; RGX/PGEN remain black boxes. Other producer implementations, '
              'executable membership/comments/replacement and global historical audits remain separate.'),
    'rederive': {'status': 'checked',
                'command': '; '.join('bash tools/run_python_project_data.sh '+PREFIX+x
                                    for x in ('inventory.py', 'capture.py', 'review.py', 'freeze.py', 'book.py --review')),
                'granularity': '112 contracts/115 literal cases/3 seeds/227 events and2 origins per seed;4252 Git inputs/3 overlays/4 commands;6 suites/103 groups;11 compiler cases per seed;58 book inputs/19 examples/3 chapters;108 prior hashes.',
                'result': statement},
    'falsify': {'status': 'checked',
               'hypothesis': 'Omitted compatibility contracts, incorrect original arguments, invented source authority, equal-valued copied references or incomplete captured inputs/TAP could falsely establish a complete original diagnosis.',
               'oracle': 'Independent retained literal raw/args/cumulative scalar source fixture oracle; exact original dispatcher/handler inventory and complete six-family partition; actual return constructor/args/event references; exact default callback sequence/results; complete original full channels across seeds; immutable Git byte/mode/membership and positive ordered TAP/nested-failure rejection.',
               'red_control': '123 actual reason-specific RED controls erase each of112 contract event populations, forge each returned/constructor/args relationship, invent an uninstrumented origin, omit a return origin, lose commands/guards/Git/overlays or forge channel/producer.20 actual rendered-book controls reject missing Legacy family teaching, original examples, earlier source teaching, guards/input/channel/renderer or failed rendering. The original quoted-comma result differs from the independently authored two-token intended boundary list; its repair remains owned.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}]}
capacity = json.loads((ROOT/(PREFIX+'capacity-verification.json')).read_bytes())
assert capacity['complete'] and capacity['revision'] == REVISION
assert capacity['instrument_sha256'] == digest(PREFIX+'capacity-review.py')
assert (capacity['scalar_changes'], capacity['collection_files'], capacity['manifest_lines'],
        capacity['manifest_bytes'], capacity['archive_bytes'], capacity['archive_lines'],
        capacity['root_bytes'], capacity['root_lines'], capacity['prior_archives'],
        capacity['production_thresholds'], capacity['production_red_controls']) == (3,44,43,26021,27233,201,32359,144,41,18,7)
assert len(capacity['controls']) == 6 and all(c['observed']=='RED' and c['reason'] for c in capacity['controls'])
record['claims'].append({
    'name':'granted-finite-engineering-note-rollover',
    'statement':'Exactly three Granted scalars admit44 collection files and a43-line/26021-byte manifest. Governed clean segment4964 preserves201 lines/27233 bytes; final root144 lines/32359 bytes after removing only one final blank separator. All41 prior archive files and prior manifest rows remain byte-exact. Six reconstruction controls and seven actual production authority controls observe RED;18 actual threshold observations agree with independent scalar comparisons.',
    'scope':'One exact engineering-note archive at clean da3d only; unchanged root/per-segment/aggregate budgets, stable route responsibility, other surfaces and all immutable prior history. Director Granted applies only to the retained three-scalar proposal. Actual production functions are extracted unchanged with in-memory staged-ADR fixtures; these bounded function checks do not replace normal resulting-tree doctrines or exact staged canonical CI. No later capacity, canonical or push waiver is inferred.',
    'rederive':{'status':'checked','command':'bash tools/run_python_project_data.sh '+PREFIX+'capacity-review.py',
               'granularity':'Every registry row/scalar and prior archive/manifest byte; full root reconstruction and exact new segment;18 actual threshold executions and seven actual indexed authority denials.',
               'result':'3/44/43/26021 admission;201/27233 archive;144/32359 final root;41 prior archives exact;6 evidence RED/18 thresholds/7 authority RED PASS.'},
    'falsify':{'status':'checked','hypothesis':'Unrelated limit growth, changed prior history, altered source binding or missing exact indexed authority could be accepted as the approved finite rollover.',
               'oracle':'Independent exact HEAD registry/manifest/archive/root byte reconstruction and literal approved scalar objects; actual unchanged production exceeds_limits and indexed ADR authorization functions.',
               'red_control':'Six observed reason-specific RED controls corrupt new/prior archive bytes, prior manifest order, root bytes, unrelated aggregate capacity and source commit. Seven observed actual production RED controls remove added ADR/index, erase each old/new limits/contracts marker or deny reviewed authority. Actual new limits pass equality and reject plus-one for files, manifest lines and manifest bytes.'},
    'durability':{'status':'checked','mode':'live','inputs':inputs}})
target = ROOT/('docs/claims/'+OWNER+'.json')
target.write_text(json.dumps(record, indent=2)+'\n')
assert target.stat().st_size <= 131072
print('Published original Legacy diagnosis with '+str(len(inputs))+' retained inputs')
