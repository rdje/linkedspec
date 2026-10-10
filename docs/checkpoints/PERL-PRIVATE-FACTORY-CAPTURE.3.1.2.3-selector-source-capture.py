"""One-shot exact-source scanner RED/GREEN channels for the bounded migration."""
import base64,hashlib,json,os,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
assert sys.argv[1:] in (['before'],['after'])
mode=sys.argv[1];target=ROOT/(PREFIX+'selector-source-'+mode+'.json');assert not target.exists()
sha=lambda r:hashlib.sha256(r).hexdigest()
paths=['t/actionir_method_inference_capture.t',PREFIX+'selector-review.py',PREFIX+'selector-source-probe.py','tools/check_executable_aggregate_selector_sources.py']
inputs={p:sha((ROOT/p).read_bytes()) for p in paths}
args=['python3',PREFIX+'selector-source-probe.py']
p=subprocess.run(args,cwd=ROOT,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
assert inputs=={q:sha((ROOT/q).read_bytes()) for q in paths} and not p.stderr
data=json.loads(p.stdout);assert p.returncode==(1 if mode=='before' else 0)
assert len(data['positive'])==(6 if mode=='before' else 0)
target.write_text(json.dumps({'inputs':inputs,'args':args,'exit_code':p.returncode,
 'stdout_base64':base64.b64encode(p.stdout).decode(),'stderr_base64':base64.b64encode(p.stderr).decode(),
 'producer_sha256':sha(Path(__file__).read_bytes()),'unchanged':True},indent=2)+'\n')
print('Actual two-input scanner',mode,'retained.')
