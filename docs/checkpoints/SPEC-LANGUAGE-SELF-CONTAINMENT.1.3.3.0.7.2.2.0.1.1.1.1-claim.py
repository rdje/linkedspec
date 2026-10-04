"""Publish the bounded private canonical splitter frame proof."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.1'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
DIAGNOSIS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-'
REVISION = 'e6140e2240879377dc1280b73194cb93554bae7b'

def digest(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()

results = {name: json.loads((ROOT / (PREFIX + name + '.json')).read_bytes())
           for name in ('verification', 'consumer-verification', 'book-verification', 'freeze')}
r = results['verification']; c = results['consumer-verification']; b = results['book-verification']
assert r['revision'] == c['revision'] == results['freeze']['revision'] == REVISION
assert (r['git_inputs'], r['supplied_inputs'], r['compiler_pairs'], r['frames'],
        r['fixture_groups'], r['before_failed_groups'], r['after_failed_groups']) == (3764, 3766, 66, 177, 28, 25, 0)
assert r['initial_boundaries_preserved']
assert (c['suites'], c['top_level_tests'], b['book_inputs'], b['rendered_examples']) == (8, 1148, 58, 4)
assert b['complete'] and results['freeze']['bound_inputs'] == 28
assert tuple(len(result['controls']) for result in (r, c, b)) == (15, 6, 5)
assert all(item['rejected'] and item['reason'] for result in (r, c, b) for item in result['controls'])
for result, producer in ((r, 'review.py'), (c, 'consumer-review.py'), (b, 'book.py'), (results['freeze'], 'freeze.py')):
    assert result['instrument_sha256'] == digest(PREFIX + producer)

paths = [path.relative_to(ROOT).as_posix()
         for path in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if path.is_file()]
paths += [DIAGNOSIS + name for name in ('capture.py', 'review.py', 'cases.json', 'verification.json')]
paths += ['perl/LinkedSpec/ActionIR/StatementSplit/Core.pm', 't/actionir_statement_source_frames.t',
          'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
          'tools/run_python_project_data.sh', 'tools/project_data_run.sh', 'tools/project_data_env.sh']
inputs = [{'path': path, 'sha256': digest(path),
           'role': 'producer' if path.endswith(('.py', '.pl', '.pm', '.t', '.sh')) else 'input'}
          for path in sorted(set(paths))]
statement = ('The private canonical splitter channel preserves the original callback result and aligned original '
             'Unicode scalar source frames. The same 28-group fixture fails 25 groups against the original Core '
             'and passes all 28 against the changed Core. Sixty-six complete before/after Toolbox compiler pairs '
             'retain identical public results while producing 177 authored source frames after the change. '
             'Each fixed boundary supplies 3764 immutable regular Git inputs and the same two explicit fixture/probe '
             'overlays, totaling 3766 inputs; only the Core contents differ between the boundaries. Eight unchanged '
             'consumers pass 1148 complete top-level groups, including 1034 Phase-0 groups. Fifteen independent '
             'frame controls, six consumer controls and five render controls reject their specific corruptions. '
             'Four examples render from 58 separately retained book inputs. The original initial fixture/Core '
             'boundaries and actual streams remain separately recoverable. All 28 original diagnosis input hashes '
             'verify before its claim freezes at the exact activation commit.')
scope = ('Bounded private statement-frame implementation, not the eleven statement event hooks, executable '
         'membership/comment semantics, runtime execution, DSL/backend admission, cross-host equivalence or global '
         'audit closure. The callback executes once with its original arguments; exact returned-array identity and '
         'occurrence index select frames, never an equal-text search. Opaque/copied results, changed entries, '
         'non-scalar source and custom interior transformations decline fabricated coordinates; unaffected exact '
         'entries and nested collectors are covered. Arbitrary malicious callback mutations and arbitrary host '
         'syntax are unassessed. The complete supplied-input superset is not a minimal observed runtime read set. '
         'Regular Git bytes/modes are recoverable at ' + REVISION + '; explicit overlays, original initial Core/test '
         'bytes, manifests, producer hashes and both actual channels are retained. Gitlinks and non-regular entries '
         'are excluded without payload reads. Every actual command has before/after contents/modes/population guards. '
         'Read-only host OS, Perl, Python standard libraries and PATH-resolved prove/mdBook are necessary external '
         'execution prerequisites; consumer/render executable SHA identities are recorded separately. Project-owned '
         'scratch and outputs stay on the repository filesystem. Eleven producer hooks belong to .1.1.1.2; '
         'canonical statement-family acceptance belongs to .1.1.1.3; twenty-contract composition and broader '
         'historical claim audit remain open.')
command = '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + step for step in
                    ('capture.py --mode before', 'capture.py --mode after', 'review.py', 'consumers.py',
                     'consumer-review.py', 'freeze.py', 'book.py --review'))
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'private-canonical-statement-frame-channel', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked', 'command': command,
                 'granularity': 'Complete immutable Git membership/object/SHA256/mode census and explicit overlays; '
                 'all actual command boundaries and full channels; 28 ordered fixture groups and exact observed RED; '
                 'all 22 authored source cases across three seeds, 66 full public compiler pairs and 177 source frames; '
                 'eight complete ordered positive TAP plans; complete 58-input render capsule and four literal examples; '
                 'original initial producer/input boundaries and exact 28-input historical freeze.', 'result': statement},
    'falsify': {'status': 'checked',
                'hypothesis': 'Equal raw text, byte offsets, dropped comments/frames, altered public compiler results, '
                'unretained inputs, changed producers, incomplete or failed actual commands could falsely pass frame acceptance.',
                'oracle': 'Independent literal-segment construction and Unicode scalar occurrence offsets; full public '
                'compiler equality; immutable Git object/content/mode census; exact actual producer and channel hashes; '
                'complete ordered TAP reach including nested failures; original authored examples in actual rendered HTML.',
                'red_control': 'The unchanged 28-group fixture observes actual baseline exit 1 and exactly 25 failed '
                'top-level groups, then actual changed-Core exit 0 with all 28 groups passing. Fifteen reason-sensitive '
                'corruptions reject altered compiler results, dropped/reused/byte-offset/quoted/comment frames, invented '
                'event origins, missing or forged source/Core overlays, partial reports, forged producers/guards/exits/channels. '
                'Six consumer corruptions reject omitted/partial suites or forged producer/guard/exit/channel. Five render '
                'corruptions reject failed render, missing guard, forged producer/channel and missing examples.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}
}]}
target = ROOT / 'docs/claims' / (OWNER + '.json')
target.write_text(json.dumps(record, indent=2) + '\n')
assert target.stat().st_size <= 131072
print('Published private splitter frame claim with ' + str(len(inputs)) + ' retained producer/input artifacts')
