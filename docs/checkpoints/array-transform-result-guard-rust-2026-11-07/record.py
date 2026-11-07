"""Retain the actual outer invocation channels for a one-shot acquisition/review."""
import gzip
import json
from pathlib import Path
import subprocess
import sys

BASE = Path(__file__).resolve().parent
tag, script, *arguments = sys.argv[1:]
out = BASE / (tag + '-outer')
out.mkdir()
command = ['bash', 'tools/run_python_project_data.sh', str(BASE.relative_to(Path.cwd()) / script), *arguments]
(out / 'command.json').write_text(json.dumps(dict(argv=command, cwd='.'), indent=2) + '\n')
result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
for channel in ('stdout', 'stderr'):
    (out / (channel + '.log.gz')).write_bytes(gzip.compress(getattr(result, channel), mtime=0))
(out / 'exit.txt').write_text(str(result.returncode) + '\n')
print(tag + ': exit' + str(result.returncode) + '; actual outer channels retained')
raise SystemExit(result.returncode)
