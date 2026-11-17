"""Retain installed public API documentation as after-use development evidence."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
FOLDER = BASE / 'documentation'
FOLDER.mkdir()
with tarfile.open(FOLDER / 'producer-before.tar.gz', 'x:gz') as archive:
    for path in (BASE / 'capture_docs.py', Path('tools/project_data_run.sh')):
        archive.add(path, arcname=str(path), recursive=False)
rows = []
for label, module in [('variable', 'PPI::Statement::Variable'), ('node', 'PPI::Node'),
    ('quote', 'PPI::Token::Quote'), ('double', 'PPI::Token::Quote::Double')]:
    argv = ['bash', 'tools/project_data_run.sh', 'env', 'PERL5LIB=', 'PERL5OPT=', 'perldoc', '-T', '-t', module]
    child = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (FOLDER / (label + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(child, channel), mtime=0))
    rows.append(dict(module=module, argv=argv, cwd='.', exit=child.returncode,
        stdout_sha256=hashlib.sha256(child.stdout).hexdigest(), stderr_sha256=hashlib.sha256(child.stderr).hexdigest()))
    (FOLDER / 'commands.json').write_text(json.dumps(rows, indent=2) + chr(10))
    assert child.returncode == 0 and not child.stderr
(FOLDER / 'LIMITS.txt').write_text('Public installed API docs retained after earlier planning reads; no original first-use or complete PPI/Perl/library/native/physical custody credit. No LinkedSpec source execution.' + chr(10))
print('Retained four public PPI API documentation outputs')
