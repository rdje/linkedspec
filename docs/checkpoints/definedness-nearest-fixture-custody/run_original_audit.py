"""One-shot retention of the read-only original-packet audit; run from repo root."""
from pathlib import Path
import hashlib,json,subprocess

directory=Path('docs/checkpoints/definedness-nearest-fixture-custody')
report=directory/'original-audit.json';result_path=directory/'original-audit-result.json'
assert not report.exists() and not result_path.exists()
command=['bash','tools/run_python_project_data.sh',str(directory/'audit_original.py')]
result=subprocess.run(command,capture_output=True)
assert result.returncode==1 and not result.stderr
observations=json.loads(result.stdout)
assert set(observations)=={'perl','rust','dart','julia','lua'}
assert all(row['missing_from_original_capture'] for item in observations.values() for row in item['dependencies'])
report.write_bytes(result.stdout)
result_path.write_text(json.dumps({'command':command,'exit':result.returncode,'stderr':result.stderr.decode(),'stdout_file':str(report),'stdout_sha256':hashlib.sha256(result.stdout).hexdigest(),'scope':'Named direct fixture dependencies identified by retained literal paths or explicit stem/extension loaders; no full transitive input census or runtime RED.'},indent=2)+'\n')
print('Observed missing-input audit RED (exit1), complete report retained; no runtime RED')
