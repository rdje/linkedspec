"""Freeze effective current-image drift before the bounded successor admission."""
import base64
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).parent
OUTPUT = HERE / 'objective-image-intake.json.gz'


def packet(raw):
    return dict(base64=base64.b64encode(raw).decode(), sha256=hashlib.sha256(raw).hexdigest())


def git(*args):
    return subprocess.check_output(['git', *args], cwd=ROOT)


assert not OUTPUT.exists(), 'one-shot pre-change intake'
spec = importlib.util.spec_from_file_location('objective_intake_audit', ROOT / 'tests/language-readiness/verify_objectives.py')
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)
read = lambda name: (ROOT / name).read_bytes()
images = audit.current_image_admissions(read)
effective, phase0 = audit.phase0_fixture_reader(read, images)
activation = git('rev-parse', 'HEAD').decode().strip()
rows = []
for name, row in images.rows.items():
    raw = effective(name)
    previous = images.image(images.data['activation_commit'], name, row['current_sha256'])
    changed = hashlib.sha256(raw).hexdigest() != row['current_sha256']
    item = dict(path=name, original_row=row, prior_current=packet(previous), effective_current=packet(raw), changed=changed)
    if changed:
        assert name != audit.PHASE0_FIXTURE, 'Phase0 calibration must remain separate'
        assert raw == git('show', activation + ':' + name), 'current source is not a clean committed image'
        tree = git('ls-tree', '-z', activation, '--', name)
        assert tree.endswith(b'\0') and tree.count(b'\0') == 1
        header, path = tree[:-1].split(b'\t')
        mode, kind, blob = header.decode().split()
        assert path.decode() == name and mode in ('100644', '100755') and kind == 'blob'
        item['current_git_entry'] = dict(mode=mode, kind=kind, blob=blob)
        item['accepted_change_history'] = git('log', '--format=%H %s', images.data['activation_commit'] + '..' + activation, '--', name).decode().splitlines()
        assert item['accepted_change_history'], 'changed image has no accepted source history'
    rows.append(item)
names = ('tests/language-readiness/verify_objectives.py', 'tools/historical_objective_images.py',
         audit.CURRENT_IMAGE_TABLE, audit.PHASE0_FIXTURE_TABLE,
         'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py',
         str(Path(__file__).relative_to(ROOT)))
report = dict(activation_commit=activation, base_owner=images.data['owner'],
              base_activation=images.data['activation_commit'], rows=rows, phase0=phase0,
              inputs={name: packet(read(name)) for name in names},
              canonical_failure=packet((HERE / 'canonical-fifth.log.gz').read_bytes()),
              limits='Exact effective current-image identity drift and accepted parent-repository source history only. '
                     'No fresh runtime/objective compatibility, feature promotion, dependency inspection or native/transitive custody.')
OUTPUT.write_bytes(gzip.compress(json.dumps(report, sort_keys=True, separators=(',', ':')).encode(), mtime=0))
assert json.loads(gzip.decompress(OUTPUT.read_bytes())) == report
print(json.dumps(dict(result='PASS', changed=[row['path'] for row in rows if row['changed']],
                      unchanged=[row['path'] for row in rows if not row['changed']], activation=activation), sort_keys=True))
