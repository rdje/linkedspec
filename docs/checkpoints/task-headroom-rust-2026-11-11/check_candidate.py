"""One-time current target/manifest identity, separate from historical replay."""
import gzip
import hashlib
import json
from pathlib import Path
import subprocess
import sys

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
if sys.argv[1:] == ['--check']:
    for name, row in json.loads((BASE / 'outputs-before-reader-identities.json').read_bytes()).items():
        path = ROOT / name
        assert path.is_file() and not path.is_symlink()
        assert len(path.read_bytes()) == row['bytes']
        assert hashlib.sha256(path.read_bytes()).hexdigest() == row['sha256']
        assert path.stat().st_mode & 0o777 == row['mode']
    print(json.dumps(dict(candidate='PASS', scope='Current migrated task and epoch manifest match actual before-reader bytes/modes.')))
else:
    assert not sys.argv[1:]
    target = BASE / 'candidate-command.json'; assert not target.exists()
    source = Path(__file__).read_bytes()
    metadata = (BASE / 'outputs-before-reader-identities.json').read_bytes()
    command = dict(cwd='.', argv=['bash', 'tools/run_python_project_data.sh', str(REL / 'check_candidate.py'), '--check'],
        producer_sha256=hashlib.sha256(source).hexdigest(), input_metadata_sha256=hashlib.sha256(metadata).hexdigest())
    target.write_text(json.dumps(command, indent=2) + '\n')
    result = subprocess.run(command['argv'], cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    for channel in ('stdout', 'stderr'):
        (BASE / ('candidate-' + channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
    (BASE / 'candidate-exit.txt').write_text(str(result.returncode) + '\n')
    assert result.returncode == 0 and result.stderr == b''
    assert source == Path(__file__).read_bytes() and metadata == (BASE / 'outputs-before-reader-identities.json').read_bytes()
    (BASE / 'candidate-result.json').write_bytes(result.stdout)
    print(result.stdout.decode(), end='')
