"""One-shot supplemental diagnosis; transitive input population is not reconstructed."""
import base64, hashlib, json, subprocess, sys
from pathlib import Path
root=Path(__file__).resolve().parents[3]
target=Path(__file__).with_name('result.json')
assert sys.argv[1:]==['--capture'] and not target.exists()
probe=Path(__file__).with_name('probe.pl').relative_to(root).as_posix()
command=['perl','-Iperl',probe]
r=subprocess.run(command,cwd=root,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=False)
record={'command':command,'returncode':r.returncode,'stdout_base64':base64.b64encode(r.stdout).decode(),'stderr_base64':base64.b64encode(r.stderr).decode(),'producer_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'probe_sha256':hashlib.sha256((root/probe).read_bytes()).hexdigest(),'source_sha256':hashlib.sha256((root/'perl/LinkedSpec/ActionIR/MethodLowering.pm').read_bytes()).hexdigest(),'base_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip(),'scope':'Actual supplemental live-worktree Get/source/fallback diagnosis. Full channels retained; complete transitive inputs and independent repair acceptance remain with PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.'}
target.write_text(json.dumps(record,indent=2)+'\n')
assert r.returncode==0
observed=json.loads(r.stdout)
assert observed['public'][0]['value']==[]
assert observed['public'][1]['value']=={'k':'v'}
assert observed['public'][2]['value']==1
assert 'undefined value as a subroutine reference' in observed['legacy']['error']
print('Supplemental receiver diagnosis retained: hash .copy loses type; function and multi-step controls pass; legacy kind callback fails')
