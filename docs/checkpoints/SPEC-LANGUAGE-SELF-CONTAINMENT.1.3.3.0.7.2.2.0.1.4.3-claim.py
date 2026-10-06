"""Publish named Legacy origins and disclose the rejected original wrapper stream."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.3'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
REVISION = '2bd501d5e03a28d98bc687dc885c9b04ca519bf8'

def sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()

runtime, book, freeze = [json.loads((ROOT / (PREFIX + name + '.json')).read_bytes())
                         for name in ('verification', 'book-verification', 'freeze')]
assert runtime['complete'] and book['complete']
assert runtime['revision'] == freeze['revision'] == REVISION
assert tuple(runtime[k] for k in ('overlays', 'contracts', 'cases', 'commands', 'seeds',
    'before_origins', 'after_origins', 'events_per_seed', 'before_red_groups',
    'after_green_groups', 'fixture_suites', 'fixture_groups', 'compiler_cases_per_seed',
    'initial_diagnostic_commands', 'initial_warning_pid')) == (3, 112, 115, 8, 3, 71, 105,
        227, 17, 67, 11, 1245, 11, 4, 92090)
assert len(runtime['controls']) == 152
assert all(c['observed'] == 'RED' and c['reason'] for c in runtime['controls'])
assert (book['book_inputs'], book['rendered_examples'], book['rendered_sections'],
        len(book['controls']), freeze['bound_inputs'], freeze['unique_inputs'],
        freeze['claims']) == (58, 7, 3, 15, 30, 30, 1)
for report, producer in ((runtime, 'review.py'), (book, 'book.py'), (freeze, 'freeze.py')):
    assert report['instrument_sha256'] == sha(PREFIX + producer)
count = runtime['regular_inputs']
statement = (f'The17 original named Legacy regex producers retain original scalar bounds and '
    f'actual returned/constructor/argument references. Each accepted epoch retains{count} '
    'immutable regular Git originals, one declared standard-fixture replacement and three '
    'authored overlays; after replaces only LegacyRules production. Eight guarded commands '
    'cover112 contracts/115 cases under three seeds, retaining227 events and growing private '
    'origins71-to105 per seed. Complete public events/arguments/default callbacks/compiler '
    'channels stay unchanged. Original RED17/GREEN67; eleven suites1245 groups including '
    'Phase01035 pass.152 reason-specific controls observe RED. The58-input book renders '
    'seven examples/three chapters with15 RED controls.30 prior claim input hashes verify '
    'before exact historical freeze. Four additional original diagnostic commands remain '
    'retained; their actual wrapper stderr is strictly rejected and the exact unfiltered '
    'original replay supplies accepted before evidence.')
scope = ('Original internal compatibility population at ' + REVISION + '. Regular Git '
    'inputs are a complete superset, not minimal observed IO; gitlinks/nonregular entries '
    'are metadata-only exclusions. Source inverse removes only17 snapshots/wrappers to '
    'recover the entire committed original file. Matching/raw spellings/argument expressions '
    'and dispatch stay exact. The unchanged115-case literal fixture retains independently '
    'authored symbolic marks, start/end order and Unicode/CRLF/repeated scalar spans. Actual '
    'object references distinguish equal-valued copies. Prior call/anonymous origins and '
    'boundary repairs remain intact. Named take aliases and the anonymous-boundary bridge '
    'keep their physical spelling. No new runtime mark storage/capture semantics, grammar, '
    'public schema, ScannerCore, CI/hook/storage/dependency or other-repository change. '
    'Quoted syntactic recognition stays original; executable quoted/comment membership, '
    'replacement authority, mark/cursor/entry producers and other backends remain separate. '
    'Book examples are rendered teaching. Necessary host tools are read-only; project data '
    'stays on the repository volume and RGX/PGEN remain black boxes. The retained initial '
    'setpgid92090 warning identifies wrapper emission; final PGID and warning frequency '
    'are unassessed. Existing startup .7 owns establishment/liveness repair; recovery/purge '
    'remain prohibited. No filtered stream or wrapper repair is claimed. Prior control34 '
    'actually rejects an extra anonymous origin; current original-named/current-mark and '
    'reversed two-mark controls repair that narrower historical label. Earlier producer '
    'artifacts/counts/adjudications remain exact; prior durability alone becomes historical. '
    'Focused proof does not claim canonical CI; complete-family and push still require it.')
paths = [p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*')
         if p.is_file()]
paths += [
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0-cases.json',
    'perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm',
    'perl/LinkedSpec/ActionIR/ScannerCore.pm', 't/actionir_helper_source_provenance.t',
    'docs/knowledge/perl-legacy-named-capture-source-origins.md',
    'docs/knowledge/perl-legacy-anonymous-capture-source-origins.md',
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
    'name': 'named-legacy-capture-source-origins', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked', 'command': commands,
        'granularity': f'{count} originals/one fixture replacement/three overlays per epoch/one '
            'production delta;112 contracts/115 cases/three seeds/227 events/71-to105 origins;'
            'RED17-GREEN67/eleven suites1245 groups;58 book inputs/seven examples/three chapters;'
            '30 prior hashes; four retained initial diagnostic commands rejected for wrapper stderr.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Wrong spans/mark order, copied objects, changed public effects/compiler '
            'channels, invented origins or incomplete inputs/positive TAP could falsely '
            'establish named source compatibility; expected exits alone could hide wrapper stderr.',
        'oracle': 'Independent original literal events/mark arguments/scalar intervals; actual '
            'object identities; entire original Git source inverse; complete original compiler '
            'channels and input/mode/population/replacement/full stream/exit/guard/positive TAP.',
        'red_control': 'Untouched Legacy fails17 expanded groups; repaired source passes67. '
            'All152 observed denials cover omitted events for112 contracts, missing named origins '
            'for17 rows, forged object identities/spans/callbacks/compiler channels/producer/inputs/'
            'command/guard/exit/TAP, hidden nested failures, invented original named/current mark '
            'and excluded origins, reversed named mark order, changed original regex and missing '
            'snapshot. The retained actual initial warning is rejected for empty outer stderr. '
            '15 book controls reject missing examples/authority/input guards, forged artifacts '
            'and failed rendering.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print(str(len(inputs)) + ' bound actual producer/artifact inputs; named Legacy claim published')
