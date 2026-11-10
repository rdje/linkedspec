"""Qualified complete-source image review; earlier four-image proof stays dated."""
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
SNAPSHOT = HERE / 'objective-current-inputs.json.gz'
UNIT = HERE / 'objective-current-unit.json.gz'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def decode(row):
    raw = base64.b64decode(row['base64'], validate=True)
    assert packet(raw) == row
    return raw


def encoded(value):
    return gzip.compress(json.dumps(value, sort_keys=True, separators=(',', ':')).encode(), mtime=0)


def review(capture=False):
    names = ('tools/historical_objective_images.py', 'tools/test_historical_objective_images.py',
             'tests/language-readiness/verify_objectives.py', 'tests/language-readiness/current-source-images.json.gz',
             'tests/language-readiness/current-source-successors.json.gz', 'tests/language-readiness/additional-source-images.json.gz',
             'tests/language-readiness/phase0-fixture-calibration.json.gz', 't/phase0_regression.t',
             'tools/run_python_project_data.sh', 'tools/project_data_env.sh', 'tools/project_data_run.sh',
             str(Path(__file__).relative_to(ROOT)))
    if capture:
        assert not SNAPSHOT.exists() and not UNIT.exists(), 'one-shot qualified capture'
        SNAPSHOT.write_bytes(encoded({name: packet((ROOT / name).read_bytes()) for name in names}))
    saved = json.loads(gzip.decompress(SNAPSHOT.read_bytes()))
    assert set(saved) == set(names)
    for name, row in saved.items():
        assert decode(row) == (ROOT / name).read_bytes(), 'dated source/input changed: ' + name
    command = ['bash', 'tools/run_python_project_data.sh', 'tools/test_historical_objective_images.py']
    unit = subprocess.run(command, cwd=ROOT, capture_output=True)
    observed = dict(argv=command, cwd='.', exit=unit.returncode, stdout=packet(unit.stdout), stderr=packet(unit.stderr))
    if capture: UNIT.write_bytes(encoded(observed))
    assert json.loads(gzip.decompress(UNIT.read_bytes())) == observed
    assert unit.returncode == 0 and unit.stderr == b''
    assert b'historical additional-image controls: PASS' in unit.stdout
    intake = json.loads(gzip.decompress((HERE / 'objective-image-intake.json.gz').read_bytes()))
    frontier = json.loads(gzip.decompress((HERE / 'objective-frontier-intake.json.gz').read_bytes()))
    spec = importlib.util.spec_from_file_location('complete_image_audit', ROOT / 'tests/language-readiness/verify_objectives.py')
    audit = importlib.util.module_from_spec(spec); spec.loader.exec_module(audit)
    read = lambda name: (ROOT / name).read_bytes()
    images = audit.current_image_admissions(read)
    effective, phase0 = audit.phase0_fixture_reader(read, images)
    sources = {row['path']: dict(sha256=row['historical_sha256']) for row in frontier['rows']}
    expected = {row['path']: row for row in frontier['rows']}
    report = images.verify(sources, effective)
    old = types.ModuleType('preserved_original_images'); old.__file__ = str(ROOT / 'tools/historical_objective_images.py')
    exec(compile(decode(intake['inputs']['tools/historical_objective_images.py']), old.__file__, 'exec'), old.__dict__)
    raw = decode(intake['inputs']['tests/language-readiness/current-source-images.json.gz'])
    assert raw == read('tests/language-readiness/current-source-images.json.gz')
    git = lambda *args: subprocess.check_output(['git', *args], cwd=ROOT)
    baseline = old.ImageAdmissions(raw, hashlib.sha256(raw).hexdigest(), git)
    prior = {row['path']: decode(row['prior_current']) for row in intake['rows']}
    baseline.verify(sources, prior.__getitem__)
    successor_paths = {row['path'] for row in frontier['rows'] if row['classification'] == 'existing-successor'}
    initial_paths = {row['path'] for row in frontier['rows'] if row['classification'] == 'first-exact-image-required'}
    assert set(images.baseline.successors.rows) == successor_paths
    assert set(images.additional.rows) == initial_paths
    assert set(images.rows) == set(baseline.rows) | initial_paths
    assert phase0 == intake['phase0'] and images.data == baseline.data
    for name in images.rows:
        current = effective(name); row = expected[name]
        assert current == decode(row['current'])
        predecessor = (baseline.predecessor(name, prior[name]) if name in baseline.rows else decode(row['historical']))
        assert images.predecessor(name, current) == predecessor
        assert images.read_predecessor(name, effective) == predecessor
        actual = next(item for item in report if item['path'] == name)
        assert actual['current_sha256'] == row['current']['sha256']
        assert actual['activation_commit'] == (intake['activation_commit'] if name in successor_paths | initial_paths else baseline.data['activation_commit'])
    assert images.falsify(sources, effective) == sorted(images.rows)
    module = audit._IMAGE_MODULE
    rejected = []
    def reject(label, action, reason):
        try: action()
        except ValueError as error:
            assert reason in str(error), (label, error)
            rejected.append(label)
        else: raise AssertionError('qualified image corruption admitted: ' + label)
    def admitted(data):
        raw = encoded(data)
        return module.ImageAdmissions(raw, hashlib.sha256(raw).hexdigest(), audit.git)
    successors = json.loads(gzip.decompress(read(audit.CURRENT_SUCCESSOR_TABLE)))
    bad = copy.deepcopy(successors); bad['images'][0]['prior_sha256'] = '0' * 64
    reject('wrong-successor-predecessor', lambda: module.SuccessorImageAdmissions(images.baseline.baseline, admitted(bad)), 'predecessor image mismatch')
    additional = json.loads(gzip.decompress(read(audit.ADDITIONAL_IMAGE_TABLE)))
    bad = copy.deepcopy(additional); bad['images'][0]['prior_sha256'] = '0' * 64
    reject('wrong-initial-predecessor', lambda: module.AdditionalImageAdmissions(images.baseline, admitted(bad)), 'predecessor is not historical')
    bad = copy.deepcopy(additional); bad['images'][0]['path'] = 'unrelated/parent-owned.pm'
    reject('foreign-historical-member', lambda: module.AdditionalImageAdmissions(images.baseline, admitted(bad)).verify(sources, effective), 'outside historical source population')
    bad = copy.deepcopy(additional); bad['activation_commit'] = git('rev-parse', 'HEAD:README.md').decode().strip()
    reject('noncommit-current-image', lambda: module.AdditionalImageAdmissions(images.baseline, admitted(bad)).verify(sources, effective), 'image revision is not a commit')
    reject('successor-table-byte', lambda: module.ImageAdmissions(read(audit.CURRENT_SUCCESSOR_TABLE) + b'changed', audit.CURRENT_SUCCESSOR_SHA256, audit.git), 'input drift')
    reject('initial-table-byte', lambda: module.ImageAdmissions(read(audit.ADDITIONAL_IMAGE_TABLE) + b'changed', audit.ADDITIONAL_IMAGE_SHA256, audit.git), 'input drift')
    for name, row in saved.items(): assert (ROOT / name).read_bytes() == decode(row)
    return dict(result='PASS', exact_successor_paths=sorted(successor_paths), exact_initial_paths=sorted(initial_paths),
                original_predecessor_stages_preserved=True, protected_phase0=True,
                current_image_denials=sorted(images.rows), rejected_controls=rejected,
                focused_unit='legacy/successor/initial controls PASS with empty stderr', limits=frontier['limits'])


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__); parser.add_argument('--capture', action='store_true')
    args = parser.parse_args(); print(json.dumps(review(args.capture), sort_keys=True))
