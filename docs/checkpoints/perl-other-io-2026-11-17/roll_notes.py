"""Own the required engineering-notes rollover through the existing public tool."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
ROOT = Path('DEVELOPMENT_NOTES.md')
HISTORY = Path('docs/history/development-notes')
assert not (BASE / 'rollover-before.tar.gz').exists()
before = ROOT.read_bytes()
old = {str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in HISTORY.rglob('*') if p.is_file()}
with tarfile.open(BASE / 'rollover-before.tar.gz', 'x:gz') as packed:
    for path in (ROOT, BASE / 'roll_notes.py', Path('tools/roll_document_history.pl'), Path('tools/lib/LinkedSpec/DocumentHistoryCatalog.pm')):
        packed.add(path, arcname=str(path), recursive=False)
(BASE / 'rollover-old-identities.json').write_text(json.dumps(old, sort_keys=True, indent=2) + '\n')
argv = ['bash', 'tools/project_data_run.sh', 'perl', 'tools/roll_document_history.pl', '--surface', 'engineering_notes', '--apply']
(BASE / 'rollover-command.json').write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
child = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (BASE / ('rollover-' + channel + '.gz')).write_bytes(gzip.compress(getattr(child, channel), mtime=0))
(BASE / 'rollover-exit.txt').write_text(str(child.returncode) + '\n')
assert child.returncode == 0, child.stderr.decode()
added = [p for p in HISTORY.glob('segment-*.md') if str(p) not in old]
assert len(added) == 1
segment = added[0].read_bytes()
assert before.endswith(segment), 'exact hot suffix archived'
prefix = before[:-len(segment)]
assert ROOT.read_bytes() == prefix.rstrip(b'\n') + b'\n', 'only authorized mutable EOF normalization'
for name, digest in old.items():
    if Path(name).name.startswith('segment-'):
        assert hashlib.sha256(Path(name).read_bytes()).hexdigest() == digest, 'immutable history unchanged'
(BASE / 'rollover-review.json').write_text(json.dumps(dict(result='PASS', segment=str(added[0]),
    source_sha256=hashlib.sha256(before).hexdigest(), archived_sha256=hashlib.sha256(segment).hexdigest(),
    retained_prefix_sha256=hashlib.sha256(ROOT.read_bytes()).hexdigest(),
    limits='Exact current hot suffix/prefix and old immutable member preservation; no new tool/schema/cap or full native/physical custody.'), indent=2) + '\n')
print(child.stdout.decode(), end='')
