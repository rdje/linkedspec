"""One-shot paired fixture/current supplied consumer proof for literal-only migration."""
import base64,hashlib,json,os,re,subprocess,sys,tempfile
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
BASE='cdc45f9cbddbc53603e885225af2a35688657292'
SEED='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1-consumers.json'
TEST='t/actionir_method_inference_capture.t'
sha=lambda r:hashlib.sha256(r).hexdigest()
blob=lambda p:subprocess.check_output(['git','show',BASE+':'+p],cwd=ROOT)
assert sys.argv[1:] in (['before'],['after'],['consumers'])
mode=sys.argv[1];target=ROOT/(PREFIX+'selector-fixture-'+mode+'.json');assert not target.exists()
seed_raw=blob(SEED);seed=json.loads(seed_raw)
files={p:blob(p) for p in seed['inputs']}
assert len(files)==152 and {p:sha(r) for p,r in files.items()}==seed['inputs']
for p,r in files.items():
 if p!=TEST:assert (ROOT/p).read_bytes()==r,'unchanged consumer input: '+p
if mode!='before':files[TEST]=(ROOT/TEST).read_bytes()
inputs={p:sha(r) for p,r in sorted(files.items())}
with tempfile.TemporaryDirectory(prefix='selector-fixture-',dir=os.environ['TMPDIR']) as directory:
 supplied=Path(directory);assert supplied.stat().st_dev==ROOT.stat().st_dev
 for path,raw in files.items():
  p=supplied/path;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(raw)
 args=seed['command'] if mode=='consumers' else ['perl','-Iperl',TEST]
 p=subprocess.run(args,cwd=supplied,env=dict(os.environ,PERL5LIB='',PERL5OPT='',LINKEDSPEC_EVENT_ORDER_BASELINE='0',LINKEDSPEC_MEMBERSHIP_BASELINE='0'),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
 assert all((supplied/q).read_bytes()==r for q,r in files.items())
 assert p.returncode==0,(p.returncode,p.stderr)
 if mode=='consumers':assert b'All tests successful.' in p.stdout and b'Files=33,' in p.stdout
 else:assert re.findall(rb'^1\.\.(\d+)$',p.stdout,re.M)==[b'277'] and not re.search(rb'^not ok ',p.stdout,re.M)
 target.write_text(json.dumps({'base':BASE,'seed':SEED,'seed_sha256':sha(seed_raw),'inputs':inputs,
  'args':args,'exit_code':p.returncode,'stdout_base64':base64.b64encode(p.stdout).decode(),
  'stderr_base64':base64.b64encode(p.stderr).decode(),'producer_sha256':sha(Path(__file__).read_bytes()),'unchanged':True},indent=2)+'\n')
print('Literal-only fixture migration',mode,'PASS; supplied152 unchanged.')
