"""Retain actual readonly recovery inputs, argv and complete outer channels."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
assert len(sys.argv) == 2 and sys.argv[1] in ('preflight', 'normal')
kind = sys.argv[1]
OUT = BASE / (kind + '_review')
OUT.mkdir()
paths = [p for p in BASE.rglob('*') if p.is_file() and OUT not in p.parents]
paths += [Path('tests/fixtures') / n for n in ('array_transform_result_guard_cases.json', 'array_transform_result_guard_perl_profiles.json')]
paths += [Path('t/array_transform_result_guard_composition.t')]
identities = {}
for p in sorted(set(paths)):
    assert not p.is_absolute() and '..' not in p.parts and not p.is_symlink()
    raw = p.read_bytes()
    identities[str(p)] = dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())
(OUT / 'input-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
script = 'review_preflight.py' if kind == 'preflight' else 'review_normal.py'
command = ['bash', 'tools/run_python_project_data.sh', str(BASE / script)]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name in ('stdout', 'stderr'):
    (OUT / (name + '.log.gz')).write_bytes(gzip.compress(getattr(result, name), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest() == r['sha256'] for p, r in identities.items())
print('Recorded readonly', kind, 'exit', result.returncode)
assert result.returncode == 0 and result.stderr == b'', 'preserve failure; qualify separately'
