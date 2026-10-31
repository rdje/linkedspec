"""One-shot capture of the repeatable read-only companion review."""
from pathlib import Path
import json,subprocess

directory=Path('docs/checkpoints/definedness-nearest-fixture-custody')
output=directory/'companion-review.json';assert not output.exists()
command=['bash','tools/run_python_project_data.sh',str(directory/'review.py')]
result=subprocess.run(command,capture_output=True)
assert result.returncode==0 and not result.stderr
report=json.loads(result.stdout)
assert report['historical_edges']==13 and report['unique_named_fixtures']==5 and report['original_captures_unchanged']
assert len(report['fresh_cases'])==6 and all(row['exit']==0 and row['before_after_identity_exact'] for row in report['fresh_cases'].values())
output.write_text(json.dumps({'command':command,'exit':result.returncode,'stdout':result.stdout.decode(),'stderr':result.stderr.decode(),'report':report},indent=2)+'\n')
print('Companion review actual exit0; thirteen named edges/five fixtures/six fresh passing cases verified; original captures unchanged')
