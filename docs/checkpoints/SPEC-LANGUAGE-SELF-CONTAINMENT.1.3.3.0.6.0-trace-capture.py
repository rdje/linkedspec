"""Capture public debug traces to stdout; preserve every unmodified raw stream."""
import json,os,subprocess
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
rows=[]
for case in ('body_original','repeated','raw_ambiguous','raw_single','quoted'):
 for seed in ('0','1','2'):
  cmd=['perl','-Iperl','docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.0-trace.pl',case]
  r=subprocess.run(cmd,cwd=ROOT,env=dict(os.environ,PERL5LIB='',PERL_HASH_SEED=seed,PERL_PERTURB_KEYS='2'),capture_output=True)
  assert r.returncode==0 and not r.stderr,(case,r.stderr)
  rows.append({'command':cmd,'exit':r.returncode,'stdout':r.stdout.decode(),'stderr':r.stderr.decode(),'observation':json.loads(r.stdout)})
print(json.dumps({'rows':rows},indent=2))
