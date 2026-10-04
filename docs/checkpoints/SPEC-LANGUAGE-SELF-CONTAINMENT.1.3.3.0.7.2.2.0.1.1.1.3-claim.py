"""Publish the exact fresh statement-family acceptance, separate from canonical CI."""
from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
OWNER = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.3'
PREFIX = 'docs/checkpoints/' + OWNER + '-'
PREVIOUS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2-'
DIAGNOSIS = 'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-'
REVISION = 'ab2c0b9357007aab31302e01c9f4a73aaf2fc5c8'


def digest(path):
    return hashlib.sha256((ROOT / path).read_bytes()).hexdigest()


results = {name: json.loads((ROOT / (PREFIX + name + '.json')).read_bytes())
           for name in ('verification', 'book-verification', 'freeze', 'retention-verification')}
r, b, f = (results[n] for n in ('verification', 'book-verification', 'freeze'))
assert r['revision'] == f['revision'] == REVISION
assert (r['git_inputs'], r['overlays'], len(r['contracts']), r['fixture_suites'], r['fixture_groups'],
        r['toolbox_inspections'], r['frames'], r['event_origins'], r['foreign_source_probes']) == (3864, 0, 11, 4, 80, 66, 177, 111, 3)
assert r['exact_previous_guarded_compiler_recurrence'] and r['diagnostic_replays_source_bound'] and r['original_formatter_input_gap_disclosed']
assert r['diagnostic_controls'] == 6
retention = results['retention-verification']
assert retention['complete'] and retention['failed_replays'] == 2 and retention['logical_frames'] == 6
assert len(retention['controls']) == 6 and all(c['observed'] == 'RED' for c in retention['controls'])
assert retention['instrument_sha256'] == digest(PREFIX + 'review-retention.py')
assert (len(r['controls']), b['book_inputs'], b['rendered_examples'], len(b['controls']), f['bound_inputs']) == (15, 58, 5, 6, 61)
assert all(c['observed'] == 'RED' and c['reason'] for c in r['controls'])
assert b['complete'] and all(c['rejected'] and c['reason'] for c in b['controls'])
for result, producer in ((r, 'review.py'), (b, 'book.py'), (f, 'freeze.py')):
    assert result['instrument_sha256'] == digest(PREFIX + producer)
paths = [p.relative_to(ROOT).as_posix() for p in (ROOT / 'docs/checkpoints').glob(OWNER + '-*') if p.is_file()]
paths += [DIAGNOSIS + name for name in ('capture.py', 'review.py', 'cases.json', 'verification.json')]
paths += [PREVIOUS + name for name in ('review.py', 'after.json', 'probe.pl', 'guard-probe.pl')]
paths += ['perl/LinkedSpec/ActionIR/StatementSplit/Core.pm', 'perl/LinkedSpec/ActionIR/ScannerCore.pm',
          'perl/LinkedSpec/ActionIR/Scanner/PrimitiveBasicRules.pm',
          't/actionir_statement_source_frames.t', 't/actionir_basic_statement_source_provenance.t',
          't/actionir_basic_regex_source_provenance.t', 't/actionir_helper_source_provenance.t',
          'docs/linkedspec-book/src/dsl/actionir-lowering-mental-model.md',
          'docs/linkedspec-book/src/development/documentation-workflow.md',
          'tools/project_data_env.sh', 'tools/project_data_run.sh', 'tools/run_python_project_data.sh']
inputs = [{'path': p, 'sha256': digest(p), 'role': 'producer' if p.endswith(('.py', '.pl', '.pm', '.t', '.sh')) else 'input'} for p in sorted(set(paths))]
statement = ('Fresh eleven-contract statement-family recurrence supplies all3864 regular Git inputs from the immutable '
             'activation commit, without overlays. Four unchanged focused fixtures pass80 complete groups. '
             'Sixty-six Toolbox inspections retain177 authored scalar frames and111 exact original event origins, '
             'including original reference identities; all three-seed full compiler channels equal the prior guarded '
             'boundary exactly. Three foreign-source probes preserve their declaration events with no invented origins. '
             'Fifteen reason-specific acceptance controls observe RED, six diagnostic-context controls and six render controls reject corruptions. Two source-bound failed replays reproduce their original errors with all six displayed logical frames matching executed source. '
             'Five original examples render from58 complete book inputs. All61 original prior producer-claim input '
             'hashes verify before its historical mode/revision-only freeze.')
