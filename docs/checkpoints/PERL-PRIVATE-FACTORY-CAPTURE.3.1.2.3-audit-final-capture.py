"""One-shot complete recovery capture after the final book teaching edit."""
import base64,gzip,hashlib,json,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
PROOF='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py'
AUDITOR='tests/language-readiness/verify_objectives.py'
sha=lambda r:hashlib.sha256(r).hexdigest()
def envelope(r):return {'encoding':'gzip-base64','bytes':len(r),'sha256':sha(r),'data':base64.b64encode(gzip.compress(r,mtime=0)).decode()}
target=ROOT/(PREFIX+'audit-final.json');assert not target.exists()
args=['bash','tools/run_python_project_data.sh',PROOF]
p=subprocess.run(args,cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
record={'args':args,'exit_code':p.returncode,'stdout':envelope(p.stdout),'stderr':envelope(p.stderr),'producer_sha256':sha(Path(__file__).read_bytes()),'proof_sha256':sha((ROOT/PROOF).read_bytes()),'auditor_sha256':sha((ROOT/AUDITOR).read_bytes())}
target.write_text(json.dumps(record,indent=2)+'\n')
assert p.returncode==0 and not p.stderr
print('Complete post-book historical recovery channels retained.')
