"""Record the separate readonly current-input review."""
import importlib.util
from pathlib import Path

BASE = Path(__file__).resolve().parent.relative_to(Path.cwd())
spec = importlib.util.spec_from_file_location('named_include_recorder', BASE / 'capture.py')
recorder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(recorder)
result = recorder.run('review', ['bash', 'tools/run_python_project_data.sh', str(BASE / 'review.py'), '--current'])
assert result.returncode == 0, result.stderr.decode()
print(result.stdout.decode(), end='')
