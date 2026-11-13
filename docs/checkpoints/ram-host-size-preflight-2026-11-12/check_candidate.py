"""Point-in-time current direct-source/document check before canonical staging."""
import hashlib
import json
from pathlib import Path
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
proof = BASE / 'proofs/source-bound-controls'
rows = json.loads((proof / 'input-identities.json').read_bytes())
paths = ['tools/host_ram_usage.sh', 'tools/ram_guard.sh', 'tools/run_ci_local.sh', 'tools/test_ram_guard.py',
         'doctrine/project_data_storage/python_entrypoints.json', 'doctrine/project_data_storage/python_temporary_owners.json']
for name in paths:
    path = Path(name)
    assert hashlib.sha256(path.read_bytes()).hexdigest() == rows[name]['sha256'], name
    assert path.stat().st_mode & 0o777 == rows[name]['mode'], name
publication = BASE / 'publication'
rows = json.loads((publication / 'outputs-after-use.json').read_bytes())
with tarfile.open(publication / 'outputs-after-use.tar.gz') as archive:
    for member in archive:
        if not member.name.startswith(('docs/knowledge/', 'docs/linkedspec-book/', 'docs/claims/')):
            continue
        path = Path(member.name)
        assert path.read_bytes() == archive.extractfile(member).read(), member.name
        assert path.stat().st_mode & 0o777 == rows[member.name]['mode'], member.name
print('Current direct producer/registry/publication identities: PASS (pre-staging only)')
