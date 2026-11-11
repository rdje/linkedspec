"""Populate only the owned same-path private compiler control from retained images."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(ROOT)
source = Path('perl/LinkedSpec/ActionIR/MethodLowering.pm')
activation = '09bad87aa19304486f836cf6dff44b499a8ea5ec'
parent = Path('.linkedspec-data/scratch')
assert parent.is_dir() and parent.resolve().is_relative_to(ROOT) and parent.stat().st_dev == ROOT.stat().st_dev
directory = parent / 'callable-transform-result-perl'
owner = directory / 'owner.pm'
mode = sys.argv[1]
assert mode in ('old', 'current')
if mode == 'old':
    assert not directory.exists() and not directory.is_symlink()
    directory.mkdir(mode=0o700)
    old = subprocess.check_output(['git', 'show', activation + ':' + str(source)])
    current = source.read_bytes()
    assert current != old
    permissions = source.stat().st_mode & 0o777
    images = {}
    for label, raw in (('old', old), ('current', current)):
        alias = BASE / ('owner-' + label + '.pm.gz')
        assert not alias.exists()
        alias.write_bytes(gzip.compress(raw, mtime=0))
        images[label] = dict(alias=alias.name, bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest(), mode=permissions)
    (BASE / 'owner-images.json').write_text(json.dumps(dict(source=str(source), activation=activation, owner=str(owner), images=images), indent=2) + '\n')
    owner.write_bytes(old)
    owner.chmod(permissions)
else:
    data = json.loads((BASE / 'owner-images.json').read_bytes())
    assert data['owner'] == str(owner) and owner.is_file() and not owner.is_symlink()
    assert hashlib.sha256(owner.read_bytes()).hexdigest() == data['images']['old']['sha256']
    assert (BASE / 'private_old/complete.txt').is_file()
    row = data['images']['current']
    raw = gzip.decompress((BASE / row['alias']).read_bytes())
    assert raw == source.read_bytes() and hashlib.sha256(raw).hexdigest() == row['sha256']
    owner.write_bytes(raw)
    owner.chmod(row['mode'])
command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(REL / 'prepare_owners.py'), mode]
(BASE / ('owner-' + mode + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
print('Prepared', mode, 'owner at the same owned repository-volume path.')
