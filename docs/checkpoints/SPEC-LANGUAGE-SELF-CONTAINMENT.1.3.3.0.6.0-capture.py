"""Emit raw controlled per-source public observations; never write tracked captures."""
from pathlib import Path
import json,os,subprocess
ROOT=Path(__file__).resolve().parents[2]
PREFIX='docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.0-'
rows=[]
for case in json.loads((ROOT/(PREFIX+'cases.json')).read_bytes()):
 for seed in ('0','1','2'):
  command=['perl','-Iperl',PREFIX+'probe.pl',case['id']]
  run=subprocess.run(command,cwd=ROOT,env=dict(os.environ,PERL5LIB='',PERL_HASH_SEED=seed,PERL_PERTURB_KEYS='2'),capture_output=True)
  assert run.returncode==0 and not run.stderr,(case['id'],seed,run.stderr)
  rows.append({'command':command,'exit':run.returncode,'stdout':run.stdout.decode(),'stderr':run.stderr.decode(),'observation':json.loads(run.stdout)})
print(json.dumps({'owner':'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.0','seeds':['0','1','2'],'perturbation':'2','rows':rows},indent=2))
