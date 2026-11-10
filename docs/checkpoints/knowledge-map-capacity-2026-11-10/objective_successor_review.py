"""Replay exact successor lineage while preserving all original image stages."""
import argparse
import base64
import copy
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import types

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
SNAPSHOT = HERE / 'objective-successor-inputs.json.gz'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert packet(raw) == row
    return raw


def encoded(data):
    return gzip.compress(json.dumps(data, sort_keys=True, separators=(',', ':')).encode(), mtime=0)


def review(capture=False):
    names = ('tools/historical_objective_images.py', 'tools/test_historical_objective_images.py',
             'tests/language-readiness/verify_objectives.py',
             'tests/language-readiness/current-source-images.json.gz',
             'tests/language-readiness/current-source-successors.json.gz',
             'tests/language-readiness/phase0-fixture-calibration.json.gz',
             't/phase0_regression.t', str(Path(__file__).relative_to(ROOT)))
    if capture:
        assert not SNAPSHOT.exists(), 'one-shot source snapshot'
        SNAPSHOT.write_bytes(encoded({name: packet((ROOT / name).read_bytes()) for name in names}))
    saved = json.loads(gzip.decompress(SNAPSHOT.read_bytes()))
    assert set(saved) == set(names)
    for name, row in saved.items():
        assert decode(row) == (ROOT / name).read_bytes(), 'dated producer/input changed: ' + name
    intake = json.loads(gzip.decompress((HERE / 'objective-image-intake.json.gz').read_bytes()))
    spec = importlib.util.spec_from_file_location('successor_review_audit', ROOT / 'tests/language-readiness/verify_objectives.py')
    audit = importlib.util.module_from_spec(spec); spec.loader.exec_module(audit)
    read = lambda name: (ROOT / name).read_bytes()
    images = audit.current_image_admissions(read)
    effective, phase0 = audit.phase0_fixture_reader(read, images)
    sources = {row['path']: dict(sha256=row['original_row']['historical_sha256']) for row in intake['rows']}
    report = images.verify(sources, effective)
    old = types.ModuleType('original_image_admissions')
    old.__file__ = str(ROOT / 'tools/historical_objective_images.py')
    exec(compile(decode(intake['inputs']['tools/historical_objective_images.py']), old.__file__, 'exec'), old.__dict__)
    original_table = decode(intake['inputs']['tests/language-readiness/current-source-images.json.gz'])
    assert original_table == read('tests/language-readiness/current-source-images.json.gz')
    git = lambda *args: subprocess.check_output(['git', *args], cwd=ROOT)
    baseline = old.ImageAdmissions(original_table, hashlib.sha256(original_table).hexdigest(), git)
    prior_current = {row['path']: decode(row['prior_current']) for row in intake['rows']}
    baseline.verify(sources, prior_current.__getitem__)
    expected_changed = {row['path'] for row in intake['rows'] if row['changed']}
    assert set(images.successors.rows) == expected_changed
    assert phase0 == intake['phase0'] and images.data == baseline.data and images.rows == baseline.rows
    for row in intake['rows']:
        name = row['path']; current = effective(name)
        assert current == decode(row['effective_current'])
        assert images.predecessor(name, current) == baseline.predecessor(name, prior_current[name])
        actual = next(item for item in report if item['path'] == name)
        assert actual['current_sha256'] == row['effective_current']['sha256']
        if row['changed']:
            assert actual['activation_commit'] == intake['activation_commit']
            assert actual['previous_current_sha256'] == row['original_row']['current_sha256']
        else:
            assert actual['activation_commit'] == baseline.data['activation_commit']
    assert images.falsify(sources, effective) == sorted(sources)
    module = audit._IMAGE_MODULE
    data = json.loads(gzip.decompress(read(audit.CURRENT_SUCCESSOR_TABLE)))
    def build(candidate, protected=(audit.PHASE0_FIXTURE,)):
        raw = encoded(candidate)
        return module.SuccessorImageAdmissions(images.baseline,
            module.ImageAdmissions(raw, hashlib.sha256(raw).hexdigest(), audit.git), protected)
    rejected = []
    def reject(label, action, reason):
        try:
            action()
        except ValueError as error:
            assert reason in str(error), (label, error)
            rejected.append(label)
        else:
            raise AssertionError('successor control accepted: ' + label)
    bad = copy.deepcopy(data); bad['images'][0]['prior_sha256'] = '0' * 64
    reject('wrong-prior-image', lambda: build(bad), 'successor predecessor image mismatch')
    bad = copy.deepcopy(data); missing = bad['images'].pop(0)['path']
    reject('missing-changed-member', lambda: build(bad).verify(sources, effective), 'unreviewed current source image: ' + missing)
    bad = copy.deepcopy(data); bad['images'][0]['path'] = 'unrelated/parent-owned.pm'; bad['images'].sort(key=lambda row: row['path'])
    reject('foreign-member', lambda: build(bad), 'successor image outside baseline population')
    bad = copy.deepcopy(data)
    row = copy.deepcopy(images.rows[audit.PHASE0_FIXTURE])
    row.update(prior_revision=images.data['activation_commit'], prior_sha256=row['current_sha256'], current_sha256='e' * 64)
    bad['images'] = [row]
    reject('protected-phase0', lambda: build(bad), 'protected calibration')
    bad = copy.deepcopy(data); bad['activation_commit'] = git('rev-parse', 'HEAD:README.md').decode().strip()
    reject('noncommit-revision', lambda: build(bad).verify(sources, effective), 'image revision is not a commit')
    raw = read(audit.CURRENT_SUCCESSOR_TABLE) + b'changed'
    reject('table-input-byte', lambda: module.ImageAdmissions(raw, audit.CURRENT_SUCCESSOR_SHA256, audit.git), 'input drift')
    for name, row in saved.items():
        assert (ROOT / name).read_bytes() == decode(row)
    return dict(result='PASS', exact_successor_paths=sorted(expected_changed),
                original_predecessors_and_unchanged_images=True, protected_phase0=True,
                current_image_denials=sorted(sources), rejected_controls=rejected,
                limits=intake['limits'])


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('--capture', action='store_true')
    args = parser.parse_args()
    print(json.dumps(review(args.capture), sort_keys=True))
