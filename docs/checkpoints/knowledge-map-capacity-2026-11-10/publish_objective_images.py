"""Publish finite source-identity admission with all actual recovery inputs."""
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
TARGET = ROOT / 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.18.1.json'
original = TARGET.read_bytes(); record = json.loads(original)
assert len(record['claims']) == 4, 'one-shot image publication'
archive = HERE / 'implementation-pre-objective-claim.json.gz'
assert not archive.exists(); archive.write_bytes(gzip.compress(original, mtime=0))
result = json.loads((HERE / 'objective-current-result.json').read_bytes())
recovery = json.loads((HERE / 'objective-recovery-qualified-result.json').read_bytes())
actual = json.loads(gzip.decompress((HERE / 'objective-current-recovery.stdout.log.gz').read_bytes()))
assert result['result'] == recovery['result'] == 'PASS'
assert actual['restored_inputs'] == 134 and len(actual['controls']) == 22
assert actual['audit_controls']['governance_mutations_rejected'] == 714
assert len(result['current_image_denials']) == 19
paths = {ROOT / name for name in actual['tracked_inputs']}
for name, expected in actual['tracked_inputs'].items():
    assert hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == expected
names = ('objective_image_intake.py', 'objective-image-intake.json.gz', 'objective-image-intake-result.json',
         'objective_frontier_intake.py', 'objective-frontier-intake.json.gz', 'objective-frontier-intake-result.json',
         'objective_successor_review.py', 'objective-successor-inputs.json.gz', 'objective-successor-result.json',
         'objective-first-recovery-stdout.log.gz', 'objective-first-recovery-stderr.log.gz',
         'objective_current_review.py', 'objective-current-inputs.json.gz', 'objective-current-unit.json.gz', 'objective-current-result.json',
         'objective_recovery_review.py', 'objective-current-recovery.stdout.log.gz', 'objective-current-recovery.stderr.log.gz',
         'objective-recovery-qualified-result.json', 'objective-recovery-review-initial.py.gz',
         'objective-recovery-review-initial.stdout.log.gz', 'objective-original-claim.json.gz',
         'preserve_objective_claim.py', 'objective-claim-preservation-result.json', 'canonical-fifth.log.gz',
         'implementation-pre-objective-claim.json.gz', 'publish_objective_images.py')
paths |= {HERE / name for name in names}
paths |= {ROOT / 'docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.3.json',
          ROOT / 'docs/checkpoints/task-acceptance-backend-scope/ci-registration-after.json.gz'}
assert TARGET not in paths
producers = {'tests/language-readiness/verify_objectives.py', 'tools/historical_objective_images.py',
             'tools/test_historical_objective_images.py', 'tests/language-readiness/recover_objective_audit_inputs.py',
             'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py',
             'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-archive.py',
             'tools/run_python_project_data.sh', 'tools/project_data_run.sh', 'tools/project_data_env.sh'}
producers |= {str((HERE / name).relative_to(ROOT)) for name in names if name.endswith('.py')}
inputs = [dict(path=path.relative_to(ROOT).as_posix(), sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
               role='producer' if path.relative_to(ROOT).as_posix() in producers else 'input') for path in sorted(paths)]
record['claims'].append(dict(
    name='bounded-committed-current-image-admission',
    statement='The finite historical source frontier admits four exact committed runtime successors and one previously accepted Dart emitter-test image while preserving the original image table, every historical/admitted predecessor stage and Phase0 calibration. Actual isolated recovery preserves all134 recovered inputs,22 recovery controls,714 accepted governance denials and every other prior control;19 current-image mutations reject.',
    scope='Exact149 historical source-hash paths from retained milestone records, compared with the actual independent recovery report. Fourteen existing effective images remain; four runtime source successors are committed at7289836f28e4873463ad1c50d354d8e66c77af8d. The sole first-image path is dart/test/source_emitter_test.dart from accepted Count73.3 commit553f9d18, with its exact historical Git predecessor. Existing exact inverses and documentation evolution remain separate. Original eighteen-only intake and four-path proof are bounded intermediates: the first direct recovery reveals the extra emitter test and earns no complete-recovery credit. Initial additional-unit ordering assertion fails before sorting the merged row map. The first recovery-comparison observer uses older pre-registration703 governance controls; preserve its source/empty stdout and qualify the baseline to accepted backend-registration714, not a product RED. Current actual producer closes191 observed artifact inputs within202 declared bodies; all are retained and hash-gated here. Completed channels are packaged after exit without original first-use capture credit. This is historical integrity/source identity, not fresh runtime/objective compatibility, feature promotion, full native/cache/transitive custody or parent23.4 admission.',
    rederive=dict(status='checked', command='bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/objective_current_review.py && bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/objective_recovery_review.py && bash tools/run_python_project_data.sh docs/checkpoints/knowledge-map-capacity-2026-11-10/preserve_objective_claim.py',
                  granularity='Every finite historical source path and admitted current/predecessor byte identity; actual isolated recovery population, prior control records and reported artifact input bodies; exact older claim preservation at acceptedf6295bc8.',
                  result=json.dumps(dict(images=result, recovery=recovery), sort_keys=True)),
    falsify=dict(status='checked', hypothesis='Source evolution can bypass historical/member/commit guards, replace old predecessor oracles, or silently drop a historical source/control while appearing to pass recovery.',
                 oracle='Unchanged original table and archived original ImageAdmissions producer recover every prior stage; the separate actual isolated consumer supplies the complete source population and accepted backend-registration epoch supplies prior recovery/control records.',
                 red_control='Actual canonical current-image refusal and the first direct non-table emitter-test refusal remain retained. Qualified actual source mutations reject on all19 paths; wrong successor/initial predecessor, foreign member, noncommit revision and both table-byte controls reject. Missing source and altered historical SHA reject against the actual complete source report. Legacy/successor/first-image mode/lineage/guard controls and the complete isolated producer pass with empty stderr; original recovery/controls stay exact.'),
    durability=dict(status='checked', mode='live', inputs=inputs)))
assert record['claims'][:4] == json.loads(original)['claims']
body = json.dumps(record, indent=2).encode() + b'\n'
assert len(body) <= 131072, len(body)
TARGET.write_bytes(body)
print(json.dumps(dict(result='PASS', bytes=len(body), claims=len(record['claims']), current_claim_inputs=len(inputs)), sort_keys=True))
