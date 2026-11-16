"""Finish the already captured source epoch; never recapture or execute Perl."""
import gzip
import hashlib
import importlib.util
import json
from pathlib import Path
import stat
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
assert (BASE / 'capture-exit.txt').read_text() == '1\n'
assert not (BASE / 'qualification-sources.tar.gz').exists(), 'qualification is one-shot'
identities = {}
with tarfile.open(BASE / 'qualification-sources.tar.gz', 'x:gz') as archive:
    for name in ('review_qualified.py', 'qualify.py'):
        path = BASE / name
        assert not path.is_absolute() and not path.is_symlink()
        identities[str(path)] = dict(sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                                    mode=stat.S_IMODE(path.stat().st_mode))
        archive.add(path, arcname=str(path), recursive=False)
(BASE / 'qualification-identities.json').write_text(json.dumps(identities, indent=2, sort_keys=True) + '\n')
spec = importlib.util.spec_from_file_location('qualified_roles', BASE / 'review_qualified.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
reader = module.load()
inputs = reader.recover()
roles, includes = reader.reconstruct(inputs)
(BASE / 'roles.json').write_text(json.dumps(roles, indent=2, sort_keys=True) + '\n')
(BASE / 'named-includes.json').write_text(json.dumps(includes, indent=2, sort_keys=True) + '\n')
argv = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review_qualified.py'), '--current']
(BASE / 'review-command.json').write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for name in ('stdout', 'stderr'):
    (BASE / ('review-' + name + '.gz')).write_bytes(gzip.compress(getattr(result, name), mtime=0))
(BASE / 'review-exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and result.stderr == b'', 'qualification channels retained'
print(result.stdout.decode(), end='')
