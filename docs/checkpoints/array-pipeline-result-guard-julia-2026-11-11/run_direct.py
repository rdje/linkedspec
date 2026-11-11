"""Bind the selected default grammar before the unmodified direct test driver."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

ROOT = Path.cwd().resolve()
BASE = Path(__file__).resolve().parent.relative_to(ROOT)
OUT = BASE / 'direct-preflight'
OUT.mkdir()
grammar = Path('specs/user_function_definition.spec')
loader = Path('julia/src/parser/UserFunctionDefinitionParser.jl')
paths = [Path(__file__).relative_to(ROOT), BASE / 'capture.py', loader, grammar,
         Path('tools/run_python_project_data.sh'), Path('tools/project_data_run.sh'), Path('tools/project_data_env.sh')]
records = {}
with tarfile.open(OUT / 'inputs.tar.gz', 'x:gz') as archive:
    for path in paths:
        body = path.read_bytes()
        records[str(path)] = dict(bytes=len(body), sha256=hashlib.sha256(body).hexdigest(), mode=path.stat().st_mode & 0o777)
        archive.add(path, arcname=str(path), recursive=False)
(OUT / 'inputs.json').write_text(json.dumps(records, indent=2, sort_keys=True) + '\n')
nearer = [Path(directory) / grammar for directory in ('julia/src/parser', 'julia/src', 'julia')]
assert not any(path.exists() for path in nearer), 'a nearer default function grammar would change input binding'
(OUT / 'default-grammar-resolution.json').write_text(json.dumps(dict(anchor='julia/src/parser',
    nearer=[dict(path=str(path), exists=False) for path in nearer], selected=str(grammar),
    selected_sha256=records[str(grammar)]['sha256'], search_owner=str(loader),
    search_owner_sha256=records[str(loader)]['sha256']), indent=2) + '\n')
command = ['bash', 'tools/run_python_project_data.sh', str(BASE / 'capture.py'), 'direct']
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0
for name, row in records.items():
    path = Path(name)
    assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256'] and path.stat().st_mode & 0o777 == row['mode']
assert not any(path.exists() for path in nearer)
print('Direct unchanged command0 with default-grammar owner/candidate/source inputs bound before SDK use')
