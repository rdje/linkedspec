"""Retain the actual original reviewer rejection before host remeasurement."""
from pathlib import Path
import hashlib
import importlib.util
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review-failure-capture.py')
spec = importlib.util.spec_from_file_location('retained_failure_stream', Path(PREFIX + 'capture.py'))
capture = importlib.util.module_from_spec(spec); spec.loader.exec_module(capture)
review = Path(PREFIX + 'review.py').relative_to(ROOT).as_posix()
command = ['bash', 'tools/run_python_project_data.sh', review]
result = subprocess.run(command, cwd=ROOT, capture_output=True)
assert result.returncode == 1 and b'AssertionError: empty actual command stderr' in result.stderr
assert Path(PREFIX + 'review.py').read_bytes() == Path(PREFIX + 'initial-review.py').read_bytes()
record = {'command': command, 'exit': result.returncode,
          'producer_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
          'reviewer_sha256': hashlib.sha256(Path(PREFIX + 'initial-review.py').read_bytes()).hexdigest(),
          'stdout': capture.streams.envelope(result.stdout),
          'stderr': capture.streams.envelope(result.stderr),
          'scope': 'Actual preserved initial reviewer rejection. Original before/after records and supplied inputs remain byte-exact in initial-* snapshots. One baseline seed1 command emitted the known startup .7 setpgid warning; no warning was removed or accepted.'}
Path(PREFIX + 'review-initial-failure.json').write_text(json.dumps(record, indent=2) + '\n')
print('initial reviewer rejection retained')
