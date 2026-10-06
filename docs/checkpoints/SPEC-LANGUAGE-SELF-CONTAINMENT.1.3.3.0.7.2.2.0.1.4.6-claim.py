"""Publish entry/match provenance from retained, complete focused evidence."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.6'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
REVISION = '7113d085b4b7ec0ef11e2f009395d9f2b6e71f21'


def sha(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


runtime, book, freeze = [json.loads((ROOT / (PREFIX + name + '.json')).read_bytes())
                         for name in ('verification', 'book-verification', 'freeze')]
assert runtime['complete'] and book['complete']
assert runtime['revision'] == freeze['revision'] == REVISION
assert tuple(runtime[k] for k in ('overlays', 'contracts', 'cases', 'commands', 'seeds',
    'before_origins', 'after_origins', 'events_per_seed', 'before_red_groups',
    'after_green_groups', 'fixture_suites', 'fixture_groups', 'compiler_cases_per_seed')) == (
        3, 112, 115, 8, 3, 163, 227, 227, 32, 128, 12, 1318, 11)
assert len(runtime['controls']) == 168
assert all(c['observed'] == 'RED' and c['reason'] for c in runtime['controls'])
assert (book['book_inputs'], book['rendered_examples'], book['rendered_sections'],
        len(book['controls']), freeze['bound_inputs'], freeze['unique_inputs'],
        freeze['claims']) == (58, 14, 3, 21, 35, 35, 1)
for report, producer in ((runtime, 'review.py'), (book, 'book.py'), (freeze, 'freeze.py')):
    assert report['instrument_sha256'] == sha(PREFIX + producer)

count = runtime['regular_inputs']
statement = (f'The32 original entry/match producers preserve original scalar bounds, '
    f'index-string/name/empty arguments, actual alias spelling and event/argument references. '
    f'Each epoch retains{count} immutable regular Git originals, one declared standard-fixture '
    'replacement and three authored overlays; after replaces only LegacyRules production. '
    'Eight guarded commands cover112 contracts/115 cases under three seeds, retaining227 '
    'events and growing private origins163-to227 per seed. Complete original public events, '
    'arguments, default callbacks and compiler channels remain unchanged. Actual original '
    'RED32/GREEN128; twelve suites1318 groups including generated source12 and Phase01035 '
    'pass.168 effective reason-specific controls observe RED. The58-input book renders14 '
    'examples/three chapters with21 RED controls.35 prior claim hashes verify before exact '
    'historical freeze.')
scope = ('Original internal compatibility population at ' + REVISION + '. Regular Git '
    'inputs are a complete supplied superset, not a minimal observed IO census; gitlinks '
    'and nonregular entries are metadata-only exclusions. Whole-file inverse removes '
    'only32 snapshots/wrappers to recover committed original bytes. Every recognizer, raw '
    'and argument expression, callback and dispatch stays exact. Independent115-case '
    'literal events/index/name arguments and Unicode/CRLF/repeated scalar intervals remain '
    'unchanged. Actual returned/constructor/argument references distinguish clones. All32 '
    'scanners construct captured/empty args directly without parser/trim callbacks. Group '
    'indices remain captured strings, symbolic names stay exact and aliases retain actual '
    'raw spelling; no argument coercion or alias normalization is added. All prior source '
    'families and boundary repairs recur; all227 original syntactic events have origins. '
    'No entry/local-match runtime values, absent/empty/zero-text distinctions, cursor '
    'semantics, grammar, public schema, ScannerCore, CI/hook/storage/dependency or '
    'other-repository change. The unchanged generated-source suite exercises native '
    'and warning-enabled fresh emitted entry cases; this does not create a new absence '
    'contract. Fresh complete-family acceptance remains .1.4.7-owned after scheduled '
    'rollover infrastructure repair. Executable quoted/comment membership, replacement, '
    'other backends and broad audits remain separate. The existing mark-copy observation '
    'repair remains CONFORMANCE-SOURCE-READING.2.7-owned. Every final corruption must '
    'alter its input, stable IDs/family guards protect index/name/alias control scope, '
    'and the source regex has one actual original target. Previous producer/report/'
    'count/adjudication bytes remain exact; only prior durability becomes historical. '
    'Book examples are rendered teaching. Necessary host tools are read-only; all project '
    'data remains repository-volume rooted and RGX/PGEN remain black boxes. Wrapper '
    'startup .7 owns establishment/liveness; recovery/purge stay prohibited and no '
    'lifecycle guarantee follows. Focused proof does not claim canonical CI; infrastructure/'
    'complete-family/push boundaries require it.')
paths = [p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*')
         if p.is_file()]
paths += [
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-capture.py',
    'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0-cases.json',
    'perl/LinkedSpec/ActionIR/Scanner/LegacyRules.pm',
    'perl/LinkedSpec/ActionIR/ScannerCore.pm', 't/actionir_helper_source_provenance.t',
    't/generated_source_contract.t',
    'docs/knowledge/perl-legacy-entry-match-source-origins.md',
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
    'name': 'entry-match-legacy-source-origins', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked', 'command': commands,
        'granularity': f'{count} originals/one fixture replacement/three overlays per epoch/'
            'one production delta;112 contracts/115 cases/three seeds/227 events/163-to227 '
            'origins;RED32-GREEN128/twelve suites1318 groups;58 book inputs/14 examples/'
            'three chapters;35 prior hashes.', 'result': statement},
    'falsify': {'status': 'checked',
        'hypothesis': 'Wrong scalar intervals, coerced group indices or symbolic names, '
            'normalized alias spelling, copied objects, changed compiler channels or '
            'incomplete input/TAP evidence could falsely establish source compatibility.',
        'oracle': 'Original independent literal raw/index-string/name/empty arguments and '
            'scalar bounds, actual object identities, entire original Git source inverse, '
            'all original public compiler channels, full input/mode/population/replacement/'
            'stream/exit/guard and complete ordered positive TAP.',
        'red_control': 'Original source fails32 expanded groups; repaired source passes128. '
            'All168 effective denials cover112 omitted events,32 missing entry/match origins, '
            'forged references/spans/callbacks/compiler channels/producer/inputs/commands/'
            'guards/exits/TAP, nested failures, invented original entry/extra match/'
            'excluded origins, changed group index/name/alias, original regex and snapshot. '
            'Every mutation alters its input and exact rejection reasons are observed. '
            'All21 book controls reject missing teaching/authority/examples/guards, '
            'forged artifacts and failed rendering.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}}]}
(ROOT / ('docs/claims/' + OWNER + '.json')).write_text(json.dumps(record, indent=2) + '\n')
print(str(len(inputs)) + ' bound actual producer/artifact inputs; entry/match claim published')
