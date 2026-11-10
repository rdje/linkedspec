"""Retain the exact Git-byte/full-permission distinction behind reader1."""
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent
ACTIVATION = 'fe4906fb0bdac1ff7dc4f33728862cd6d47cf79d'
identities = json.loads((BASE / 'before/input-identities.json').read_bytes())
differences = []
with tarfile.open(BASE / 'before/inputs-before-first-run.tar.gz') as archive:
    for name, row in identities.items():
        if not name.startswith('perl/'):
            continue
        actual = archive.extractfile(name).read()
        git = subprocess.check_output(['git', 'show', ACTIVATION + ':' + name])
        mode = int(subprocess.check_output(['git', 'ls-tree', ACTIVATION, '--', name]).split()[0], 8) & 0o777
        assert actual == git
        if row['mode'] != mode:
            differences.append(dict(path=name, bytes_equal=True, observed_mode=row['mode'],
                                    git_mode=mode, sha256=hashlib.sha256(actual).hexdigest()))
assert len(differences) == 6
target = BASE / 'mode-diagnostic.json'
assert not target.exists()
target.write_text(json.dumps(differences, indent=2) + '\n')
print(json.dumps(differences, indent=2))
