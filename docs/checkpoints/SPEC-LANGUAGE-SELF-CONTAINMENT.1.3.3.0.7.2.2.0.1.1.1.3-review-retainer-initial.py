"""Retain the original acceptance-reviewer failure without rewriting actual TAP."""
from pathlib import Path
import importlib.util
import base64
import gzip
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review-initial-capture.py')
spec = importlib.util.spec_from_file_location('initial_review', Path(PREFIX + 'review-initial.py'))
review = importlib.util.module_from_spec(spec)
spec.loader.exec_module(review)
paths = [PREFIX + name for name in ('review-initial.py', 'inputs.json', 'observations.json')]
inputs = [{'path': Path(p).relative_to(ROOT).as_posix(), 'sha256': review.sha(Path(p).read_bytes())} for p in paths]
command = ['bash', 'tools/run_python_project_data.sh', Path(PREFIX + 'review-initial.py').relative_to(ROOT).as_posix()]
result = subprocess.run(command, cwd=ROOT, capture_output=True)
assert result.returncode == 1 and b'complete selected suite population' in result.stderr
assert inputs == [{'path': Path(p).relative_to(ROOT).as_posix(), 'sha256': review.sha(Path(p).read_bytes())} for p in paths]
def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': review.sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}

report = {'command': command, 'exit': result.returncode, 'inputs': inputs,
          'stdout': envelope(result.stdout),
          'stderr': envelope(result.stderr),
          'instrument_sha256': review.sha(Path(__file__).read_bytes()),
          'scope': 'Original reviewer source and actual failed channels; complete GREEN TAP is preserved unchanged.'}
Path(PREFIX + 'review-initial-result.json').write_text(json.dumps(report, indent=2) + '\n')
print('Original reviewer exit1 retained; actual four-suite GREEN transcript unchanged')
