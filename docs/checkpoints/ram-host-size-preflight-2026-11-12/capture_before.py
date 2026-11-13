"""Retain original producers and actual native channels before the repair."""
import gzip
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'before'
OUT.mkdir()
paths = [Path('tools/ram_guard.sh'), Path('tools/run_ci_local.sh'), Path('tools/test_ram_guard.py'),
         Path('tools/project_data_run.sh'), Path('tools/project_data_env.sh'), Path('tools/run_python_project_data.sh'),
         Path(__file__).relative_to(ROOT), BASE / 'preserve_ci_claim.py',
         Path('docs/claims/TYPE-REFERENCE-BOOK.1.2.23.4.3.json')]
identities = {}
with tarfile.open(OUT / 'inputs-before-use.tar.gz', 'x:gz') as archive:
    for path in paths:
        body = path.read_bytes()
        identities[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
with tarfile.open(OUT / 'inputs-before-use.tar.gz') as archive:
    assert set(archive.getnames()) == identities.keys()
    for member in archive:
        body = archive.extractfile(member).read()
        assert hashlib.sha256(body).hexdigest() == identities[member.name]['sha256']
        assert member.mode & 0o777 == identities[member.name]['mode']
(OUT / 'input-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
commands = [
    ('uname', ['uname', '-s']),
    ('sysctl', ['sysctl', '-n', 'hw.memsize']),
    ('memory-pressure', ['memory_pressure', '-Q']),
    ('vm-stat', ['vm_stat']),
    ('original-denial-red', ['bash', 'tools/run_python_project_data.sh', 'tools/test_ram_guard.py', '--legacy-red', 'tools/ram_guard.sh']),
]
observed = []
for name, command in commands:
    result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, LC_ALL='C'), capture_output=True)
    (OUT / (name + '-command.json')).write_text(json.dumps(dict(argv=command, cwd='.', environment={'LC_ALL': 'C'}), indent=2) + '\n')
    for channel in ('stdout', 'stderr'):
        (OUT / (name + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (OUT / (name + '-exit.txt')).write_text(str(result.returncode) + '\n')
    observed.append(dict(name=name, exit=result.returncode))
    if name == 'original-denial-red':
        assert result.returncode == 1 and b'admission/child exit' in result.stderr
        row = json.loads(result.stdout.splitlines()[0])
        assert row['code'] == 0 and row['child_ran'] and row['calls'].count('vm_stat') == 3
        assert 'RAM 25% used' in row['stdout']
(OUT / 'result.json').write_text(json.dumps(observed, indent=2) + '\n')
print(json.dumps(dict(retained_inputs=len(identities), native_and_original_observations=observed)))
