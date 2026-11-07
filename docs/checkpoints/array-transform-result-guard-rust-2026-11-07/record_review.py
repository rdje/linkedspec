"""Seal actual review inputs, bind the tested candidate, and retain first channels."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'readonly-review'
OUT.mkdir()
direct = json.loads((BASE / 'direct/custody.json').read_bytes())[0]
for name in ('rust/linkedspec-runtime/src/engine.rs',
             'rust/linkedspec-runtime/tests/array_transform_result_guard_composition.rs',
             'tests/fixtures/array_transform_result_guard_cases.json',
             'tests/fixtures/array_transform_optional_result_guard_cases.json',
             'tests/fixtures/array_transform_result_guard_rust_profiles.json'):
    row = direct['files'][name]
    assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == row['sha256']
    assert Path(name).stat().st_mode & 0o777 == row['mode']
paths = [p for p in BASE.rglob('*') if p.is_file() and OUT not in p.parents]
paths += [Path(name) for name in direct['files'] if not name.startswith(str(BASE) + '/')]
identities = {}
for path in sorted(set(paths)):
    assert not path.is_absolute() and not path.is_symlink()
    assert path.stat().st_dev == ROOT.stat().st_dev
    body = path.read_bytes()
    identities[str(path)] = dict(sha256=hashlib.sha256(body).hexdigest(), bytes=len(body),
                                mode=path.stat().st_mode & 0o777)
(OUT / 'input-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
with tarfile.open(OUT / 'review-instrument-before-first-run.tar.gz', 'w:gz') as archive:
    for name in identities:
        if name.endswith('.py') and name.startswith(str(BASE) + '/'):
            archive.add(name, arcname=name, recursive=False)
command = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review.py')]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
for name, row in identities.items():
    assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == row['sha256']
    assert Path(name).stat().st_mode & 0o777 == row['mode']
assert result.returncode == 0 and result.stderr == b'', 'first readonly result retained; do not overwrite'
print('first readonly0/empty stderr; tested candidate and actual review inputs identity-bound')
