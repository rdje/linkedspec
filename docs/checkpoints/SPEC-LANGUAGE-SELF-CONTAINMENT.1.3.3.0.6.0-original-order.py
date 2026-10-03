from pathlib import Path
import json,os,subprocess
rows=[]
for case in ('nested','body'):
 for seed in ('0','1','2'):
  command=['perl','-Iperl','docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.1-order.pl',case]
  run=subprocess.run(command,env=dict(os.environ,PERL5LIB='',PERL_HASH_SEED=seed,PERL_PERTURB_KEYS='2'),capture_output=True)
  assert run.returncode==0 and not run.stderr,(case,seed,run.stderr)
  rows.append({'command':command,'exit':run.returncode,'stdout':run.stdout.decode(),'stderr':run.stderr.decode(),'observation':json.loads(run.stdout)})
Path('docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.0-original-order.json').write_text(json.dumps(rows,indent=2)+'\n')
for r in rows:
 o=r['observation'];m=o['metadata'];print(o['id'],o['seed'],m.get('language_agnostic_action_ir_ready'),m.get('unresolved_helper_count'),[(e.get('kind'),e.get('name'),e.get('start'),e.get('end')) for e in m['canonical_action_ir_events']])
