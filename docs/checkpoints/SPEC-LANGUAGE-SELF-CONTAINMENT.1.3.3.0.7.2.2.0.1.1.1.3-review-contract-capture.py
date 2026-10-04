"""Retain the original acceptance-reviewer failure without rewriting actual TAP."""
from pathlib import Path
import importlib.util
import base64
import gzip
import json
import subprocess

ROOT = Path(__file__).resolve().parents[2]
PREFIX = __file__.removesuffix('review-contract-capture.py')
spec = importlib.util.spec_from_file_location('initial_review', Path(PREFIX + 'review-contract-initial.py'))
review = importlib.util.module_from_spec(spec)
spec.loader.exec_module(review)
paths = [PREFIX + name for name in ('review-contract-initial.py', 'inputs.json', 'observations.json')]
inputs = [{'path': Path(p).relative_to(ROOT).as_posix(), 'sha256': review.sha(Path(p).read_bytes())} for p in paths]
assert inputs == [{'path': Path(p).relative_to(ROOT).as_posix(), 'sha256': review.sha(Path(p).read_bytes())} for p in paths]
def envelope(raw):
    return {'encoding': 'gzip-base64', 'bytes': len(raw), 'sha256': review.sha(raw),
            'data': base64.b64encode(gzip.compress(raw, mtime=0)).decode()}

logical = Path(PREFIX + 'review.py').relative_to(ROOT).as_posix()
original = Path(PREFIX + 'review-contract-initial.py').relative_to(ROOT).as_posix()
commands = [
    ['bash', 'tools/run_python_project_data.sh', original],
    ['bash', 'tools/project_data_run.sh', 'python3', '-c',
     "from pathlib import Path; logical = str(Path(" + repr(logical) + ").resolve()); exec(compile(Path(" + repr(original) + " ).read_bytes(), logical, 'exec'), {'__file__': logical, '__name__': '__main__'})"],
]
for index, command in enumerate(commands):
    result = subprocess.run(command, cwd=ROOT, capture_output=True)
    report = {'command': command, 'exit': result.returncode, 'inputs': inputs,
          'stdout': envelope(result.stdout),
          'stderr': envelope(result.stderr),
          'instrument_sha256': review.sha(Path(__file__).read_bytes()),
          'scope': 'Original reviewer source executed with its original logical filename; selection-failure attempt retained separately. Complete GREEN TAP is preserved unchanged.'}
    name = 'review-contract-selection-result.json' if index == 0 else 'review-contract-initial-result.json'
    Path(PREFIX + name).write_text(json.dumps(report, indent=2) + '\n')
    assert result.returncode == 1
    assert (b'FileNotFoundError' if index == 0 else b"KeyError: 'contract'") in result.stderr
    assert inputs == [{'path': Path(p).relative_to(ROOT).as_posix(), 'sha256': review.sha(Path(p).read_bytes())} for p in paths]
print('Original contract-field reviewer exit1 retained; actual family channels unchanged')
