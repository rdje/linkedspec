"""Publish original mark-control source provenance from retained focused evidence."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.4'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
REVISION = 'd0b40ade098e1c2e8e7fc983ee2d9f3980205e46'

def sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()

runtime, book, freeze = [json.loads((ROOT / (PREFIX + name + '.json')).read_bytes())
                         for name in ('verification', 'book-verification', 'freeze')]
assert runtime['complete'] and book['complete']
assert runtime['revision'] == freeze['revision'] == REVISION
assert tuple(runtime[k] for k in ('overlays', 'contracts', 'cases', 'commands', 'seeds',
    'before_origins', 'after_origins', 'events_per_seed', 'before_red_groups',
    'after_green_groups', 'fixture_suites', 'fixture_groups', 'compiler_cases_per_seed')) == (
        3, 112, 115, 8, 3, 105, 133, 227, 14, 81, 11, 1259, 11)
assert len(runtime['controls']) == 148
assert all(c['observed'] == 'RED' and c['reason'] for c in runtime['controls'])
assert (book['book_inputs'], book['rendered_examples'], book['rendered_sections'],
        len(book['controls']), freeze['bound_inputs'], freeze['unique_inputs'],
        freeze['claims']) == (58, 9, 3, 17, 33, 33, 1)
for report, producer in ((runtime, 'review.py'), (book, 'book.py'), (freeze, 'freeze.py')):
    assert report['instrument_sha256'] == sha(PREFIX + producer)
count = runtime['regular_inputs']
statement = (f'The14 original mark-control regex producers preserve original scalar bounds, '
    f'symbolic mark/target-source order and actual event/argument references. Each epoch retains{count} '
    'immutable regular Git originals, one declared standard-fixture replacement and three '
    'authored overlays; after replaces only LegacyRules production. Eight guarded commands '
    'cover112 contracts/115 cases under three seeds, retaining227 events and growing private '
    'origins105-to133 per seed. Complete original public events/arguments/default callbacks/'
    'compiler channels remain unchanged. Actual original RED14/GREEN81; eleven suites1259 '
    'groups including Phase01035 pass.148 reason-specific controls observe RED. The58-input '
    'book renders nine examples/three chapters with17 RED controls.33 prior claim hashes '
    'verify before exact historical freeze.')
scope = ('Original internal compatibility population at ' + REVISION + '. Regular Git inputs '
    'are a complete supplied superset, not a minimal observed IO census; gitlinks/nonregular '
    'entries are metadata-only exclusions. Whole-file inverse removes only14 snapshots/wrappers '
    'to recover the committed original. Matching/raw/argument expressions and dispatch stay '
    'exact; literal115-case events and independently authored Unicode/CRLF/repeated intervals '
    'remain unchanged. Actual returned/constructor/argument references distinguish clones. '
    'mark_copy keeps target first/source second; event.args.source and private origin.source '
    'have distinct roles. All existing call/anonymous/named origins and boundary repairs '
    'remain exact. No runtime mark storage/clearing semantics, grammar, public schema, '
    'ScannerCore, CI/hook/storage/dependency or other-repository change. The existing '
    'missing-source mark_copy fixture does not seed its target; its deletion-observation '
    'repair remains CONFORMANCE-SOURCE-READING.2.7-owned and is not closed here. Executable '
    'quoted/comment membership, replacement authority, cursor/entry producers, other backends '
    'and broad historical audits remain separate. Book examples are rendered teaching. '
    'Necessary host tools are read-only; project data stays on the repository volume and '
    'RGX/PGEN remain black boxes. Wrapper startup .7 still owns establishment/liveness; '
    'recovery/purge remain prohibited and no lifecycle guarantee follows. Previous proof '
    'bytes/counts/adjudications remain exact; only prior durability becomes historical. '
    'Focused proof does not claim canonical CI; complete-family/push boundaries require it.')
paths = [p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*')
         if p.is_file()]
paths += [
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0-cases.json',
    'perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm',
    'perl/LinkedSpec/ActionIR/ScannerCore.pm', 't/actionir_helper_source_provenance.t',
    'docs/knowledge/perl-legacy-mark-control-source-origins.md',
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
    'name': 'mark-control-legacy-source-origins', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked', 'command': commands,
        'granularity': f'{count} originals/one fixture replacement/three overlays per epoch/one '
            'production delta;112 contracts/115 cases/three seeds/227 events/105-to133 origins;'
            'RED14-GREEN81/eleven suites1259 groups;58 book inputs/nine examples/three chapters;33 prior hashes.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Wrong source intervals/mark-copy order, copied objects, altered public '
            'effects/compiler channels, invented origins or incomplete inputs/TAP could falsely '
            'establish mark source compatibility.',
        'oracle': 'Independent original literal events/mark arguments/scalar intervals, actual '
            'object identities, complete original Git source inverse and public compiler '
            'channels, full input/mode/population/replacement/stream/exit/guard/positive TAP.',
        'red_control': 'Original Legacy fails14 expanded groups; repaired source passes81. '
            'All148 observed denials cover omitted events for112 contracts, missing origins '
            'for14 mark rows, forged references/spans/callbacks/compiler channels/producer/'
            'inputs/command/guard/exit/TAP, nested failures, invented original mark/current '
            'cursor and excluded origins, reversed mark-copy args, changed original regex '
            'and missing snapshot. Stable contract IDs and family guards protect control '
            'scope.17 book controls reject missing teaching/authority/examples/input guards, '
            'forged artifacts and failed rendering.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print(str(len(inputs)) + ' bound actual producer/artifact inputs; mark Legacy claim published')
