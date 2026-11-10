"""Copy and verify one retained owner at the same project-local load path."""
import hashlib
import json
from pathlib import Path
import sys
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert len(sys.argv) == 2 and sys.argv[1] in ('private_inverse', 'private_restored')
phase = sys.argv[1]
source = 'before' if phase == 'private_inverse' else 'after'
name = 'perl/LinkedSpec/ActionIR/MethodLowering.pm'
with tarfile.open(BASE / source / 'inputs-before-first-run.tar.gz') as archive:
    member = archive.getmember(name)
    body = archive.extractfile(member).read()
    mode = member.mode & 0o777
after = json.loads((BASE / 'after/input-identities.json').read_bytes())[name]
assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == after['sha256']
target = Path('.linkedspec-data/scratch/array-pipeline-composition-perl/owner.pm')
target.parent.mkdir(parents=True, exist_ok=True)
assert not target.is_symlink() and target.parent.stat().st_dev == ROOT.stat().st_dev
if phase == 'private_inverse':
    assert not target.exists()
else:
    old = json.loads((BASE / 'before/input-identities.json').read_bytes())[name]
    assert hashlib.sha256(target.read_bytes()).hexdigest() == old['sha256']
record = BASE / (phase + '-image.json')
assert not record.exists()
target.write_bytes(body)
target.chmod(mode)
assert target.read_bytes() == body and target.stat().st_mode & 0o777 == mode
record.write_text(json.dumps(dict(path=str(target), source_epoch=source, source=name,
    bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=mode), indent=2) + '\n')
print('Verified', source, 'image at the unchanged private path; checkout remains repaired')
