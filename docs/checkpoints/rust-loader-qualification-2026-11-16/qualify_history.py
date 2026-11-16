"""Retain the separate archive-locator qualification before its proof."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
assert not (BASE / 'history-instruments.tar.gz').exists(), 'one-shot historical qualification'
identities = {}
with tarfile.open(BASE / 'history-instruments.tar.gz', 'x:gz') as archive:
    for leaf in ('qualify_history.py', 'review_qualified2.py'):
        path = BASE / leaf
        body = path.read_bytes()
        identities[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(BASE / 'history-instruments.json').write_text(json.dumps(identities, indent=2) + '\n')
spec = importlib.util.spec_from_file_location('rust_history_qualification', BASE / 'review_qualified2.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
first = module.first_qualification()
sources, _ = first.preparation()
(BASE / 'first-qualified-refusal.json').write_text(json.dumps(module.first_refusal(first), indent=2) + '\n')
(BASE / 'qualified2-source.py.gz').write_bytes(gzip.compress(module.derive(first, sources), mtime=0))
argv = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review_qualified2.py'), '--current']
(BASE / 'qualified2-command.json').write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('qualified2-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'qualified2-exit.txt').write_text(str(result.returncode) + '\n')
print(result.stdout.decode(), end='')
if result.stderr:
    print(result.stderr.decode(), end='')
assert result.returncode == 0, 'historical qualification failure retained'
