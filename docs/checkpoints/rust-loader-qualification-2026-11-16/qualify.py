"""Complete the retained partial epoch without rerunning the failed capture."""
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
    for leaf in ('qualify.py', 'review_qualified.py'):
        path = BASE / leaf
        body = path.read_bytes()
        identities[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(BASE / 'qualification-instruments.json').write_text(json.dumps(identities, indent=2) + '\n')
spec = importlib.util.spec_from_file_location('rust_plan_qualification', BASE / 'review_qualified.py')
qualified = importlib.util.module_from_spec(spec)
spec.loader.exec_module(qualified)
sources, _ = qualified.preparation()
(BASE / 'original-reader-refusal.json').write_text(json.dumps(qualified.original_refusal(sources), indent=2) + '\n')
body = qualified.derive(sources)
(BASE / 'qualified-source.py.gz').write_bytes(gzip.compress(body, mtime=0))
module = qualified.engine(body)
ledger = module.scan(sources)
plan = json.loads(sources[str(BASE / 'plan.json')])
spec = importlib.util.spec_from_file_location('retained_capture_helpers', BASE / 'capture.py')
capture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture)
targets = {row['target'] for row in ledger['input_edges']} - set(sources)
capture.archive('fixtures', targets)
references = json.loads((BASE / 'reused-inputs.json').read_bytes())
fixed = {plan[key] for key in ('grammar', 'grammar_owner', 'historical', 'grammar_fact')}
argv = ['git', 'ls-tree', '-rz', plan['activation'], '--', *sorted(fixed | targets | set(references))]
tree = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
(BASE / 'activation-tree.json').write_text(json.dumps(dict(activation=plan['activation'], argv=argv, cwd='.',
    exit=tree.returncode, stdout_hex=tree.stdout.hex(), stderr_hex=tree.stderr.hex()), indent=2) + '\n')
assert tree.returncode == 0 and not tree.stderr
sources, _ = module.recover()
ledger = module.scan(sources)
(BASE / 'loaders.json').write_text(json.dumps(ledger, indent=2, sort_keys=True) + '\n')
argv = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review_qualified.py'), '--current']
(BASE / 'qualified-command.json').write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('qualified-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(BASE / 'qualified-exit.txt').write_text(str(result.returncode) + '\n')
print(result.stdout.decode(), end='')
if result.stderr:
    print(result.stderr.decode(), end='')
assert result.returncode == 0, 'qualified failure retained'
