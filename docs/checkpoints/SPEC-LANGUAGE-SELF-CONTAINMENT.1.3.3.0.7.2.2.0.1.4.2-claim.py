"""Publish anonymous Legacy origins from retained complete runtime and book evidence."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.2'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
REVISION = 'd52add3e5e070b243eb3a2a532d061b51994a36a'

def sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()

runtime, book, freeze = [json.loads((ROOT / (PREFIX + name + '.json')).read_bytes())
                         for name in ('verification', 'book-verification', 'freeze')]
assert runtime['complete'] and book['complete']
assert runtime['revision'] == freeze['revision'] == REVISION
assert tuple(runtime[k] for k in ('regular_inputs', 'overlays', 'contracts', 'cases',
    'commands', 'seeds', 'before_origins', 'after_origins', 'events_per_seed',
    'before_red_groups', 'after_green_groups', 'fixture_suites', 'fixture_groups',
    'compiler_cases_per_seed')) == (4394, 3, 112, 115, 8, 3, 18, 71, 227, 27, 50, 10, 1225, 11)
assert len(runtime['controls']) == 159
assert all(c['observed'] == 'RED' and c['reason'] for c in runtime['controls'])
assert (book['book_inputs'], book['rendered_examples'], book['rendered_sections'],
        len(book['controls']), freeze['bound_inputs'], freeze['unique_inputs'],
        freeze['claims']) == (58, 5, 3, 13, 43, 43, 1)
for report, producer in ((runtime, 'review.py'), (book, 'book.py'), (freeze, 'freeze.py')):
    assert report['instrument_sha256'] == sha(PREFIX + producer)

statement = ('The26 original anonymous Legacy regex producers retain their own scalar bounds '
    'before argument decoding and preserve actual returned/constructor/argument references. '
    'Each epoch retains4394 immutable regular Git originals, one declared standard-fixture '
    'replacement and three authored overlays; after replaces only LegacyRules production. '
    'Eight guarded commands cover112 original contracts/115 cases under three seeds, '
    'retaining227 events and growing private origins18-to71 per seed. Complete public events, '
    'arguments, default callbacks, substitution, descriptors, diagnostics and parser-source '
    'channels remain unchanged. The standard source fixture is actual RED27/GREEN50; '
    'ten suites1225 groups including Phase01035 pass.159 reason-specific controls observe '
    'RED. The58-input book renders five examples/three chapters with13 RED controls. '
    'All43 prior live claim input hashes verify before exact historical freeze.')
scope = ('Original internal compatibility population at ' + REVISION + '. Supplied inputs '
    'are a complete regular Git superset, not a minimal observed IO census; gitlinks and '
    'nonregular entries are metadata-only exclusions. Entire source inverse reconstruction '
    'removes exactly26 snapshots/wrappers to recover the clean original file. Original '
    'recognizers, raw spellings, argument expressions, dispatch and callback behavior stay '
    'exact. The literal115-case oracle changes only the already verified quoted-comma labels; '
    'historical original fixture bytes remain immutable. Scalar Unicode/CRLF/repeated spans '
    'are independently authored. Actual object references distinguish equal-valued copies. '
    'Previously accepted call origins and boundary lexical behavior remain intact. Macro '
    'dollar inclusion and take aliases retain their original regex match spelling. Quoted '
    'syntactic recognition is preserved; executable quoted/comment membership and replacement '
    'authority remain separately owned under .7.2.2. Named/mark/cursor/entry families and '
    'other backends are not admitted. Book examples are rendered teaching, not execution. '
    'Host OS/Perl/Python/prove/mdBook are necessary read-only toolchain inputs; project data '
    'stays on the repository volume and RGX/PGEN remain black boxes. No public schema, '
    'ScannerCore, recognizer grammar, CI/hook/storage/dependency or other-repository change. '
    'Prior proof and adjudications stay exact; only prior durability mode/revision changes. '
    'Focused verification does not claim canonical CI; family/push boundaries still require it.')

paths = [p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*')
         if p.is_file()]
paths += [
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0-cases.json',
    'perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm',
    'perl/LinkedSpec/ActionIR/ScannerCore.pm', 't/actionir_helper_source_provenance.t',
    'docs/knowledge/perl-legacy-anonymous-capture-source-origins.md',
    'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
    'tools/project_data_env.sh', 'tools/project_data_run.sh',
    'tools/run_python_project_data.sh', 'tools/check_claim_verification.py']
inputs = [{'path': path, 'sha256': sha(path),
           'role': 'producer' if path.endswith(('.py', '.pl', '.pm', '.t', '.sh')) else 'input'}
          for path in sorted(set(paths))]
commands = '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + command
    for command in ('capture.py before', 'capture.py after', 'review.py', 'freeze.py',
                    'book.py --review', 'claim.py'))
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'anonymous-legacy-capture-source-origins', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked', 'command': commands,
        'granularity': '4394 originals/one fixture replacement/three overlays per epoch/one '
            'production delta;112 contracts/115 cases/three seeds/227 events/18-to71 origins;'
            'RED27-GREEN50/ten suites1225 groups;58 book inputs/five examples/three chapters;43 prior hashes.',
        'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Missing/wrong source frames, copied objects, changed callbacks/compiler '
            'channels, invented excluded origins or incomplete inputs/positive TAP could falsely '
            'establish source compatibility.',
        'oracle': 'Independent original literal events/arguments/scalar intervals; actual '
            'returned/constructor/argument identities; full original public/compiler channels; '
            'whole-file original Git byte inverse; complete input/mode/population, declared '
            'overlays, full streams/exit/guards and ordered positive/nested TAP.',
        'red_control': 'Untouched Legacy fails27 expanded groups; repaired source passes50. '
            'All159 observed reason-specific controls reject omitted events for all112 contracts, '
            'missing origins for all27 anonymous rows, forged references/spans/callbacks/compiler '
            'dump, missing commands/guards/inputs/overlays, forged producer/channel/exit/TAP or '
            'nested failures, invented excluded/uninstrumented origins and changed original '
            'capture regex or missing coordinate snapshot.13 rendered-book controls reject '
            'missing examples/source authority, forged inputs/channels/producer and failed rendering.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print(str(len(inputs)) + ' bound actual producer/artifact inputs; anonymous Legacy claim published')
