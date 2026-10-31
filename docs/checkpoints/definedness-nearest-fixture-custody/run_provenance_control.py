"""One-shot capture of the independent historical-byte negative control."""
from pathlib import Path
import json,subprocess

directory=Path('docs/checkpoints/definedness-nearest-fixture-custody')
output=directory/'provenance-negative.json';assert not output.exists()
command=['bash','tools/run_python_project_data.sh',str(directory/'review.py'),'--falsify-historical-provenance']
result=subprocess.run(command,capture_output=True)
assert result.returncode==1 and not result.stderr
report=json.loads(result.stdout);assert report['observed_red'] and report['self_consistent_payload'] and not report['runtime_red']
output.write_text(json.dumps({'command':command,'exit':result.returncode,'stdout':result.stdout.decode(),'stderr':result.stderr.decode(),'report':report},indent=2)+'\n')
print('Historical provenance negative control actual exit1, self-consistent payload rejected by independent Git bytes; no runtime RED')
