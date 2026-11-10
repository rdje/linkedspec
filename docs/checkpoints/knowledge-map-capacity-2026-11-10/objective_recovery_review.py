"""Retain completed recovery channels and compare all earlier audit controls."""
import argparse
import base64
import copy
import gzip
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OLD = ROOT / 'docs/checkpoints/task-acceptance-backend-scope/ci-registration-after.json.gz'
OUTPUT = HERE / 'objective-current-recovery.stdout.log.gz'
ERROR = HERE / 'objective-current-recovery.stderr.log.gz'


def packet(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert hashlib.sha256(raw).hexdigest() == row['sha256']
    return raw


def population(frontier, actual):
    expected = actual['audit_report']['latest_source_inputs']
    rows = frontier['rows']
    assert len(rows) == len({row['path'] for row in rows})
    assert {row['path'] for row in rows} == set(expected), 'historical source population mismatch'
    for row in rows:
        assert row['historical_sha256'] == expected[row['path']]['sha256'], 'historical source identity mismatch'


def review():
    current = json.loads(gzip.decompress(OUTPUT.read_bytes()))
    assert gzip.decompress(ERROR.read_bytes()) == b''
    previous = json.loads(packet(json.loads(gzip.decompress(OLD.read_bytes()))['report']))
    frontier = json.loads(gzip.decompress((HERE / 'objective-frontier-intake.json.gz').read_bytes()))
    population(frontier, current)
    assert current['audit_report']['latest_source_inputs'] == previous['audit_report']['latest_source_inputs']
    for name in ('restored_inputs', 'restored_bytes', 'restored_hashes', 'archive', 'controls'):
        assert current[name] == previous[name], 'original recovery boundary changed: ' + name
    assert current['isolated_deterministic_capture']
    assert current['healthy_audit_guard'] == previous['healthy_audit_guard'] == dict(original_log_attempts=0, tracked_write_attempts=0)
    old_controls = previous['audit_controls']
    new_controls = current['audit_controls']
    for name, value in old_controls.items():
        if name != 'current_image_mutations_rejected':
            assert new_controls[name] == value, 'prior audit controls changed: ' + name
    initial = {row['path'] for row in frontier['rows'] if row['classification'] == 'first-exact-image-required'}
    assert new_controls['current_image_mutations_rejected'] == sorted(set(old_controls['current_image_mutations_rejected']) | initial)
    declared = current['tracked_inputs']; observed = current['observed_artifact_inputs']
    assert set(observed) <= set(declared)
    assert all(declared[name] == value for name, value in observed.items())
    for name in ('tests/language-readiness/current-source-successors.json.gz', 'tests/language-readiness/additional-source-images.json.gz'):
        assert name in observed and name in declared
    # Every reported artifact input still has the bytes observed by the actual
    # consumer; publication binds these inputs rather than refreshing old hashes.
    for name, expected in declared.items():
        assert hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == expected, 'actual recovery input changed: ' + name
    rejected = []
    for label in ('missing-source', 'wrong-historical-sha'):
        changed = copy.deepcopy(frontier)
        if label == 'missing-source': changed['rows'].pop()
        else: changed['rows'][0]['historical_sha256'] = '0' * 64
        try: population(changed, current)
        except AssertionError as error:
            assert str(error) in ('historical source population mismatch', 'historical source identity mismatch')
            rejected.append(label)
        else: raise AssertionError('qualified source census corruption admitted')
    return dict(result='PASS', original_recovery_and_prior_controls_preserved=True,
                current_image_denials=new_controls['current_image_mutations_rejected'],
                complete_finite_source_population=True, declared_inputs=len(declared), observed_inputs=len(observed),
                rejected_controls=rejected, limits='Historical recovery integrity and exact committed source identities only; no fresh runtime/objective compatibility, feature promotion or full native/transitive custody. Completed actual command channels are packaged after exit; no retroactive first-use capture credit.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('--retain', action='store_true')
    args = parser.parse_args()
    if args.retain:
        for name, destination in (('stdout', OUTPUT), ('stderr', ERROR)):
            assert not destination.exists(), 'one-shot completed-channel retention'
            raw = (ROOT / ('.linkedspec-data/objective-current-recovery.' + name + '.log')).read_bytes()
            destination.write_bytes(gzip.compress(raw, mtime=0))
            assert gzip.decompress(destination.read_bytes()) == raw
    print(json.dumps(review(), sort_keys=True))
