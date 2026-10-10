"""One-shot actual classifier RED/GREEN channels with every scanned source bound."""
import base64,hashlib,importlib.util,json,os,subprocess,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-'
CHECKER='tools/check_public_aggregate_selector_surface.py'
sha=lambda r:hashlib.sha256(r).hexdigest()
assert sys.argv[1:] in (['before'],['after'])
mode=sys.argv[1];target=ROOT/(PREFIX+'selector-'+mode+'.json');assert not target.exists()
spec=importlib.util.spec_from_file_location('selector',ROOT/CHECKER);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
paths=[p.relative_to(ROOT).as_posix() for p in m.public_markdown_paths()]
paths+=[CHECKER,PREFIX+'selector-classify.py']
inputs={p:sha((ROOT/p).read_bytes()) for p in sorted(paths)}
args=['python3',PREFIX+'selector-classify.py']
p=subprocess.run(args,cwd=ROOT,env=dict(os.environ,PYTHONDONTWRITEBYTECODE='1'),stdout=subprocess.PIPE,stderr=subprocess.PIPE)
assert inputs=={q:sha((ROOT/q).read_bytes()) for q in inputs}
if mode=='before':assert p.returncode!=0 and b"without explicit removed/rejected/migrated historical context" in p.stderr
else:assert p.returncode==0 and not p.stderr and json.loads(p.stdout)=={'public_files':70,'classified_references':36,'result':'PASS'}
target.write_text(json.dumps({'mode':mode,'producer_sha256':sha(Path(__file__).read_bytes()),'inputs':inputs,
 'args':args,'exit_code':p.returncode,'stdout_base64':base64.b64encode(p.stdout).decode(),
 'stderr_base64':base64.b64encode(p.stderr).decode(),'unchanged':True,
 'scope':'Actual unchanged public path discovery and exact-reference classifier only; every scanned public source and actual producer bound. Canonical CI separately executes the complete composed retirement checker.'},indent=2)+'\n')
print('Actual unchanged classifier',mode,'captured.')
