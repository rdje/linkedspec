"""Acquire exact ordinary terminal/composed controls on the same old/current SDK."""
from pathlib import Path
import subprocess

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[2]
REL = BASE.relative_to(ROOT)
for phase in ('ordinary-old', 'ordinary-fixed'):
    command = ['bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(REL / 'run_stage.py'), phase,
        'bash', 'tools/project_data_run.sh', 'env', 'PYTHONPATH=', 'python3', '-P', str(REL / 'capture_ordinary.py'), phase]
    result = subprocess.run(command, cwd=ROOT)
    assert result.returncode == 0, 'Actual ordinary acquisition failure retained:' + phase
