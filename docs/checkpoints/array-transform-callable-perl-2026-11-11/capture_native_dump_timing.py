"""One-shot source-bound timing qualification; this does not replay the SDK."""
import gzip
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
REL = BASE.relative_to(Path.cwd().resolve())
OUT = BASE / 'native-dump-timing'
OUT.mkdir()
for name in ('capture_native_dump_timing.py', 'review_native_dump_timing.py'):
    (OUT / (name + '.gz')).write_bytes(gzip.compress((BASE / name).read_bytes(), mtime=0))
command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(REL / 'review_native_dump_timing.py')]
(OUT / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (OUT / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(OUT / 'exit.txt').write_text(str(result.returncode) + '\n')
assert result.returncode == 0 and not result.stderr, 'Actual failure retained; qualify separately'
print(result.stdout.decode(), end='')
