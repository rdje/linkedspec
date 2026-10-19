"""Execute unchanged production numeric/authority functions with actual new inputs."""
import base64
import hashlib
import json
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.5.8/'
target=ROOT/(PREFIX+'controls-final.json');assert not target.exists()
command=['perl',PREFIX+'controls-final.pl']
run=subprocess.run(command,cwd=ROOT,capture_output=True)
value=dict(command=command,returncode=run.returncode,
    producer_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
    stdout_base64=base64.b64encode(run.stdout).decode(),stderr_base64=base64.b64encode(run.stderr).decode())
with target.open('x') as output:output.write(json.dumps(value,indent=2)+'\n')
assert run.returncode==0 and not run.stderr
data=json.loads(run.stdout)
assert len(data['thresholds'])==60 and len(data['authority'])==31
print('Actual production controls PASS:60 inclusive numeric observations;31 authority REDs')
