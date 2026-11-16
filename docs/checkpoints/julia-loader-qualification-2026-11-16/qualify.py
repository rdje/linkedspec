"""Capture the separate control qualification before its readonly proof."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
assert not (BASE / 'qualification-instruments.tar.gz').exists(), 'one-shot qualification'
identities = {}
with tarfile.open(BASE / 'qualification-instruments.tar.gz', 'x:gz') as archive:
    for leaf in ('review_qualified.py', 'qualify.py'):
        path = BASE / leaf
        body = path.read_bytes()
        identities[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(BASE / 'qualification-instruments.json').write_text(json.dumps(identities, indent=2) + '\n')
spec = importlib.util.spec_from_file_location('julia_control_qualification', BASE / 'review_qualified.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
original = module.retained_reader()
sources, _ = original.recover()
ledger = original.scan(sources)
(BASE / 'control-victim.json').write_text(json.dumps(module.victim_oracle(ledger), indent=2, sort_keys=True) + '\n')
(BASE / 'qualified-source.py.gz').write_bytes(gzip.compress(module.derive(sources), mtime=0))
argv = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review_qualified.py'), '--current']
(BASE / 'qualified-command.json').write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('qualified-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'qualified-exit.txt').write_text(str(result.returncode) + '\n')
print(result.stdout.decode(), end='')
assert result.returncode == 0 and not result.stderr, 'qualified proof failed; actual channels retained'
