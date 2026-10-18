"""Readonly composition of strict observation completeness and the frozen review."""
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
PREFIX = 'docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.7/'
assert not sys.argv[1:]
for name in ('authority-shape.py', 'review.py'):
    result = subprocess.run(['python3', PREFIX + name], cwd=ROOT, capture_output=True)
    sys.stdout.buffer.write(result.stdout)
    sys.stderr.buffer.write(result.stderr)
    if result.returncode:
        raise SystemExit(result.returncode)
