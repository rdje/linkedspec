"""Retain readonly review inputs, actual command and complete outer channels."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'result_preservation_review'
OUT.mkdir()
paths = [p for p in BASE.rglob('*') if p.is_file() and OUT not in p.parents]
paths += [Path('t/array_transform_source_isolation.t'), Path('docs/checkpoints/array-transform-result-perl-2026-11-07/preflight/stdout.log.gz')]
paths += [Path('tests/fixtures') / n for n in ('array_transform_source_isolation_perl_cases.json', 'array_transform_result_guard_perl_profiles.json', 'array_transform_result_guard_cases.json')]
paths += [Path('tools') / n for n in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
records = {}
for p in sorted(set(paths)):
    assert not p.is_absolute() and '..' not in p.parts and not p.is_symlink()
    raw = p.read_bytes()
    records[str(p)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())
(OUT / 'input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
command = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review_result_preservation.py')]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name in ('stdout', 'stderr'):
    (OUT / (name + '.log.gz')).write_bytes(gzip.compress(getattr(result, name), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest() == row['sha256'] for p, row in records.items())
print('Actual readonly source review retained, exit', result.returncode)
assert result.returncode == 0 and result.stderr == b'', 'preserve unexpected first review; qualify separately'
