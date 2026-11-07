"""Retain actual readonly inputs/channels and bind the tested candidate bytes."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'readonly_review'
OUT.mkdir()
paths = [p for p in BASE.rglob('*') if p.is_file() and OUT not in p.parents]
locations = json.loads((BASE / 'direct/artifact-locations.json').read_bytes())
for key in ('source', 'hash'):
    paths += [p for p in Path(locations[key]).rglob('*') if p.is_file()]
paths += [Path(p) for p in ('perl/LinkedSpec/ActionIR/MethodLowering.pm',
    't/array_transform_result_guard_composition.t', 't/array_transform_source_isolation.t', 't/hash_value_result_guard_composition.t')]
paths += [Path('tests/fixtures') / name for name in ('array_transform_result_guard_cases.json',
    'array_transform_result_guard_perl_profiles.json', 'array_transform_result_guard_perl_prefix_profiles.json',
    'array_transform_source_isolation_perl_cases.json', 'hash_value_result_guard_perl_cases.json', 'hash_value_result_guard_perl_profiles.json')]
paths += [Path('tools') / name for name in ('project_data_env.sh', 'project_data_run.sh', 'run_python_project_data.sh')]
with tarfile.open(BASE / 'after/inputs-before-first-run.tar.gz') as archive:
    for path in ('perl/LinkedSpec/ActionIR/MethodLowering.pm', 't/array_transform_result_guard_composition.t',
                 'tests/fixtures/array_transform_result_guard_cases.json', 'tests/fixtures/array_transform_result_guard_perl_profiles.json',
                 'tests/fixtures/array_transform_result_guard_perl_prefix_profiles.json'):
        assert Path(path).read_bytes() == archive.extractfile(path).read(), 'candidate drift after testing'
records = {}
for path in sorted(set(paths)):
    assert not path.is_absolute() and '..' not in path.parts and not path.is_symlink()
    raw = path.read_bytes()
    records[str(path)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())
(OUT / 'input-identities.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
command = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review.py')]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name in ('stdout', 'stderr'):
    (OUT / (name + '.log.gz')).write_bytes(gzip.compress(getattr(result, name), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert all(hashlib.sha256(Path(path).read_bytes()).hexdigest() == row['sha256'] for path, row in records.items())
print('Actual composition readonly review retained, exit', result.returncode)
assert result.returncode == 0 and result.stderr == b'', 'preserve unexpected first result; qualify separately'
