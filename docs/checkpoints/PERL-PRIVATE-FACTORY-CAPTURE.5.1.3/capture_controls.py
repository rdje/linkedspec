"""One-shot production threshold and authority channels; never a resume command."""
import base64, hashlib, json, subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3/'
sha=lambda b:hashlib.sha256(b).hexdigest()
target=ROOT/(PREFIX+'controls.json')
assert not target.exists(), 'one-shot control capture'
command=['perl', PREFIX+'controls.pl']
process=subprocess.run(command,cwd=ROOT,capture_output=True)
record={'producer_sha256':sha(Path(__file__).read_bytes()),'command':command,'returncode':process.returncode,'stdout_base64':base64.b64encode(process.stdout).decode(),'stderr_base64':base64.b64encode(process.stderr).decode()}
target.write_text(json.dumps(record,indent=2)+'\n')
assert process.returncode==0 and not process.stderr
result=json.loads(process.stdout)
assert len(result['thresholds'])==30 and len(result['authority'])==23
print('Unchanged production controls PASS:30 numeric observations/23 authority REDs')
