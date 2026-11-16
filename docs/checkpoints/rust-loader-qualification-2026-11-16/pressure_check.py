"""Record the unchanged routing check and lossless-summary review before landing."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
DIRECTORY = BASE / 'pressure'
assert not (DIRECTORY / 'recorder.py.gz').exists(), 'one-shot pressure check recording'
body = Path(__file__).read_bytes()
(DIRECTORY / 'recorder.py.gz').write_bytes(gzip.compress(body, mtime=0))
(DIRECTORY / 'recorder.json').write_text(json.dumps(dict(sha256=hashlib.sha256(body).hexdigest(),
    mode=Path(__file__).stat().st_mode & 0o777), indent=2) + '\n')
for label, argv in [
    ('routing', ['bash', 'scripts/check_readme_stability.sh']),
    ('review', ['bash', 'tools/run_python_project_data.sh', str(BASE / 'pressure_repair.py'), '--review', '--current']),
]:
    (DIRECTORY / (label + '-command.json')).write_text(json.dumps(dict(argv=argv, cwd='.'), indent=2) + '\n')
    result = subprocess.run(argv, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (DIRECTORY / (label + '-' + channel + '.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (DIRECTORY / (label + '-exit.txt')).write_text(str(result.returncode) + '\n')
    print(label, result.returncode)
    if result.returncode:
        print(result.stdout.decode(), end='')
        print(result.stderr.decode(), end='')
    assert result.returncode == 0, 'actual pressure check failure retained'