scope = ('The eleven basic statement contracts and their private splitter/producer/source-authority composition only. '
         'This is a new immutable activation-boundary recurrence, not relabeled prior observations or a new behavior '
         'change. The supplied regular Git population is a conservative input superset, not minimal observed IO; '
         'original bytes, modes, object identities and excluded metadata are recoverable at ' + REVISION + '. '
         'Every actual recurrence command has complete before/after population/content/mode guards and full stdout/stderr. '
         'Current Perl/spec/test bytes must still equal those immutable members during review. Exact original authored '
         'segments independently define Unicode scalar intervals and event occurrence indices; no equal-raw search. '
         'Unknown/copied/transformed/foreign callbacks decline fabricated frames while retaining existing events; the '
         'permanent fixtures cover nesting, error state, callback signatures/counts and original array/event identity. '
         'Two initial reviewer defects and the renamed-file selection attempts retain original source and actual failed '
         'channels separately; only the reviewer is repaired. Complete publication inputs and rendered HTML remain a '
         'separate captured boundary. Host OS/Perl/Python standard libraries and PATH-resolved prove/mdBook are necessary '
         'read-only prerequisites. Project scratch is repository-local on the same volume. Gitlinks/non-regular entries '
         'are excluded without dependency payload reads. Canonical CI is an independently required exact staged-receipt '
         'landing condition; this record does not publish a canonical CI measurement. Wider twenty-contract composition, '
         'remaining producers, executable membership, comment semantics, source replacement, arbitrary host syntax, '
         'malicious callback mutation, cross-host/backend admission and global historical audit remain separately owned.')
commands = '; '.join('bash tools/run_python_project_data.sh ' + PREFIX + step for step in
                     ('capture.py', 'review-retention.py', 'review.py', 'freeze.py', 'book.py --review'))
record = {'version': 1, 'owner': OWNER, 'claims': [{
    'name': 'eleven-statement-family-immutable-recurrence', 'statement': statement, 'scope': scope,
    'rederive': {'status': 'checked', 'command': commands,
                 'granularity': '3864 exact regular Git members, all7 actual commands/channels/guards, four ordered TAP suites/80 groups,22 authored sources/three seeds,177 frames/111 origins/66 complete compiler inspections, three literal foreign-source probes,58 complete render inputs/five examples and61 unchanged prior input hashes.',
                 'result': statement},
    'falsify': {'status': 'checked',
                'hypothesis': 'Equal text, altered source/event identity, unretained inputs or producers, partial or failed runs, incomplete TAP and invented foreign origins could falsely pass family acceptance.',
                'oracle': 'Independent authored literal segments/scalar intervals and event indices; exact prior guarded full-channel equality; literal foreign-source public/private result; independent Git object/content/mode/membership census; exact producer/channel hashes and complete ordered TAP plans with nested failure rejection; original rendered examples.',
                'red_control': 'Fifteen observed reason-specific RED controls reject dropped/reused origins, forged reference identity, dropped frames, invented foreign origins, missing/forged Git inputs, partial runs, forged producer/guard/channel, unsuccessful exits, omitted suites, shortened plans and concealed nested failures. Six render corruptions reject failed render, missing input guard, forged renderer/channel, missing examples and missing developer diagnostic teaching. Six diagnostic-context controls reject both original unbound contexts, partial replays, forged replay producer, erased actual failure and forged channel. Original reviewer and selection failures retain actual full channels, without changing observed fixture output.'},
    'durability': {'status': 'checked', 'mode': 'live', 'inputs': inputs}
}]}
target = ROOT / 'docs/claims' / (OWNER + '.json')
target.write_text(json.dumps(record, indent=2) + '\n')
assert target.stat().st_size <= 131072
print('Published statement-family recurrence claim with ' + str(len(inputs)) + ' retained input/producer artifacts')
