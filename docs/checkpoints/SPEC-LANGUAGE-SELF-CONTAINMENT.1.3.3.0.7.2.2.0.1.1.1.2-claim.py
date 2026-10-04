"""Publish the bounded private basic statement event source proof."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
DIAGNOSIS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-'
REVISION = 'aef9e551c7e563985c79c53fcba574ee5df8d509'

def digest(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()

results = {name: json.loads((ROOT / (PREFIX + name + '.json')).read_bytes())
           for name in ('verification', 'consumer-verification', 'book-verification', 'freeze', 'guard-verification')}
r = results['verification']; c = results['consumer-verification']; b = results['book-verification']; g = results['guard-verification']
assert r['revision'] == c['revision'] == results['freeze']['revision'] == REVISION
assert (r['git_inputs'], r['supplied_inputs'], r['compiler_pairs'], r['frames'],
        r['fixture_groups'], r['before_failed_groups'], r['after_failed_groups']) == (3811, 3813, 66, 177, 29, 21, 0)
assert r['event_origins'] == 111 and r['initial_boundaries_preserved']
assert g['supplied_inputs'] == 3813 and g['fixture_groups'] == 29 and g['before_failed_groups'] == [29] and g['after_failed_groups'] == [] and g['probe_pairs'] == 3
assert len(g['controls']) == 5 and all(control['rejected'] for control in g['controls'])
assert g['instrument_sha256'] == digest(PREFIX+'guard-review.py')
assert (c['suites'], c['top_level_tests'], b['book_inputs'], b['rendered_examples']) == (8, 1148, 58, 5)
assert b['complete'] and results['freeze']['bound_inputs'] == 21
assert tuple(len(result['controls']) for result in (r, c, b)) == (16, 8, 5)
assert all(item['rejected'] and item['reason'] for result in (r, c, b) for item in result['controls'])
for result, producer in ((r, 'review.py'), (c, 'consumer-review.py'), (b, 'book.py'), (results['freeze'], 'freeze.py')):
    assert result['instrument_sha256'] == digest(PREFIX + producer)

paths = [path.relative_to(ROOT).as_posix()
         for path in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if path.is_file()]
paths += [DIAGNOSIS + name for name in ('capture.py', 'review.py', 'cases.json', 'verification.json')]
paths += ['perl/LinkedSpec/ActionIR/ScannerCore.pm', 'perl/LinkedSpec/ActionIR/Scanner/PrimitiveBasicRules.pm', 't/actionir_basic_statement_source_provenance.t',
          'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
          'tools/run_python_project_data.sh', 'tools/project_data_run.sh', 'tools/project_data_env.sh']
inputs = [{'path': path, 'sha256': digest(path),
           'role': 'producer' if path.endswith(('.py', '.pl', '.pm', '.t', '.sh')) else 'input'}
          for path in sorted(set(paths))]
statement = ('Eleven basic statement producers retain the exact original event/argument objects and aligned original '
             'Unicode scalar source origins privately. The same 29-group fixture fails21 groups against original producers '
             'and passes all29 after the hooks. Sixty-six complete before/after Toolbox compiler pairs retain identical '
             'public results and177 unchanged authored statement frames while111 event origins match exact original '
             'occurrence intervals. Each fixed boundary supplies3811 immutable regular Git inputs and the same two '
             'explicit fixture/probe overlays, totaling3813 members; only PrimitiveBasicRules and ScannerCore contents '
             'differ between phases. Eight unchanged consumers pass1148 complete top-level groups including1034 Phase0. '
             'Sixteen independent event/source/compiler controls, eight consumer controls and five render controls reject '
             'their specific corruptions. A separately source-fixed same29-group guard fixture fails only group29 before the source guard and passes afterward; three actual foreign-source probe pairs and five guard controls verify the repair at3813 complete inputs. Five examples render from58 separately retained complete book inputs. All21 '
             'original cleanup input hashes verify before that claim freezes at the exact activation commit.')
scope = ('Bounded eleven producer hooks over the implemented private canonical statement frame channel, not canonical '
         'family acceptance, wider twenty-contract composition, executable membership/comment semantics, source replacement, '
         'runtime execution, DSL/backend admission, cross-host equivalence or global audit closure. Ordinary scans call '
         'their existing split callback directly. Private scans call it once with its original arguments; exact returned '
         'array identity and statement occurrence index select frames before filtering, never equal-text search. '
         'Opaque/copied split results, changed entries and later custom trim transformations preserve events and decline '
         'fabricated origins. A pre-callback source snapshot declines foreign canonical source frames; the fixed-input foreign-source probe changes from one wrong origin before the guard to zero afterward. The initial live probe is exploratory and is not promoted to closed-input acceptance. Original initial28-group source/fixture/captures/reviewer and separately retained pre-guard consumer channels are not promoted to final guarded acceptance. The previous book-input boundary remains separately recoverable. Exact event/argument identity, five callback signatures/call sequence, empty results, nested '
         'collectors, callback exception count/text and caller error state are covered. Arbitrary malicious callback '
         'mutations and arbitrary host syntax are unassessed. The complete supplied-input superset is not a minimal '
         'observed runtime read set. Regular Git bytes/modes are recoverable at ' + REVISION + '; both exact common overlays, '
         'both after-only production replacements with original Git identities, manifests, actual producer hashes and '
         'both full channels are retained. Gitlinks/non-regular entries are excluded without payload reads. Every actual '
         'command has before/after contents/modes/population guards. Read-only host OS/Perl/Python standard libraries and '
         'PATH-resolved prove/mdBook are necessary external execution prerequisites; consumer/render executable SHA '
         'identities are recorded separately. All project-owned scratch/output stays on the repository filesystem. '
         'Canonical eleven-contract family acceptance belongs to .1.1.1.3; twenty-contract composition, remaining '
         'producers/membership/replacement and broader historical claim audit retain their separate owners.')
command = '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + step for step in
                    ('capture.py --mode before', 'capture.py --mode after', 'review.py', 'guard-capture.py --mode before', 'guard-capture.py --mode after', 'guard-review.py', 'guarded-consumers.py',
                     'consumer-review.py', 'freeze.py', 'book.py --review'))
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'private-basic-statement-event-source-channel', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked', 'command': command,
                 'granularity': 'Complete immutable Git membership/object/SHA256/mode census and explicit overlays; '
                 'all actual command boundaries and full channels; 29 ordered fixture groups and exact observed RED; '
                 'all 22 authored source cases across three seeds, 66 full public compiler pairs and 177 unchanged source frames and111 event origins; '
                 'eight complete ordered positive TAP plans; complete 58-input render capsule and five literal examples; '
                 'exact21-input historical cleanup freeze.', 'result': statement},
    'falsify': {'status': 'checked',
                'hypothesis': 'Equal raw text, byte offsets, dropped comments/frames, altered public compiler results, '
                'unretained inputs, changed producers, incomplete or failed actual commands could falsely pass frame acceptance.',
                'oracle': 'Independent literal-segment construction and Unicode scalar occurrence offsets; full public '
                'compiler equality; immutable Git object/content/mode census; exact actual producer and channel hashes; '
                'complete ordered TAP reach including nested failures; original authored examples in actual rendered HTML.',
                'red_control': 'The unchanged 29-group fixture observes actual baseline exit 1 and exactly 21 failed '
                'top-level groups, then actual changed-producer exit 0 with all 29 groups passing. Sixteen reason-sensitive '
                'corruptions reject altered compiler results, dropped/reused/byte-offset/quoted event origins, forged event identity, dropped frames, invented '
                'event origins, missing or forged source/producer overlays, partial reports, forged producers/guards/exits/channels. '
                'The separate complete guard fixture fails group29 at its original pre-guard source and passes29 after; three literal probe pairs independently verify foreign-source rejection, with five guard corruptions. Eight consumer corruptions reject omitted/partial suites or forged producer/source manifest/source tree/guard/exit/channel. Five render '
                'corruptions reject failed render, missing guard, forged producer/channel and missing examples.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}
}]}
target = ROOT / 'docs/claims' / (OWNER + '.json')
target.write_text(json.dumps(record, indent=2) + '\n')
assert target.stat().st_size <= 131072
print('Published private basic statement event claim with ' + str(len(inputs)) + ' retained producer/input artifacts')
