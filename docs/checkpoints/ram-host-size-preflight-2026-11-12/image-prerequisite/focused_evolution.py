"""Exercise actual later images and the RAM inverse without runtime execution."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'focused-evolution'
OUT.mkdir()
inventory = json.loads((BASE / 'intake/source-inventory.json').read_bytes())
sources = {row['path']: dict(sha256=row['historical_sha256']) for row in inventory['historical_sources']}
rows = {}
with tarfile.open(OUT / 'observed-inputs-before-use.tar.gz', 'x:gz') as archive:
    def read(name):
        path = Path(name)
        raw = path.read_bytes()
        assert path.is_file() and not path.is_symlink() and path.stat().st_dev == ROOT.stat().st_dev
        if name not in rows:
            rows[name] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=path.stat().st_mode & 0o777)
            archive.add(path, arcname=name, recursive=False)
        else:
            assert hashlib.sha256(raw).hexdigest() == rows[name]['sha256']
        return raw
    read(str(Path(__file__).relative_to(ROOT)))
    read('tests/language-readiness/verify_objectives.py')
    read('tools/historical_objective_images.py')
    spec = importlib.util.spec_from_file_location('resource_current_evolution', ROOT / 'tests/language-readiness/verify_objectives.py')
    audit = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(audit)
    audit.read_relative = read
    images = audit.current_image_admissions(read)
    fixture_read, fixture_evolution = audit.phase0_fixture_reader(read, images)
    current = images.verify(sources, fixture_read)
    new_denials = images.falsify(sources, fixture_read)
    helper = audit._IMAGE_MODULE
    initial = helper.ImageAdmissions(read(audit.CURRENT_IMAGE_TABLE), audit.CURRENT_IMAGE_TABLE_SHA256, audit.git)
    successor = helper.ImageAdmissions(read(audit.CURRENT_SUCCESSOR_TABLE), audit.CURRENT_SUCCESSOR_SHA256, audit.git)
    extra = helper.ImageAdmissions(read(audit.ADDITIONAL_IMAGE_TABLE), audit.ADDITIONAL_IMAGE_SHA256, audit.git)
    old = helper.AdditionalImageAdmissions(helper.SuccessorImageAdmissions(initial, successor, protected=(audit.PHASE0_FIXTURE,)), extra)
    latest = json.loads(gzip.decompress(read(audit.LATER_IMAGE_TABLE)))
    replacements = {row['path']: helper.ImageAdmissions.image(successor, row['prior_revision'], row['path'], row['prior_sha256'])
                    for row in latest['images']}

    def old_stage(name):
        return replacements[name] if name in replacements else fixture_read(name)

    old_report = old.verify(sources, old_stage)
    prior_denials = old.falsify(sources, old_stage)
    assert new_denials == prior_denials and len(current) == len(old_report)
    for item in current:
        name = item['path']
        if name in replacements:
            admitted = next(row for row in latest['images'] if row['path'] == name)
            assert item['activation_commit'] == latest['activation_commit'] and item['current_sha256'] == admitted['current_sha256']
            assert item['successor_admission']['previous_current_sha256'] == admitted['prior_sha256']
        else:
            assert item == next(row for row in old_report if row['path'] == name)
    assert images.data['activation_commit'] == old.data['activation_commit']
    inverse = audit.ram_ci_inverse(read)
    ci = read('tools/run_ci_local.sh')
    precursor = inverse.restore(ci)
    expected = subprocess.check_output(['git', 'show', audit.RAM_CI_ACTIVATION + ':tools/run_ci_local.sh'])
    assert precursor == expected
    before_result = audit.verify_governance_precursor('tools/run_ci_local.sh', precursor, sources['tools/run_ci_local.sh']['sha256'])
    after_result = audit.verify_governance_evolution('tools/run_ci_local.sh', ci, sources['tools/run_ci_local.sh']['sha256'])
    assert before_result['historical'] == after_result['historical'] and after_result['current'] == hashlib.sha256(ci).hexdigest()
with tarfile.open(OUT / 'observed-inputs-before-use.tar.gz') as archive:
    assert set(archive.getnames()) == rows.keys()
    for member in archive:
        assert hashlib.sha256(archive.extractfile(member).read()).hexdigest() == rows[member.name]['sha256']
        assert member.mode & 0o777 == rows[member.name]['mode']
(OUT / 'observed-identities.json').write_text(json.dumps(rows, indent=2, sort_keys=True) + '\n')
result = dict(result='PASS', historical_sources=len(sources), current_images=current,
    prior_images=old_report, current_denials=new_denials, prior_denials=prior_denials,
    ram_ci_inverse=after_result, phase0_activation_unchanged=True,
    scope='Exact committed source identity and original-stage corruption controls; no runtime execution, old observation refresh or feature admission.')
(OUT / 'result.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(result='PASS', changed_images=len(replacements), prior_and_current_image_denials=len(new_denials),
                     ci_committed_precursor_exact=True, phase0_activation_unchanged=True)))
